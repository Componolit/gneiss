
with Ada.Unchecked_Conversion;
with System;
with Cxx;
with Cxx.Block;
with Cxx.Block.Client;
with Cxx.Genode;
use all type Cxx.Bool;

package body Componolit.Interfaces.Block.Client with
   SPARK_Mode
is

   type Request_Handle is record
      Valid   : Boolean;
      Tag     : Cxx.Unsigned_Long;
      Success : Boolean;
   end record;

   type Request_Handle_Cache is array (Integer range 1 .. 128) of Request_Handle;

   H_Cache : Request_Handle_Cache := (others => (False, 0, False));

   procedure Allocate_Request (C : in out Client_Session;
                               R : in out Client_Request;
                               K :        Request_Kind;
                               S :        Id;
                               L :        Count;
                               I :        Request_Id;
                               E :    out Result)
   is
      use type Cxx.Unsigned_Long;
      Opcode : Integer;
      Res    : Integer;
   begin
      case K is
         when Read  => Opcode := 0;
         when Write => Opcode := 1;
         when Sync  => Opcode := 2;
         when Trim  => Opcode := 3;
         when others => Opcode := -1;
      end case;
      R.Packet.Block_Count := 0;
      R.Session := C.Instance.Tag;
      Cxx.Block.Client.Allocate_Request (C.Instance, R.Packet, Opcode,
                                         Cxx.Genode.Uint64_T (S),
                                         Cxx.Unsigned_Long (L),
                                         Cxx.Unsigned_Long (Request_Id'Pos (I)),
                                         Res);
      if R.Packet.Block_Count > 0 and Res = 0 then
         R.Status   := Componolit.Interfaces.Internal.Block.Allocated;
         E          := Success;
      else
         if Res = 1 then
            E := Out_Of_Memory;
         else
            E := Unsupported;
         end if;
      end if;
   end Allocate_Request;

   procedure Update_Response_Queue (C : in out Client_Session;
                                    H : in out Request_Handle);

   pragma Warnings (Off, "formal parameter ""C"" is not modified");
   --  Cxx.Block.Client.Update_Response_Queue modifies state
   procedure Update_Response_Queue (C : in out Client_Session;
                                    H : in out Request_Handle)
   is
      State : Integer;
      Succ  : Integer;
      Tag   : Cxx.Unsigned_Long;
   begin
      if not H.Valid then
         Cxx.Block.Client.Update_Response_Queue (C.Instance, State, Tag, Succ);
         if State = 1 then
            H := Request_Handle'(Valid   => True,
                                 Tag     => Tag,
                                 Success => Succ = 1);
         end if;
      end if;
   end Update_Response_Queue;
   pragma Warnings (On, "formal parameter ""C"" is not modified");

   procedure Update_Request (C : in out Client_Session;
                             R : in out Client_Request)
   is
      use type Cxx.Unsigned_Long;
   begin
      for I in H_Cache'Range loop
         Update_Response_Queue (C, H_Cache (I));
         if
            H_Cache (I).Valid
            and then H_Cache (I).Tag = R.Packet.Tag
         then
            R.Status := (if
                            H_Cache (I).Success
                         then
                            Componolit.Interfaces.Internal.Block.Ok
                         else
                            Componolit.Interfaces.Internal.Block.Error);
            H_Cache (I) := Request_Handle'(Valid   => False,
                                           Tag     => 0,
                                           Success => False);
         end if;
      end loop;
   end Update_Request;

   procedure Crw (C : in out Client_Session;
                  O :        Integer;
                  T :        Cxx.Unsigned_Long;
                  L :        Count;
                  D :        System.Address);

   procedure Crw (C : in out Client_Session;
                  O :        Integer;
                  T :        Cxx.Unsigned_Long;
                  L :        Count;
                  D :        System.Address) with
      SPARK_Mode => Off
   is
      Data : Buffer (1 .. Block_Size (C) * L) with
         Address => D;
   begin
      case O is
         when 1 =>
            Write (C, Request_Id'Val (T), Data);
         when 0 =>
            Read (C, Request_Id'Val (T), Data);
         when others =>
            null;
      end case;
   end Crw;

   function Event_Address return System.Address;
   function Crw_Address return System.Address;

   function Event_Address return System.Address with
      SPARK_Mode => Off
   is
   begin
      return Event'Address;
   end Event_Address;

   function Crw_Address return System.Address with
      SPARK_Mode => Off
   is
   begin
      return Crw'Address;
   end Crw_Address;

   procedure Initialize (C           : in out Client_Session;
                         Cap         :        Componolit.Interfaces.Types.Capability;
                         Path        :        String;
                         Tag         :        Session_Id;
                         Buffer_Size :        Byte_Length := 0)
   is
      C_Path : constant String := Path & Character'Val (0);
      subtype C_Path_String is String (1 .. C_Path'Length);
      subtype C_String is Cxx.Char_Array (1 .. C_Path'Length);
      function To_C_String is new Ada.Unchecked_Conversion (C_Path_String,
                                                            C_String);
   begin
      Cxx.Block.Client.Initialize (C.Instance,
                                   Cap,
                                   To_C_String (C_Path),
                                   Event_Address,
                                   Crw_Address,
                                   Cxx.Genode.Uint64_T (Buffer_Size));
      if Initialized (C) then
         C.Instance.Tag := Session_Id'Pos (Tag);
      end if;
   end Initialize;

   procedure Finalize (C : in out Client_Session)
   is
   begin
      Cxx.Block.Client.Finalize (C.Instance);
   end Finalize;

   procedure Enqueue (C : in out Client_Session;
                      R : in out Client_Request)
   is
   begin
      Cxx.Block.Client.Enqueue (C.Instance, R.Packet);
      R.Status := Componolit.Interfaces.Internal.Block.Pending;
   end Enqueue;

   procedure Submit (C : in out Client_Session)
   is
   begin
      Cxx.Block.Client.Submit (C.Instance);
   end Submit;

   procedure Read (C : in out Client_Session;
                   R :        Client_Request)
   is
   begin
      Cxx.Block.Client.Read (C.Instance, R.Packet);
   end Read;

   procedure Release (C : in out Client_Session;
                      R : in out Client_Request)
   is
   begin
      Cxx.Block.Client.Release (C.Instance, R.Packet);
      R.Status := Componolit.Interfaces.Internal.Block.Raw;
   end Release;

   procedure Lemma_Read (C      : in out Client_Session;
                         Req    :        Request_Id;
                         Data   :        Buffer)
   is
   begin
      Read (C, Req, Data);
   end Lemma_Read;

   procedure Lemma_Write (C      : in out Client_Session;
                          Req    :        Request_Id;
                          Data   :    out Buffer)
   is
   begin
      Write (C, Req, Data);
   end Lemma_Write;

end Componolit.Interfaces.Block.Client;
