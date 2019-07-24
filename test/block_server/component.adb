
with Componolit.Interfaces.Log.Client;

package body Component is

   Log         : Componolit.Interfaces.Log.Client_Session := Componolit.Interfaces.Log.Client.Create;
   Dispatcher  : Block.Dispatcher_Session                 := Block_Dispatcher.Create;
   Server      : Block.Server_Session                     := Block_Server.Create;
   Buffer_Size : Block.Byte_Length;

   subtype Block_Buffer is Buffer (1 .. 512);
   type Disk is array (Block.Id range 0 .. 1023) of Block_Buffer;

   Ram_Disk : Disk;

   type Request_Index is mod 8;
   type Cache_Element is limited record
      Req     : Block_Server.Request;
      Success : Boolean;
   end record;
   type Request_Cache_Type is array (Request_Index'Range) of Cache_Element;
   Request_Cache : Request_Cache_Type := (others => (Req     => Block_Server.Null_Request,
                                                     Success => False));

   use all type Block.Id;
   use all type Block.Count;
   use all type Block.Request_Kind;
   use all type Block.Request_Status;

   procedure Construct (Cap : Componolit.Interfaces.Types.Capability)
   is
   begin
      Componolit.Interfaces.Log.Client.Initialize (Log, Cap, "Ada_Block_Server");
      Block_Dispatcher.Initialize (Dispatcher, Cap);
      Block_Dispatcher.Register (Dispatcher);
      Componolit.Interfaces.Log.Client.Info (Log, "Dispatcher initialized");
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

   procedure Read (R : in out Cache_Element);

   procedure Read (R : in out Cache_Element)
   is
      Start  : constant Block.Id    := Block_Server.Start (R.Req);
      Length : constant Block.Count := Block_Server.Length (R.Req);
      Buf    : Buffer (1 .. Length * Block_Size (Block_Server.Instance (Server)));
   begin
      if Buf'Length mod Block_Buffer'Length = 0 and then
         Start in Ram_Disk'Range and then
         Start + (Length - 1) in Ram_Disk'Range
      then
         for I in Block.Id range Start .. Start + (Length - 1) loop
            Buf (Buf'First + (I - Start) * Block_Buffer'Length ..
               Buf'First + (I - Start + 1) * Block_Buffer'Length - 1) := Ram_Disk (I);
         end loop;
         Block_Server.Read (Server, R.Req, Buf);
         R.Success := True;
      end if;
   end Read;

   procedure Write (R : in out Cache_Element);

   procedure Write (R : in out Cache_Element)
   is
      Start  : constant Block.Id    := Block_Server.Start (R.Req);
      Length : constant Block.Count := Block_Server.Length (R.Req);
      B      : Buffer (1 .. Length * Block_Size (Block_Server.Instance (Server)));
   begin
      if
         B'Length mod Block_Buffer'Length = 0 and then
         Start in Ram_Disk'Range and then
         Start + (Length - 1) in Ram_Disk'Range
      then
         Block_Server.Write (Server, R.Req, B);
         for I in Block.Id range Start .. Start + (Length - 1) loop
            Ram_Disk (I) :=
               B (B'First + (I - Start) * Block_Buffer'Length ..
                  B'First + ((I - Start) + 1) * Block_Buffer'Length - 1);
         end loop;
         R.Success := True;
      end if;
   end Write;

   procedure Event
   is
      Alloc         : Request_Index;
      Alloc_Success : Boolean := False;
   begin
      if Block_Server.Initialized (Server) then
         loop
            for I in Request_Cache'Range loop
               if Block_Server.Status (Request_Cache (I).Req) = Raw then
                  Alloc := I;
                  Alloc_Success := True;
                  exit;
               end if;
            end loop;
            exit when not Alloc_Success;
            Request_Cache (Alloc).Success := False;
            Block_Server.Process (Server, Request_Cache (Alloc).Req);
            exit when Block_Server.Status (Request_Cache (Alloc).Req) = Raw;
            case Block_Server.Kind (Request_Cache (Alloc).Req) is
               when Block.Read =>
                  Read (Request_Cache (Alloc));
                  loop
                     Block_Server.Acknowledge (Server, Request_Cache (Alloc).Req,
                                               (if Request_Cache (Alloc).Success then Block.Ok else Block.Error));
                     exit when Block_Server.Status (Request_Cache (Alloc).Req) = Raw;
                  end loop;
               when Block.Write =>
                  Write (Request_Cache (Alloc));
                  loop
                     Block_Server.Acknowledge (Server, Request_Cache (Alloc).Req,
                                               (if Request_Cache (Alloc).Success then Block.Ok else Block.Error));
                     exit when Block_Server.Status (Request_Cache (Alloc).Req) = Raw;
                  end loop;
               when others => null;
            end case;
         end loop;
      end if;
      Block_Server.Unblock_Client (Server);
   end Event;

   function Block_Count (S : Block.Server_Instance) return Block.Count
   is
      pragma Unreferenced (S);
   begin
      return Block.Count (Ram_Disk'Length);
   end Block_Count;

   function Block_Size (S : Block.Server_Instance) return Block.Size
   is
      pragma Unreferenced (S);
   begin
      return Block.Size (Block_Buffer'Length);
   end Block_Size;

   function Writable (S : Block.Server_Instance) return Boolean
   is
      pragma Unreferenced (S);
   begin
      return True;
   end Writable;

   function Maximum_Transfer_Size (S : Block.Server_Instance) return Block.Byte_Length
   is
      pragma Unreferenced (S);
   begin
      return Buffer_Size;
   end Maximum_Transfer_Size;

   function Initialized (S : Block.Server_Instance) return Boolean
   is
      pragma Unreferenced (S);
   begin
      return True;
   end Initialized;

   procedure Initialize (S : Block.Server_Instance; L : String; B : Block.Byte_Length)
   is
      pragma Unreferenced (S);
   begin
      Componolit.Interfaces.Log.Client.Info (Log, "Server initialize with label: " & L);
      Ram_Disk := (others => (others => 0));
      Buffer_Size := B;
      Componolit.Interfaces.Log.Client.Info (Log, "Initialized");
   end Initialize;

   procedure Finalize (S : Block.Server_Instance)
   is
      pragma Unreferenced (S);
   begin
      null;
   end Finalize;

   procedure Request (C : Block.Dispatcher_Capability)
   is
   begin
      if Block_Dispatcher.Valid_Session_Request (Dispatcher, C) and not Block_Server.Initialized (Server) then
         Block_Dispatcher.Session_Initialize (Dispatcher, C, Server);
         if Block_Server.Initialized (Server) then
            Block_Dispatcher.Session_Accept (Dispatcher, C, Server);
         end if;
      end if;
      Block_Dispatcher.Session_Cleanup (Dispatcher, C, Server);
   end Request;

end Component;
