
with Cxx.Genode;
with Cxx.Block.Server;
use all type Cxx.Bool;
use all type Cxx.Genode.Uint64_T;

package body Componolit.Interfaces.Block.Server
is

   procedure Process (S : in out Server_Session;
                      R : in out Server_Request)
   is
      State : Integer;
   begin
      Cxx.Block.Server.Process_Request (S.Instance, R.Request, State);
      if State = 1 then
         R.Status := Componolit.Interfaces.Internal.Block.Pending;
         R.Session := S.Instance.Tag;
      end if;
   end Process;

   procedure Read (S : in out Server_Session;
                   R :        Server_Request;
                   B :        Buffer) with
      SPARK_Mode => Off
   is
   begin
      Cxx.Block.Server.Read (S.Instance,
                             R.Request,
                             B'Address);
   end Read;

   procedure Write (S : in out Server_Session;
                    R :        Server_Request;
                    B :    out Buffer) with
      SPARK_Mode => Off
   is
   begin
      Cxx.Block.Server.Write (S.Instance,
                              R.Request,
                              B'Address);
   end Write;

   procedure Acknowledge (S   : in out Server_Session;
                          R   : in out Server_Request;
                          Res :        Request_Status)
   is
      Succ : Integer := (if Res = Ok then 1 else 0);
   begin
      Cxx.Block.Server.Acknowledge (S.Instance, R.Request, Succ);
      if Succ = 1 then
         R.Status := Componolit.Interfaces.Internal.Block.Raw;
      end if;
   end Acknowledge;

   procedure Unblock_Client (S : in out Server_Session)
   is
   begin
      Cxx.Block.Server.Unblock_Client (S.Instance);
   end Unblock_Client;

   procedure Lemma_Initialize (S : in out Server_Session;
                               L :        String;
                               B :        Byte_Length)
   is
   begin
      Initialize (S, L, B);
   end Lemma_Initialize;

   procedure Lemma_Finalize (S : in out Server_Session)
   is
   begin
      Finalize (S);
   end Lemma_Finalize;

end Componolit.Interfaces.Block.Server;
