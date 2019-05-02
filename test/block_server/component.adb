
with Cai.Log.Client;

package body Component is

   Log : Cai.Log.Client_Session;

   Dispatcher : Block.Dispatcher_Session;
   Server : Block.Server_Session;
   Buffer_Size : Block.Byte_Length;

   subtype Block_Buffer is Buffer (1 .. 512);
   type Disk is array (Block.Id range 0 .. 1023) of Block_Buffer;

   Ram_Disk : Disk;

   use all type Block.Id;
   use all type Block.Count;
   use all type Block.Request_Kind;
   use all type Block.Request_Status;

   procedure Construct (Cap : Cai.Types.Capability)
   is
   begin
      Cai.Log.Client.Initialize (Log, Cap, "Ada_Block_Server");
      Block_Dispatcher.Initialize (Dispatcher, Cap);
      Block_Dispatcher.Register (Dispatcher);
      Cai.Log.Client.Info (Log, "Dispatcher initialized");
   end Construct;

   procedure Destruct
   is
   begin
      if Cai.Log.Client.Initialized (Log) then
         Cai.Log.Client.Finalize (Log);
      end if;
      if Block_Dispatcher.Initialized (Dispatcher) then
         Block_Dispatcher.Finalize (Dispatcher);
      end if;
   end Destruct;

   procedure Read (R : in out Block_Server.Request);

   procedure Read (R : in out Block_Server.Request)
   is
      Buf : Buffer (1 .. R.Length * Block_Size (Block_Server.Get_Instance (Server)));
   begin
      if Buf'Length mod Block_Buffer'Length = 0 and then
         R.Start in Ram_Disk'Range and then
         R.Start + (R.Length - 1) in Ram_Disk'Range
      then
         for I in Block.Id range R.Start .. R.Start + (R.Length - 1) loop
            Buf (Buf'First + (I - R.Start) * Block_Buffer'Length ..
               Buf'First + (I - R.Start + 1) * Block_Buffer'Length - 1) := Ram_Disk (I);
         end loop;
         Block_Server.Read (Server, R, Buf);
         R.Status := Block.Ok;
      else
         R.Status := Block.Error;
      end if;
   end Read;

   procedure Write (R : in out Block_Server.Request);

   procedure Write (R : in out Block_Server.Request)
   is
      B : Buffer (1 .. R.Length * Block_Size (Block_Server.Get_Instance (Server)));
   begin
      R.Status := Block.Error;
      if
         B'Length mod Block_Buffer'Length = 0 and then
         R.Start in Ram_Disk'Range and then
         R.Start + (R.Length - 1) in Ram_Disk'Range
      then
         Block_Server.Write (Server, R, B);
         for I in Block.Id range R.Start .. R.Start + (R.Length - 1) loop
            Ram_Disk (I) :=
               B (B'First + (I - R.Start) * Block_Buffer'Length ..
                  B'First + ((I - R.Start) + 1) * Block_Buffer'Length - 1);
         end loop;
         R.Status := Block.Ok;
      end if;
   end Write;

   procedure Event
   is
      R : Block_Server.Request;
   begin
      if Block_Server.Initialized (Server) then
         loop
            R := Block_Server.Head (Server);
            case R.Kind is
               when Block.Read =>
                  Read (R);
                  while R.Status /= Block.Acknowledged loop
                     Block_Server.Acknowledge (Server, R);
                  end loop;
                  Block_Server.Discard (Server);
               when Block.Write =>
                  Write (R);
                  while R.Status /= Block.Acknowledged loop
                     Block_Server.Acknowledge (Server, R);
                  end loop;
                  Block_Server.Discard (Server);
               when others => null;
            end case;
            exit when R.Kind = Block.None;
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

   procedure Initialize (S : Block.Server_Instance; L : String; B : Block.Byte_Length)
   is
      pragma Unreferenced (S);
   begin
      Cai.Log.Client.Info (Log, "Server initialize with label: " & L);
      Ram_Disk := (others => (others => 0));
      Buffer_Size := B;
      Cai.Log.Client.Info (Log, "Initialized");
   end Initialize;

   procedure Finalize (S : Block.Server_Instance)
   is
      pragma Unreferenced (S);
   begin
      null;
   end Finalize;

   procedure Request
   is
      Label : String (1 .. 160);
      Last : Natural;
      Valid : Boolean;
   begin
      Block_Dispatcher.Session_Request (Dispatcher, Valid, Label, Last);
      if Valid and not Block_Server.Initialized (Server) then
         Cai.Log.Client.Info (Log, "Received request with label " & Label (1 .. Last));
         Block_Dispatcher.Session_Accept (Dispatcher, Server, Label (1 .. Last));
      end if;
      Block_Dispatcher.Session_Cleanup (Dispatcher, Server);
   end Request;

end Component;
