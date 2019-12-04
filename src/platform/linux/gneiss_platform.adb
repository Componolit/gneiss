
package body Gneiss_Platform with
   SPARK_Mode
is
   use type System.Address;

   function Is_Valid (Cap : Initializer_Cap) return Boolean is
      (Cap.Address /= System.Null_Address and then Cap.Cap /= System.Null_Address);

   procedure Invalidate (Cap : in out Initializer_Cap)
   is
   begin
      Cap.Address := System.Null_Address;
      Cap.Cap     := System.Null_Address;
   end Invalidate;

   function Is_Valid (Cap : Dispatcher_Cap) return Boolean is
      (Cap.Address /= System.Null_Address and then Cap.Cap /= System.Null_Address);

   procedure Invalidate (Cap : in out Dispatcher_Cap)
   is
   begin
      Cap.Address := System.Null_Address;
      Cap.Cap     := System.Null_Address;
   end Invalidate;

   function Create_Set_Status_Cap return Set_Status_Cap with
      SPARK_Mode => Off
   is
   begin
      return Set_Status_Cap'(Address => Set_Status'Address);
   end Create_Set_Status_Cap;

   procedure Call (Cap : Set_Status_Cap;
                   S   : Integer)
   is
      procedure Set_Status (S : Integer) with
         Import,
         Address => Cap.Address;
   begin
      Set_Status (S);
   end Call;

   function Create_Initializer_Cap (S : Session_Type) return Initializer_Cap with
      SPARK_Mode => Off
   is
   begin
      return Initializer_Cap'(Address => Initializer'Address,
                              Cap     => S'Address);
   end Create_Initializer_Cap;

   procedure Initializer_Call (Cap     : Initializer_Cap;
                               Label   : String;
                               Success : Boolean;
                               Fd      : Integer)
   is
      procedure Initializer (Ssn : in out Session_Type;
                             Lbl :        String;
                             Suc :        Boolean;
                             Fdr :        Integer) with
         Import,
         Address => Cap.Address;
      Session : Session_Type with
         Import,
         Address => Cap.Cap;
   begin
      Initializer (Session, Label, Success, Fd);
   end Initializer_Call;

   function Create_Register_Initializer_Cap return Register_Initializer_Cap with
      SPARK_Mode => Off
   is
   begin
      return Register_Initializer_Cap'(Address => Register'Address);
   end Create_Register_Initializer_Cap;

   procedure Call (Cap     :     Register_Initializer_Cap;
                   I_Cap   :     Initializer_Cap;
                   Kind    :     RFLX.Session.Kind_Type;
                   Success : out Boolean)
   is
      procedure Register (K :     RFLX.Session.Kind_Type;
                          I :     Initializer_Cap;
                          S : out Boolean) with
         Import,
         Address => Cap.Address;
   begin
      Register (Kind, I_Cap, Success);
   end Call;

   function Create_Register_Service_Cap return Register_Service_Cap with
      SPARK_Mode => Off
   is
   begin
      return Register_Service_Cap'(Address => Register'Address);
   end Create_Register_Service_Cap;

   procedure Call (Cap     :     Register_Service_Cap;
                   Kind    :     RFLX.Session.Kind_Type;
                   D_Cap   :     Dispatcher_Cap;
                   Success : out Boolean)
   is
      procedure Register (K :     RFLX.Session.Kind_Type;
                          D :     Dispatcher_Cap;
                          S : out Boolean) with
         Import,
         Address => Cap.Address;
   begin
      Register (Kind, D_Cap, Success);
   end Call;

   function Create_Dispatcher_Cap (S : Session_Type) return Dispatcher_Cap with
      SPARK_Mode => Off
   is
   begin
      return Dispatcher_Cap'(Address => Dispatch'Address,
                             Cap     => S'Address);
   end Create_Dispatcher_Cap;

   procedure Dispatcher_Call (Cap   : Dispatcher_Cap;
                              Name  : String;
                              Label : String)
   is
      procedure Dispatch (S : in out Session_Type;
                          N :        String;
                          L :        String) with
         Import,
         Address => Cap.Address;
      Session : Session_Type with
         Import,
         Address => Cap.Cap;
   begin
      Dispatch (Session, Name, Label);
   end Dispatcher_Call;

end Gneiss_Platform;
