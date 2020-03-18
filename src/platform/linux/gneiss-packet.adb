
with Gneiss_Access;
with RFLX.Session.Packet;
with RFLX.Types;

package body Gneiss.Packet with
   SPARK_Mode
is

   package Buffer is new Gneiss_Access (1024);

   procedure Send (Fd     : Integer;
                   Buf    : RFLX.Types.Bytes;
                   Length : Integer;
                   Fds    : Gneiss_Syscall.Fd_Array);

   procedure Recv (Fd     :     Integer;
                   Buf    : out RFLX.Types.Bytes;
                   Fds    : out Gneiss_Syscall.Fd_Array;
                   Block  :     Boolean);

   procedure Send (Fd     : Integer;
                   Action : RFLX.Session.Action_Type;
                   Kind   : RFLX.Session.Kind_Type;
                   Name   : Gneiss_Internal.Session_Label;
                   Label  : Gneiss_Internal.Session_Label;
                   Fds    : Gneiss_Syscall.Fd_Array)
   is
      use type RFLX.Types.Length;
      procedure Buffer_Name is new Buffer.Set (Name.Value (Name.Value'First .. Name.Last));
      procedure Buffer_Label is new Buffer.Set (Label.Value (Label.Value'First .. Label.Last));
      procedure Set_Name is new RFLX.Session.Packet.Set_Name (Buffer_Name);
      procedure Set_Label is new RFLX.Session.Packet.Set_Label (Buffer_Label);
      Context : RFLX.Session.Packet.Context := RFLX.Session.Packet.Create;
   begin
      RFLX.Session.Packet.Initialize (Context, Buffer.Ptr);
      RFLX.Session.Packet.Set_Action (Context, Action);
      RFLX.Session.Packet.Set_Kind (Context, Kind);
      RFLX.Session.Packet.Set_Name_Length (Context, RFLX.Session.Length_Type (Name.Last));
      if Name.Last > 0 then
         Set_Name (Context);
      end if;
      RFLX.Session.Packet.Set_Label_Length (Context, RFLX.Session.Length_Type (Label.Last));
      if Label.Last > 0 then
         Set_Label (Context);
      end if;
      RFLX.Session.Packet.Take_Buffer (Context, Buffer.Ptr);
      Send (Fd, Buffer.Ptr.all,
            4 + Name.Last + Label.Last,
            Fds);
   end Send;

   procedure Receive (Fd    :     Integer;
                      Msg   : out Message;
                      Fds   : out Gneiss_Syscall.Fd_Array;
                      Block :     Boolean)
   is
      use type RFLX.Session.Length_Type;
      Context : RFLX.Session.Packet.Context := RFLX.Session.Packet.Create;
      Action  : RFLX.Session.Action_Type;
      Kind    : RFLX.Session.Kind_Type;
      Name    : Gneiss_Internal.Session_Label;
      Label   : Gneiss_Internal.Session_Label;
      procedure Parse_Name is new Buffer.Get (Name.Value, Name.Last);
      procedure Parse_Label is new Buffer.Get (Label.Value, Label.Last);
      procedure Get_Name is new RFLX.Session.Packet.Get_Name (Parse_Name);
      procedure Get_Label is new RFLX.Session.Packet.Get_Label (Parse_Label);
   begin
      Msg := Message'(Valid => False);
      Recv (Fd, Buffer.Ptr.all, Fds, Block);
      RFLX.Session.Packet.Initialize (Context, Buffer.Ptr);
      RFLX.Session.Packet.Verify_Message (Context);
      if not RFLX.Session.Packet.Structural_Valid_Message (Context) then
         return;
      end if;
      Action := RFLX.Session.Packet.Get_Action (Context);
      Kind := RFLX.Session.Packet.Get_Kind (Context);
      if
         RFLX.Session.Packet.Get_Name_Length (Context) > 0
         and then RFLX.Session.Packet.Present (Context, RFLX.Session.Packet.F_Name)
      then
         Get_Name (Context);
      end if;
      if
         RFLX.Session.Packet.Get_Label_Length (Context) > 0
         and then RFLX.Session.Packet.Present (Context, RFLX.Session.Packet.F_Label)
      then
         Get_Label (Context);
      end if;
      Msg := Message'(Valid  => True,
                      Action => Action,
                      Kind   => Kind,
                      Name   => Name,
                      Label  => Label);
      RFLX.Session.Packet.Take_Buffer (Context, Buffer.Ptr);
   end Receive;

   procedure Send (Fd     : Integer;
                   Buf    : RFLX.Types.Bytes;
                   Length : Integer;
                   Fds    : Gneiss_Syscall.Fd_Array) with
      SPARK_Mode => Off
   is
   begin
      Gneiss_Syscall.Write_Message (Fd, Buf'Address, Length, Fds, Fds'Length);
   end Send;

   procedure Recv (Fd     :     Integer;
                   Buf    : out RFLX.Types.Bytes;
                   Fds    : out Gneiss_Syscall.Fd_Array;
                   Block  :     Boolean)
   is
      Ignore_Trunc  : Integer;
      Ignore_Length : Integer;
   begin
      Gneiss_Syscall.Read_Message (Fd, Buf'Address, Buf'Length, Fds, Fds'Length,
                                   Ignore_Length, Ignore_Trunc, Boolean'Pos (Block));
   end Recv;

end Gneiss.Packet;
