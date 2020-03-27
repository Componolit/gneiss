
with Gneiss.Packet;

package body Gneiss.Platform_Client with
   SPARK_Mode
is

   procedure Register (Broker_Fd :     Integer;
                       Kind      :     Gneiss_Protocol.Session.Kind_Type;
                       Fd        : out Integer)
   is
      use type Gneiss_Protocol.Session.Kind_Type;
      Fds   : Gneiss_Syscall.Fd_Array (1 .. 1) := (others => -1);
      Name  : Gneiss_Internal.Session_Label;
      Label : Gneiss_Internal.Session_Label;
      Msg   : Packet.Message;
   begin
      Fd := -1;
      Packet.Send (Broker_Fd, Gneiss_Protocol.Session.Register, Kind, Name, Label, (1 .. 0 => -1));
      Packet.Receive (Broker_Fd, Msg, Fds, True);
      if
         not Msg.Valid
         or else Fds (Fds'First) < 0
         or else Msg.Kind /= Kind
      then
         return;
      end if;
      Fd := Fds (Fds'First);
   end Register;

   procedure Initialize (Cap   :        Capability;
                         Kind  :        Gneiss_Protocol.Session.Kind_Type;
                         Fds   : in out Gneiss_Syscall.Fd_Array;
                         Label :        String)
   is
      use type Gneiss_Protocol.Session.Kind_Type;
      Name : Gneiss_Internal.Session_Label;
      Lbl  : Gneiss_Internal.Session_Label;
      Msg  : Packet.Message;
      Last : Integer := Fds'First - 1;
   begin
      for I in Fds'Range loop
         exit when Fds (I) < 0;
         Last := I;
      end loop;
      Lbl.Last := Lbl.Value'First + Label'Length - 1;
      Lbl.Value (Lbl.Value'First .. Lbl.Last) := Label;
      Packet.Send (Cap.Broker_Fd, Gneiss_Protocol.Session.Request, Kind, Name, Lbl, Fds (Fds'First .. Last));
      Packet.Receive (Cap.Broker_Fd, Msg, Fds, True);
      if
         not Msg.Valid
         or else Msg.Kind /= Kind
      then
         Fds := (others => -1);
      end if;
   end Initialize;

   procedure Dispatch (Fd    :     Integer;
                       Kind  :     Gneiss_Protocol.Session.Kind_Type;
                       Name  : out Gneiss_Internal.Session_Label;
                       Label : out Gneiss_Internal.Session_Label;
                       Fds   : out Gneiss_Syscall.Fd_Array)
   is
      use type Gneiss_Protocol.Session.Kind_Type;
      Msg : Packet.Message;
   begin
      Packet.Receive (Fd, Msg, Fds, False);
      if not Msg.Valid or else Msg.Kind /= Kind then
         Fds := (others => -1);
      end if;
      Name  := Msg.Name;
      Label := Msg.Label;
   end Dispatch;

   procedure Confirm (Fd    : Integer;
                      Kind  : Gneiss_Protocol.Session.Kind_Type;
                      Name  : String;
                      Label : String;
                      Fds   : Gneiss_Syscall.Fd_Array)
   is
      S_Name  : Gneiss_Internal.Session_Label;
      S_Label : Gneiss_Internal.Session_Label;
   begin
      S_Name.Last := S_Name.Value'First + Name'Length - 1;
      S_Name.Value (S_Name.Value'First .. S_Name.Last) := Name;
      S_Label.Last := S_Label.Value'First + Label'Last - 1;
      S_Label.Value (S_Label.Value'First .. S_Label.Last) := Label;
      Packet.Send (Fd, Gneiss_Protocol.Session.Confirm, Kind, S_Name, S_Label, Fds);
   end Confirm;

   procedure Reject (Fd    : Integer;
                     Kind  : Gneiss_Protocol.Session.Kind_Type;
                     Name  : String;
                     Label : String)
   is
      S_Name  : Gneiss_Internal.Session_Label;
      S_Label : Gneiss_Internal.Session_Label;
   begin
      S_Name.Last := S_Name.Value'First + Name'Length - 1;
      S_Name.Value (S_Name.Value'First .. S_Name.Last) := Name;
      S_Label.Last := S_Label.Value'First + Label'Last - 1;
      S_Label.Value (S_Label.Value'First .. S_Label.Last) := Label;
      Packet.Send (Fd, Gneiss_Protocol.Session.Reject, Kind, S_Name, S_Label, (1 .. 0 => -1));
   end Reject;

end Gneiss.Platform_Client;
