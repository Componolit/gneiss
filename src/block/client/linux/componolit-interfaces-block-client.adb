
with C;
with System;

use all type System.Address;

package body Componolit.Interfaces.Block.Client
is
   use type C.Uint32_T;
   use type C.Uint64_T;

   ------------------
   -- Null_Request --
   ------------------

   function Null_Request return Request
   is
      (Request'(Kind   => 0,
                Tag    => 0,
                Start  => 0,
                Length => 0,
                Status => 0,
                Aiocb  => System.Null_Address));

   ----------
   -- Kind --
   ----------

   function Kind (R : Request) return Request_Kind
   is
      (case R.Kind is
         when 1 => Read,
         when 2 => Write,
         when 3 => Sync,
         when 4 => Trim,
         when others => None);

   ------------
   -- Status --
   ------------

   function Status (R : Request) return Request_Status
   is
      (case R.Status is
         when 1 => Allocated,
         when 2 => Pending,
         when 3 => Pending,
         when 4 => Pending,
         when 5 => Ok,
         when 6 => Error,
         when others => Raw);

   -----------
   -- Start --
   -----------

   function Start (R : Request) return Id
   is
      (Id (R.Start));

   ------------
   -- Length --
   ------------

   function Length (R : Request) return Count
   is
      (Count (R.Length));

   ----------------
   -- Identifier --
   ----------------

   function Identifier (R : Request) return Request_Id
   is
      (Request_Id'Val (R.Tag));

   ----------------------
   -- Allocate_Request --
   ----------------------

   procedure Allocate_Request (C : in out Client_Session;
                               R : in out Request;
                               K :        Request_Kind;
                               S :        Id;
                               L :        Count;
                               I :        Request_Id)
   is
      procedure C_Allocate_Request (Inst :        System.Address;
                                    Req  : in out Request) with
         Import,
         Convention    => C,
         External_Name => "block_client_allocate_request",
         Global        => null;
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
      C_Allocate_Request (C.Instance, R);
   end Allocate_Request;

   -----------
   -- Valid --
   -----------

   function Valid (H : Request_Handle) return Boolean
   is
      (H.Valid = 1);

   ----------------
   -- Identifier --
   ----------------

   function Identifier (H : Request_Handle) return Request_Id
   is
      (Request_Id'Val (H.Tag));

   ---------------------------
   -- Update_Response_Queue --
   ---------------------------

   procedure Update_Response_Queue (C : in out Client_Session;
                                    H :    out Request_Handle)
   is
      procedure C_Update_Response_Queue (Inst   :     System.Address;
                                         Handle : out Request_Handle) with
         Import,
         Convention    => C,
         External_Name => "block_client_update_response_queue",
         Global        => null;
   begin
      C_Update_Response_Queue (C.Instance, H);
   end Update_Response_Queue;

   --------------------
   -- Update_Request --
   --------------------

   procedure Update_Request (C : in out Client_Session;
                             R : in out Request;
                             H :        Request_Handle)
   is
      procedure C_Update_Request (Inst   :        System.Address;
                                  Req    : in out Request;
                                  Handle :        Request_Handle) with
         Import,
         Convention    => C,
         External_Name => "block_client_update_request",
         Global        => null;
   begin
      C_Update_Request (C.Instance, R, H);
   end Update_Request;

   ------------
   -- Create --
   ------------

   function Create return Client_Session is
   begin
      return Client_Session'(Instance => System.Null_Address);
   end Create;

   ------------------
   -- Get_Instance --
   ------------------

   function Instance (C : Client_Session) return Client_Instance is
      function C_Get_Instance (T : System.Address) return Client_Instance with
         Import,
         Convention    => CPP,
         External_Name => "block_client_get_instance",
         Global        => null;
   begin
      return C_Get_Instance (C.Instance);
   end Instance;

   -----------------
   -- Initialized --
   -----------------

   function Initialized (C : Client_Session) return Boolean is
      (C.Instance /= System.Null_Address);

   ----------------
   -- Initialize --
   ----------------

   procedure Crw (C : Client_Instance;
                  R : Request;
                  D : System.Address);

   procedure Crw (C : Client_Instance;
                  R : Request;
                  D : System.Address) with
      SPARK_Mode => Off
   is
      Data : Buffer (1 .. Buffer_Index (R.Start * R.Length)) with
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

   procedure Finalize (C : in out Client_Session) is
      procedure C_Finalize (T : in out System.Address) with
         Import,
         Convention    => C,
         External_Name => "block_client_finalize",
         Global        => null;
      --  FIXME: procedure has platform state
   begin
      C_Finalize (C.Instance);
      C.Instance := System.Null_Address;
   end Finalize;

   -------------
   -- Enqueue --
   -------------

   procedure Enqueue (C : in out Client_Session;
                      R : in out Request) with
      SPARK_Mode => Off
   is
      procedure C_Enqueue (T   :        System.Address;
                           Req : in out Request) with
         Import,
         Convention    => C,
         External_Name => "block_client_enqueue",
         Global        => null;
   begin
      C_Enqueue (C.Instance, R);
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
                   R :        Request) with
      SPARK_Mode => Off
   is
      procedure C_Read (T   : System.Address;
                        Req : Request) with
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
                      R : in out Request) with
      SPARK_Mode => Off
   is
      procedure C_Release (T   :        System.Address;
                           Req : in out Request) with
         Import,
         Convention    => C,
         External_Name => "block_client_release",
         Global        => null;
   begin
      C_Release (C.Instance, R);
   end Release;

   --------------
   -- Writable --
   --------------

   function Writable (C : Client_Session) return Boolean is
      function C_Writable (T : System.Address) return Integer with
         Import,
         Convention    => C,
         External_Name => "block_client_writable",
         Global        => null;
   begin
      return C_Writable (C.Instance) = 1;
   end Writable;

   -----------------
   -- Block_Count --
   -----------------

   function Block_Count (C : Client_Session) return Count is
      function C_Block_Count (T : System.Address) return Count with
         Import,
         Convention    => C,
         External_Name => "block_client_block_count",
         Global        => null;
   begin
      return C_Block_Count (C.Instance);
   end Block_Count;

   ----------------
   -- Block_Size --
   ----------------

   function Block_Size (C : Client_Session) return Size is
      function C_Block_Size (T : System.Address) return Size with
         Import,
         Convention    => C,
         External_Name => "block_client_block_size",
         Global        => null;
   begin
      return C_Block_Size (C.Instance);
   end Block_Size;

   ---------------------------
   -- Maximum_Transfer_Size --
   ---------------------------

   function Maximum_Transfer_Size (C : Client_Session) return Byte_Length is
      function C_Maximum_Transfer_Size (T : System.Address) return Byte_Length with
         Import,
         Convention    => C,
         External_Name => "block_client_maximum_transfer_size",
         Global        => null;
   begin
      return C_Maximum_Transfer_Size (C.Instance);
   end Maximum_Transfer_Size;

end Componolit.Interfaces.Block.Client;
