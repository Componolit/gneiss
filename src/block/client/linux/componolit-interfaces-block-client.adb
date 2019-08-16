
with C;
with System;

package body Componolit.Interfaces.Block.Client with
   SPARK_Mode
is
   --  pragma Assertion_Policy (Pre => Ignore, Post => Check);

   type Address is new System.Address;
   Null_Address : constant Address := Address (System.Null_Address);

   ----------------------
   -- Allocate_Request --
   ----------------------

   procedure Allocate_Request (C : in out Client_Session;
                               R : in out Client_Request;
                               K :        Request_Kind;
                               S :        Id;
                               L :        Count;
                               I :        Request_Id;
                               E :    out Result)
   is
      procedure C_Allocate_Request (Inst :        Address;
                                    Req  : in out Client_Request;
                                    Ret  :    out Integer) with
         Import,
         Convention    => C,
         External_Name => "block_client_allocate_request",
         Global        => null,
         Post          => Status (Req) in Raw | Allocated;
      Retr : Integer;
   begin
      case K is
         when None      => R.Kind := Componolit.Interfaces.Internal.Block.None;
         when Read      => R.Kind := Componolit.Interfaces.Internal.Block.Read;
         when Write     => R.Kind := Componolit.Interfaces.Internal.Block.Write;
         when Sync      => R.Kind := Componolit.Interfaces.Internal.Block.Sync;
         when Trim      => R.Kind := Componolit.Interfaces.Internal.Block.Trim;
         when Undefined => R.Kind := Componolit.Interfaces.Internal.Block.None;
      end case;
      R.Start  := Standard.C.Uint64_T (S);
      R.Length := Standard.C.Uint64_T (L);
      R.Tag    := Request_Id'Pos (I);
      C_Allocate_Request (Address (C.Instance), R, Retr);
      if Status (R) = Allocated then
         E := Success;
      else
         R.Status := Componolit.Interfaces.Internal.Block.Raw;
         case Retr is
            when 1 => E := Retry;
            when 2 => E := Out_Of_Memory;
            when others => E := Unsupported;
         end case;
      end if;
   end Allocate_Request;

   --------------------
   -- Update_Request --
   --------------------

   procedure Update_Request (C : in out Client_Session;
                             R : in out Client_Request)
   is
      procedure C_Update_Request (Inst   :        Address;
                                  Req    : in out Client_Request) with
         Import,
         Convention    => C,
         External_Name => "block_client_update_request",
         Global        => null,
         Post          => Status (Req) in Pending | Ok | Error;
   begin
      C_Update_Request (Address (C.Instance), R);
   end Update_Request;

   ----------------
   -- Initialize --
   ----------------

   procedure Crw (C : Client_Instance;
                  B : Size;
                  R : Client_Request;
                  D : System.Address);

   procedure Crw (C : Client_Instance;
                  B : Size;
                  R : Client_Request;
                  D : System.Address) with
      SPARK_Mode => Off
   is
      Data : Buffer (1 .. B * Count (R.Length)) with
         Address => D;
   begin
      case R.Kind is
         when Componolit.Interfaces.Internal.Block.Read =>
            Read (C, Request_Id'Val (R.Tag), Data);
         when Componolit.Interfaces.Internal.Block.Write =>
            Write (C, Request_Id'Val (R.Tag), Data);
         when others =>
            null;
      end case;
   end Crw;

   procedure Initialize (C           : in out Client_Session;
                         Cap         :        Componolit.Interfaces.Types.Capability;
                         Path        :        String;
                         Buffer_Size :        Byte_Length := 0) with
      SPARK_Mode => Off
   is
      pragma Unreferenced (Cap);
      C_Path : String := Path & Character'Val (0);
      procedure C_Initialize (T : out System.Address;
                              P : System.Address;
                              B : Byte_Length;
                              E : System.Address;
                              W : System.Address) with
         Import,
         Convention    => C,
         External_Name => "block_client_initialize",
         Global        => null;
   begin
      C_Initialize (C.Instance, C_Path'Address, Buffer_Size, Event'Address, Crw'Address);
   end Initialize;

   --------------
   -- Finalize --
   --------------

   procedure Finalize (C : in out Client_Session)
   is
      procedure C_Finalize (T : in out Address) with
         Import,
         Convention    => C,
         External_Name => "block_client_finalize",
         Global        => null,
         Post          => T = Null_Address;
   begin
      C_Finalize (Address (C.Instance));
   end Finalize;

   -------------
   -- Enqueue --
   -------------

   procedure Enqueue (C : in out Client_Session;
                      R : in out Client_Request)
   is
      procedure C_Enqueue (T   :        Address;
                           Req : in out Client_Request) with
         Import,
         Convention    => C,
         External_Name => "block_client_enqueue",
         Global        => null,
         Pre           => Status (Req) = Allocated,
         Post          => Status (Req) in Allocated | Pending;
   begin
      C_Enqueue (Address (C.Instance), R);
   end Enqueue;

   ------------
   -- Submit --
   ------------

   procedure Submit (C : in out Client_Session) is
      procedure C_Submit (T : System.Address) with
         Import,
         Convention    => C,
         External_Name => "block_client_submit",
         Global        => null;
   begin
      C_Submit (C.Instance);
   end Submit;

   ----------
   -- Read --
   ----------

   procedure Read (C : in out Client_Session;
                   R :        Client_Request)
   is
      procedure C_Read (T   : System.Address;
                        Req : Client_Request) with
         Import,
         Convention    => C,
         External_Name => "block_client_read",
         Global        => null;
   begin
      C_Read (C.Instance, R);
   end Read;

   -------------
   -- Release --
   -------------

   procedure Release (C : in out Client_Session;
                      R : in out Client_Request)
   is
      procedure C_Release (T   :        Address;
                           Req : in out Client_Request) with
         Import,
         Convention    => C,
         External_Name => "block_client_release",
         Global        => null,
         Post          => Status (Req) = Raw;
   begin
      C_Release (Address (C.Instance), R);
   end Release;

   procedure Lemma_Read (C      : Client_Instance;
                         Req    : Request_Id;
                         Data   : Buffer)
   is
   begin
      Read (C, Req, Data);
   end Lemma_Read;

   procedure Lemma_Write (C      :     Client_Instance;
                          Req    :     Request_Id;
                          Data   : out Buffer)
   is
   begin
      Write (C, Req, Data);
   end Lemma_Write;

end Componolit.Interfaces.Block.Client;
