
with RFLX.Session;
with Gneiss_Internal;
with Gneiss_Syscall;

package Gneiss.Packet with
   SPARK_Mode
is

   type Message (Valid : Boolean := False) is record
      case Valid is
         when True =>
            Action : RFLX.Session.Action_Type;
            Kind   : RFLX.Session.Kind_Type;
            Name   : Gneiss_Internal.Session_Label;
            Label  : Gneiss_Internal.Session_Label;
         when False =>
            null;
      end case;
   end record;

   procedure Send (Fd     : Integer;
                   Action : RFLX.Session.Action_Type;
                   Kind   : RFLX.Session.Kind_Type;
                   Name   : Gneiss_Internal.Session_Label;
                   Label  : Gneiss_Internal.Session_Label;
                   Fds    : Gneiss_Syscall.Fd_Array) with
      Pre => Fd > -1;

   procedure Receive (Fd    :     Integer;
                      Msg   : out Message;
                      Fds   : out Gneiss_Syscall.Fd_Array;
                      Block :     Boolean) with
      Pre  => Fd > -1;

end Gneiss.Packet;
