
with RFLX.Session;
with Gneiss_Syscall;
with Gneiss_Internal;

package Gneiss.Platform_Client with
   SPARK_Mode
is

   procedure Register (Broker_Fd :     Integer;
                       Kind      :     RFLX.Session.Kind_Type;
                       Fd        : out Integer);

   procedure Initialize (Cap   :        Capability;
                         Kind  :        RFLX.Session.Kind_Type;
                         Fds   : in out Gneiss_Syscall.Fd_Array;
                         Label :        String);

   procedure Dispatch (Fd    :     Integer;
                       Kind  :     RFLX.Session.Kind_Type;
                       Name  : out Gneiss_Internal.Session_Label;
                       Label : out Gneiss_Internal.Session_Label;
                       Fds   : out Gneiss_Syscall.Fd_Array);

   procedure Confirm (Fd    : Integer;
                      Kind  : RFLX.Session.Kind_Type;
                      Name  : String;
                      Label : String;
                      Fds   : Gneiss_Syscall.Fd_Array);

   procedure Reject (Fd    : Integer;
                     Kind  : RFLX.Session.Kind_Type;
                     Name  : String;
                     Label : String);

end Gneiss.Platform_Client;
