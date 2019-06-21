
with Ada.Unchecked_Conversion;
with Componolit.Interfaces.Muen;
with Componolit.Interfaces.Muen_Block;
with Componolit.Interfaces.Muen_Registry;
with Musinfo;
with Musinfo.Instance;

package body Componolit.Interfaces.Block.Client with
   SPARK_Mode
is
   use type Musinfo.Memregion_Type;
   package CIM renames Componolit.Interfaces.Muen;
   package Blk renames Componolit.Interfaces.Muen_Block;
   package Reg renames Componolit.Interfaces.Muen_Registry;

   subtype Block_Buffer is Buffer (1 .. 4096);
   function Convert_Buffer is new Ada.Unchecked_Conversion (Blk.Raw_Data_Type, Block_Buffer);
   function Convert_Buffer is new Ada.Unchecked_Conversion (Block_Buffer, Blk.Raw_Data_Type);

   function Initialized (C : Client_Session) return Boolean
   is
      use type Blk.Count;
      use type Blk.Session_Name;
      use type CIM.Session_Index;
   begin
      return C.Name /= Componolit.Interfaces.Muen_Block.Null_Name
             and C.Count > 0
             and C.Request_Memory /= Musinfo.Null_Memregion
             and C.Registry_Index /= CIM.Invalid_Index;
   end Initialized;

   function Create return Client_Session
   is
   begin
      return Client_Session'(Name            => Blk.Null_Name,
                             Count           => 0,
                             Request_Memory  => Musinfo.Null_Memregion,
                             Registry_Index  => CIM.Invalid_Index,
                             Queued          => 0);
   end Create;

   function Get_Instance (C : Client_Session) return Client_Instance
   is
   begin
      return Client_Instance (C.Name);
   end Get_Instance;

   procedure Set_Null (C : in out Client_Session) with
      Post => not Initialized (C);

   procedure Set_Null (C : in out Client_Session)
   is
      use type CIM.Session_Index;
   begin
      C.Name            := Blk.Null_Name;
      C.Count           := 0;
      C.Request_Memory  := Musinfo.Null_Memregion;
      if C.Registry_Index /= CIM.Invalid_Index then
         Reg.Registry (C.Registry_Index) := Reg.Session_Entry'(Kind => CIM.None);
         C.Registry_Index                := CIM.Invalid_Index;
      end if;
   end Set_Null;

   procedure Initialize (C           : in out Client_Session;
                         Cap         :        Componolit.Interfaces.Types.Capability;
                         Path        :        String;
                         Buffer_Size :        Byte_Length := 0)
   is
      use type CIM.Async_Session_Type;
      use type CIM.Session_Index;
      use type Blk.Sector;
      use type Blk.Count;
      use type Blk.Event_Type;
      use type Blk.Response_Channel.Result_Type;
      pragma Unreferenced (Cap);
      pragma Unreferenced (Buffer_Size);
      Name       : Blk.Session_Name := Blk.Null_Name;
      Req_Name   : Musinfo.Name_Type;
      Res_Name   : Musinfo.Name_Type;
      Req_Mem    : Musinfo.Memregion_Type;
      Res_Mem    : Musinfo.Memregion_Type;
      Index      : CIM.Session_Index := CIM.Invalid_Index;
      Size_Event : Blk.Event := (Kind  => Blk.Command,
                                 Error => 0,
                                 Id    => Blk.Size,
                                 Priv  => 0,
                                 Data  => (others => 0));
      Reader     : Blk.Response_Channel.Reader_Type := Blk.Response_Channel.Null_Reader;
      Result     : Blk.Response_Channel.Result_Type := Blk.Response_Channel.Inactive;
   begin
      if Path'Length <= Blk.Session_Name'Length then
         for I in Reg.Registry'Range loop
            if Reg.Registry (I).Kind = CIM.None then
               Index := I;
               exit;
            end if;
         end loop;
         Name (Name'First .. Name'First + Path'Length - 1) := Blk.Session_Name (Path);
         Req_Name := CIM.String_To_Name ("req:" & CIM.Str_Cut (String (Name)));
         Res_Name := CIM.String_To_Name ("rsp:" & CIM.Str_Cut (String (Name)));
         Req_Mem := Musinfo.Instance.Memory_By_Name (Req_Name);
         Res_Mem := Musinfo.Instance.Memory_By_Name (Res_Name);
         if
            Index /= CIM.Invalid_Index
            and then Req_Mem /= Musinfo.Null_Memregion
            and then Res_Mem /= Musinfo.Null_Memregion
         then
            Blk.Request_Channel.Activate (Req_Mem, Blk.Request_Channel.Channel.Header_Field_Type
                                                      (Musinfo.Instance.TSC_Schedule_Start));
            Blk.Request_Channel.Write (Req_Mem, Size_Event);
            loop
               Blk.Response_Channel.Read (Res_Mem, Reader, Size_Event, Result);
               exit when Result = Blk.Response_Channel.Epoch_Changed
                         or Result = Blk.Response_Channel.Success;
            end loop;
            if
               Size_Event.Kind = Blk.Command and Size_Event.Id = Blk.Size
               and (Result = Blk.Response_Channel.Success or Result = Blk.Response_Channel.Epoch_Changed)
            then
               Reg.Registry (Index) := Reg.Session_Entry'(Kind            => CIM.Block,
                                                          Response_Memory => Res_Mem,
                                                          Response_Reader => Reader,
                                                          Block_Event     => Event'Address);
               C.Registry_Index     := Index;
               C.Name               := Name;
               C.Request_Memory     := Req_Mem;
               C.Count              := Blk.Get_Size_Command_Data (Size_Event.Data).Value / 8;
            end if;
         end if;
      end if;
   end Initialize;

   procedure Finalize (C : in out Client_Session)
   is
   begin
      Blk.Request_Channel.Deactivate (C.Request_Memory);
      Set_Null (C);
   end Finalize;

   function Supported (C : Client_Session;
                       R : Request_Kind) return Boolean
   is
      pragma Unreferenced (C);
   begin
      return R = Read or R = Write or R = Sync;
   end Supported;

   function Ready (C : Client_Session;
                   R : Request) return Boolean
   is
   begin
      return C.Queued < Blk.Element_Count and R.Length = 1;
   end Ready;

   Enqueue_Buffer : Block_Buffer;

   procedure Enqueue (C : in out Client_Session;
                      R :        Request)
   is
      Ev : Blk.Event := Blk.Null_Event;
   begin
      Enqueue_Buffer := (others => Byte'First);
      case R.Kind is
         when Read =>
            Ev.Kind  := Blk.Read;
            Ev.Error := 0;
            Ev.Id    := Blk.Sector (R.Start);
            Ev.Priv  := 0;
         when Write =>
            Ev.Kind  := Blk.Write;
            Ev.Error := 0;
            Ev.Id    := Blk.Sector (R.Start);
            Ev.Priv  := 0;
            Write (Get_Instance (C),
                   Size (Blk.Event_Block_Size),
                   R.Start,
                   1,
                   Enqueue_Buffer);
            Ev.Data  := Convert_Buffer (Enqueue_Buffer);
         when Sync =>
            Ev.Kind  := Blk.Command;
            Ev.Error := 0;
            Ev.Id    := Blk.Sync;
            Ev.Priv  := 0;
         when others =>
            return;
      end case;
      Blk.Request_Channel.Write (C.Request_Memory, Ev);
      C.Queued := C.Queued + 1;
   end Enqueue;

   procedure Submit (C : in out Client_Session)
   is
   begin
      C.Queued := 0;
   end Submit;

   function Next (C : Client_Session) return Request
   is
      pragma Unreferenced (C);
   begin
      return Request'(Kind => None,
                      Priv => Null_Data);
   end Next;

   procedure Read (C : in out Client_Session;
                   R :        Request)
   is
      pragma Unreferenced (C);
      pragma Unreferenced (R);
   begin
      null;
   end Read;

   procedure Release (C : in out Client_Session;
                      R : in out Request)
   is
      pragma Unreferenced (C);
      pragma Unreferenced (R);
   begin
      null;
   end Release;

   function Writable (C : Client_Session) return Boolean
   is
      pragma Unreferenced (C);
   begin
      return True;
   end Writable;

   function Block_Count (C : Client_Session) return Count
   is
   begin
      return Count (C.Count);
   end Block_Count;

   function Block_Size (C : Client_Session) return Size
   is
      pragma Unreferenced (C);
   begin
      return Blk.Event_Block_Size;
   end Block_Size;

   function Maximum_Transfer_Size (C : Client_Session) return Byte_Length
   is
      pragma Unreferenced (C);
   begin
      return Blk.Event_Block_Size;
   end Maximum_Transfer_Size;

end Componolit.Interfaces.Block.Client;
