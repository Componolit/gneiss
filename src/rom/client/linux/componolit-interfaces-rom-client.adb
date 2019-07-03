
with System;
with C;

package body Componolit.Interfaces.Rom.Client
is

   use type System.Address;
   use type C.Uint64_T;

   procedure C_Parse (Ptr : System.Address;
                      Len : C.Uint64_T);

   function Create return Client_Session
   is
   begin
      return Client_Session'(Ifd   => -1,
                             Parse => System.Null_Address,
                             Cap   => System.Null_Address,
                             Name  => System.Null_Address);
   end Create;

   function Initialized (C : Client_Session) return Boolean
   is
      (C.Ifd       >= 0
       and C.Parse /= System.Null_Address
       and C.Cap   /= System.Null_Address
       and C.Name  /= System.Null_Address);

   procedure Initialize (C    : in out Client_Session;
                         Cap  :        Componolit.Interfaces.Types.Capability;
                         Name :        String := "") with
      SPARK_Mode => Off
   is
      procedure C_Initialize (S : in out Client_Session;
                              C : Componolit.Interfaces.Types.Capability;
                              L : System.Address;
                              N : System.Address) with
         Import,
         Convention    => C,
         External_Name => "configuration_client_initialize",
         Global        => null;
      C_Name      : constant String         := Name & Character'First;
      C_Name_Addr : constant System.Address := (if Name'Length > 0 then C_Name'Address else System.Null_Address);
   begin
      C_Initialize (C, Cap, C_Parse'Address, C_Name_Addr);
   end Initialize;

   procedure Load (C : in out Client_Session)
   is
      procedure C_Load (C : in out Client_Session) with
         Import,
         Convention    => C,
         External_Name => "configuration_client_load",
         Global        => null,
         Pre           => Initialized (C),
         Post          => Initialized (C);
   begin
      C_Load (C);
   end Load;

   procedure Parse_Deref (First : Index;
                          Last  : Index;
                          Ptr   : System.Address) with
      Pre => Last >= First and Ptr /= System.Null_Address;

   procedure Parse_Deref (First : Index;
                          Last  : Index;
                          Ptr   : System.Address) with
      SPARK_Mode => Off
   is
      Data : Buffer (First .. Last) with
         Address => Ptr;
   begin
      Parse (Data);
   end Parse_Deref;

   procedure C_Parse (Ptr : System.Address;
                      Len : C.Uint64_T)
   is
      Elen  : constant C.Uint64_T := Len / (Element'Size / 8);
   begin
      if
         Ptr /= System.Null_Address
         and then Elen > 0
         and then Elen < C.Uint64_T (Index'Last)
         and then C.Uint64_T (Index'Last) > C.Uint64_T (Index'First) + Elen
      then
         Parse_Deref (Index'First, Index'First + Index (Elen) - 1, Ptr);
      end if;
   end C_Parse;

   procedure Finalize (C : in out Client_Session)
   is
      procedure C_Finalize (C : in out Client_Session) with
         Import,
         Convention    => C,
         External_Name => "configuration_client_finalize",
         Global        => null;
      --  FIXME: model platform state (freeing memory)
   begin
      C_Finalize (C);
      C.Ifd   := -1;
      C.Parse := System.Null_Address;
      C.Cap   := System.Null_Address;
      C.Name  := System.Null_Address;
   end Finalize;

end Componolit.Interfaces.Rom.Client;
