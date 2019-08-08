
with Componolit.Interfaces.Log;
with Componolit.Interfaces.Log.Client;

package body Component is

   use all type Block.Request_Kind;
   use all type Block.Request_Status;

   Client     : Block.Client_Session     := Block_Client.Create;
   Dispatcher : Block.Dispatcher_Session := Block_Dispatcher.Create;
   Server     : Block.Server_Session     := Block_Server.Create;

   Capability : Componolit.Interfaces.Types.Capability;

   Log : Componolit.Interfaces.Log.Client_Session := Componolit.Interfaces.Log.Client.Create;

   procedure Construct (Cap : Componolit.Interfaces.Types.Capability)
   is
   begin
      Capability := Cap;
      if not Componolit.Interfaces.Log.Client.Initialized (Log) then
         Componolit.Interfaces.Log.Client.Initialize (Log, Cap, "Proxy");
      end if;
      if Componolit.Interfaces.Log.Client.Initialized (Log) then
         if not Block_Dispatcher.Initialized (Dispatcher) then
            Block_Dispatcher.Initialize (Dispatcher, Cap);
         end if;
         if Block_Dispatcher.Initialized (Dispatcher) then
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
      if Componolit.Interfaces.Log.Client.Initialized (Log) then
         Componolit.Interfaces.Log.Client.Finalize (Log);
      end if;
      if Block_Dispatcher.Initialized (Dispatcher) then
         Block_Dispatcher.Finalize (Dispatcher);
      end if;
   end Destruct;

   type Cache_Entry is record
      C : Block_Client.Request;
      S : Block_Server.Request;
      A : Boolean;
   end record;

   type Registry is array (Request_Index'Range) of Cache_Entry;

   Cache : Registry := (others => (C => Block_Client.Null_Request,
                                   S => Block_Server.Null_Request,
                                   A => False));

   procedure Write (C :     Block.Client_Instance;
                    I :     Request_Index;
                    D : out Buffer)
   is
      pragma Unreferenced (C);
   begin
      Block_Server.Write (Server, Cache (I).S, D);
   end Write;

   procedure Read (C : Block.Client_Instance;
                   I : Request_Index;
                   D : Buffer)
   is
      pragma Unreferenced (C);
   begin
      Block_Server.Read (Server, Cache (I).S, D);
   end Read;

   procedure Event
   is
      use type Block_Client.Result;
      Re : Block_Client.Result;
   begin
      if
         Block_Client.Initialized (Client)
         and Block_Server.Initialized (Server)
      then
         for I in Cache'Range loop
            pragma Loop_Invariant (Block_Client.Initialized (Client));
            pragma Loop_Invariant (Block_Server.Initialized (Server));
            if Block_Server.Status (Cache (I).S) = Block.Raw then
               if Block_Client.Status (Cache (I).C) in Block.Ok | Block.Error then
                  Block_Client.Release (Client, Cache (I).C);
                  Cache (I).A := False;
               end if;
               if Block_Client.Status (Cache (I).C) = Block.Raw then
                  Block_Server.Process (Server, Cache (I).S);
               end if;
            end if;
            if Block_Server.Status (Cache (I).S) = Block.Pending then
               if Block_Client.Status (Cache (I).C) = Block.Pending then
                  Block_Client.Update_Request (Client, Cache (I).C);
               end if;
               if Block_Client.Status (Cache (I).C) in Block.Ok | Block.Error then
                  if
                     Block_Client.Status (Cache (I).C) = Block.Ok
                     and then Block_Client.Kind (Cache (I).C) = Block.Read
                  then
                     Block_Client.Read (Client, Cache (I).C);
                  end if;
                  Block_Server.Acknowledge (Server, Cache (I).S, Block_Client.Status (Cache (I).C));
               end if;
               if Block_Client.Status (Cache (I).C) = Block.Raw then
                  Block_Client.Allocate_Request (Client,
                                                 Cache (I).C,
                                                 Block_Server.Kind (Cache (I).S),
                                                 Block_Server.Start (Cache (I).S),
                                                 Block_Server.Length (Cache (I).S),
                                                 I,
                                                 Re);
                  case Re is
                     when Block_Client.Success =>
                        Block_Client.Enqueue (Client, Cache (I).C);
                     when Block_Client.Retry =>
                        null;
                     when others =>
                        Cache (I).A := True;
                  end case;
               end if;
               if Block_Client.Status (Cache (I).C) = Block.Allocated then
                  Block_Client.Enqueue (Client, Cache (I).C);
               end if;
            end if;
         end loop;
         Block_Client.Submit (Client);
         Block_Server.Unblock_Client (Server);
      end if;
   end Event;

   procedure Dispatch (C : Block.Dispatcher_Capability)
   is
   begin
      if Block_Dispatcher.Initialized (Dispatcher) then
         if Block_Dispatcher.Valid_Session_Request (Dispatcher, C) and not Block_Server.Initialized (Server) then
            Block_Dispatcher.Session_Initialize (Dispatcher, C, Server);
            if Block_Server.Initialized (Server) then
               Block_Dispatcher.Session_Accept (Dispatcher, C, Server);
            end if;
         end if;
         Block_Dispatcher.Session_Cleanup (Dispatcher, C, Server);
      end if;
   end Dispatch;

   procedure Initialize_Server (S : Block.Server_Instance; L : String; B : Block.Byte_Length)
   is
      pragma Unreferenced (S);
   begin
      if not Block_Client.Initialized (Client) then
         Block_Client.Initialize (Client, Capability, L, B);
      end if;
   end Initialize_Server;

   procedure Finalize_Server (S : Block.Server_Instance)
   is
      pragma Unreferenced (S);
   begin
      if Block_Client.Initialized (Client) then
         Block_Client.Finalize (Client);
      end if;
   end Finalize_Server;

   function Block_Count (S : Block.Server_Instance) return Block.Count
   is
      pragma Unreferenced (S);
   begin
      if Block_Client.Initialized (Client) then
         return Block_Client.Block_Count (Client);
      else
         return 0;
      end if;
   end Block_Count;

   function Block_Size (S : Block.Server_Instance) return Block.Size
   is
      pragma Unreferenced (S);
   begin
      if Block_Client.Initialized (Client) then
         return Block_Client.Block_Size (Client);
      else
         return 0;
      end if;
   end Block_Size;

   function Writable (S : Block.Server_Instance) return Boolean
   is
      pragma Unreferenced (S);
   begin
      if Block_Client.Initialized (Client) then
         return Block_Client.Writable (Client);
      else
         return False;
      end if;
   end Writable;

   function Initialized (S : Block.Server_Instance) return Boolean
   is
      pragma Unreferenced (S);
   begin
      return Block_Client.Initialized (Client);
   end Initialized;

end Component;
