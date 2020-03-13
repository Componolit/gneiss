
with RFLX.Types;
with RFLX.Session.Packet;
with Gneiss_Access;

package body Gneiss.Platform_Client with
   SPARK_Mode
is

   package Buffer is new Gneiss_Access (520);

   procedure Answer (Fd     : Integer;
                     Kind   : RFLX.Session.Kind_Type;
                     Action : RFLX.Session.Action_Type;
                     Name   : String;
                     Label  : String;
                     Fds    : Gneiss_Syscall.Fd_Array);

   procedure Register (Broker_Fd :     Integer;
                       Kind      :     RFLX.Session.Kind_Type;
                       Fd        : out Integer)
   is
      use type RFLX.Session.Action_Type;
      use type RFLX.Session.Kind_Type;
      Context : RFLX.Session.Packet.Context      := RFLX.Session.Packet.Create;
      Fds     : Gneiss_Syscall.Fd_Array (1 .. 1) := (others => -1);
      Length  : Integer;
      Trunc   : Integer;
   begin
      Fd := -1;
      RFLX.Session.Packet.Initialize (Context, Buffer.Ptr);
      RFLX.Session.Packet.Set_Action (Context, RFLX.Session.Register);
      RFLX.Session.Packet.Set_Kind (Context, Kind);
      RFLX.Session.Packet.Set_Name_Length (Context, 0);
      RFLX.Session.Packet.Set_Label_Length (Context, 0);
      RFLX.Session.Packet.Take_Buffer (Context, Buffer.Ptr);
      Gneiss_Syscall.Write_Message (Broker_Fd,
                                    Buffer.Ptr.all'Address,
                                    4, Fds, 0);
      Gneiss_Syscall.Read_Message (Broker_Fd,
                                   Buffer.Ptr.all'Address,
                                   Buffer.Ptr.all'Length,
                                   Fds, 1, Length, Trunc, 1);
      if Trunc > 0 or else Length < 4 or else Fds (Fds'First) < 0 then
         return;
      end if;
      Context := RFLX.Session.Packet.Create;
      RFLX.Session.Packet.Initialize (Context, Buffer.Ptr);
      RFLX.Session.Packet.Verify_Message (Context);
      if
         RFLX.Session.Packet.Structural_Valid_Message (Context)
         and then RFLX.Session.Packet.Get_Action (Context) = RFLX.Session.Confirm
         and then RFLX.Session.Packet.Get_Kind (Context) = Kind
      then
         Fd := Fds (Fds'First);
      end if;
   end Register;

   procedure Initialize (Cap   :     Capability;
                         Kind  :     RFLX.Session.Kind_Type;
                         Fds   : out Gneiss_Syscall.Fd_Array;
                         Label :     String)
   is
      use type RFLX.Session.Action_Type;
      use type RFLX.Session.Kind_Type;
      procedure Set_Label (Buf : out RFLX.Types.Bytes);
      procedure Set_Label (Buf : out RFLX.Types.Bytes)
      is
         I : Positive := Label'First;
      begin
         for B of Buf loop
            B := RFLX.Types.Byte'Val (Character'Pos (Label (I)));
            if I < Label'Last then
               I := I + 1;
            end if;
         end loop;
      end Set_Label;
      procedure Set_Label_Payload is new RFLX.Session.Packet.Set_Label (Set_Label);
      Context   : RFLX.Session.Packet.Context := RFLX.Session.Packet.Create;
      Length    : Integer;
      Trunc     : Integer;
      Dummy_Fds : constant Gneiss_Syscall.Fd_Array (1 .. 0) := (others => -1);
   begin
      RFLX.Session.Packet.Initialize (Context, Buffer.Ptr);
      RFLX.Session.Packet.Set_Action (Context, RFLX.Session.Request);
      RFLX.Session.Packet.Set_Kind (Context, Kind);
      RFLX.Session.Packet.Set_Name_Length (Context, 0);
      RFLX.Session.Packet.Set_Label_Length (Context, RFLX.Session.Length_Type (Label'Length));
      Set_Label_Payload (Context);
      RFLX.Session.Packet.Take_Buffer (Context, Buffer.Ptr);
      Gneiss_Syscall.Write_Message (Cap.Broker_Fd,
                                    Buffer.Ptr.all'Address,
                                    4 + Label'Length, Dummy_Fds, 0);
      Gneiss_Syscall.Read_Message (Cap.Broker_Fd,
                                   Buffer.Ptr.all'Address,
                                   Buffer.Ptr.all'Length,
                                   Fds, Fds'Length, Length, Trunc, 1);
      RFLX.Session.Packet.Initialize (Context, Buffer.Ptr);
      RFLX.Session.Packet.Verify_Message (Context);
      if
         RFLX.Session.Packet.Structural_Valid_Message (Context)
         and then RFLX.Session.Packet.Get_Action (Context) = RFLX.Session.Confirm
         and then RFLX.Session.Packet.Get_Kind (Context) = Kind
      then
         RFLX.Session.Packet.Take_Buffer (Context, Buffer.Ptr);
         return;
      end if;
      Fds := (others => -1);
      RFLX.Session.Packet.Take_Buffer (Context, Buffer.Ptr);
   end Initialize;

   procedure Dispatch (Fd         :     Integer;
                       Kind       :     RFLX.Session.Kind_Type;
                       Name       : out String;
                       Name_Last  : out Natural;
                       Label      : out String;
                       Label_Last : out Natural;
                       Fds        : out Gneiss_Syscall.Fd_Array)
   is
      use type RFLX.Session.Action_Type;
      use type RFLX.Session.Kind_Type;
      Valid : Boolean := False;
      procedure Parse_Name (Data : RFLX.Types.Bytes);
      procedure Parse_Label (Data : RFLX.Types.Bytes);
      procedure Parse_Name (Data : RFLX.Types.Bytes)
      is
         Index : Natural := Name'First;
      begin
         for C of Data loop
            Name (Index) := Character'Val (RFLX.Types.Byte'Pos (C));
            exit when Index = Name'Last;
            Index := Index + 1;
         end loop;
         Name_Last := Index;
      end Parse_Name;
      procedure Parse_Label (Data : RFLX.Types.Bytes)
      is
         Index : Natural := Label'First;
      begin
         for C of Data loop
            Label (Index) := Character'Val (RFLX.Types.Byte'Pos (C));
            exit when Index = Label'Last;
            Index := Index + 1;
         end loop;
         Label_Last := Index;
      end Parse_Label;
      Context : RFLX.Session.Packet.Context := RFLX.Session.Packet.Create;
      Length : Integer;
      Trunc : Integer;
      procedure Get_Name is new RFLX.Session.Packet.Get_Name (Parse_Name);
      procedure Get_Label is new RFLX.Session.Packet.Get_Label (Parse_Label);
   begin
      Name       := (others => Character'First);
      Name_Last  := 0;
      Label      := (others => Character'First);
      Label_Last := 0;
      Gneiss_Syscall.Read_Message (Fd, Buffer.Ptr.all'Address,
                                   Buffer.Ptr.all'Length,
                                   Fds, Fds'Length, Length, Trunc, 0);
      RFLX.Session.Packet.Initialize (Context, Buffer.Ptr);
      RFLX.Session.Packet.Verify_Message (Context);
      if
         RFLX.Session.Packet.Structural_Valid_Message (Context)
         and then RFLX.Session.Packet.Get_Action (Context) = RFLX.Session.Request
         and then RFLX.Session.Packet.Get_Kind (Context) = Kind
         and then RFLX.Session.Packet.Present (Context, RFLX.Session.Packet.F_Name)
      then
         Get_Name (Context);
         Valid := True;
      end if;
      if
         RFLX.Session.Packet.Structural_Valid_Message (Context)
         and then RFLX.Session.Packet.Present (Context, RFLX.Session.Packet.F_Label)
      then
         Get_Label (Context);
      end if;
      if not Valid then
         Fds := (others => -1);
      end if;
      RFLX.Session.Packet.Take_Buffer (Context, Buffer.Ptr);
   end Dispatch;

   procedure Confirm (Fd    : Integer;
                      Kind  : RFLX.Session.Kind_Type;
                      Name  : String;
                      Label : String;
                      Fds   : Gneiss_Syscall.Fd_Array)
   is
   begin
      Answer (Fd, Kind, RFLX.Session.Confirm, Name, Label, Fds);
   end Confirm;

   procedure Reject (Fd    : Integer;
                     Kind  : RFLX.Session.Kind_Type;
                     Name  : String;
                     Label : String)
   is
   begin
      Answer (Fd, Kind, RFLX.Session.Reject, Name, Label, (1 .. 0 => -1));
   end Reject;

   procedure Answer (Fd     : Integer;
                     Kind   : RFLX.Session.Kind_Type;
                     Action : RFLX.Session.Action_Type;
                     Name   : String;
                     Label  : String;
                     Fds    : Gneiss_Syscall.Fd_Array)
   is
      use type RFLX.Types.Length;
      procedure Set_Name (Buf : out RFLX.Types.Bytes);
      procedure Set_Label (Buf : out RFLX.Types.Bytes);
      procedure Set_Name (Buf : out RFLX.Types.Bytes)
      is
         I : Positive := Name'First;
      begin
         for B of Buf loop
            B := RFLX.Types.Byte'Val (Character'Pos (Name (I)));
            if I < Name'Last then
               I := I + 1;
            end if;
         end loop;
      end Set_Name;
      procedure Set_Label (Buf : out RFLX.Types.Bytes)
      is
         I : Positive := Label'First;
      begin
         for B of Buf loop
            B := RFLX.Types.Byte'Val (Character'Pos (Name (I)));
            if I < Label'Last then
               I := I + 1;
            end if;
         end loop;
      end Set_Label;
      Context : RFLX.Session.Packet.Context := RFLX.Session.Packet.Create;
      procedure Set_Name_Payload is new RFLX.Session.Packet.Set_Name (Set_Name);
      procedure Set_Label_Payload is new RFLX.Session.Packet.Set_Label (Set_Label);
   begin
      RFLX.Session.Packet.Initialize (Context, Buffer.Ptr);
      RFLX.Session.Packet.Set_Action (Context, Action);
      RFLX.Session.Packet.Set_Kind (Context, Kind);
      RFLX.Session.Packet.Set_Name_Length (Context, RFLX.Session.Length_Type (Name'Length));
      RFLX.Session.Packet.Set_Label_Length (Context, RFLX.Session.Length_Type (Label'Length));
      Set_Name_Payload (Context);
      Set_Label_Payload (Context);
      RFLX.Session.Packet.Take_Buffer (Context, Buffer.Ptr);
      Gneiss_Syscall.Write_Message (Fd, Buffer.Ptr.all'Address,
                                    Name'Length + Label'Length + 4,
                                    Fds, Fds'Length);
   end Answer;

end Gneiss.Platform_Client;
