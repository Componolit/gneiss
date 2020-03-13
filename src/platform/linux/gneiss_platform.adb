
package body Gneiss_Platform with
   SPARK_Mode
is
   use type System.Address;

   function Is_Valid (Cap : Event_Cap) return Boolean is
      (Cap.Address /= System.Null_Address and then Cap.Context /= System.Null_Address);

   function Is_Valid (Cap : Set_Status_Cap) return Boolean is
      (Cap.Address /= System.Null_Address);

   procedure Invalidate (Cap : in out Event_Cap)
   is
   begin
      Cap.Address := System.Null_Address;
      Cap.Context := System.Null_Address;
   end Invalidate;

   function Create_Event_Cap (C : Context) return Event_Cap with
      SPARK_Mode => Off
   is
   begin
      return Event_Cap'(Address => Event'Address, Context => C'Address);
   end Create_Event_Cap;

   procedure Call (Cap : Event_Cap;
                   Ev  : Gneiss_Epoll.Event_Type) with
      SPARK_Mode => Off
   is
      procedure Event (Context : System.Address;
                       E       : Gneiss_Epoll.Event_Type) with
         Import,
         Address => Cap.Address;
   begin
      Event (Cap.Context, Ev);
   end Call;

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

end Gneiss_Platform;
