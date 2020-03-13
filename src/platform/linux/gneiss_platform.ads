
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
      type Context is limited private;
      with procedure Event (Ctx : in out Context;
                            Ev  :        Gneiss_Epoll.Event_Type);
   function Create_Event_Cap (C : Context) return Event_Cap;

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
      Address : System.Address := System.Null_Address;
      Context : System.Address := System.Null_Address;
   end record;

   type Set_Status_Cap is record
      Address : System.Address := System.Null_Address;
   end record;

end Gneiss_Platform;
