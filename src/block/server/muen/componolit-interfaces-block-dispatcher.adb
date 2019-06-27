
with System;
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

   procedure Check_Channels;

   function Initialized (D : Dispatcher_Session) return Boolean
   is
      use type CIM.Session_Index;
   begin
      return D.Registry_Index /= CIM.Invalid_Index;
   end Initialized;

   function Create return Dispatcher_Session
   is
   begin
      return Dispatcher_Session'(Registry_Index => Componolit.Interfaces.Muen.Invalid_Index);
   end Create;

   function Get_Instance (D : Dispatcher_Session) return Dispatcher_Instance
   is
   begin
      return Dispatcher_Instance (D.Registry_Index);
   end Get_Instance;

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

   procedure Session_Request (D     : in out Dispatcher_Session;
                              Cap   :        Dispatcher_Capability;
                              Valid :    out Boolean;
                              Label :    out String;
                              Last  :    out Natural)
   is
      pragma Unreferenced (D);
      use type Blk.Connection_Status;
      Name : constant String := CIM.Str_Cut (String (Cap.Name));
   begin
      if
         Cap.Status = Blk.Client_Connect
         and then Name (Name'First) /= Character'First
         and then Label'Length >= Name'Length
      then
         Label (Label'First .. Label'First + Name'Length - 1) := Name (Name'First .. Name'Last);
         Valid := True;
         Last := Name'Last;
      else
         Valid := False;
      end if;
   end Session_Request;

   procedure Session_Accept (D : in out Dispatcher_Session;
                             C :        Dispatcher_Capability;
                             I : in out Server_Session;
                             L :        String)
   is
      pragma Unreferenced (D);
      pragma Unreferenced (C);
      use type CIM.Async_Session_Type;
      use type CIM.Session_Index;
      use type Musinfo.Memregion_Type;
      use type Blk.Connection_Status;
      Name      : Blk.Session_Name;
      S_Name    : String (1 .. Blk.Session_Name'Length);
      Req_Name  : Musinfo.Name_Type;
      Resp_Name : Musinfo.Name_Type;
      Req_Mem   : Musinfo.Memregion_Type;
      Resp_Mem  : Musinfo.Memregion_Type;
      Index     : CIM.Session_Index := CIM.Invalid_Index;
      Req_Act   : Boolean;
      Resp_Act  : Boolean;
      Status    : Blk.Connection_Status;
   begin
      if L'Length <= Name'Length then
         S_Name (S_Name'First .. S_Name'First + L'Length - 1) := L (L'First .. L'Last);
         Name := Blk.Session_Name (S_Name);
         Req_Name  := CIM.String_To_Name ("blk:req:" & CIM.Str_Cut (String (Name)));
         Resp_Name := CIM.String_To_Name ("blk:rsp:" & CIM.Str_Cut (String (Name)));
         Req_Mem   := Musinfo.Instance.Memory_By_Name (Req_Name);
         Resp_Mem  := Musinfo.Instance.Memory_By_Name (Resp_Name);
         for I in Reg.Registry'Range loop
            if Reg.Registry (I).Kind = CIM.None then
               Index := I;
               exit;
            end if;
         end loop;
         if
            Index /= CIM.Invalid_Index
            and then Req_Mem /= Musinfo.Null_Memregion
            and then Resp_Mem /= Musinfo.Null_Memregion
         then
            Blk.Server_Request_Channel.Is_Active (Req_Mem, Req_Act);
            Blk.Server_Response_Channel.Is_Active (Resp_Mem, Resp_Act);
            Status := Blk.Connection_Matrix (Req_Act, Resp_Act);
            if Status = Blk.Client_Connect then
               I.Name               := Name;
               I.Registry_Index     := Index;
               I.Request_Memory     := Req_Mem;
               I.Response_Memory    := Resp_Mem;
               I.Queued             := 0;
               Reg.Registry (Index) := Reg.Session_Entry'(Kind               => CIM.Block_Server,
                                                          Block_Server_Event => Serv.Event'Address);
               Serv.Initialize (Serv.Get_Instance (I),
                                L,
                                Byte_Length (I.Response_Memory.Size));
               Blk.Server_Response_Channel.Activate (Resp_Mem, Blk.Server_Response_Channel.Channel.Header_Field_Type
                                                                  (Musinfo.Instance.TSC_Schedule_Start));
            end if;
         end if;
      end if;
   end Session_Accept;

   procedure Session_Cleanup (D : in out Dispatcher_Session;
                              C :        Dispatcher_Capability;
                              I : in out Server_Session)
   is
      pragma Unreferenced (D);
      pragma Unreferenced (C);
      use type Blk.Connection_Status;
      Req_Active  : Boolean;
      Resp_Active : Boolean;
      Status      : Blk.Connection_Status;
   begin
      Blk.Server_Request_Channel.Is_Active (I.Request_Memory, Req_Active);
      Blk.Server_Response_Channel.Is_Active (I.Response_Memory, Resp_Active);
      Status := Blk.Connection_Matrix (Req_Active, Resp_Active);
      if Status = Blk.Client_Disconnect then
         Serv.Finalize (Serv.Get_Instance (I));
         Blk.Server_Response_Channel.Deactivate (I.Response_Memory);
         Reg.Registry (I.Registry_Index) := Reg.Session_Entry'(Kind => CIM.None);
         I.Name                          := Blk.Null_Name;
         I.Registry_Index                := CIM.Invalid_Index;
         I.Request_Memory                := Musinfo.Null_Memregion;
         I.Response_Memory               := Musinfo.Null_Memregion;
         I.Queued                        := 0;
         I.Latest_Request                := Blk.Null_Event;
         I.Latest_Cache_Index            := 0;
         for J in I.Request_Cache'Range loop
            I.Request_Cache (J).Age := 0;
         end loop;
      end if;
   end Session_Cleanup;

   procedure Check_Channels
   is
      use type Blk.Session_Name;
      use type Blk.Connection_Status;
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
      Status      : Blk.Connection_Status;
   begin
      while Musinfo.Instance.Has_Element (Iter) loop
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
         end if;
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
            Status := Blk.Connection_Matrix (Req_Active, Resp_Active);
            if Status = Blk.Client_Connect or Status = Blk.Client_Disconnect then
               Dispatch (Dispatcher_Capability'(Name   => Name,
                                                Status => Status));
            end if;
         end if;
         Musinfo.Instance.Next (Iter);
      end loop;
   end Check_Channels;

end Componolit.Interfaces.Block.Dispatcher;
