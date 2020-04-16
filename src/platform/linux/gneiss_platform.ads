
with Gneiss_Epoll;
private with System;

package Gneiss_Platform with
   SPARK_Mode
is

   type Event_Cap is private;
   type Set_Status_Cap is private;

   function Is_Valid (Cap : Event_Cap) return Boolean;
   function Is_Valid (Cap : Set_Status_Cap) return Boolean;

   procedure Invalidate (Cap : in out Event_Cap) with
      Post => not Is_Valid (Cap);

   generic
      type Event_Context is limited private;
      type Error_Context is limited private;
      with procedure Event (Ctx : in out Event_Context;
                            Fd  :        Integer);
      with procedure Error (Ctx : in out Error_Context;
                            Fd  :        Integer);
   function Create_Event_Cap (Ev_Ctx : Event_Context;
                              Er_Ctx : Error_Context;
                              Fd     : Integer) return Event_Cap with
      Post => Is_Valid (Create_Event_Cap'Result);

   procedure Call (Cap : Event_Cap;
                   Ev  : Gneiss_Epoll.Event_Type);

   generic
      --  @param S  Status code (0 - Success, 1 - Failure)
      with procedure Set_Status (S : Integer);
   function Create_Set_Status_Cap return Set_Status_Cap with
      Post => Is_Valid (Create_Set_Status_Cap'Result);

   procedure Call (Cap : Set_Status_Cap;
                   S   : Integer) with
      Pre => Is_Valid (Cap);

private

   type Event_Cap is record
      Event_Adr : System.Address := System.Null_Address;
      Event_Ctx : System.Address := System.Null_Address;
      Error_Adr : System.Address := System.Null_Address;
      Error_Ctx : System.Address := System.Null_Address;
      Fd        : Integer        := -1;
   end record;

   type Set_Status_Cap is record
      Address : System.Address := System.Null_Address;
   end record;

end Gneiss_Platform;
