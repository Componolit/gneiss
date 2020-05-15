
with Gneiss_Protocol.Session.PDU;

package body Gneiss_Internal.Socket with
   SPARK_Mode,
   Refined_State => (Packet_State => null)
is

   generic
   package Generic_Buffer with
      SPARK_Mode
   is

      Ptr : Gneiss_Protocol.Types.Bytes_Ptr;

   end Generic_Buffer;

   package body Generic_Buffer with
      SPARK_Mode
   is

      Buf : aliased Gneiss_Protocol.Types.Bytes (1 .. 1024);

   begin
      pragma SPARK_Mode (Off);
      Ptr := Buf'Unrestricted_Access;
   end Generic_Buffer;

   procedure Get (Data : Gneiss_Protocol.Types.Bytes)
   is
      use type Gneiss_Protocol.Types.Length;
      I : Natural := Field'First;
   begin
      for J in Data'Range loop
         Field (I) := Character'Val (Gneiss_Protocol.Types.Byte'Pos (Data (J)));
         exit when I = Field'Last or else J = Data'Last;
         I := I + 1;
      end loop;
      Last := I;
   end Get;

   procedure Set (Data : out Gneiss_Protocol.Types.Bytes)
   is
      use type Gneiss_Protocol.Types.Length;
      I : Natural := Field'First;
   begin
      Data := (others => Gneiss_Protocol.Types.Byte'First);
      for J in Data'Range loop
         Data (J) := Gneiss_Protocol.Types.Byte'Val (Character'Pos (Field (I)));
         exit when I = Field'Last or else J = Data'Last;
         I := I + 1;
      end loop;
   end Set;

   procedure Send (Fd     : File_Descriptor;
                   Action : Gneiss_Protocol.Session.Action_Type;
                   Kind   : Gneiss_Protocol.Session.Kind_Type;
                   Name   : Session_Label;
                   Label  : Session_Label;
                   Fds    : Fd_Array)
   is
      use type Gneiss_Protocol.Types.Length;
      package Buffer is new Generic_Buffer;
      procedure Buffer_Name is new Set (Name.Value (Name.Value'First .. Name.Last));
      procedure Buffer_Label is new Set (Label.Value (Label.Value'First .. Label.Last));
      procedure Set_Name is new Gneiss_Protocol.Session.PDU.Set_Name (Buffer_Name);
      procedure Set_Label is new Gneiss_Protocol.Session.PDU.Set_Label (Buffer_Label);
      Context : Gneiss_Protocol.Session.PDU.Context := Gneiss_Protocol.Session.PDU.Create;
   begin
      Gneiss_Protocol.Session.PDU.Initialize (Context, Buffer.Ptr);
      Gneiss_Protocol.Session.PDU.Set_Action (Context, Action);
      Gneiss_Protocol.Session.PDU.Set_Kind (Context, Kind);
      Gneiss_Protocol.Session.PDU.Set_Name_Length (Context, Gneiss_Protocol.Session.Length_Type (Name.Last));
      if Name.Last > 0 then
         Set_Name (Context);
      end if;
      Gneiss_Protocol.Session.PDU.Set_Label_Length (Context, Gneiss_Protocol.Session.Length_Type (Label.Last));
      if Label.Last > 0 then
         Set_Label (Context);
      end if;
      Gneiss_Protocol.Session.PDU.Take_Buffer (Context, Buffer.Ptr);
      Send (Fd, Buffer.Ptr.all,
            4 + Name.Last + Label.Last,
            Fds);
   end Send;

   procedure Receive (Fd    :     File_Descriptor;
                      Msg   : out Broker_Message;
                      Fds   : out Fd_Array;
                      Block :     Boolean)
   is
      use type Gneiss_Protocol.Types.Length;
      use type Gneiss_Protocol.Session.Length_Type;
      package Buffer is new Generic_Buffer;
      Context : Gneiss_Protocol.Session.PDU.Context := Gneiss_Protocol.Session.PDU.Create;
      Action  : Gneiss_Protocol.Session.Action_Type;
      Kind    : Gneiss_Protocol.Session.Kind_Type;
      Name    : Session_Label;
      Label   : Session_Label;
      Length  : Gneiss_Protocol.Types.Length;
      procedure Parse_Name is new Get (Name.Value, Name.Last);
      procedure Parse_Label is new Get (Label.Value, Label.Last);
      procedure Get_Name is new Gneiss_Protocol.Session.PDU.Get_Name (Parse_Name);
      procedure Get_Label is new Gneiss_Protocol.Session.PDU.Get_Label (Parse_Label);
   begin
      Msg := Broker_Message'(Valid => False);
      Recv (Fd, Buffer.Ptr.all, Length, Fds, Block);
      if Length = 0 then --  EOF
         return;
      end if;
      Gneiss_Protocol.Session.PDU.Initialize (Context, Buffer.Ptr);
      Gneiss_Protocol.Session.PDU.Verify_Message (Context);
      if not Gneiss_Protocol.Session.PDU.Structural_Valid_Message (Context) then
         return;
      end if;
      Action := Gneiss_Protocol.Session.PDU.Get_Action (Context);
      Kind := Gneiss_Protocol.Session.PDU.Get_Kind (Context);
      if
         Gneiss_Protocol.Session.PDU.Get_Name_Length (Context) > 0
         and then Gneiss_Protocol.Session.PDU.Present (Context, Gneiss_Protocol.Session.PDU.F_Name)
      then
         Get_Name (Context);
      end if;
      if
         Gneiss_Protocol.Session.PDU.Get_Label_Length (Context) > 0
         and then Gneiss_Protocol.Session.PDU.Present (Context, Gneiss_Protocol.Session.PDU.F_Label)
      then
         Get_Label (Context);
      end if;
      Msg := Broker_Message'(Valid  => True,
                             Action => Action,
                             Kind   => Kind,
                             Name   => Name,
                             Label  => Label);
      Gneiss_Protocol.Session.PDU.Take_Buffer (Context, Buffer.Ptr);
   end Receive;

   procedure Send (Fd     : File_Descriptor;
                   Buf    : Gneiss_Protocol.Types.Bytes;
                   Length : Integer;
                   Fds    : Fd_Array) with
      SPARK_Mode => Off
   is
   begin
      Linux.Write_Message (Fd, Buf'Address, Length, Fds, Fds'Length);
   end Send;

   procedure Recv (Fd     :     File_Descriptor;
                   Buf    : out Gneiss_Protocol.Types.Bytes;
                   Length : out Gneiss_Protocol.Types.Length;
                   Fds    : out Fd_Array;
                   Block  :     Boolean)
   is
      Ignore_Trunc : Integer;
      Len          : Integer;
   begin
      Linux.Read_Message (Fd, Buf'Address, Buf'Length, Fds, Fds'Length,
                          Len, Ignore_Trunc, Boolean'Pos (Block));
      Length := (if Len > 0 then Gneiss_Protocol.Types.Length (Len) else 0);
   end Recv;

end Gneiss_Internal.Socket;
