
with Cai.Log;
with Cai.Log.Client;

package body Component is

   use all type Block_Server.Request;
   use all type Block.Id;
   use all type Block.Request_Kind;

   Client : Block.Client_Session;
   Dispatcher : Block.Dispatcher_Session;
   Server : Block.Server_Session;

   Capability : Cai.Types.Capability;

   Log : Cai.Log.Client_Session := Cai.Log.Client.Create;

   procedure Construct (Cap : Cai.Types.Capability)
   is
   begin
      Capability := Cap;
      Block_Dispatcher.Initialize (Dispatcher, Cap);
      Block_Dispatcher.Register (Dispatcher);
      Cai.Log.Client.Initialize (Log, Cap, "Proxy");
   end Construct;

   type Cache_Entry is record
      Used : Boolean;
      Request : Block_Server.Request;
   end record;

   type Registry is array (1 .. 16) of Cache_Entry;

   Cache : Registry := (others => (False, (Kind => Block.None, Priv => Block.Null_Data)));

   procedure Store (R : Block_Server.Request; Success : out Boolean);

   function Peek (K : Block.Request_Kind; B : Block.Id) return Block_Server.Request;

   procedure Load (R : out Block_Server.Request; K : Block.Request_Kind; B : Block.Id);

   procedure Store (R : Block_Server.Request; Success : out Boolean)
   is
      First_Free : Integer := 0;
   begin
      Success := False;
      for I in Cache'Range loop
         if not Cache (I).Used and First_Free = 0 then
            First_Free := I;
         end if;
         if Cache (I).Used and then Cache (I).Request = R then
            Success := True;
            return;
         end if;
      end loop;
      if First_Free > 0 then
         Cache (First_Free).Used := True;
         Cache (First_Free).Request := R;
         Success := True;
      end if;
   end Store;

   function Peek (K : Block.Request_Kind; B : Block.Id) return Block_Server.Request
   is
   begin
      for I in Cache'Range loop
         if
            Cache (I).Used
            and then Cache (I).Request.Kind = K
            and then Cache (I).Request.Start = B
         then
            return Cache (I).Request;
         end if;
      end loop;
      return Block_Server.Request'(Kind => None, Priv => Block.Null_Data);
   end Peek;

   procedure Load (R : out Block_Server.Request; K : Block.Request_Kind; B : Block.Id)
   is
   begin
      R := Block_Server.Request'(Kind => None, Priv => Block.Null_Data);
      for I in Cache'Range loop
         if
            Cache (I).Used
            and then Cache (I).Request.Kind = K
            and then Cache (I).Request.Start = B
         then
            R := Cache (I).Request;
            Cache (I).Used := False;
            return;
         end if;
      end loop;
   end Load;

   procedure Write (C :     Block.Client_Instance;
                    B :     Block.Size;
                    S :     Block.Id;
                    L :     Block.Count;
                    D : out Buffer)
   is
   begin
      null;
   end Write;

   procedure Read (C : Block.Client_Instance;
                   B : Block.Size;
                   S : Block.Id;
                   L : Block.Count;
                   D : Buffer)
   is
   begin
      null;
   end Read;

   procedure Event
   is
      R : Block_Server.Request;
      A : Block_Client.Request;
      Success : Boolean;
   begin
      if
         Block_Client.Initialized (Client)
         and Block_Server.Initialized (Server)
      then
         null;
      end if;
   end Event;

   procedure Dispatch
   is
      Label : String (1 .. 160);
      Last : Natural;
      Valid : Boolean;
   begin
      Block_Dispatcher.Session_Request (Dispatcher, Valid, Label, Last);
      if Valid and not Block_Server.Initialized (Server) then
         Block_Dispatcher.Session_Accept (Dispatcher, Server, Label (1 .. Last));
      end if;
      Block_Dispatcher.Session_Cleanup (Dispatcher, Server);
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

   function Maximal_Transfer_Size (S : Block.Server_Instance) return Block.Byte_Length
   is
      pragma Unreferenced (S);
   begin
      return 16#ffffffff#;
   end Maximal_Transfer_Size;

end Component;
