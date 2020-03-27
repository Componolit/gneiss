
private with Gneiss_Syscall;
private with Gneiss_Protocol.Session;

package Gneiss.Broker.Message with
   SPARK_Mode
is

   procedure Read_Message (State    : in out Broker_State;
                           Index    :        Positive;
                           Filedesc :        Integer);

private

   type Gneiss_Protocol_String is array (Gneiss_Protocol.Session.Length_Type range <>) of Character;

   function Convert_Message (S : String) return Gneiss_Protocol_String;

   procedure Handle_Message (State  : in out Broker_State;
                             Source :        Positive;
                             Action :        Gneiss_Protocol.Session.Action_Type;
                             Kind   :        Gneiss_Protocol.Session.Kind_Type;
                             Name   :        String;
                             Label  :        String;
                             Fds    :        Gneiss_Syscall.Fd_Array);

   procedure Process_Request (State  : in out Broker_State;
                              Source :        Positive;
                              Kind   :        Gneiss_Protocol.Session.Kind_Type;
                              Label  :        String;
                              Fds    :        Gneiss_Syscall.Fd_Array);

   procedure Process_Message_Request (Fds   : out Gneiss_Syscall.Fd_Array;
                                      Valid : out Boolean);

   procedure Process_Rom_Request (State       :     Broker_State;
                                  Serv_State  :     SXML.Query.State_Type;
                                  Fds         : out Gneiss_Syscall.Fd_Array;
                                  Valid       : out Boolean);

   procedure Process_Memory_Request (Fds_In  :        Gneiss_Syscall.Fd_Array;
                                     Fds_Out :    out Gneiss_Syscall.Fd_Array;
                                     Valid   :    out Boolean);

   procedure Process_Timer_Request (Fds   : out Gneiss_Syscall.Fd_Array;
                                    Valid : out Boolean);

   procedure Process_Confirm (State : Broker_State;
                              Kind  : Gneiss_Protocol.Session.Kind_Type;
                              Name  : String;
                              Label : String;
                              Fds   : Gneiss_Syscall.Fd_Array);

   procedure Process_Reject (State : Broker_State;
                             Kind  : Gneiss_Protocol.Session.Kind_Type;
                             Name  : String;
                             Label : String);

   procedure Process_Register (State  : in out Broker_State;
                               Source :        Positive;
                               Kind   :        Gneiss_Protocol.Session.Kind_Type);

   procedure Send_Request (Destination : Integer;
                           Kind        : Gneiss_Protocol.Session.Kind_Type;
                           Name        : String;
                           Label       : String;
                           Fds         : Gneiss_Syscall.Fd_Array);

   procedure Send_Confirm (Destination : Integer;
                           Kind        : Gneiss_Protocol.Session.Kind_Type;
                           Label       : String;
                           Fds         : Gneiss_Syscall.Fd_Array);

   procedure Send_Reject (Destination : Integer;
                          Kind        : Gneiss_Protocol.Session.Kind_Type;
                          Label       : String);
end Gneiss.Broker.Message;
