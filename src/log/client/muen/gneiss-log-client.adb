
with System;
with Interfaces;
with Musinfo;
with Musinfo.Instance;
with Debuglog.Types;
with Debuglog.Stream;
with Debuglog.Stream.Writer_Instance;
with Gneiss.Muen;
with Gneiss.Muen_Registry;

package body Gneiss.Log.Client with
   SPARK_Mode
is
   use type Standard.Interfaces.Unsigned_64;

   package CIM renames Gneiss.Muen;
   package Reg renames Gneiss.Muen_Registry;

   function Event_Address return System.Address;

   function Event_Address return System.Address with
      SPARK_Mode => Off
   is
   begin
      return Event'Address;
   end Event_Address;

   procedure Activate_Channel (Mem : Musinfo.Memregion_Type) with
      Pre => Debuglog.Stream.Channel_Type'Size <= Mem.Size;

   procedure Activate_Channel (Mem : Musinfo.Memregion_Type) with
      SPARK_Mode => Off
   is
      Channel : Debuglog.Stream.Channel_Type with
         Address => System'To_Address (Mem.Address),
         Async_Readers;
   begin
      Debuglog.Stream.Writer_Instance.Initialize (Channel, 1);
   end Activate_Channel;

   procedure Deactivate_Channel (Mem : Musinfo.Memregion_Type) with
      Pre => Debuglog.Stream.Channel_Type'Size <= Mem.Size;

   procedure Deactivate_Channel (Mem : Musinfo.Memregion_Type) with
      SPARK_Mode => Off
   is
      Channel : Debuglog.Stream.Channel_Type with
         Address => System'To_Address (Mem.Address),
         Async_Readers;
   begin
      Debuglog.Stream.Writer_Instance.Deactivate (Channel);
   end Deactivate_Channel;

   procedure Write_Channel (Mem : Musinfo.Memregion_Type;
                            Msg : Debuglog.Types.Data_Type) with
      Pre => Debuglog.Stream.Channel_Type'Size <= Mem.Size;

   procedure Write_Channel (Mem : Musinfo.Memregion_Type;
                            Msg : Debuglog.Types.Data_Type) with
      SPARK_Mode => Off
   is
      Channel : Debuglog.Stream.Channel_Type with
         Address => System'To_Address (Mem.Address),
         Async_Readers;
   begin
      Debuglog.Stream.Writer_Instance.Write (Channel, Msg);
   end Write_Channel;

   procedure Put (C    : in out Client_Session;
                  Char :        Character) with
      Pre => Status (C) = Initialized;

   procedure Put (C    : in out Client_Session;
                  Char :        Character)
   is
   begin
      if Char /= ASCII.NUL and then Char /= ASCII.CR then
         C.Buffer.Message (C.Index) := Char;
         if C.Index = Debuglog.Types.Message_Index'Last or else Char = ASCII.LF then
            Flush (C);
         else
            C.Index := C.Index + 1;
         end if;
      end if;
   end Put;

   procedure Print (Session : in out Client_Session;
                    Msg     :        String)
   is
   begin
      for C of Msg loop
         Put (Session, C);
      end loop;
   end Print;

   procedure Initialize (Session : in out Client_Session;
                         Cap     :        Capability;
                         Label   :        String;
                         Idx     :        Session_Index := 0)
   is
      use type Musinfo.Name_Type;
      use type Musinfo.Memregion_Type;
      use type CIM.Session_Id;
      use type CIM.Async_Session_Type;
      pragma Unreferenced (Cap);
      Name   : constant Musinfo.Name_Type := CIM.String_To_Name (Label);
      Memory : Musinfo.Memregion_Type;
      M_Idx  : CIM.Session_Id;
   begin
      if Status (Session) = Initialized then
         return;
      end if;
      for I in Reg.Registry'Range loop
         if Reg.Registry (I).Kind = CIM.None then
            M_Idx := I;
            exit;
         end if;
      end loop;
      Memory := Musinfo.Instance.Memory_By_Name (Name);
      if
         Name /= Musinfo.Null_Name
         and then Memory /= Musinfo.Null_Memregion
         and then M_Idx /= CIM.Invalid_Index
      then
         Reg.Registry (M_Idx) := Reg.Session_Entry'(Kind             => CIM.Log_Client,
                                                    Log_Client_Event => Event_Address);
         Session.R_Index := M_Idx;
         Session.Name    := Name;
         Session.Mem     := Memory;
         Session.S_Index := Idx;
         Activate_Channel (Memory);
      end if;
   end Initialize;

   procedure Finalize (Session : in out Client_Session)
   is
   begin
      if Status (Session) = Uninitialized then
         return;
      end if;
      Deactivate_Channel (Session.Mem);
      Reg.Registry (Session.R_Index) := Reg.Session_Entry'(Kind => CIM.None);
      Session.R_Index := CIM.Invalid_Index;
      Session.S_Index := 0;
      Session.Name    := Musinfo.Null_Name;
      Session.Mem     := Musinfo.Null_Memregion;
      Session.Index   := Debuglog.Types.Message_Index'First;
      Session.Buffer  := Debuglog.Types.Null_Data;
   end Finalize;

   function Get_Label (C : Client_Session) return String;

   function Get_Label (C : Client_Session) return String
   is
   begin
      return "[" & CIM.Name_To_String (C.Name) & "] ";
   end Get_Label;

   procedure Info (Session : in out Client_Session;
                   Msg     :        String;
                   Newline :        Boolean := True)
   is
   begin
      Print (Session, Get_Label (Session) & "Info: " & Msg);
      if Newline then
         Put (Session, ASCII.LF);
      end if;
   end Info;

   procedure Warning (Session : in out Client_Session;
                      Msg     :        String;
                      Newline :        Boolean := True)
   is
   begin
      Print (Session, Get_Label (Session) & "Warning: " & Msg);
      if Newline then
         Put (Session, ASCII.LF);
      end if;
   end Warning;

   procedure Error (Session : in out Client_Session;
                    Msg     :        String;
                    Newline :        Boolean := True)
   is
   begin
      Print (Session, Get_Label (Session) & "Error: " & Msg);
      if Newline then
         Put (Session, ASCII.LF);
      end if;
   end Error;

   procedure Flush (Session : in out Client_Session)
   is
   begin
      Session.Buffer.Timestamp := Musinfo.Instance.TSC_Schedule_Start;
      Write_Channel (Session.Mem,
                     Session.Buffer);
      Session.Index  := Debuglog.Types.Message_Index'First;
      Session.Buffer := Debuglog.Types.Null_Data;
   end Flush;

end Gneiss.Log.Client;
