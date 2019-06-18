
with System;
with Interfaces;
with Componolit.Interfaces.Muen;
with Componolit.Interfaces.Muen_Block;
with Componolit.Interfaces.Muen_Registry;
with Musinfo;
with Musinfo.Instance;

package body Componolit.Interfaces.Block.Client with
   SPARK_Mode
is
   use type Musinfo.Memregion_Type;
   use type Standard.Interfaces.Unsigned_64;
   package CIM renames Componolit.Interfaces.Muen;
   package Blk renames Componolit.Interfaces.Muen_Block;
   package Reg renames Componolit.Interfaces.Muen_Registry;

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
                             Registry_Index  => CIM.Invalid_Index);
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

   procedure Activate_Channels (Req  : Musinfo.Memregion_Type) with
      Pre => Req /= Musinfo.Null_Memregion
             and then Req.Size  >= Blk.Request_Channel.Channel_Type'Size;

   procedure Activate_Channels (Req  : Musinfo.Memregion_Type) with
      SPARK_Mode => Off
   is
      Req_Channel : Blk.Request_Channel.Channel_Type with
         Address => System'To_Address (Req.Address),
         Async_Readers;
   begin
      Blk.Request_Writer.Initialize (Req_Channel, 1);
   end Activate_Channels;

   procedure Initialize (C           : in out Client_Session;
                         Cap         :        Componolit.Interfaces.Types.Capability;
                         Path        :        String;
                         Buffer_Size :        Byte_Length := 0)
   is
      use type CIM.Async_Session_Type;
      pragma Unreferenced (Cap);
      pragma Unreferenced (Buffer_Size);
   begin
      if Path'Length <= Componolit.Interfaces.Muen_Block.Session_Name'Length then
         for I in Reg.Registry'Range loop
            if Reg.Registry (I).Kind = CIM.None then
               C.Registry_Index := I;
               Reg.Registry (I) := Reg.Session_Entry'(Kind            => CIM.Block,
                                                      Response_Memory =>
                                                         Musinfo.Instance.Memory_By_Name
                                                            (CIM.String_To_Name ("rsp:" & Path)),
                                                      Block_Event     => Event'Address);
               exit;
            end if;
         end loop;
         C.Name (C.Name'First .. C.Name'First + Path'Length - 1) :=
            Componolit.Interfaces.Muen_Block.Session_Name (Path);
         C.Request_Memory := Musinfo.Instance.Memory_By_Name (CIM.String_To_Name ("req:" & Path));
         Activate_Channels (C.Request_Memory);
      else
         Set_Null (C);
      end if;
   end Initialize;

   procedure Deactivate_Channels (Req  : Musinfo.Memregion_Type) with
      Pre => Req /= Musinfo.Null_Memregion;

   procedure Deactivate_Channels (Req  : Musinfo.Memregion_Type) with
      SPARK_Mode => Off
   is
      Req_Channel : Blk.Request_Channel.Channel_Type with
         Address => System'To_Address (Req.Address),
         Async_Readers;
   begin
      Blk.Request_Writer.Deactivate (Req_Channel);
   end Deactivate_Channels;

   procedure Finalize (C : in out Client_Session)
   is
   begin
      Deactivate_Channels (C.Request_Memory);
      Set_Null (C);
   end Finalize;

   function Supported (C : Client_Session;
                       R : Request_Kind) return Boolean
   is
      pragma Unreferenced (C);
      pragma Unreferenced (R);
   begin
      return False;
   end Supported;

   function Ready (C : Client_Session;
                   R : Request) return Boolean
   is
      pragma Unreferenced (C);
      pragma Unreferenced (R);
   begin
      return False;
   end Ready;

   procedure Enqueue (C : in out Client_Session;
                      R :        Request)
   is
      pragma Unreferenced (C);
      pragma Unreferenced (R);
   begin
      null;
   end Enqueue;

   procedure Submit (C : in out Client_Session)
   is
      pragma Unreferenced (C);
   begin
      null;
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
      pragma Unreferenced (C);
   begin
      return 0;
   end Block_Count;

   function Block_Size (C : Client_Session) return Size
   is
      pragma Unreferenced (C);
   begin
      return 512;
   end Block_Size;

   function Maximum_Transfer_Size (C : Client_Session) return Byte_Length
   is
      pragma Unreferenced (C);
   begin
      return 0;
   end Maximum_Transfer_Size;

end Componolit.Interfaces.Block.Client;
