
with Componolit.Interfaces.Log;
with Componolit.Interfaces.Log.Client;

package body Component is

   use type Block.Request_Kind;
   use type Block.Request_Status;

   Dispatcher : Block.Dispatcher_Session;
   Client : Block.Client_Session;
   Server : Block.Server_Session;

   Capability : Componolit.Interfaces.Types.Capability;

   Log : Componolit.Interfaces.Log.Client_Session := Componolit.Interfaces.Log.Create;

   procedure Construct (Cap : Componolit.Interfaces.Types.Capability)
   is
   begin
      Capability := Cap;
      if not Componolit.Interfaces.Log.Initialized (Log) then
         Componolit.Interfaces.Log.Client.Initialize (Log, Cap, "Proxy");
      end if;
      if Componolit.Interfaces.Log.Initialized (Log) then
         if not Block.Initialized (Dispatcher) then
            Block_Dispatcher.Initialize (Dispatcher, Cap, 42);
         end if;
         if Block.Initialized (Dispatcher) then
            Block_Dispatcher.Register (Dispatcher);
         else
            Componolit.Interfaces.Log.Client.Error (Log, "Failed to initialize Dispatcher");
            Main.Vacate (Capability, Main.Failure);
         end if;
      else
         Main.Vacate (Capability, Main.Failure);
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

   type Cache_Entry is record
      C : Block.Client_Request;
      S : Block.Server_Request;
      A : Boolean := False;
   end record;

   type Registry is array (Request_Index'Range) of Cache_Entry;

   Cache : Registry;

   procedure Write (C : in out Block.Client_Session;
                    I :        Request_Index;
                    D :    out Buffer)
   is
      pragma Unreferenced (C);
   begin
      if
         Block.Status (Cache (I).S) = Block.Pending
         and then Block.Kind (Cache (I).S) = Block.Write
         and then Initialized (Server)
         and then Block.Initialized (Server)
         and then Block.Assigned (Server, Cache (I).S)
         and then D'Length = Block_Size (Server) * Block.Length (Cache (I).S)
      then
         Block_Server.Write (Server, Cache (I).S, D);
      else
         Cache (I).A := True;
      end if;
   end Write;

   procedure Read (C : in out Block.Client_Session;
                   I :        Request_Index;
                   D :        Buffer)
   is
      pragma Unreferenced (C);
   begin
      if
         Block.Status (Cache (I).S) = Block.Pending
         and then Block.Kind (Cache (I).S) = Block.Read
         and then Initialized (Server)
         and then Block.Initialized (Server)
         and then Block.Assigned (Server, Cache (I).S)
         and then D'Length = Block_Size (Server) * Block.Length (Cache (I).S)
      then
         Block_Server.Read (Server, Cache (I).S, D);
      else
         Cache (I).A := True;
      end if;
   end Read;

   procedure Event
   is
      Re : Block.Result;
   begin
      if
         Block.Initialized (Client)
         and then Initialized (Server)
         and then Block.Initialized (Server)
      then
         pragma Assert (Block.Initialized (Server));
         for I in Cache'Range loop
            pragma Loop_Invariant (Block.Initialized (Client));
            pragma Loop_Invariant (Block.Initialized (Server));
            pragma Loop_Invariant (Initialized (Server));
            if Block.Status (Cache (I).S) = Block.Raw then
               if
                  Block.Status (Cache (I).C) in Block.Ok | Block.Error
                  and then Block.Assigned (Client, Cache (I).C)
               then
                  Block_Client.Release (Client, Cache (I).C);
                  Cache (I).A := False;
               end if;
               if Block.Status (Cache (I).C) = Block.Raw then
                  Block_Server.Process (Server, Cache (I).S);
               end if;
            end if;
            if
               Block.Status (Cache (I).S) = Block.Error
               and then Block.Assigned (Server, Cache (I).S)
            then
               Block_Server.Acknowledge (Server, Cache (I).S, Block.Error);
            end if;
            if Block.Status (Cache (I).S) = Block.Pending then
               if
                  Block.Status (Cache (I).C) = Block.Pending
                  and then Block.Assigned (Client, Cache (I).C)
               then
                  Block_Client.Update_Request (Client, Cache (I).C);
               end if;
               if
                  Block.Status (Cache (I).C) in Block.Ok | Block.Error
                  and then Block.Assigned (Client, Cache (I).C)
               then
                  if
                     Block.Status (Cache (I).C) = Block.Ok
                     and then Block.Kind (Cache (I).C) = Block.Read
                  then
                     Block_Client.Read (Client, Cache (I).C);
                  end if;
                  if Block.Assigned (Server, Cache (I).S) then
                     Block_Server.Acknowledge (Server, Cache (I).S, Block.Status (Cache (I).C));
                  end if;
               end if;
               if Block.Status (Cache (I).C) = Block.Raw then
                  Block_Client.Allocate_Request (Client,
                                                 Cache (I).C,
                                                 Block.Kind (Cache (I).S),
                                                 Block.Start (Cache (I).S),
                                                 Block.Length (Cache (I).S),
                                                 I,
                                                 Re);
                  case Re is
                     when Block.Success =>
                        Block_Client.Enqueue (Client, Cache (I).C);
                        null;
                     when Block.Retry =>
                        null;
                     when others =>
                        Cache (I).A := True;
                  end case;
               end if;
               if
                  Block.Status (Cache (I).C) = Block.Allocated
                  and then Block.Assigned (Client, Cache (I).C)
               then
                  Block_Client.Enqueue (Client, Cache (I).C);
                  null;
               end if;
            end if;
         end loop;
         Block_Client.Submit (Client);
         Block_Server.Unblock_Client (Server);
      end if;
   end Event;

   procedure Dispatch (I : in out Block.Dispatcher_Session;
                       C :        Block.Dispatcher_Capability)
   is
   begin
      if Block_Dispatcher.Valid_Session_Request (I, C)
         and then not Initialized (Server)
         and then not Block.Initialized (Server)
      then
         Block_Dispatcher.Session_Initialize (I, C, Server, 42);
         if Initialized (Server) and then Block.Initialized (Server) then
            Block_Dispatcher.Session_Accept (I, C, Server);
         end if;
      end if;
      Block_Dispatcher.Session_Cleanup (I, C, Server);
   end Dispatch;

   procedure Initialize_Server (S : in out Block.Server_Session;
                                L :        String;
                                B :        Block.Byte_Length)
   is
   begin
      if not Block.Initialized (Client) then
         Block_Client.Initialize (Client, Capability, L, 42, B);
      end if;
      if Block.Initialized (Client) and then not Initialized (S) then
         Block_Client.Finalize (Client);
      end if;
   end Initialize_Server;

   procedure Finalize_Server (S : in out Block.Server_Session)
   is
      pragma Unreferenced (S);
   begin
      Block_Client.Finalize (Client);
   end Finalize_Server;

   function Block_Count (S : Block.Server_Session) return Block.Count
   is
      pragma Unreferenced (S);
   begin
      return Block.Block_Count (Client);
   end Block_Count;

   function Block_Size (S : Block.Server_Session) return Block.Size
   is
      pragma Unreferenced (S);
   begin
      return Block.Block_Size (Client);
   end Block_Size;

   function Writable (S : Block.Server_Session) return Boolean
   is
      pragma Unreferenced (S);
   begin
      return Block.Writable (Client);
   end Writable;

   function Initialized (S : Block.Server_Session) return Boolean is
      (Block.Initialized (Client)
       and then Block.Block_Size (Client) in 512 | 1024 | 2048 | 4096
       and then Block.Block_Count (Client) > 0
       and then Block.Block_Count (Client) < Block.Count'Last / (Block.Count (Block.Block_Size (Client)) / 512));

end Component;
