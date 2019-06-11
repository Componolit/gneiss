
with Componolit.Interfaces.Log;
with Componolit.Interfaces.Log.Client;

package body Component is

   use all type Block_Server.Request;
   use all type Block.Id;
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
      pragma Unreferenced (C);
      pragma Unreferenced (B);
      pragma Unreferenced (L);
      S_R : constant Block_Server.Request := Peek (Block.Write, S);
   begin
      Block_Server.Write (Server, S_R, D);
   end Write;

   procedure Read (C : Block.Client_Instance;
                   B : Block.Size;
                   S : Block.Id;
                   L : Block.Count;
                   D : Buffer)
   is
      pragma Unreferenced (C);
      pragma Unreferenced (B);
      pragma Unreferenced (L);
      S_R : constant Block_Server.Request := Peek (Block.Read, S);
   begin
      Block_Server.Read (Server, S_R, D);
   end Read;

   function Convert_Request (R : Block_Server.Request) return Block_Client.Request;

   function Convert_Request (R : Block_Server.Request) return Block_Client.Request
   is
      C : Block_Client.Request (Kind => R.Kind);
   begin
      if C.Kind /= Block.None then
         C.Priv := Block.Null_Data;
         C.Start := R.Start;
         C.Length := R.Length;
         C.Status := Block.Raw;
      end if;
      return C;
   end Convert_Request;

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
         loop
            A := Block_Client.Next (Client);
            exit when A.Kind = Block.None;
            if A.Kind = Block.Read and then A.Status = Block.Ok then
               Block_Client.Read (Client, A);
            end if;
            Load (R, A.Kind, A.Start);
            if R.Kind /= Block.None then
               R.Status := A.Status;
               Block_Server.Acknowledge (Server, R);
            end if;
            Block_Client.Release (Client, A);
            exit when R.Kind = Block.None;
         end loop;

         loop
            R := Block_Server.Head (Server);
            exit when R.Kind = Block.None;
            Store (R, Success);
            exit when not Success;
            Block_Client.Enqueue (Client, Convert_Request (R));
            Block_Server.Discard (Server);
         end loop;
         Block_Client.Submit (Client);
      end if;
      Block_Server.Unblock_Client (Server);
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

   function Maximum_Transfer_Size (S : Block.Server_Instance) return Block.Byte_Length
   is
      pragma Unreferenced (S);
   begin
      return 16#ffffffff#;
   end Maximum_Transfer_Size;

end Component;
