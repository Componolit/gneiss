
with Cxx.Genode;
with Cxx.Block.Server;
use all type Cxx.Bool;
use all type Cxx.Genode.Uint64_T;

package body Componolit.Interfaces.Block.Server
is

   function Create_Request return Request
   is
   begin
      return Request'(Request => Cxx.Block.Server.Request'(Kind         => -1,
                                                           Block_Number => 0,
                                                           Block_Count  => 0,
                                                           Success      => 0,
                                                           Offset       => 0,
                                                           Tag          => 0),
                      Status  => Componolit.Interfaces.Internal.Block.Raw);
   end Create_Request;

   function Request_Type (R : Request) return Request_Kind
   is
   begin
      case R.Request.Kind is
         when 1 => return Read;
         when 2 => return Write;
         when 3 => return Sync;
         when 4 => return Trim;
         when others => raise Constraint_Error;
      end case;
   end Request_Type;

   function Request_State (R : Request) return Request_Status
   is
   begin
      case R.Status is
         when Componolit.Interfaces.Internal.Block.Raw          => return Raw;
         when Componolit.Interfaces.Internal.Block.Allocated    => return Allocated;
         when Componolit.Interfaces.Internal.Block.Pending      => return Pending;
         when Componolit.Interfaces.Internal.Block.Ok           => return Ok;
         when Componolit.Interfaces.Internal.Block.Error        => return Error;
      end case;
   end Request_State;

   function Request_Start (R : Request) return Id
   is
   begin
      return Id (R.Request.Block_Number);
   end Request_Start;

   function Request_Length (R : Request) return Count
   is
   begin
      return Count (R.Request.Block_Count);
   end Request_Length;

   function Create return Server_Session
   is
   begin
      return Server_Session'(Instance => Cxx.Block.Server.Constructor);
   end Create;

   function Get_Instance (S : Server_Session) return Server_Instance
   is
   begin
      return Server_Instance (Cxx.Block.Server.Get_Instance (S.Instance));
   end Get_Instance;

   procedure Process_Request (S : in out Server_Session;
                              R : in out Request)
   is
      Status : Integer;
   begin
      Cxx.Block.Server.Process_Request (S.Instance, R.Request, Status);
      if Status = 1 then
         R.Status := Componolit.Interfaces.Internal.Block.Pending;
      end if;
   end Process_Request;

   procedure Read (S : in out Server_Session;
                   R :        Request;
                   B :        Buffer) with
      SPARK_Mode => Off
   is
   begin
      Cxx.Block.Server.Read (S.Instance,
                             R.Request,
                             B'Address);
   end Read;

   procedure Write (S : in out Server_Session;
                    R :        Request;
                    B :    out Buffer) with
      SPARK_Mode => Off
   is
   begin
      Cxx.Block.Server.Write (S.Instance,
                              R.Request,
                              B'Address);
   end Write;

   procedure Acknowledge (S      : in out Server_Session;
                          R      : in out Request;
                          Status :        Request_Status)
   is
      Success : Integer := (if Status = Ok then 1 else 0);
   begin
      Cxx.Block.Server.Acknowledge (S.Instance, R.Request, Success);
      if Success = 1 then
         R.Status := Componolit.Interfaces.Internal.Block.Raw;
      end if;
   end Acknowledge;

   function Initialized (S : Server_Session) return Boolean
   is
   begin
      return Cxx.Block.Server.Initialized (S.Instance) = Cxx.Bool'Val (1);
   end Initialized;

   procedure Unblock_Client (S : in out Server_Session)
   is
   begin
      Cxx.Block.Server.Unblock_Client (S.Instance);
   end Unblock_Client;

end Componolit.Interfaces.Block.Server;
