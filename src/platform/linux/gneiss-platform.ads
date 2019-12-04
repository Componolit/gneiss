
with System;
with RFLX.Session;

package Gneiss.Platform with
   SPARK_Mode
is

   --  Set the application return state
   --
   --  @param C  System capability
   --  @param S  Status code (0 - Success, 1 - Failure)
   procedure Set_Status (C : Capability;
                         S : Integer);

   procedure Register_Service (C       :     Capability;
                               Kind    :     RFLX.Session.Kind_Type;
                               Fp      :     System.Address;
                               Success : out Boolean);

   generic
      type Session_Type is limited private;
      with procedure Initialize (Session  : in out Session_Type;
                                 Label    :        String;
                                 Success  :        Boolean;
                                 Filedesc :        Integer);
   procedure Register_Initializer (Session : in out Session_Type;
                                   Cap     :        Capability;
                                   Kind    :        RFLX.Session.Kind_Type;
                                   Label   :        String);

end Gneiss.Platform;
