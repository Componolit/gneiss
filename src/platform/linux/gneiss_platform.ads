
with RFLX.Session;
private with System;

package Gneiss_Platform with
   SPARK_Mode
is

   type Set_Status_Cap is private;
   type Initializer_Cap is private;
   type Register_Initializer_Cap is private;
   type Register_Service_Cap is private;
   type Dispatcher_Cap is private;

   function Is_Valid (Cap : Set_Status_Cap) return Boolean;
   function Is_Valid (Cap : Initializer_Cap) return Boolean;
   function Is_Valid (Cap : Dispatcher_Cap) return Boolean;
   function Is_Valid (Cap : Register_Initializer_Cap) return Boolean;
   function Is_Valid (Cap : Register_Service_Cap) return Boolean;

   procedure Invalidate (Cap : in out Initializer_Cap) with
      Post => not Is_Valid (Cap);

   procedure Invalidate (Cap : in out Dispatcher_Cap) with
      Post => not Is_Valid (Cap);

   generic
      --  @param S  Status code (0 - Success, 1 - Failure)
      with procedure Set_Status (S : Integer);
   function Create_Set_Status_Cap return Set_Status_Cap with
      Post => Is_Valid (Create_Set_Status_Cap'Result);

   procedure Call (Cap : Set_Status_Cap;
                   S   : Integer) with
      Pre => Is_Valid (Cap);

   generic
      type Session_Type is limited private;
      with procedure Initializer (Session : in out Session_Type;
                                  Label   :        String;
                                  Success :        Boolean;
                                  Fd      :        Integer);
   function Create_Initializer_Cap (S : Session_Type) return Initializer_Cap with
      Post => Is_Valid (Create_Initializer_Cap'Result);

   generic
      type Session_Type is limited private;
   procedure Initializer_Call (Cap     : Initializer_Cap;
                               Label   : String;
                               Success : Boolean;
                               Fd      : Integer) with
      Pre => Is_Valid (Cap);

   generic
      with procedure Register (K :     RFLX.Session.Kind_Type;
                               I :     Initializer_Cap;
                               S : out Boolean);
   function Create_Register_Initializer_Cap return Register_Initializer_Cap with
      Post => Is_Valid (Create_Register_Initializer_Cap'Result);

   procedure Call (Cap     :     Register_Initializer_Cap;
                   I_Cap   :     Initializer_Cap;
                   Kind    :     RFLX.Session.Kind_Type;
                   Success : out Boolean) with
      Pre => Is_Valid (Cap);

   generic
      with procedure Register (K :     RFLX.Session.Kind_Type;
                               D :     Dispatcher_Cap;
                               S : out Boolean);
   function Create_Register_Service_Cap return Register_Service_Cap with
      Post => Is_Valid (Create_Register_Service_Cap'Result);

   procedure Call (Cap     :     Register_Service_Cap;
                   Kind    :     RFLX.Session.Kind_Type;
                   D_Cap   :     Dispatcher_Cap;
                   Success : out Boolean) with
      Pre => Is_Valid (Cap);

   generic
      type Session_Type is limited private;
      with procedure Dispatch (Session : in out Session_Type;
                               Name    :        String;
                               Label   :        String;
                               Fd      : in out Integer);
   function Create_Dispatcher_Cap (S : Session_Type) return Dispatcher_Cap with
      Post => Is_Valid (Create_Dispatcher_Cap'Result);

   generic
      type Session_Type is limited private;
   procedure Dispatcher_Call (Cap   :        Dispatcher_Cap;
                              Name  :        String;
                              Label :        String;
                              Fd    : in out Integer) with
      Pre => Is_Valid (Cap);

private

   type Set_Status_Cap is record
      Address : System.Address := System.Null_Address;
   end record;

   type Initializer_Cap is record
      Address : System.Address := System.Null_Address;
      Cap     : System.Address := System.Null_Address;
   end record;

   type Register_Initializer_Cap is record
      Address : System.Address := System.Null_Address;
   end record;

   type Register_Service_Cap is record
      Address : System.Address := System.Null_Address;
   end record;

   type Dispatcher_Cap is record
      Address : System.Address := System.Null_Address;
      Cap     : System.Address := System.Null_Address;
   end record;

end Gneiss_Platform;
