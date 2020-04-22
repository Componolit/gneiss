with Gneiss_Protocol.Session;
private with System;

package Gneiss_Internal with
   SPARK_Mode,
   Abstract_State => Platform_State,
   Initializes => Platform_State,
   Elaborate_Body
is

   type File_Descriptor is new Integer;

   type Epoll_Fd is new Integer;

   type Event_Type is (Epoll_Ev, Epoll_Er);

   type Fd_Array is array (Natural range <>) of File_Descriptor;

   type Session_Label is record
      Last  : Natural           := 0;
      Value : String (1 .. 255) := (others => Character'First);
   end record with
      Dynamic_Predicate => Last <= Value'Last;

   type Broker_Message (Valid : Boolean := False) is record
      case Valid is
         when True =>
            Action : Gneiss_Protocol.Session.Action_Type;
            Kind   : Gneiss_Protocol.Session.Kind_Type;
            Name   : Session_Label;
            Label  : Session_Label;
         when False =>
            null;
      end case;
   end record;

   function Valid (Fd : File_Descriptor) return Boolean is (Fd > -1);

   function Valid (Efd : Epoll_Fd) return Boolean is (Efd >= 0);

   type Event_Cap is private;

   type Set_Status_Cap is private;

   Invalid_Event_Cap      : constant Event_Cap;

   Invalid_Set_Status_Cap : constant Set_Status_Cap;

   function Valid (Cap : Event_Cap) return Boolean;

   function Valid (Cap : Set_Status_Cap) return Boolean;

   type Capability is record
      Broker_Fd  : File_Descriptor;
      Set_Status : Set_Status_Cap;
      Efd        : Epoll_Fd;
   end record with
      Dynamic_Predicate => Valid (Capability.Broker_Fd) and then Valid (Capability.Efd);

   procedure Invalidate (Cap : in out Event_Cap) with
      Post => not Valid (Cap);

   generic
      type Event_Context is limited private;
      type Error_Context is limited private;
      with procedure Event (Ctx : in out Event_Context;
                            Fd  :        File_Descriptor);
      with procedure Error (Ctx : in out Error_Context;
                            Fd  :        File_Descriptor);
   function Create_Event_Cap (Ev_Ctx : Event_Context;
                              Er_Ctx : Error_Context;
                              Fd     : File_Descriptor) return Event_Cap with
      Post => Valid (Create_Event_Cap'Result);

   procedure Call (Cap : Event_Cap;
                   Ev  : Event_Type);

   generic
      --  @param S  Status code (0 - Success, 1 - Failure)
      with procedure Set_Status (S : Integer);
   function Create_Set_Status_Cap return Set_Status_Cap with
      Post => Valid (Create_Set_Status_Cap'Result);

   procedure Call (Cap : Set_Status_Cap;
                   S   : Integer) with
      Pre => Valid (Cap);

private

   type Event_Cap is record
      Event_Adr : System.Address  := System.Null_Address;
      Event_Ctx : System.Address  := System.Null_Address;
      Error_Adr : System.Address  := System.Null_Address;
      Error_Ctx : System.Address  := System.Null_Address;
      Fd        : File_Descriptor := -1;
   end record;

   Invalid_Event_Cap : constant Event_Cap := Event_Cap'(Event_Adr => System.Null_Address,
                                                        Event_Ctx => System.Null_Address,
                                                        Error_Adr => System.Null_Address,
                                                        Error_Ctx => System.Null_Address,
                                                        Fd        => -1);

   type Set_Status_Cap is record
      Address : System.Address := System.Null_Address;
   end record;

   Invalid_Set_Status_Cap : constant Set_Status_Cap := Set_Status_Cap'(Address => System.Null_Address);

end Gneiss_Internal;
