
with Ada.Unchecked_Conversion;
with System;
with C;
with C.Block;

use all type System.Address;

package body Componolit.Interfaces.Block.Client
is

   function Convert_Request (R : Request) return C.Block.Request;
   function Convert_Request (R : C.Block.Request) return Request with
      Pre => R.Length in C.Uint64_T (Count'First) .. C.Uint64_T (Count'Last);

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

   function Get_Instance (C : Client_Session) return Client_Instance is
      function C_Get_Instance (T : System.Address) return Client_Instance with
         Import,
         Convention    => CPP,
         External_Name => "block_client_get_instance",
         Global        => null;
   begin
      return C_Get_Instance (C.Instance);
   end Get_Instance;

   -----------------
   -- Initialized --
   -----------------

   function Initialized (C : Client_Session) return Boolean is
      (C.Instance /= System.Null_Address);

   ----------------
   -- Initialize --
   ----------------

   procedure Crw (C : Client_Instance;
                  K : Standard.C.Block.Request_Kind;
                  B : Size;
                  S : Id;
                  L : Count;
                  D : System.Address);

   procedure Crw (C : Client_Instance;
                  K : Standard.C.Block.Request_Kind;
                  B : Size;
                  S : Id;
                  L : Count;
                  D : System.Address) with
      SPARK_Mode => Off
   is
      Data : Buffer (1 .. B * L) with
         Address => D;
   begin
      case K is
         when Standard.C.Block.Read =>
            Read (C, B, S, L, Data);
         when Standard.C.Block.Write =>
            Write (C, B, S, L, Data);
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

   -----------
   -- Ready --
   -----------

   function Ready (C : Client_Session;
                   R : Request) return Boolean with
      SPARK_Mode => Off
   is
      function C_Ready (T   : System.Address;
                        Req : System.Address) return Integer with
         Import,
         Convention    => C,
         External_Name => "block_client_ready",
         Global        => null;
      Req : Standard.C.Block.Request := Convert_Request (R);
   begin
      return C_Ready (C.Instance, Req'Address) = 1;
   end Ready;

   ---------------
   -- Supported --
   ---------------

   function C_Supported (T   : System.Address;
                         Req : Standard.C.Block.Request_Kind) return Integer with
      Import,
      Convention     => C,
      External_Name  => "block_client_supported",
      Global         => null;

   procedure C_Supported (Cs   : Client_Session;
                          Req1 : Standard.C.Block.Request_Kind;
                          Req2 : Request_Kind) with
      Ghost,
      Annotate => (GNATprove, Terminating),
      Post => (C_Supported (Cs.Instance, Req1) = 1) = Supported (Get_Instance (Cs), Req2);

   procedure C_Supported (Cs   : Client_Session;
                          Req1 : Standard.C.Block.Request_Kind;
                          Req2 : Request_Kind) with
      SPARK_Mode => Off
   is
      pragma Unreferenced (Cs);
      pragma Unreferenced (Req1);
      pragma Unreferenced (Req2);
   begin
      null;
   end C_Supported;

   function Supported (C : Client_Session;
                       R : Request_Kind) return Boolean
   is
   begin
      if R = None or R = Undefined then
         return False;
      end if;
      C_Supported (C, Standard.C.Block.Read, Read);
      C_Supported (C, Standard.C.Block.Write, Write);
      C_Supported (C, Standard.C.Block.Sync, Sync);
      C_Supported (C, Standard.C.Block.Trim, Trim);
      return C_Supported (C.Instance, (case R is
                                       when None      => Standard.C.Block.None,
                                       when Read      => Standard.C.Block.Read,
                                       when Write     => Standard.C.Block.Write,
                                       when Sync      => Standard.C.Block.Sync,
                                       when Trim      => Standard.C.Block.Trim,
                                       when Undefined => Standard.C.Block.None)) = 1;
   end Supported;

   ------------------
   -- Enqueue_Read --
   ------------------

   procedure Enqueue (C : in out Client_Session;
                      R :        Request) with
      SPARK_Mode => Off
   is
      procedure C_Enqueue (T   : System.Address;
                           Req : System.Address) with
         Import,
         Convention    => C,
         External_Name => "block_client_enqueue",
         Global        => null;
      Req : Standard.C.Block.Request := Convert_Request (R);
   begin
      C_Enqueue (C.Instance, Req'Address);
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
   -- Next --
   ----------

   function Next (C : Client_Session) return Request
   is
      use type Standard.C.Uint64_T;
      use type Standard.C.Block.Request_Kind;
      use type Standard.C.Block.Request_Status;
      procedure C_Next (T :     System.Address;
                        R : out Standard.C.Block.Request) with
         Import,
         Convention    => C,
         External_Name => "block_client_next",
         Global        => null;
      R : Standard.C.Block.Request;
   begin
      C_Next (C.Instance, R);
      if R.Kind = Standard.C.Block.None then
         R.Start := 0;
         R.Length := 0;
      else
         if
            R.Length > Standard.C.Uint64_T (Count'Last)
         then
            R.Length := 0;
            R.Status := Standard.C.Block.Error;
         end if;
      end if;
      if R.Status /= Standard.C.Block.Ok then
         R.Status := Standard.C.Block.Error;
      end if;
      return Convert_Request (R);
   end Next;

   ----------
   -- Read --
   ----------

   procedure Read (C : in out Client_Session;
                   R :        Request) with
      SPARK_Mode => Off
   is
      procedure C_Read (T   :     System.Address;
                        Req :     System.Address) with
         Import,
         Convention    => C,
         External_Name => "block_client_read",
         Global        => null;
      Req : Standard.C.Block.Request := Convert_Request (R);
   begin
      C_Read (C.Instance, Req'Address);
   end Read;

   -------------
   -- Release --
   -------------

   pragma Warnings (Off, "formal parameter ""R"" is not modified");
   --  R is not modified but the platform state has changed and R becomes invalid on the platform
   procedure Release (C : in out Client_Session;
                      R : in out Request) with
      SPARK_Mode => Off
   is
      pragma Warnings (On, "formal parameter ""R"" is not modified");
      procedure C_Release (T   : System.Address;
                           Req : System.Address) with
         Import,
         Convention    => C,
         External_Name => "block_client_release",
         Global        => null;
      Req : Standard.C.Block.Request := Convert_Request (R);
   begin
      if R.Kind /= None and R.Kind /= Undefined then
         C_Release (C.Instance, Req'Address);
      end if;
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

   function Convert_Request (R : Request) return C.Block.Request
   is
      subtype C_Private_Data is C.Uint8_T_Array (1 .. 16);
      function Convert_Priv is new Ada.Unchecked_Conversion (Private_Data, C_Private_Data);
      Req : C.Block.Request := (Kind   => (case R.Kind is
                                           when None      => C.Block.None,
                                           when Read      => C.Block.Read,
                                           when Write     => C.Block.Write,
                                           when Sync      => C.Block.Sync,
                                           when Trim      => C.Block.Trim,
                                           when Undefined => C.Block.None),
                                Priv   => Convert_Priv (R.Priv),
                                Start  => 0,
                                Length => 0,
                                Status => C.Block.Raw);
   begin
      case R.Kind is
         when None | Undefined =>
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

   subtype C_Private_Data is C.Uint8_T_Array (1 .. 16);
   function Convert_Priv is new Ada.Unchecked_Conversion (C_Private_Data,
                                                          Private_Data);

   function Convert_Request (R : C.Block.Request) return Request
   is
      (case R.Kind is
         when C.Block.None =>
            Request'(Kind => None, Priv => Convert_Priv (R.Priv)),
         when C.Block.Read =>
            Request'(Kind => Read,
                     Priv => Convert_Priv (R.Priv),
                     Start => Id (R.Start),
                     Length => Count (R.Length),
                     Status => (case R.Status is
                           when C.Block.Raw          => Raw,
                           when C.Block.Ok           => Ok,
                           when C.Block.Error        => Error,
                           when C.Block.Acknowledged => Acknowledged,
                           when others               => Error)),
         when C.Block.Write =>
            Request'(Kind => Write,
                     Priv => Convert_Priv (R.Priv),
                     Start => Id (R.Start),
                     Length => Count (R.Length),
                     Status => (case R.Status is
                           when C.Block.Raw          => Raw,
                           when C.Block.Ok           => Ok,
                           when C.Block.Error        => Error,
                           when C.Block.Acknowledged => Acknowledged,
                           when others               => Error)),
         when C.Block.Sync =>
            Request'(Kind => Sync,
                     Priv => Convert_Priv (R.Priv),
                     Start => Id (R.Start),
                     Length => Count (R.Length),
                     Status => (case R.Status is
                           when C.Block.Raw          => Raw,
                           when C.Block.Ok           => Ok,
                           when C.Block.Error        => Error,
                           when C.Block.Acknowledged => Acknowledged,
                           when others               => Error)),
         when C.Block.Trim =>
            Request'(Kind => Trim,
                     Priv => Convert_Priv (R.Priv),
                     Start => Id (R.Start),
                     Length => Count (R.Length),
                     Status => (case R.Status is
                           when C.Block.Raw          => Raw,
                           when C.Block.Ok           => Ok,
                           when C.Block.Error        => Error,
                           when C.Block.Acknowledged => Acknowledged,
                           when others               => Error)),
         when others =>
            Request'(Kind => Undefined, Priv => Convert_Priv (R.Priv))
      );

end Componolit.Interfaces.Block.Client;
