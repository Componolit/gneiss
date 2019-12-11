
with System;
with Interfaces;
with Gneiss.Muen;
with Gneiss.Muen_Block;
with Gneiss.Muen_Registry;
with Musinfo;
with Musinfo.Instance;
with Musinfo.Utils;

package body Gneiss.Block.Dispatcher with
   SPARK_Mode
is
   package CIM renames Gneiss.Muen;
   package Blk renames Gneiss.Muen_Block;
   package Reg renames Gneiss.Muen_Registry;

   use type Blk.Connection_Status;

   procedure Check_Channels (D : in out Dispatcher_Session) with
      Pre => Initialized (D) and then not Accepted (D);

   function Serv_Event return System.Address;

   function Serv_Event return System.Address is
      (Serv.Event'Address) with
      SPARK_Mode => Off;

   function Session_Address (D : Dispatcher_Session) return System.Address;

   function Session_Address (D : Dispatcher_Session) return System.Address with
      SPARK_Mode => Off
   is
   begin
      return D'Address;
   end Session_Address;

   procedure Initialize (D   : in out Dispatcher_Session;
                         Cap :        Capability;
                         Tag :        Session_Id)
   is
      pragma Unreferenced (Cap);
      use type CIM.Async_Session_Type;
   begin
      if Initialized (D) then
         return;
      end if;
      for I in Reg.Registry'Range loop
         if Reg.Registry (I).Kind = CIM.None then
            D.Registry_Index := I;
            Reg.Registry (I) := Reg.Session_Entry'(Kind                 => CIM.Block_Dispatcher,
                                                   Block_Dispatch_Event => System.Null_Address,
                                                   Tag                  => Standard.Interfaces.Unsigned_32'Val
                                                                              (Session_Id'Pos (Tag)
                                                                               - Session_Id'Pos (Session_Id'First)),
                                                   Session              => Session_Address (D));
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
      if not Initialized (D) then
         return;
      end if;
      Reg.Registry (D.Registry_Index) := Reg.Session_Entry'(Kind => CIM.None);
      D.Registry_Index                := CIM.Invalid_Index;
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
                                 S : in out Server_Session;
                                 I :        Session_Id)
   is
      pragma Unreferenced (D);
      use type CIM.Async_Session_Type;
      use type CIM.Session_Id;
      use type Musinfo.Memregion_Type;
      use type Standard.Interfaces.Unsigned_64;
      Req_Name  : Musinfo.Name_Type;
      Resp_Name : Musinfo.Name_Type;
      Req_Mem   : Musinfo.Memregion_Type;
      Resp_Mem  : Musinfo.Memregion_Type;
      Index     : CIM.Session_Id := CIM.Invalid_Index;
   begin
      Req_Name  := CIM.String_To_Name ("blk:req:" & Str (C));
      Resp_Name := CIM.String_To_Name ("blk:rsp:" & Str (C));
      Req_Mem   := Musinfo.Instance.Memory_By_Name (Req_Name);
      Resp_Mem  := Musinfo.Instance.Memory_By_Name (Resp_Name);
      for J in Reg.Registry'Range loop
         if Reg.Registry (J).Kind = CIM.None then
            Index := J;
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
      S.Name               := C.Name;
      S.Registry_Index     := Index;
      S.Request_Memory     := Req_Mem;
      S.Response_Memory    := Resp_Mem;
      S.Read_Select        := (others => Blk.Null_Event_Header);
      Reg.Registry (Index) := Reg.Session_Entry'(Kind               => CIM.Block_Server,
                                                 Block_Server_Event => Serv_Event);
      S.Tag                := Standard.Interfaces.Unsigned_32'Val (Session_Id'Pos (I)
                                                                   - Session_Id'Pos (Session_Id'First));
      Serv.Initialize (S,
                       CIM.Str_Cut (String (C.Name)),
                       (if
                           S.Response_Memory.Size <= Standard.Interfaces.Unsigned_64 (Byte_Length'Last)
                        then
                           Byte_Length (S.Response_Memory.Size) --  PROOF steps: 800
                        else
                           Byte_Length'Last));
      if not Serv.Ready (S) then
         Reg.Registry (S.Registry_Index) := Reg.Session_Entry'(Kind => CIM.None);
         S.Name                          := Blk.Null_Name;
         S.Registry_Index                := CIM.Invalid_Index;
         S.Request_Memory                := Musinfo.Null_Memregion;
         S.Response_Memory               := Musinfo.Null_Memregion;
         return;
      end if;
   end Session_Initialize;

   pragma Warnings (Off, """I"" is not modified, could be IN");
   procedure Session_Accept (D : in out Dispatcher_Session;
                             C :        Dispatcher_Capability;
                             S : in out Server_Session)
   is
      pragma Unreferenced (D);
      pragma Unreferenced (C);
   begin
      Blk.Server_Response_Channel.Activate (S.Response_Memory,
                                            Blk.Server_Response_Channel.Channel.Header_Field_Type
                                               (Musinfo.Instance.TSC_Schedule_Start));
   end Session_Accept;
   pragma Warnings (On, """I"" is not modified, could be IN");

   procedure Session_Cleanup (D : in out Dispatcher_Session;
                              C :        Dispatcher_Capability;
                              S : in out Server_Session)
   is
      pragma Unreferenced (D);
      pragma Unreferenced (C);
      Req_Active  : Boolean;
      Resp_Active : Boolean;
      Stat        : Blk.Connection_Status;
   begin
      if Serv.Ready (S) and then Initialized (S) then
         Blk.Server_Request_Channel.Is_Active (S.Request_Memory, Req_Active);
         Blk.Server_Response_Channel.Is_Active (S.Response_Memory, Resp_Active);
         Stat := Blk.Connection_Matrix (Req_Active, Resp_Active);
         if Stat = Blk.Client_Disconnect then
            Serv.Finalize (S);
            Blk.Server_Response_Channel.Deactivate (S.Response_Memory);
            Reg.Registry (S.Registry_Index) := Reg.Session_Entry'(Kind => CIM.None);
            S.Name                          := Blk.Null_Name;
            S.Registry_Index                := CIM.Invalid_Index;
            S.Request_Memory                := Musinfo.Null_Memregion;
            S.Response_Memory               := Musinfo.Null_Memregion;
            S.Read_Select                   := (others => Blk.Null_Event_Header);
            S.Read_Data                     := (others => (others => 0));
         end if;
      end if;
   end Session_Cleanup;

   procedure Check_Channels (D : in out Dispatcher_Session)
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

   procedure Lemma_Dispatch (D : in out Dispatcher_Session;
                             C :        Dispatcher_Capability)
   is
   begin
      Dispatch (D, C);
   end Lemma_Dispatch;

end Gneiss.Block.Dispatcher;
