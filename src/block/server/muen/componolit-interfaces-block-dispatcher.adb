
with System;
with Interfaces;
with Componolit.Interfaces.Muen;
with Componolit.Interfaces.Muen_Block;
with Componolit.Interfaces.Muen_Registry;
with Musinfo;
with Musinfo.Instance;
with Musinfo.Utils;

package body Componolit.Interfaces.Block.Dispatcher with
   SPARK_Mode
is
   package CIM renames Componolit.Interfaces.Muen;
   package Blk renames Componolit.Interfaces.Muen_Block;
   package Reg renames Componolit.Interfaces.Muen_Registry;

   use type Blk.Connection_Status;

   procedure Check_Channels (D : Dispatcher_Instance) with
      Pre => Initialized (D) and then not Accepted (D);

   function Serv_Event return System.Address;

   function Serv_Event return System.Address is
      (Serv.Event'Address) with
      SPARK_Mode => Off;

   procedure Initialize (D   : in out Dispatcher_Session;
                         Cap :        Componolit.Interfaces.Types.Capability)
   is
      pragma Unreferenced (Cap);
      use type CIM.Async_Session_Type;
   begin
      for I in Reg.Registry'Range loop
         if Reg.Registry (I).Kind = CIM.None then
            D.Registry_Index := I;
            Reg.Registry (I) := Reg.Session_Entry'(Kind                 => CIM.Block_Dispatcher,
                                                   Block_Dispatch_Event => System.Null_Address);
            exit;
         end if;
      end loop;
   end Initialize;

   procedure Register (D : in out Dispatcher_Session) with
      SPARK_Mode => Off
   is
   begin
      Reg.Registry (D.Registry_Index).Block_Dispatch_Event := Check_Channels'Address;
   end Register;

   procedure Finalize (D : in out Dispatcher_Session)
   is
   begin
      Reg.Registry (D.Registry_Index) := Reg.Session_Entry'(Kind => CIM.None);
      D.Registry_Index := CIM.Invalid_Index;
   end Finalize;

   function Str (C : Dispatcher_Capability) return String is
      (CIM.Str_Cut (String (C.Name)));

   function Valid_Session_Request (D : Dispatcher_Session;
                                   C : Dispatcher_Capability) return Boolean is
      (C.Status = Blk.Client_Connect
       and then Str (C)'Length > 0
       and then Str (C) (Str (C)'First) /= Character'First);

   procedure Session_Initialize (D : in out Dispatcher_Session;
                                 C :        Dispatcher_Capability;
                                 I : in out Server_Session)
   is
      pragma Unreferenced (D);
      use type CIM.Async_Session_Type;
      use type CIM.Session_Index;
      use type Musinfo.Memregion_Type;
      use type Standard.Interfaces.Unsigned_64;
      Req_Name  : Musinfo.Name_Type;
      Resp_Name : Musinfo.Name_Type;
      Req_Mem   : Musinfo.Memregion_Type;
      Resp_Mem  : Musinfo.Memregion_Type;
      Index     : CIM.Session_Index := CIM.Invalid_Index;
   begin
      Req_Name  := CIM.String_To_Name ("blk:req:" & Str (C));
      Resp_Name := CIM.String_To_Name ("blk:rsp:" & Str (C));
      Req_Mem   := Musinfo.Instance.Memory_By_Name (Req_Name);
      Resp_Mem  := Musinfo.Instance.Memory_By_Name (Resp_Name);
      for I in Reg.Registry'Range loop
         if Reg.Registry (I).Kind = CIM.None then
            Index := I;
            exit;
         end if;
      end loop;
      if
         Index = CIM.Invalid_Index
         or else Req_Mem = Musinfo.Null_Memregion
         or else Resp_Mem = Musinfo.Null_Memregion
      then
         return;
      end if;
      I.Name               := C.Name;
      I.Registry_Index     := Index;
      I.Request_Memory     := Req_Mem;
      I.Response_Memory    := Resp_Mem;
      I.Read_Select        := (others => Blk.Null_Event_Header);
      Reg.Registry (Index) := Reg.Session_Entry'(Kind               => CIM.Block_Server,
                                                 Block_Server_Event => Serv_Event);
      Serv.Initialize (Instance (I),
                       CIM.Str_Cut (String (C.Name)),
                       (if
                           I.Response_Memory.Size <= Standard.Interfaces.Unsigned_64 (Byte_Length'Last)
                        then
                           Byte_Length (I.Response_Memory.Size) --  PROOF steps: 800
                        else
                           Byte_Length'Last));
      if not Serv.Ready (Instance (I)) then
         Reg.Registry (I.Registry_Index) := Reg.Session_Entry'(Kind => CIM.None);
         I.Name                          := Blk.Null_Name;
         I.Registry_Index                := CIM.Invalid_Index;
         I.Request_Memory                := Musinfo.Null_Memregion;
         I.Response_Memory               := Musinfo.Null_Memregion;
         return;
      end if;
   end Session_Initialize;

   pragma Warnings (Off, """I"" is not modified, could be IN");
   procedure Session_Accept (D : in out Dispatcher_Session;
                             C :        Dispatcher_Capability;
                             I : in out Server_Session)
   is
      pragma Unreferenced (D);
      pragma Unreferenced (C);
      use type Standard.Interfaces.Unsigned_64;
   begin
      pragma Assert (Initialized (I));
      pragma Assert (if Initialized (I) then I.Response_Memory.Size = Blk.Channel_Size);
      pragma Assert (I.Response_Memory.Size = Blk.Channel_Size);
      Blk.Server_Response_Channel.Activate (I.Response_Memory,
                                            Blk.Server_Response_Channel.Channel.Header_Field_Type
                                               (Musinfo.Instance.TSC_Schedule_Start));
   end Session_Accept;
   pragma Warnings (On, """I"" is not modified, could be IN");

   procedure Session_Cleanup (D : in out Dispatcher_Session;
                              C :        Dispatcher_Capability;
                              I : in out Server_Session)
   is
      pragma Unreferenced (D);
      pragma Unreferenced (C);
      Req_Active  : Boolean;
      Resp_Active : Boolean;
      Stat        : Blk.Connection_Status;
   begin
      if Serv.Ready (Instance (I)) and then Initialized (I) then
         Blk.Server_Request_Channel.Is_Active (I.Request_Memory, Req_Active);
         Blk.Server_Response_Channel.Is_Active (I.Response_Memory, Resp_Active);
         Stat := Blk.Connection_Matrix (Req_Active, Resp_Active);
         if Stat = Blk.Client_Disconnect then
            Serv.Finalize (Instance (I));
            Blk.Server_Response_Channel.Deactivate (I.Response_Memory);
            Reg.Registry (I.Registry_Index) := Reg.Session_Entry'(Kind => CIM.None);
            I.Name                          := Blk.Null_Name;
            I.Registry_Index                := CIM.Invalid_Index;
            I.Request_Memory                := Musinfo.Null_Memregion;
            I.Response_Memory               := Musinfo.Null_Memregion;
            I.Read_Select                   := (others => Blk.Null_Event_Header);
            I.Read_Data                     := (others => (others => 0));
         end if;
      end if;
   end Session_Cleanup;

   procedure Check_Channels (D : Dispatcher_Instance)
   is
      use type Blk.Session_Name;
      use type Musinfo.Resource_Kind;
      use type Musinfo.Memregion_Type;
      use type Musinfo.Name_Size_Type;
      Iter        : Musinfo.Utils.Resource_Iterator_Type := Musinfo.Instance.Create_Resource_Iterator;
      Res         : Musinfo.Resource_Type;
      Req_Mem     : Musinfo.Memregion_Type;
      Resp_Mem    : Musinfo.Memregion_Type;
      Name        : Blk.Session_Name := Blk.Null_Name;
      Req_Active  : Boolean;
      Resp_Active : Boolean;
      Stat        : Blk.Connection_Status;
   begin
      while Musinfo.Instance.Has_Element (Iter) loop
         pragma Loop_Invariant (Musinfo.Instance.Belongs_To (Iter));
         Res := Musinfo.Instance.Element (Iter);
         if Res.Kind = Musinfo.Res_Memory
            and then Res.Name.Length > 8
            and then Musinfo.Utils.Names_Match (Res.Name, CIM.String_To_Name ("blk:req:"), 8)
         then
            Name (Name'First .. Name'First + Natural (Res.Name.Length) - 9) :=
               Blk.Session_Name (String (Res.Name.Data (
                  Positive (Res.Name.Data'First) + 8
                  .. Res.Name.Data'First + Positive (Res.Name.Length) - 1)));
         end if;
         if Name /= Blk.Null_Name then
            Req_Mem := Musinfo.Instance.Memory_By_Name
               (CIM.String_To_Name ("blk:req:" & CIM.Str_Cut (String (Name))));
            Resp_Mem := Musinfo.Instance.Memory_By_Name
               (CIM.String_To_Name ("blk:rsp:" & CIM.Str_Cut (String (Name))));
            if
               Req_Mem /= Musinfo.Null_Memregion
               and then Req_Mem.Flags.Channel
               and then not Req_Mem.Flags.Writable
               and then Resp_Mem /= Musinfo.Null_Memregion
               and then Resp_Mem.Flags.Channel
               and then Resp_Mem.Flags.Writable
            then
               Blk.Server_Request_Channel.Is_Active (Req_Mem, Req_Active);
               Blk.Server_Response_Channel.Is_Active (Resp_Mem, Resp_Active);
               Stat := Blk.Connection_Matrix (Req_Active, Resp_Active);
               if Stat = Blk.Client_Connect or Stat = Blk.Client_Disconnect then
                  Dispatch (D, Dispatcher_Capability'(Name   => Name,
                                                      Status => Stat));
               end if;
            end if;
         end if;
         Musinfo.Instance.Next (Iter);
      end loop;
   end Check_Channels;

   procedure Lemma_Dispatch (D : Dispatcher_Instance;
                             C : Dispatcher_Capability)
   is
   begin
      Dispatch (D, C);
   end Lemma_Dispatch;

end Componolit.Interfaces.Block.Dispatcher;
