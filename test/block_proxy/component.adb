
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
      Block_Dispatcher.Initialize (Dispatcher, Cap);
      Block_Dispatcher.Register (Dispatcher);
      Componolit.Interfaces.Log.Client.Initialize (Log, Cap, "Proxy");
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
   end record;

   type Registry is array (Request_Index'Range) of Cache_Entry;

   Cache : Registry := (others => (C => Block_Client.Null_Request,
                                   S => Block_Server.Null_Request));

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
      Rh : Block_Client.Request_Handle;
      Ri : Request_Index;
      As : Boolean;
   begin
      if
         Block_Client.Initialized (Client)
         and Block_Server.Initialized (Server)
      then
         for I in Cache'Range loop
            if
               Block_Server.Status (Cache (I).S) = Block.Pending
               and then Block_Client.Status (Cache (I).C) = Block.Raw
            then
               Block_Client.Allocate_Request (Client,
                                              Cache (I).C,
                                              Block_Server.Kind (Cache (I).S),
                                              Block_Server.Start (Cache (I).S),
                                              Block_Server.Length (Cache (I).S),
                                              I);
               if Block_Client.Status (Cache (I).C) = Block.Allocated then
                  Componolit.Interfaces.Log.Client.Info (Log, "Enq cache");
                  Block_Client.Enqueue (Client, Cache (I).C);
               end if;
            end if;
         end loop;
         Block_Client.Submit (Client);
         loop
            Block_Client.Update_Response_Queue (Client, Rh);
            exit when not Block_Client.Valid (Rh);
            Ri := Block_Client.Identifier (Rh);
            Block_Client.Update_Request (Client, Cache (Ri).C, Rh);
            if
               Block_Client.Status (Cache (Ri).C) = Ok
               and then Block_Client.Kind (Cache (Ri).C) = Read
            then
               Block_Client.Read (Client, Cache (Ri).C);
            end if;
            loop
               Block_Server.Acknowledge (Server, Cache (Ri).S, Block_Client.Status (Cache (Ri).C));
               exit when Block_Server.Status (Cache (Ri).S) = Block.Raw;
            end loop;
            Block_Client.Release (Client, Cache (Ri).C);
         end loop;
         As := False;
         loop
            for I in Cache'Range loop
               if Block_Server.Status (Cache (I).S) = Block.Raw then
                  Ri := I;
                  As := True;
                  exit;
               end if;
            end loop;
            exit when not As;
            Block_Server.Process (Server, Cache (Ri).S);
            exit when Block_Server.Status (Cache (Ri).S) = Block.Raw;
            Block_Client.Allocate_Request (Client,
                                           Cache (Ri).C,
                                           Block_Server.Kind (Cache (Ri).S),
                                           Block_Server.Start (Cache (Ri).S),
                                           Block_Server.Length (Cache (Ri).S),
                                           Ri);
            exit when Block_Client.Status (Cache (Ri).C) /= Block.Allocated;
            Block_Client.Enqueue (Client, Cache (Ri).C);
            As := False;
         end loop;
         Block_Client.Submit (Client);
      end if;
      Block_Server.Unblock_Client (Server);
   end Event;

   procedure Dispatch (C : Block.Dispatcher_Capability)
   is
      Valid : Boolean;
   begin
      Block_Dispatcher.Session_Request (Dispatcher, C, Valid);
      if Valid and not Block_Server.Initialized (Server) then
         Block_Dispatcher.Session_Accept (Dispatcher, C, Server);
      end if;
      Block_Dispatcher.Session_Cleanup (Dispatcher, C, Server);
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

   function Maximum_Transfer_Size (S : Block.Server_Instance) return Block.Byte_Length
   is
      pragma Unreferenced (S);
   begin
      return 16#ffffffff#;
   end Maximum_Transfer_Size;

end Component;
