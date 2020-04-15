
package body Gneiss_Platform with
   SPARK_Mode
is
   use type System.Address;

   function Is_Valid (Cap : Event_Cap) return Boolean is
      (Cap.Event_Adr /= System.Null_Address
       and then Cap.Event_Ctx /= System.Null_Address
       and then Cap.Error_Adr /= System.Null_Address
       and then Cap.Error_Ctx /= System.Null_Address);

   function Is_Valid (Cap : Set_Status_Cap) return Boolean is
      (Cap.Address /= System.Null_Address);

   procedure Invalidate (Cap : in out Event_Cap)
   is
   begin
      Cap.Event_Adr := System.Null_Address;
      Cap.Event_Ctx := System.Null_Address;
      Cap.Error_Adr := System.Null_Address;
      Cap.Error_Ctx := System.Null_Address;
      Cap.Fd        := -1;
   end Invalidate;

   function Create_Event_Cap (Ev_Ctx : Event_Context;
                              Er_Ctx : Error_Context;
                              Fd     : Integer) return Event_Cap with
      SPARK_Mode => Off
   is
   begin
      return Event_Cap'(Event_Adr => Event'Address,
                        Event_Ctx => Ev_Ctx'Address,
                        Error_Adr => Error'Address,
                        Error_Ctx => Er_Ctx'Address,
                        Fd        => Fd);
   end Create_Event_Cap;

   procedure Call (Cap : Event_Cap;
                   Ev  : Gneiss_Epoll.Event_Type) with
      SPARK_Mode => Off
   is
      procedure Event (Context : System.Address;
                       Fd      : Integer) with
         Import,
         Address => Cap.Event_Adr;
      procedure Error (Context : System.Address;
                       Fd      : Integer) with
         Import,
         Address => Cap.Error_Adr;
   begin
      case Ev is
         when Gneiss_Epoll.Epoll_Ev =>
            Event (Cap.Event_Ctx, Cap.Fd);
         when Gneiss_Epoll.Epoll_Er =>
            Error (Cap.Error_Ctx, Cap.Fd);
      end case;
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
