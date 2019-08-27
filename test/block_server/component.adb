
with Componolit.Gneiss.Log.Client;

package body Component with
   SPARK_Mode
is
   use type Block.Id;
   use type Block.Request_Status;
   use type Block.Request_Kind;

   Log         : Componolit.Gneiss.Log.Client_Session;
   Dispatcher  : Block.Dispatcher_Session;
   Server      : Block.Server_Session;

   subtype Disk is Buffer (0 .. 524287); --  Disk_Block_Size * Disk_Block_Count - 1

   Ram_Disk : Disk;

   type Cache_Element is limited record
      Req     : Block_Server.Request;
      Handled : Boolean := False;
      Success : Boolean := False;
   end record;
   type Request_Cache_Type is array (Request_Index'Range) of Cache_Element;
   Request_Cache : Request_Cache_Type;

   Ready : Boolean := False;

   procedure Construct (Cap : Componolit.Gneiss.Types.Capability)
   is
   begin
      if not Componolit.Gneiss.Log.Initialized (Log) then
         Componolit.Gneiss.Log.Client.Initialize (Log, Cap, "log_block_server");
      end if;
      if Componolit.Gneiss.Log.Initialized (Log) then
         if not Block.Initialized (Dispatcher) then
            Block_Dispatcher.Initialize (Dispatcher, Cap, 42);
         end if;
         if Block.Initialized (Dispatcher) then
            Block_Dispatcher.Register (Dispatcher);
            Componolit.Gneiss.Log.Client.Info (Log, "Dispatcher initialized");
         else
            Componolit.Gneiss.Log.Client.Error (Log, "Failed to initialize dispatcher");
            Main.Vacate (Cap, Main.Failure);
         end if;
      else
         Main.Vacate (Cap, Main.Failure);
      end if;
   end Construct;

   procedure Destruct
   is
   begin
      if Componolit.Gneiss.Log.Initialized (Log) then
         Componolit.Gneiss.Log.Client.Finalize (Log);
      end if;
      if Block.Initialized (Dispatcher) then
         Block_Dispatcher.Finalize (Dispatcher);
      end if;
   end Destruct;

   procedure Read (R : in out Cache_Element) with
      Pre  => Initialized (Server)
              and then Block.Initialized (Server)
              and then Block_Server.Status (R.Req) = Block.Pending
              and then Block_Server.Kind (R.Req) = Block.Read
              and then Block_Server.Start (R.Req) <= Block.Id (Ram_Disk'Length / Disk_Block_Size)
              and then Block_Server.Length (R.Req) > 0
              and then Block_Server.Length (R.Req) <= Block.Count (Ram_Disk'Length / Disk_Block_Size)
              and then Block_Server.Assigned (Server, R.Req),
      Post => Block.Initialized (Server);

   procedure Read (R : in out Cache_Element)
   is
      Start  : constant Block.Count := Block.Count (Block_Server.Start (R.Req));
      Length : constant Block.Count := Block_Server.Length (R.Req);
   begin
      if
         Start * Disk_Block_Size in Ram_Disk'Range
         and then (Start + Length) * Disk_Block_Size - 1 in Ram_Disk'Range
      then
         Block_Server.Read
            (Server,
             R.Req,
             Ram_Disk (Start * Disk_Block_Size .. (Start + Length) * Disk_Block_Size - 1));
         R.Success := True;
      else
         R.Success := False;
      end if;
   end Read;

   procedure Write (R : in out Cache_Element) with
      Pre  => Initialized (Server)
              and then Block.Initialized (Server)
              and then Block_Server.Status (R.Req) = Block.Pending
              and then Block_Server.Kind (R.Req) = Block.Write
              and then Block_Server.Start (R.Req) <= Block.Id (Ram_Disk'Length / Disk_Block_Size)
              and then Block_Server.Length (R.Req) > 0
              and then Block_Server.Length (R.Req) <= Block.Count (Ram_Disk'Length / Disk_Block_Size)
              and then Block_Server.Assigned (Server, R.Req),
      Post => Block.Initialized (Server);

   procedure Write (R : in out Cache_Element)
   is
      Start  : constant Block.Count := Block.Count (Block_Server.Start (R.Req));
      Length : constant Block.Count := Block_Server.Length (R.Req);
   begin
      if
         Start * Disk_Block_Size in Ram_Disk'Range
         and then (Start + Length) * Disk_Block_Size - 1 in Ram_Disk'Range
      then
         Block_Server.Write
            (Server,
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
      if
         Initialized (Server)
         and then Block.Initialized (Server)
      then
         for I in Request_Cache'Range loop
            pragma Loop_Invariant (Initialized (Server));
            pragma Loop_Invariant (Block.Initialized (Server));
            if Block_Server.Status (Request_Cache (I).Req) = Block.Raw then
               Request_Cache (I).Success := False;
               Request_Cache (I).Handled := False;
               Block_Server.Process (Server, Request_Cache (I).Req);
            end if;
            if
               Block_Server.Status (Request_Cache (I).Req) = Block.Pending
               and then Block_Server.Assigned (Server, Request_Cache (I).Req)
               and then not Request_Cache (I).Handled
            then
               Request_Cache (I).Handled := True;
               if
                  Block_Server.Start (Request_Cache (I).Req) <= Block.Id (Ram_Disk'Length / Disk_Block_Size)
                  and then Block_Server.Length (Request_Cache (I).Req) > 0
                  and then Block_Server.Length (Request_Cache (I).Req) <=
                     Block.Count (Ram_Disk'Length / Disk_Block_Size)
               then
                  case Block_Server.Kind (Request_Cache (I).Req) is
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
               Block_Server.Status (Request_Cache (I).Req) = Block.Pending
               and then Block_Server.Assigned (Server, Request_Cache (I).Req)
               and then Request_Cache (I).Handled
            then
               Block_Server.Acknowledge (Server, Request_Cache (I).Req,
                                         (if Request_Cache (I).Success then Block.Ok else Block.Error));
            end if;
         end loop;
         Block_Server.Unblock_Client (Server);
      end if;
   end Event;

   function Block_Count (S : Block.Server_Session) return Block.Count
   is
      pragma Unreferenced (S);
   begin
      return Disk_Block_Count;
   end Block_Count;

   function Block_Size (S : Block.Server_Session) return Block.Size
   is
      pragma Unreferenced (S);
   begin
      return Disk_Block_Size;
   end Block_Size;

   function Writable (S : Block.Server_Session) return Boolean
   is
      pragma Unreferenced (S);
   begin
      return True;
   end Writable;

   function Initialized (S : Block.Server_Session) return Boolean is
      (Ready);

   procedure Initialize (S : in out Block.Server_Session;
                         L :        String;
                         B :        Block.Byte_Length)
   is
      pragma Unreferenced (S);
      pragma Unreferenced (B);
      Max : Natural;
   begin
      if Componolit.Gneiss.Log.Initialized (Log) then
         Max := Componolit.Gneiss.Log.Maximum_Message_Length (Log);
         Componolit.Gneiss.Log.Client.Info (Log, "Server initialize with label: ");
         if L'Length <= Max then
            Componolit.Gneiss.Log.Client.Info (Log, L);
         else
            for I in Natural range 0 .. Natural'Last / Max - L'First - 1 loop
               pragma Loop_Invariant (Componolit.Gneiss.Log.Initialized (Log));
               pragma Loop_Invariant (Max = Componolit.Gneiss.Log.Maximum_Message_Length (Log));
               if L'First + (I + 1) * Max <= L'Last then
                  Componolit.Gneiss.Log.Client.Info (Log, L (L'First + I * Max .. L'First + (I + 1) * Max - 1));
               else
                  Componolit.Gneiss.Log.Client.Info (Log, L (L'First + I * Max .. L'Last));
                  exit;
               end if;
            end loop;
         end if;
         Componolit.Gneiss.Log.Client.Info (Log, "Initialized");
         Ready := True;
      end if;
      Ram_Disk := (others => 0);
   end Initialize;

   procedure Finalize (S : in out Block.Server_Session)
   is
      pragma Unreferenced (S);
   begin
      Ready := False;
   end Finalize;

   procedure Request (I : in out Block.Dispatcher_Session;
                      C :        Block.Dispatcher_Capability)
   is
   begin
      if
         Block_Dispatcher.Valid_Session_Request (I, C)
         and then not Ready
         and then not Block.Initialized (Server)
      then
         Block_Dispatcher.Session_Initialize (I, C, Server, 42);
         if Ready and then Block.Initialized (Server) then
            Block_Dispatcher.Session_Accept (I, C, Server);
         end if;
      end if;
      Block_Dispatcher.Session_Cleanup (I, C, Server);
   end Request;

end Component;
