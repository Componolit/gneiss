
private with Gneiss_Syscall;
private with RFLX.Session;

package Gneiss.Broker.Message with
   SPARK_Mode
is

   procedure Read_Message (State    : in out Broker_State;
                           Index    :        Positive;
                           Filedesc :        Integer) with
      Pre  => Gneiss_Epoll.Valid_Fd (State.Epoll_Fd)
              and then Is_Valid (State.Xml, State.Components)
              and then Is_Valid (State.Xml, State.Resources)
              and then Filedesc > -1
              and then Index in State.Components'Range
              and then State.Components (Index).Fd > -1,
      Post => Gneiss_Epoll.Valid_Fd (State.Epoll_Fd)
              and then Is_Valid (State.Xml, State.Components)
              and then Is_Valid (State.Xml, State.Resources);

private

   use type RFLX.Session.Length_Type;

   type RFLX_String is array (RFLX.Session.Length_Type range <>) of Character;

   function Convert_Message (S : String) return RFLX_String with
      Pre => S'Length < Natural (RFLX.Session.Length_Type'Last);

   procedure Handle_Message (State  : in out Broker_State;
                             Source :        Positive;
                             Action :        RFLX.Session.Action_Type;
                             Kind   :        RFLX.Session.Kind_Type;
                             Name   :        String;
                             Label  :        String;
                             Fds    :        Gneiss_Syscall.Fd_Array) with
      Pre  => Source in State.Components'Range
              and then State.Components (Source).Fd > -1
              and then Gneiss_Epoll.Valid_Fd (State.Epoll_Fd)
              and then Is_Valid (State.Xml, State.Components)
              and then Is_Valid (State.Xml, State.Resources),
      Post => Is_Valid (State.Xml, State.Components)
              and then Is_Valid (State.Xml, State.Resources)
              and then Gneiss_Epoll.Valid_Fd (State.Epoll_Fd);

   procedure Process_Request (State  : in out Broker_State;
                              Source :        Positive;
                              Kind   :        RFLX.Session.Kind_Type;
                              Label  :        String;
                              Fds    :        Gneiss_Syscall.Fd_Array) with
      Pre  => Source in State.Components'Range
              and then Is_Valid (State.Xml, State.Components)
              and then Is_Valid (State.Xml, State.Resources)
              and then State.Components (Source).Fd > -1
              and then Gneiss_Epoll.Valid_Fd (State.Epoll_Fd)
              and then Label'Length < 256,
      Post => Is_Valid (State.Xml, State.Components)
              and then Is_Valid (State.Xml, State.Resources)
              and then Gneiss_Epoll.Valid_Fd (State.Epoll_Fd);

   procedure Process_Message_Request (Fds   : out Gneiss_Syscall.Fd_Array;
                                      Valid : out Boolean) with
      Pre => Fds'Length > 1;

   procedure Process_Rom_Request (State       :     Broker_State;
                                  Serv_State  :     SXML.Query.State_Type;
                                  Fds         : out Gneiss_Syscall.Fd_Array;
                                  Valid       : out Boolean) with
      Pre => SXML.Query.Is_Valid (Serv_State, State.Xml)
             and then SXML.Query.State_Result (Serv_State) = SXML.Result_OK
             and then SXML.Query.Is_Open (Serv_State, State.Xml)
             and then Is_Valid (State.Xml, State.Resources)
             and then Fds'Length > 0;

   procedure Process_Memory_Request (Fds_In  :        Gneiss_Syscall.Fd_Array;
                                     Fds_Out :    out Gneiss_Syscall.Fd_Array;
                                     Valid   :    out Boolean) with
      Pre => Fds_In'Length > 0 and then Fds_Out'Length > 2;

   procedure Process_Timer_Request (Fds   : out Gneiss_Syscall.Fd_Array;
                                    Valid : out Boolean) with
      Pre => Fds'Length > 0;

   procedure Process_Confirm (State : Broker_State;
                              Kind  : RFLX.Session.Kind_Type;
                              Name  : String;
                              Label : String;
                              Fds   : Gneiss_Syscall.Fd_Array) with
      Pre => Is_Valid (State.Xml, State.Components)
             and then Name'Length < 256
             and then Label'Length < 256;

   procedure Process_Reject (State : Broker_State;
                             Kind  : RFLX.Session.Kind_Type;
                             Name  : String;
                             Label : String) with
      Pre => Is_Valid (State.Xml, State.Components)
             and then Label'Length < 256;

   procedure Process_Register (State  : in out Broker_State;
                               Source :        Positive;
                               Kind   :        RFLX.Session.Kind_Type) with
      Pre  => Gneiss_Epoll.Valid_Fd (State.Epoll_Fd)
              and then Is_Valid (State.Xml, State.Components)
              and then Is_Valid (State.Xml, State.Resources)
              and then Source in State.Components'Range
              and then State.Components (Source).Fd > -1,
      Post => Gneiss_Epoll.Valid_Fd (State.Epoll_Fd)
              and then Is_Valid (State.Xml, State.Components)
              and then Is_Valid (State.Xml, State.Resources);

   procedure Send_Request (Destination : Integer;
                           Kind        : RFLX.Session.Kind_Type;
                           Name        : String;
                           Label       : String;
                           Fds         : Gneiss_Syscall.Fd_Array) with
      Pre => Name'Length < 256
             and then Label'Length < 256
             and then Destination > -1;

   procedure Send_Confirm (Destination : Integer;
                           Kind        : RFLX.Session.Kind_Type;
                           Label       : String;
                           Fds         : Gneiss_Syscall.Fd_Array) with
      Pre => Label'Length < 256
             and then Destination > -1;

   procedure Send_Reject (Destination : Integer;
                          Kind        : RFLX.Session.Kind_Type;
                          Label       : String) with
      Pre => Label'Length < 256
             and then Destination > -1;

end Gneiss.Broker.Message;
