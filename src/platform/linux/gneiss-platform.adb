
with Ada.Unchecked_Conversion;
with Gneiss.Internal.Types;

package body Gneiss.Platform with
   SPARK_Mode
is

   function Convert is new Ada.Unchecked_Conversion
      (Gneiss.Types.Capability, Gneiss.Internal.Types.Capability);

   procedure Set_Status (C : Gneiss.Types.Capability;
                         S : Integer)
   is
      procedure Set (St : Integer) with
         Import,
         Address => Convert (C).Set_Status;
   begin
      Set (S);
   end Set_Status;

   procedure Register_Service (C       :     Gneiss.Types.Capability;
                               Kind    :     RFLX.Session.Kind_Type;
                               Fp      :     System.Address;
                               Success : out Boolean)
   is
      procedure Register (K :     RFLX.Session.Kind_Type;
                          F :     System.Address;
                          S : out Boolean) with
         Import,
         Address => Convert (C).Register_Service;
   begin
      Register (Kind, Fp, Success);
   end Register_Service;

   procedure Register_Initializer (Session    : in out Session_Type;
                                   Capability :        Gneiss.Types.Capability;
                                   Kind       :        RFLX.Session.Kind_Type;
                                   Label      :        String) with
      SPARK_Mode => Off
   is
      procedure Register (K : RFLX.Session.Kind_Type;
                          F : System.Address;
                          C : System.Address;
                          S : out Boolean) with
         Import,
         Address => Convert (Capability).Register_Initializer;
      Success : Boolean;
   begin
      Register (Kind, Initialize'Address, Session'Address, Success);
      if not Success then
         Initialize (Session, Label, Success, -1);
      end if;
   end Register_Initializer;

   function Get_Broker (C : Gneiss.Types.Capability) return Integer is
      (Convert (C).Filedesc);

   function Get_Epoll (C : Gneiss.Types.Capability) return Gneiss.Epoll.Epoll_Fd is
      (Convert (C).Epoll_Fd);

end Gneiss.Platform;
