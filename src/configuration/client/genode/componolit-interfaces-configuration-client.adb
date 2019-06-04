
with System;
with Cxx;
with Cxx.Genode;
with Cxx.Configuration.Client;

package body Componolit.Interfaces.Configuration.Client with
   SPARK_Mode => Off
is

   function Create return Client_Session
   is
   begin
      return Client_Session'(Instance => Cxx.Configuration.Client.Constructor);
   end Create;

   procedure C_Parse (Ptr : System.Address;
                      Len : Cxx.Genode.Uint64_T);

   procedure Initialize (C   : in out Client_Session;
                         Cap :        Componolit.Interfaces.Types.Capability)
   is
   begin
      Cxx.Configuration.Client.Initialize (C.Instance, Cap, C_Parse'Address);
   end Initialize;

   function Initialized (C : Client_Session) return Boolean
   is
      use type Cxx.Bool;
   begin
      return Cxx.Configuration.Client.Initialized (C.Instance) = Cxx.Bool'Val (1);
   end Initialized;

   procedure Load (C : in out Client_Session)
   is
   begin
      Cxx.Configuration.Client.Load (C.Instance);
   end Load;

   procedure Finalize (C : in out Client_Session)
   is
   begin
      Cxx.Configuration.Client.Finalize (C.Instance);
   end Finalize;

   procedure C_Parse (Ptr : System.Address;
                      Len : Cxx.Genode.Uint64_T)
   is
      use type System.Address;
      use type Cxx.Genode.Uint64_T;
      Empty : Buffer (1 .. 0);
      Elen  : constant Cxx.Genode.Uint64_T := Len / (Element'Size / 8);
   begin
      if
         Ptr /= System.Null_Address
         and Elen > 0
         and Cxx.Genode.Uint64_T (Index'Last) > Cxx.Genode.Uint64_T (Index'First) + Elen
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

end Componolit.Interfaces.Configuration.Client;