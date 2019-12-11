
with System;
with Cxx.Genode;
with Cxx.Block.Server;
use all type Cxx.Bool;
use all type Cxx.Genode.Uint64_T;

package body Gneiss.Block.Server with
   SPARK_Mode
is
   use type Cxx.Genode.Uint32_T;

   function Kind (R : Request) return Request_Kind is
      (case R.Request.Kind is
          when 1 => Read,
          when 2 => Write,
          when 3 => Sync,
          when 4 => Trim,
          when others => None);

   function Status (R : Request) return Request_Status is
      (case R.Status is
          when Gneiss_Internal.Block.Raw       => Raw,
          when Gneiss_Internal.Block.Allocated => Allocated,
          when Gneiss_Internal.Block.Pending   => Pending,
          when Gneiss_Internal.Block.Ok        => Ok,
          when Gneiss_Internal.Block.Error     => Error);

   function Start (R : Request) return Id is
      (Id (R.Request.Block_Number));

   function Length (R : Request) return Count is
      (Count (R.Request.Block_Count));

   function Assigned (S : Server_Session;
                      R : Request) return Boolean is
      (S.Instance.Tag = R.Session);

   procedure Process (S : in out Server_Session;
                      R : in out Request)
   is
      State : Integer;
   begin
      Cxx.Block.Server.Process_Request (S.Instance, R.Request, State);
      if State = 1 then
         R.Status := Gneiss_Internal.Block.Pending;
         R.Session := S.Instance.Tag;
      end if;
   end Process;

   procedure Read (S : in out Server_Session;
                   R :        Request;
                   B :        Buffer;
                   O :        Byte_Length) with
      SPARK_Mode => Off
   is
   begin
      Cxx.Block.Server.Read (S.Instance,
                             R.Request,
                             B'Address,
                             Cxx.Genode.Uint64_T (O),
                             Cxx.Genode.Uint64_T (B'Length));
   end Read;

   procedure Write (S : in out Server_Session;
                    R :        Request;
                    B :    out Buffer;
                    O :        Byte_Length) with
      SPARK_Mode => Off
   is
   begin
      Cxx.Block.Server.Write (S.Instance,
                              R.Request,
                              B'Address,
                              Cxx.Genode.Uint64_T (O),
                              Cxx.Genode.Uint64_T (B'Length));
   end Write;

   procedure Async_Read (S : in out Server_Session;
                         R :        Request_Id;
                         D :        System.Address;
                         L :        Buffer_Index);

   procedure Async_Read (S : in out Server_Session;
                         R :        Request_Id;
                         D :        System.Address;
                         L :        Buffer_Index)
   is
      B : Buffer (1 .. L) with
         Import,
         Address => D;
   begin
      Read (S, R, B);
   end Async_Read;

   procedure Async_Write (S : in out Server_Session;
                          R :        Request_Id;
                          D :        System.Address;
                          L :        Buffer_Index);

   procedure Async_Write (S : in out Server_Session;
                          R :        Request_Id;
                          D :        System.Address;
                          L :        Buffer_Index)
   is
      B : Buffer (1 .. L) with
         Import,
         Address => D;
   begin
      Write (S, R, B);
   end Async_Write;

   procedure Read (S : in out Server_Session;
                   R :        Request;
                   I :        Request_Id) with
      SPARK_Mode => Off
   is
   begin
      Cxx.Block.Server.Read_Write (S.Instance,
                                   R.Request,
                                   Request_Id'Pos (I),
                                   Async_Read'Address);
   end Read;

   procedure Write (S : in out Server_Session;
                    R :        Request;
                    I :        Request_Id) with
      SPARK_Mode => Off
   is
   begin
      Cxx.Block.Server.Read_Write (S.Instance,
                                   R.Request,
                                   Request_Id'Pos (I),
                                   Async_Write'Address);
   end Write;

   procedure Acknowledge (S   : in out Server_Session;
                          R   : in out Request;
                          Res :        Request_Status)
   is
      Succ : Integer := (if Res = Ok then 1 else 0);
   begin
      Cxx.Block.Server.Acknowledge (S.Instance, R.Request, Succ);
      if Succ = 1 then
         R.Status := Gneiss_Internal.Block.Raw;
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

   procedure Lemma_Read (S : in out Server_Session;
                         R :        Request_Id;
                         D :    out Buffer)
   is
   begin
      Read (S, R, D);
   end Lemma_Read;

   procedure Lemma_Write (S : in out Server_Session;
                          R :        Request_Id;
                          D :        Buffer)
   is
   begin
      Write (S, R, D);
   end Lemma_Write;

end Gneiss.Block.Server;
