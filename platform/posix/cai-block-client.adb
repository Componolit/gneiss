
with Ada.Unchecked_Conversion;
with System;
with C;
with C.Block;

use all type System.Address;

package body Cai.Block.Client with
   SPARK_Mode => Off
is

   function Convert_Request (R : Request) return C.Block.Request;
   function Convert_Request (R : C.Block.Request) return Request;

   ------------------
   -- Get_Instance --
   ------------------

   function Get_Instance (C : Client_Session) return Client_Instance is
      function C_Get_Instance (T : System.Address) return Client_Instance with
         Import,
         Convention    => CPP,
         External_Name => "block_client_get_instance";
   begin
      return C_Get_Instance (C.Instance);
   end Get_Instance;

   -----------------
   -- Initialized --
   -----------------

   function Initialized (C : Client_Session) return Boolean is
   begin
      return C.Instance /= System.Null_Address;
   end Initialized;

   ----------------
   -- Initialize --
   ----------------

   procedure Initialize (C           : out Client_Session;
                         Cap         :     Cai.Types.Capability;
                         Path        :     String;
                         Buffer_Size :     Byte_Length := 0)
   is
      pragma Unreferenced (Cap);
      C_Path : String := Path & Character'Val (0);
      procedure C_Initialize (T : out System.Address;
                              P : System.Address;
                              B : Byte_Length;
                              E : System.Address) with
         Import,
         Convention    => C,
         External_Name => "block_client_initialize";
   begin
      C_Initialize (C.Instance, C_Path'Address, Buffer_Size, Event'Address);
   end Initialize;

   --------------
   -- Finalize --
   --------------

   procedure Finalize (C : in out Client_Session) is
      procedure C_Finalize (T : in out System.Address) with
         Import,
         Convention    => C,
         External_Name => "block_client_finalize";
   begin
      C_Finalize (C.Instance);
   end Finalize;

   -----------
   -- Ready --
   -----------

   function Ready (C : Client_Session;
                   R : Request) return Boolean
   is
      function C_Ready (T   : System.Address;
                        Req : System.Address) return Integer with
         Import,
         Convention    => C,
         External_Name => "block_client_ready";
      Req : Standard.C.Block.Request := Convert_Request (R);
   begin
      return C_Ready (C.Instance, Req'Address) = 1;
   end Ready;

   ---------------
   -- Supported --
   ---------------

   function Supported (C : Client_Session;
                       R : Request) return Boolean is
      function C_Supported (T   : System.Address;
                            Req : System.Address) return Integer with
         Import,
         Convention    => C,
         External_Name => "block_client_supported";
      Req : Standard.C.Block.Request := Convert_Request (R);
   begin
      return C_Supported (C.Instance, Req'Address) = 1;
   end Supported;

   ------------------
   -- Enqueue_Read --
   ------------------

   procedure Enqueue_Read (C : in out Client_Session;
                           R :        Request)
   is
      procedure C_Enqueue_Read (T   : System.Address;
                                Req : System.Address) with
         Import,
         Convention    => C,
         External_Name => "block_client_enqueue_read";
      Req : Standard.C.Block.Request := Convert_Request (R);
   begin
      C_Enqueue_Read (C.Instance, Req'Address);
   end Enqueue_Read;

   -------------------
   -- Enqueue_Write --
   -------------------

   procedure Enqueue_Write (C : in out Client_Session;
                            R :        Request;
                            B :        Buffer)
   is
      procedure C_Enqueue_Write (T   : System.Address;
                                 Req : System.Address;
                                 Buf : System.Address) with
         Import,
         Convention    => C,
         External_Name => "block_client_enqueue_write";
      Req : Standard.C.Block.Request := Convert_Request (R);
   begin
      C_Enqueue_Write (C.Instance, Req'Address, B'Address);
   end Enqueue_Write;

   ------------------
   -- Enqueue_Sync --
   ------------------

   procedure Enqueue_Sync (C : in out Client_Session;
                           R :        Request)
   is
      procedure C_Enqueue_Sync (T : System.Address; Req : System.Address) with
         Import,
         Convention    => C,
         External_Name => "block_client_enqueue_sync";
      Req : Standard.C.Block.Request := Convert_Request (R);
   begin
      C_Enqueue_Sync (C.Instance, Req'Address);
   end Enqueue_Sync;

   ------------------
   -- Enqueue_Trim --
   ------------------

   procedure Enqueue_Trim (C : in out Client_Session;
                           R :        Request)
   is
      procedure C_Enqueue_Trim (T :   System.Address;
                                Req : System.Address) with
         Import,
         Convention    => C,
         External_Name => "block_client_enqueue_trim";
      Req : Standard.C.Block.Request := Convert_Request (R);
   begin
      C_Enqueue_Trim (C.Instance, Req'Address);
   end Enqueue_Trim;

   ------------
   -- Submit --
   ------------

   procedure Submit (C : in out Client_Session) is
      procedure C_Submit (T : System.Address) with
         Import,
         Convention    => C,
         External_Name => "block_client_submit";
   begin
      C_Submit (C.Instance);
   end Submit;

   ----------
   -- Next --
   ----------

   function Next (C : Client_Session) return Request
   is
      procedure C_Next (T :     System.Address;
                        R : out Standard.C.Block.Request) with
         Import,
         Convention    => C,
         External_Name => "block_client_next";
      R : Standard.C.Block.Request;
   begin
      C_Next (C.Instance, R);
      return Convert_Request (R);
   end Next;

   ----------
   -- Read --
   ----------

   procedure Read (C : in out Client_Session;
                   R :        Request;
                   B :    out Buffer)
   is
      procedure C_Read (T   :     System.Address;
                        Req :     System.Address;
                        Buf : out Buffer) with
         Import,
         Convention    => C,
         External_Name => "block_client_read";
      Req : Standard.C.Block.Request := Convert_Request (R);
   begin
      C_Read (C.Instance, Req'Address, B);
   end Read;

   -------------
   -- Release --
   -------------

   pragma Warnings (Off, "formal parameter ""R"" is not modified");
   --  R is not modified but the platform state has changed and R becomes invalid on the platform
   procedure Release (C : in out Client_Session;
                      R : in out Request)
   is
      pragma Warnings (On, "formal parameter ""R"" is not modified");
      procedure C_Release (T   : System.Address;
                           Req : System.Address) with
         Import,
         Convention    => C,
         External_Name => "block_client_release";
      Req : Standard.C.Block.Request := Convert_Request (R);
   begin
      C_Release (C.Instance, Req'Address);
   end Release;

   --------------
   -- Writable --
   --------------

   function Writable (C : Client_Session) return Boolean is
      function C_Writable (T : System.Address) return Integer with
         Import,
         Convention    => C,
         External_Name => "block_client_writable";
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
         External_Name => "block_client_block_count";
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
         External_Name => "block_client_block_size";
   begin
      return C_Block_Size (C.Instance);
   end Block_Size;

   ---------------------------
   -- Maximal_Transfer_Size --
   ---------------------------

   function Maximal_Transfer_Size (C : Client_Session) return Byte_Length is
      function C_Maximal_Transfer_Size (T : System.Address) return Byte_Length with
         Import,
         Convention    => C,
         External_Name => "block_client_maximal_transfer_size";
   begin
      return C_Maximal_Transfer_Size (C.Instance);
   end Maximal_Transfer_Size;

   function Convert_Request (R : Request) return C.Block.Request
   is
      subtype C_Private_Data is C.Uint8_T_Array (1 .. 16);
      function Convert_Priv is new Ada.Unchecked_Conversion (Private_Data, C_Private_Data);
      Req : C.Block.Request := (Kind   => (case R.Kind is
                                           when None  => C.Block.None,
                                           when Read  => C.Block.Read,
                                           when Write => C.Block.Write,
                                           when Sync  => C.Block.Sync,
                                           when Trim  => C.Block.Trim),
                                Priv   => Convert_Priv (R.Priv),
                                Start  => 0,
                                Length => 0,
                                Status => C.Block.Raw);
   begin
      case R.Kind is
         when None =>
            null;
         when Read .. Trim =>
            Req.Start  := C.Uint64_T (R.Start);
            Req.Length := C.Uint64_T (R.Length);
            Req.Status := (case R.Status is
                           when Raw          => C.Block.Raw,
                           when Ok           => C.Block.Ok,
                           when Error        => C.Block.Error,
                           when Acknowledged => C.Block.Acknowledged);
      end case;
      return Req;
   end Convert_Request;

   function Convert_Request (R : C.Block.Request) return Request
   is
      subtype C_Private_Data is C.Uint8_T_Array (1 .. 16);
      function Convert_Priv is new Ada.Unchecked_Conversion (C_Private_Data,
                                                             Private_Data);
      Req : Request (Kind => (case R.Kind is
                              when C.Block.None  => None,
                              when C.Block.Read  => Read,
                              when C.Block.Write => Write,
                              when C.Block.Sync  => Sync,
                              when C.Block.Trim  => Trim,
                              when others        => None));
   begin
      Req.Priv := Convert_Priv (R.Priv);
      case Req.Kind is
         when None =>
            null;
         when Read .. Trim =>
            Req.Start  := Id (R.Start);
            Req.Length := Count (R.Length);
            Req.Status := (case R.Status is
                           when C.Block.Raw          => Raw,
                           when C.Block.Ok           => Ok,
                           when C.Block.Error        => Error,
                           when C.Block.Acknowledged => Acknowledged,
                           when others               => Error);
      end case;
      return Req;
   end Convert_Request;

end Cai.Block.Client;
