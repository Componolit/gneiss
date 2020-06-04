
with Gneiss_Protocol.Generic_PDU;

package body Gneiss_Internal.Socket with
   SPARK_Mode,
   Refined_State => (Packet_State => null)
is

   package PDU is new Gneiss_Protocol.Generic_PDU (Types);

   generic
   package Generic_Buffer with
      SPARK_Mode
   is

      Ptr : String_Ptr;

   end Generic_Buffer;

   package body Generic_Buffer with
      SPARK_Mode
   is

      Buf : aliased String (1 .. 1024);

   begin
      pragma SPARK_Mode (Off);
      Ptr := Buf'Unrestricted_Access;
   end Generic_Buffer;

   procedure Get (Data : String)
   is
   begin
      Last := 0;
      if Data'Length < 1 or else Field'Length < 1 then
         return;
      end if;
      if Field'Length >= Data'Length then
         Last := Field'First + Data'Length - 1;
         Field (Field'First .. Last) := Data;
      else
         Field := Data (Data'First .. Data'First + Field'Length - 1);
         Last  := Field'Last;
      end if;
   end Get;

   procedure Set (Data : out String)
   is
   begin
      if Data'Length < 1 or else Field'Length < 1 then
         return;
      end if;
      if Field'Length >= Data'Length then
         Data := Field (Field'First .. Field'First + Data'Length - 1);
      else
         Data := (others => Character'First);
         Data (Data'First .. Data'First + Field'Length - 1) := Field;
      end if;
   end Set;

   procedure Send (Fd     : File_Descriptor;
                   Action : Gneiss_Protocol.Action_Type;
                   Kind   : Gneiss_Protocol.Kind_Type;
                   Name   : Session_Label;
                   Label  : Session_Label;
                   Fds    : Fd_Array)
   is
      package Buffer is new Generic_Buffer;
      procedure Buffer_Name is new Set (Name.Value (Name.Value'First .. Name.Last));
      procedure Buffer_Label is new Set (Label.Value (Label.Value'First .. Label.Last));
      procedure Set_Name is new PDU.Set_Name (Buffer_Name);
      procedure Set_Label is new PDU.Set_Label (Buffer_Label);
      Context : PDU.Context;
   begin
      PDU.Initialize (Context, Buffer.Ptr);
      PDU.Set_Action (Context, Action);
      PDU.Set_Kind (Context, Kind);
      PDU.Set_Name_Length (Context, Gneiss_Protocol.Length_Type (Name.Last));
      if Name.Last > 0 then
         Set_Name (Context);
      end if;
      PDU.Set_Label_Length (Context, Gneiss_Protocol.Length_Type (Label.Last));
      if Label.Last > 0 then
         Set_Label (Context);
      end if;
      PDU.Take_Buffer (Context, Buffer.Ptr);
      Send (Fd, Buffer.Ptr.all,
            4 + Name.Last + Label.Last,
            Fds);
   end Send;

   procedure Receive (Fd    :     File_Descriptor;
                      Msg   : out Broker_Message;
                      Fds   : out Fd_Array;
                      Block :     Boolean)
   is
      use type Gneiss_Protocol.Length_Type;
      package Buffer is new Generic_Buffer;
      Context : PDU.Context;
      Action  : Gneiss_Protocol.Action_Type;
      Kind    : Gneiss_Protocol.Kind_Type;
      Name    : Session_Label;
      Label   : Session_Label;
      Length  : Natural;
      procedure Parse_Name is new Get (Name.Value, Name.Last);
      procedure Parse_Label is new Get (Label.Value, Label.Last);
      procedure Get_Name is new PDU.Get_Name (Parse_Name);
      procedure Get_Label is new PDU.Get_Label (Parse_Label);
   begin
      Msg := Broker_Message'(Valid => False);
      Recv (Fd, Buffer.Ptr.all, Length, Fds, Block);
      if Length = 0 then --  EOF
         return;
      end if;
      PDU.Initialize (Context, Buffer.Ptr);
      PDU.Verify_Message (Context);
      if not PDU.Structural_Valid_Message (Context) then
         return;
      end if;
      Action := PDU.Get_Action (Context);
      Kind   := PDU.Get_Kind (Context);
      if
         PDU.Get_Name_Length (Context) > 0
         and then PDU.Present (Context, PDU.F_Name)
      then
         Get_Name (Context);
      end if;
      if
         PDU.Get_Label_Length (Context) > 0
         and then PDU.Present (Context, PDU.F_Label)
      then
         Get_Label (Context);
      end if;
      Msg := Broker_Message'(Valid  => True,
                             Action => Action,
                             Kind   => Kind,
                             Name   => Name,
                             Label  => Label);
      PDU.Take_Buffer (Context, Buffer.Ptr);
   end Receive;

   procedure Send (Fd     : File_Descriptor;
                   Buf    : String;
                   Length : Integer;
                   Fds    : Fd_Array) with
      SPARK_Mode => Off
   is
   begin
      Linux.Write_Message (Fd, Buf'Address, Length, Fds, Fds'Length);
   end Send;

   procedure Recv (Fd     :     File_Descriptor;
                   Buf    : out String;
                   Length : out Natural;
                   Fds    : out Fd_Array;
                   Block  :     Boolean) with
      SPARK_Mode => Off
   is
      Ignore_Trunc : Integer;
      Len          : Integer;
   begin
      Linux.Read_Message (Fd, Buf'Address, Buf'Length, Fds, Fds'Length,
                          Len, Ignore_Trunc, Boolean'Pos (Block));
      Length := (if Len > 0 then Natural (Len) else 0);
   end Recv;

end Gneiss_Internal.Socket;
