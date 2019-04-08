
package body Component is

   use all type Block_Server.Request;
   use all type Block.Id;
   use all type Block.Count;
   use all type Block.Request_Kind;
   use all type Block.Request_Status;

   Client : Block.Client_Session;
   Dispatcher : Block.Dispatcher_Session;
   Server : Block.Server_Session;

   Capability : Cai.Types.Capability;

   procedure Construct (Cap : Cai.Types.Capability)
   is
   begin
      Capability := Cap;
      Block_Dispatcher.Initialize (Dispatcher, Cap);
      Block_Dispatcher.Register (Dispatcher);
   end Construct;

   type Cache_Entry is record
      Used : Boolean;
      Request : Block_Server.Request;
   end record;

   type Registry is array (1 .. 16) of Cache_Entry;

   Cache : Registry := (others => (False, (Kind => Block.None, Priv => Block.Null_Data)));

   procedure Store (R : Block_Server.Request; Success : out Boolean);

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

   procedure Load (R : out Block_Server.Request; K : Block.Request_Kind; B : Block.Id);

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

   procedure Handle_Write (R : Block_Server.Request);

   procedure Handle_Write (R : Block_Server.Request)
   is
      Success : Boolean;
      B : Buffer (1 .. R.Length * Block_Size (Block_Server.Get_Instance (Server)));
      WR : constant Block_Client.Request := (Kind => Block.Write,
                                             Priv => Block.Null_Data,
                                             Start => R.Start,
                                             Length => R.Length,
                                             Status => Block.Raw);
   begin
      Store (R, Success);
      if Success then
         Block_Server.Write (Server, R, B);
         Block_Client.Enqueue_Write (Client, WR, B);
         Block_Server.Discard (Server);
      end if;
   end Handle_Write;

   procedure Handle_Read (R : Block_Server.Request);

   procedure Handle_Read (R : Block_Server.Request)
   is
      Success : Boolean;
      WR : constant Block_Client.Request := (Kind => Block.Write,
                                             Priv => Block.Null_Data,
                                             Start => R.Start,
                                             Length => R.Length,
                                             Status => Block.Raw);
   begin
      Store (R, Success);
      if Success then
         Block_Client.Enqueue_Read (Client, WR);
         Block_Server.Discard (Server);
      end if;
   end Handle_Read;

   procedure Event
   is
      R : Block_Server.Request;
      A : Block_Client.Request;
   begin
      if
         Block_Client.Initialized (Client)
         and Block_Server.Initialized (Server)
      then
         loop
            R := Block_Server.Head (Server);
            case R.Kind is
               when Block.Write =>
                  Handle_Write (R);
               when Block.Read =>
                  Handle_Read (R);
               when others =>
                  null;
            end case;
            exit when R.Kind = Block.None;
         end loop;
         Block_Client.Submit (Client);

         loop
            A := Block_Client.Next (Client);
            case A.Kind is
               when Block.Write =>
                  Load (R, A.Kind, A.Start);
                  if R.Kind = Block.Write then
                     R.Status := A.Status;
                     while R.Status /= Block.Acknowledged loop
                        Block_Server.Acknowledge (Server, R);
                     end loop;
                  else
                     A.Status := Block.Error;
                  end if;
                  Block_Client.Release (Client, A);
               when Block.Read =>
                  declare
                     B : Buffer (1 .. A.Length * Block_Client.Block_Size (Client));
                  begin
                     Load (R, A.Kind, A.Start);
                     if R.Kind = Block.Read then
                        Block_Client.Read (Client, A, B);
                        R.Status := A.Status;
                        if R.Status = Block.Ok then
                           Block_Server.Read (Server, R, B);
                           R.Status := Block.Ok;
                        end if;
                        Block_Server.Acknowledge (Server, R);
                     else
                        A.Status := Block.Error;
                     end if;
                  end;
                  Block_Client.Release (Client, A);
               when others =>
                  null;
            end case;
            exit when A.Kind = Block.None;
         end loop;
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

   procedure Initialize_Server (S : Block.Server_Instance; L : String)
   is
      pragma Unreferenced (S);
   begin
      if not Block_Client.Initialized (Client) then
         Block_Client.Initialize (Client, Capability, L);
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
