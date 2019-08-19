
with Componolit.Interfaces.Log;
with Componolit.Interfaces.Log.Client;

package body Component is

   use type Block.Request_Kind;
   use type Block.Request_Status;

   Dispatcher : Block.Dispatcher_Session := Block.Create;

   Log : Componolit.Interfaces.Log.Client_Session := Componolit.Interfaces.Log.Client.Create;

   procedure Construct (Cap : Componolit.Interfaces.Types.Capability)
   is
   begin
      Capability := Cap;
      if not Componolit.Interfaces.Log.Client.Initialized (Log) then
         Componolit.Interfaces.Log.Client.Initialize (Log, Cap, "Proxy");
      end if;
      if Componolit.Interfaces.Log.Client.Initialized (Log) then
         if not Block.Initialized (Dispatcher) then
            Block_Dispatcher.Initialize (Dispatcher, Cap);
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
      if Componolit.Interfaces.Log.Client.Initialized (Log) then
         Componolit.Interfaces.Log.Client.Finalize (Log);
      end if;
      if Block.Initialized (Dispatcher) then
         Block_Dispatcher.Finalize (Dispatcher);
      end if;
   end Destruct;

   type Cache_Entry is record
      C : Block.Client_Request;
      S : Block.Server_Request;
      A : Boolean;
   end record;

   type Registry is array (Request_Index'Range) of Cache_Entry;

   Cache : Registry := (others => (C => Block.Null_Request,
                                   S => Block.Null_Request,
                                   A => False));

   procedure Write (C :     Block.Client_Instance;
                    I :     Request_Index;
                    D : out Buffer)
   is
      use type Block.Client_Instance;
      --  pragma Unreferenced (C);
   begin
      pragma Assert (if Block.Instance (Client) = C then Block.Initialized (Client));
      if
         Block.Status (Cache (I).S) = Block.Pending
         and then Block.Kind (Cache (I).S) = Block.Write
      then
         Block_Server.Write (Server, Cache (I).S, D);
      else
         Cache (I).A := True;
      end if;
   end Write;

   procedure Read (C : Block.Client_Instance;
                   I : Request_Index;
                   D : Buffer)
   is
      pragma Unreferenced (C);
   begin
      if
         Block.Status (Cache (I).S) = Block.Pending
         and then Block.Kind (Cache (I).S) = Block.Read
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
         and Block.Initialized (Server)
      then
         pragma Assert (Block.Initialized (Server));
         for I in Cache'Range loop
            pragma Loop_Invariant (Block.Initialized (Client));
            pragma Loop_Invariant (Block.Initialized (Server));
            pragma Loop_Invariant (Initialized (Block.Instance (Server)));
            if Block.Status (Cache (I).S) = Block.Raw then
               pragma Assert (Block.Initialized (Server));
               if Block.Status (Cache (I).C) in Block.Ok | Block.Error then
                  Block_Client.Release (Client, Cache (I).C);
                  Cache (I).A := False;
               end if;
               if Block.Status (Cache (I).C) = Block.Raw then
                  pragma Assert (Block.Initialized (Server));
                  Block_Server.Process (Server, Cache (I).S);
               end if;
            end if;
            if Block.Status (Cache (I).S) = Block.Error then
               pragma Assert (Block.Initialized (Server));
               pragma Assert (Block.Status (Cache (I).S) = Block.Error);
               Block_Server.Acknowledge (Server, Cache (I).S, Block.Error);
            end if;
            if Block.Status (Cache (I).S) = Block.Pending then
               pragma Assert (Block.Initialized (Server));
               if Block.Status (Cache (I).C) = Block.Pending then
                  Block_Client.Update_Request (Client, Cache (I).C);
               end if;
               pragma Assert (Block.Status (Cache (I).S) = Block.Pending);
               if Block.Status (Cache (I).C) in Block.Ok | Block.Error then
                  pragma Assert (Block.Status (Cache (I).C) in Block.Ok | Block.Error);
                  if
                     Block.Status (Cache (I).C) = Block.Ok
                     and then Block.Kind (Cache (I).C) = Block.Read
                  then
                     Block_Client.Read (Client, Cache (I).C);
                     null;
                  end if;
                  pragma Assert (Block.Initialized (Server));
                  pragma Assert (Block.Status (Cache (I).S) = Block.Pending);
                  pragma Assert (Block.Status (Cache (I).C) in Block.Ok | Block.Error);
                  Block_Server.Acknowledge (Server, Cache (I).S, Block.Status (Cache (I).C));
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
               if Block.Status (Cache (I).C) = Block.Allocated then
                  Block_Client.Enqueue (Client, Cache (I).C);
                  null;
               end if;
            end if;
            --  pragma Assert (Block.Initialized (Server));
         end loop;
         Block_Client.Submit (Client);
         pragma Assert (Block.Initialized (Server));
         Block_Server.Unblock_Client (Server);
      end if;
   end Event;

   procedure Dispatch (I : Block.Dispatcher_Instance;
                       C : Block.Dispatcher_Capability)
   is
      use type Block.Dispatcher_Instance;
   begin
      if Block.Instance (Dispatcher) = I then
         if Block_Dispatcher.Valid_Session_Request (Dispatcher, C)
            and then not Initialized (Block.Instance (Server))
            and then not Block.Initialized (Server)
         then
            Block_Dispatcher.Session_Initialize (Dispatcher, C, Server);
            if Initialized (Block.Instance (Server)) and then Block.Initialized (Server) then
               Block_Dispatcher.Session_Accept (Dispatcher, C, Server);
            end if;
         end if;
         Block_Dispatcher.Session_Cleanup (Dispatcher, C, Server);
      end if;
   end Dispatch;

   procedure Initialize_Server (S : Block.Server_Instance; L : String; B : Block.Byte_Length)
   is
      use type Block.Server_Instance;
   begin
      if S = Block.Instance (Server) and then not Block.Initialized (Client) then
         Block_Client.Initialize (Client, Capability, L, B);
         if Block.Initialized (Client) and then not Initialized (S) then
            Block_Client.Finalize (Client);
         end if;
      end if;
   end Initialize_Server;

   procedure Finalize_Server (S : Block.Server_Instance)
   is
      pragma Unreferenced (S);
   begin
      Block_Client.Finalize (Client);
   end Finalize_Server;

   function Block_Count (S : Block.Server_Instance) return Block.Count
   is
      pragma Unreferenced (S);
   begin
      return Block.Block_Count (Client);
   end Block_Count;

   function Block_Size (S : Block.Server_Instance) return Block.Size
   is
      pragma Unreferenced (S);
   begin
      return Block.Block_Size (Client);
   end Block_Size;

   function Writable (S : Block.Server_Instance) return Boolean
   is
      pragma Unreferenced (S);
   begin
      return Block.Writable (Client);
   end Writable;

   function Initialized (S : Block.Server_Instance) return Boolean is
      (Block.Initialized (Client)
       and then Block.Block_Size (Client) in 512 | 1024 | 2048 | 4096
       and then Block.Block_Count (Client) > 0
       and then Block.Block_Count (Client) < Block.Count'Last / (Block.Count (Block.Block_Size (Client)) / 512));

end Component;
