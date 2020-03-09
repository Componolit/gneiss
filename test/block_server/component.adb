
with Gneiss.Log.Client;

package body Component with
   SPARK_Mode
is
   use type Block.Id;
   use type Block.Request_Status;
   use type Block.Request_Kind;

   Log         : Gneiss.Log.Client_Session;
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

   Ready      : Boolean := False;
   Capability : Gneiss.Capability;

   procedure Construct (Cap : Gneiss.Capability)
   is
   begin
      Capability := Cap;
      Gneiss.Log.Client.Initialize (Log, Cap, "log_block_server");
      Block_Dispatcher.Initialize (Dispatcher, Capability);
      if Gneiss.Log.Initialized (Log) and then Block.Initialized (Dispatcher) then
         Block_Dispatcher.Register (Dispatcher);
      else
         Main.Vacate (Capability, Main.Failure);
      end if;
   end Construct;

   procedure Destruct
   is
   begin
      Gneiss.Log.Client.Finalize (Log);
      Block_Dispatcher.Finalize (Dispatcher);
   end Destruct;

   procedure Read (S : in out Block.Server_Session;
                   R :        Request_Index;
                   B :    out Buffer)
   is
      pragma Unreferenced (S);
      Start  : constant Block.Count :=
         Block.Count (Block_Server.Start (Request_Cache (R).Req));
      Length : constant Block.Count :=
         Block_Server.Length (Request_Cache (R).Req);
   begin
      if
         Start * Disk_Block_Size in Ram_Disk'Range
         and then (Start + Length) * Disk_Block_Size - 1 in Ram_Disk'Range
         and then B'Length = Length * Disk_Block_Size
      then
         B := Ram_Disk (Start * Disk_Block_Size .. (Start + Length) * Disk_Block_Size - 1);
         Request_Cache (R).Success := True;
      else
         Request_Cache (R).Success := False;
      end if;
   end Read;

   procedure Write (S : in out Block.Server_Session;
                    R :        Request_Index;
                    B :        Buffer)
   is
      pragma Unreferenced (S);
      Start  : constant Block.Count :=
         Block.Count (Block_Server.Start (Request_Cache (R).Req));
      Length : constant Block.Count :=
         Block_Server.Length (Request_Cache (R).Req);
   begin
      if
         Start * Disk_Block_Size in Ram_Disk'Range
         and then (Start + Length) * Disk_Block_Size - 1 in Ram_Disk'Range
         and then B'Length = Length * Disk_Block_Size
      then
         Ram_Disk (Start * Disk_Block_Size .. (Start + Length) * Disk_Block_Size - 1) := B;
         Request_Cache (R).Success := True;
      else
         Request_Cache (R).Success := False;
      end if;
   end Write;

   procedure Event
   is
      Finished : Boolean := False;
   begin
      if
         Initialized (Server)
         and then Block.Initialized (Server)
      then
         loop
            for I in Request_Cache'Range loop
               pragma Loop_Invariant (Initialized (Server));
               pragma Loop_Invariant (Block.Initialized (Server));
               if Block_Server.Status (Request_Cache (I).Req) = Block.Raw then
                  Request_Cache (I).Success := False;
                  Request_Cache (I).Handled := False;
                  Block_Server.Process (Server, Request_Cache (I).Req);
                  Finished := Block_Server.Status (Request_Cache (I).Req) = Block.Raw;
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
                           Block_Server.Read (Server, Request_Cache (I).Req, I);
                        when Block.Write =>
                           Block_Server.Write (Server, Request_Cache (I).Req, I);
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
            exit when Finished;
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
   begin
      if Gneiss.Log.Initialized (Log) then
         Gneiss.Log.Client.Info (Log, "Server initialize with label: ");
         Gneiss.Log.Client.Info (Log, L);
         Gneiss.Log.Client.Info (Log, "Initialized");
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
