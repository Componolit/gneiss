with Gneiss_Internal.Socket;

package body Gneiss_Internal.Client with
   SPARK_Mode
is

   procedure Register (Broker_Fd :     File_Descriptor;
                       Kind      :     Gneiss_Protocol.Session.Kind_Type;
                       Fd        : out File_Descriptor)
   is
      use type Gneiss_Protocol.Session.Kind_Type;
      Fds   : Fd_Array (1 .. 1) := (others => -1);
      Name  : Session_Label;
      Label : Session_Label;
      Msg   : Broker_Message;
   begin
      Fd := -1;
      Socket.Send (Broker_Fd, Gneiss_Protocol.Session.Register, Kind, Name, Label, (1 .. 0 => -1));
      Socket.Receive (Broker_Fd, Msg, Fds, True);
      if
         not Msg.Valid
         or else not Valid (Fds (Fds'First))
         or else Msg.Kind /= Kind
      then
         return;
      end if;
      Fd := Fds (Fds'First);
   end Register;

   procedure Initialize (Broker_Fd :        File_Descriptor;
                         Kind      :        Gneiss_Protocol.Session.Kind_Type;
                         Fds       : in out Fd_Array;
                         Label     :        String)
   is
      use type Gneiss_Protocol.Session.Kind_Type;
      Name : Session_Label;
      Lbl  : Session_Label;
      Msg  : Broker_Message;
      Last : Integer := Fds'First - 1;
   begin
      for I in Fds'Range loop
         exit when not Valid (Fds (I));
         Last := I;
      end loop;
      Lbl.Last := Lbl.Value'First + Label'Length - 1;
      Lbl.Value (Lbl.Value'First .. Lbl.Last) := Label;
      Socket.Send (Broker_Fd, Gneiss_Protocol.Session.Request, Kind, Name, Lbl, Fds (Fds'First .. Last));
      Socket.Receive (Broker_Fd, Msg, Fds, True);
      if not Msg.Valid or else Msg.Kind /= Kind then
         Fds := (others => -1);
      end if;
   end Initialize;

   procedure Dispatch (Fd    :     File_Descriptor;
                       Kind  :     Gneiss_Protocol.Session.Kind_Type;
                       Name  : out Session_Label;
                       Label : out Session_Label;
                       Fds   : out Fd_Array)
   is
      use type Gneiss_Protocol.Session.Kind_Type;
      Msg : Broker_Message;
   begin
      Socket.Receive (Fd, Msg, Fds, False);
      if not Msg.Valid or else Msg.Kind /= Kind then
         Fds := (others => -1);
      end if;
      Name  := Msg.Name;
      Label := Msg.Label;
   end Dispatch;

   procedure Confirm (Fd    : File_Descriptor;
                      Kind  : Gneiss_Protocol.Session.Kind_Type;
                      Name  : String;
                      Label : String;
                      Fds   : Fd_Array)
   is
      S_Name  : Session_Label;
      S_Label : Session_Label;
   begin
      S_Name.Last := S_Name.Value'First + Name'Length - 1;
      S_Name.Value (S_Name.Value'First .. S_Name.Last) := Name;
      S_Label.Last := S_Label.Value'First + Label'Last - 1;
      S_Label.Value (S_Label.Value'First .. S_Label.Last) := Label;
      Socket.Send (Fd, Gneiss_Protocol.Session.Confirm, Kind, S_Name, S_Label, Fds);
   end Confirm;

   procedure Reject (Fd    : File_Descriptor;
                     Kind  : Gneiss_Protocol.Session.Kind_Type;
                     Name  : String;
                     Label : String)
   is
      S_Name  : Session_Label;
      S_Label : Session_Label;
   begin
      S_Name.Last := S_Name.Value'First + Name'Length - 1;
      S_Name.Value (S_Name.Value'First .. S_Name.Last) := Name;
      S_Label.Last := S_Label.Value'First + Label'Last - 1;
      S_Label.Value (S_Label.Value'First .. S_Label.Last) := Label;
      Socket.Send (Fd, Gneiss_Protocol.Session.Reject, Kind, S_Name, S_Label, (1 .. 0 => -1));
   end Reject;

   procedure Send (Fd     : File_Descriptor;
                   Action : Gneiss_Protocol.Session.Action_Type;
                   Kind   : Gneiss_Protocol.Session.Kind_Type;
                   Name   : Session_Label;
                   Label  : Session_Label;
                   Fds    : Fd_Array)
   is
   begin
      Socket.Send (Fd, Action, Kind, Name, Label, Fds);
   end Send;

   procedure Receive (Fd    :     File_Descriptor;
                      Msg   : out Broker_Message;
                      Fds   : out Fd_Array;
                      Block :     Boolean)
   is
   begin
      Socket.Receive (Fd, Msg, Fds, Block);
   end Receive;

end Gneiss_Internal.Client;
