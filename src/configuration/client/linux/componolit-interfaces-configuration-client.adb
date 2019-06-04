
with System;
with C;

package body Componolit.Interfaces.Configuration.Client with
   SPARK_Mode => Off
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
                             Cap   => System.Null_Address);
   end Create;

   function Initialized (C : Client_Session) return Boolean
   is
   begin
      return C.Ifd >= 0
             and C.Parse /= System.Null_Address
             and C.Cap /= System.Null_Address;
   end Initialized;

   procedure Initialize (C   : in out Client_Session;
                         Cap :        Componolit.Interfaces.Types.Capability)
   is
      procedure C_Initialize (S : in out Client_Session;
                              C : Componolit.Interfaces.Types.Capability;
                              L : System.Address) with
         Import,
         Convention => C,
         External_Name => "configuration_client_initialize";
   begin
      C_Initialize (C, Cap, C_Parse'Address);
   end Initialize;

   procedure Load (C : in out Client_Session)
   is
      procedure C_Load (C : in out Client_Session) with
         Import,
         Convention => C,
         External_Name => "configuration_client_load";
   begin
      C_Load (C);
   end Load;

   procedure C_Parse (Ptr : System.Address;
                      Len : C.Uint64_T)
   is
      Empty : Buffer (1 .. 0);
      Elen  : constant C.Uint64_T := Len / (Element'Size / 8);
   begin
      if
         Ptr /= System.Null_Address
         and Elen > 0
         and C.Uint64_T (Index'Last) > C.Uint64_T (Index'First) + Elen
      then
         declare
            Data : Buffer (Index'First .. Index'First + Index (Elen) - 1) with
              Address => Ptr;
         begin
            Parse (Data);
         end;
      else
         Parse (Empty);
      end if;
   end C_Parse;

   procedure Finalize (C : in out Client_Session)
   is
      procedure C_Finalize (C : in out Client_Session) with
         Import,
         Convention => C,
         External_Name => "configuration_client_finalize";
   begin
      C_Finalize (C);
   end Finalize;

end Componolit.Interfaces.Configuration.Client;
