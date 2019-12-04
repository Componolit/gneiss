
package body Gneiss.Platform with
   SPARK_Mode
is

   procedure Set_Status (C : Capability;
                         S : Integer)
   is
      procedure Set (St : Integer) with
         Import,
         Address => C.Set_Status;
   begin
      Set (S);
   end Set_Status;

   procedure Register_Service (C       :     Capability;
                               Kind    :     RFLX.Session.Kind_Type;
                               Fp      :     System.Address;
                               Success : out Boolean)
   is
      procedure Register (K :     RFLX.Session.Kind_Type;
                          F :     System.Address;
                          S : out Boolean) with
         Import,
         Address => C.Register_Service;
   begin
      Register (Kind, Fp, Success);
   end Register_Service;

   procedure Register_Initializer (Session : in out Session_Type;
                                   Cap     :        Capability;
                                   Kind    :        RFLX.Session.Kind_Type;
                                   Label   :        String) with
      SPARK_Mode => Off
   is
      procedure Register (K : RFLX.Session.Kind_Type;
                          F : System.Address;
                          C : System.Address;
                          S : out Boolean) with
         Import,
         Address => Cap.Register_Initializer;
      Success : Boolean;
   begin
      Register (Kind, Initialize'Address, Session'Address, Success);
      if not Success then
         Initialize (Session, Label, Success, -1);
      end if;
   end Register_Initializer;

end Gneiss.Platform;
