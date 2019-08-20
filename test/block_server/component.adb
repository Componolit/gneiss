
with Componolit.Interfaces.Log.Client;

package body Component with
   SPARK_Mode
is
   use type Block.Id;
   use type Block.Request_Status;
   use type Block.Request_Kind;
   --  use type Block.Server_Instance;

   Log         : Componolit.Interfaces.Log.Client_Session := Componolit.Interfaces.Log.Create;
   Dispatcher  : Block.Dispatcher_Session                 := Block.Create;
   Server      : Container;

   subtype Disk is Buffer (0 .. 524287); --  Disk_Block_Size * Disk_Block_Count - 1

   Ram_Disk : Disk;

   type Cache_Element is limited record
      Req     : Block.Server_Request;
      Handled : Boolean;
      Success : Boolean;
   end record;
   type Request_Cache_Type is array (Request_Index'Range) of Cache_Element;
   Request_Cache : Request_Cache_Type := (others => (Req     => Block.Null_Request,
                                                     Handled => False,
                                                     Success => False));

   Ready : Boolean := False;

   procedure Construct (Cap : Componolit.Interfaces.Types.Capability)
   is
   begin
      if not Componolit.Interfaces.Log.Initialized (Log) then
         Componolit.Interfaces.Log.Client.Initialize (Log, Cap, "Ada_Block_Server");
      end if;
      if Componolit.Interfaces.Log.Initialized (Log) then
         if not Block.Initialized (Dispatcher) then
            Block_Dispatcher.Initialize (Dispatcher, Cap);
         end if;
         if Block.Initialized (Dispatcher) then
            Block_Dispatcher.Register (Dispatcher);
            Componolit.Interfaces.Log.Client.Info (Log, "Dispatcher initialized");
         else
            Componolit.Interfaces.Log.Client.Error (Log, "Failed to initialize dispatcher");
            Main.Vacate (Cap, Main.Failure);
         end if;
      else
         Main.Vacate (Cap, Main.Failure);
      end if;
   end Construct;

   procedure Destruct
   is
   begin
      if Componolit.Interfaces.Log.Initialized (Log) then
         Componolit.Interfaces.Log.Client.Finalize (Log);
      end if;
      if Block.Initialized (Dispatcher) then
         Block_Dispatcher.Finalize (Dispatcher);
      end if;
   end Destruct;

   procedure Read (R : in out Cache_Element) with
      Pre  => Initialized (Block.Instance (Server.Object))
              and then Block.Initialized (Server.Object)
              and then Block.Status (R.Req) = Block.Pending
              and then Block.Kind (R.Req) = Block.Read
              and then Block.Start (R.Req) < Block.Id (Ram_Disk'Length / Disk_Block_Size)
              and then Block.Length (R.Req) > 0
              and then Block.Length (R.Req) <= Block.Count (Ram_Disk'Length / Disk_Block_Size),
      Post => Block.Initialized (Server.Object);

   procedure Read (R : in out Cache_Element)
   is
      Start  : constant Block.Count := Block.Count (Block.Start (R.Req));
      Length : constant Block.Count := Block.Length (R.Req);
   begin
      pragma Assert (Start < 1024);
      pragma Assert (Unsigned_Long (Block.Size (Start) * Disk_Block_Size) in Ram_Disk'Range);
      pragma Assert (Start * Disk_Block_Size in Ram_Disk'Range);
      if
         Unsigned_Long (Block.Size (Start) * Disk_Block_Size) in Ram_Disk'Range
         and then (Start + Length) * Disk_Block_Size - 1 in Ram_Disk'Range
      then
         Block_Server.Read
            (Server.Object,
             R.Req,
             Ram_Disk (Start * Disk_Block_Size .. (Start + Length) * Disk_Block_Size - 1));
         R.Success := True;
      else
         R.Success := False;
      end if;
   end Read;

   procedure Write (R : in out Cache_Element) with
      Pre  => Initialized (Block.Instance (Server.Object))
              and then Block.Initialized (Server.Object)
              and then Block.Status (R.Req) = Block.Pending
              and then Block.Kind (R.Req) = Block.Write
              and then Block.Start (R.Req) <= Block.Id (Ram_Disk'Length / Disk_Block_Size)
              and then Block.Length (R.Req) > 0
              and then Block.Length (R.Req) <= Block.Count (Ram_Disk'Length / Disk_Block_Size),
      Post => Block.Initialized (Server.Object);

   procedure Write (R : in out Cache_Element)
   is
      Start  : constant Block.Count := Block.Count (Block.Start (R.Req));
      Length : constant Block.Count := Block.Length (R.Req);
   begin
      if
         Start * Disk_Block_Size in Ram_Disk'Range
         and then (Start + Length) * Disk_Block_Size - 1 in Ram_Disk'Range
      then
         Block_Server.Write
            (Server.Object,
             R.Req,
             Ram_Disk (Start * Disk_Block_Size .. (Start + Length) * Disk_Block_Size - 1));
         R.Success := True;
      else
         R.Success := False;
      end if;
   end Write;

   procedure Event
   is
   begin
      if Block.Initialized (Server.Object) then
         for I in Request_Cache'Range loop
            if Block.Status (Request_Cache (I).Req) = Block.Raw then
               Request_Cache (I).Success := False;
               Request_Cache (I).Handled := False;
               Block_Server.Process (Server.Object, Request_Cache (I).Req);
            end if;
            if
               Block.Status (Request_Cache (I).Req) = Block.Pending
               and then not Request_Cache (I).Handled
            then
               Request_Cache (I).Handled := True;
               if
                  Block.Start (Request_Cache (I).Req) <= Block.Id (Ram_Disk'Length / Disk_Block_Size)
                  and then Block.Length (Request_Cache (I).Req) > 0
                  and then Block.Length (Request_Cache (I).Req) <=
                     Block.Count (Ram_Disk'Length / Disk_Block_Size)
               then
                  case Block.Kind (Request_Cache (I).Req) is
                     when Block.Read =>
                        Read (Request_Cache (I));
                     when Block.Write =>
                        Write (Request_Cache (I));
                     when others => null;
                  end case;
               else
                  Request_Cache (I).Success := False;
               end if;
            end if;
            if
               Block.Status (Request_Cache (I).Req) = Block.Pending
               and then Request_Cache (I).Handled
            then
               Block_Server.Acknowledge (Server.Object, Request_Cache (I).Req,
                                         (if Request_Cache (I).Success then Block.Ok else Block.Error));
            end if;
         end loop;
         Block_Server.Unblock_Client (Server.Object);
      end if;
   end Event;

   function Block_Count (S : Block.Server_Instance) return Block.Count
   is
      pragma Unreferenced (S);
   begin
      return Disk_Block_Count;
   end Block_Count;

   function Block_Size (S : Block.Server_Instance) return Block.Size
   is
      pragma Unreferenced (S);
   begin
      return Disk_Block_Size;
   end Block_Size;

   function Writable (S : Block.Server_Instance) return Boolean
   is
      pragma Unreferenced (S);
   begin
      return True;
   end Writable;

   function Initialized (S : Block.Server_Instance) return Boolean
   is
      pragma Unreferenced (S);
      --  use type Block.Server_Instance;
   begin
      --  pragma Assert (Block.Initialized (S));
      --  if Server.Reference = S then
      --     --  pragma Assert (Block.Instance (Server.Object) = Server.Reference);
      pragma Assert (Block.Initialized (Server.Reference));
      --     --  pragma Assert (Block.Initialized (Server.Object));
      --     return Ready;
      --  else
      --     return False;
      --  end if;
      return Ready;
   end Initialized;

      --  (if S = Block.Instance (Server) then Ready else False);
      --  (Ready);

   procedure Initialize (S : Block.Server_Instance; L : String; B : Block.Byte_Length)
   is
      pragma Unreferenced (S);
      pragma Unreferenced (B);
      Max : Natural;
   begin
      if Componolit.Interfaces.Log.Initialized (Log) then
         Max := Componolit.Interfaces.Log.Maximum_Message_Length (Log);
         Componolit.Interfaces.Log.Client.Info (Log, "Server initialize with label: ");
         if L'Length <= Max then
            Componolit.Interfaces.Log.Client.Info (Log, L);
         else
            for I in Natural range 0 .. Natural'Last / Max - L'First - 1 loop
               pragma Loop_Invariant (Componolit.Interfaces.Log.Initialized (Log));
               pragma Loop_Invariant (Max = Componolit.Interfaces.Log.Maximum_Message_Length (Log));
               if L'First + (I + 1) * Max <= L'Last then
                  Componolit.Interfaces.Log.Client.Info (Log, L (L'First + I * Max .. L'First + (I + 1) * Max - 1));
               else
                  Componolit.Interfaces.Log.Client.Info (Log, L (L'First + I * Max .. L'Last));
                  exit;
               end if;
            end loop;
         end if;
         Componolit.Interfaces.Log.Client.Info (Log, "Initialized");
         Ready := True;
      end if;
      Ram_Disk := (others => 0);
   end Initialize;

   procedure Finalize (S : Block.Server_Instance)
   is
      pragma Unreferenced (S);
   begin
      Ready := False;
   end Finalize;

   procedure Request (I : Block.Dispatcher_Instance;
                      C : Block.Dispatcher_Capability)
   is
      use type Block.Dispatcher_Instance;
   begin
      if Block.Instance (Dispatcher) = I then
         if
            Block_Dispatcher.Valid_Session_Request (Dispatcher, C)
            and then not Ready
            and then not Block.Initialized (Server.Object)
         then
            Block_Dispatcher.Session_Initialize (Dispatcher, C, Server.Object);
            Server.Reference := Block.Instance (Server.Object);
            if Ready and then Block.Initialized (Server.Object) then
               Server.Reference := Block.Instance (Server.Object);
               Block_Dispatcher.Session_Accept (Dispatcher, C, Server.Object);
               Server.Reference := Block.Instance (Server.Object);
            end if;
         end if;
         Block_Dispatcher.Session_Cleanup (Dispatcher, C, Server.Object);
      end if;
   end Request;

end Component;
