
with System;
with Interfaces;
with Musinfo;
with Musinfo.Instance;
with Debuglog.Types;
with Debuglog.Stream;
with Debuglog.Stream.Writer_Instance;
with Componolit.Interfaces.Muen;

package body Componolit.Interfaces.Log.Client with
   SPARK_Mode
is
   use type Standard.Interfaces.Unsigned_64;

   package CIM renames Componolit.Interfaces.Muen;

   function Initialized (C : Client_Session) return Boolean
   is
      use type CIM.Session_Index;
      use type CIM.Session_Type;
   begin
      return CIM.Session_Index (C) /= CIM.Invalid_Index
             and then CIM.Session_Registry (CIM.Session_Index (C)).Session = CIM.Log;
   end Initialized;

   function Create return Client_Session
   is
   begin
      return Client_Session (CIM.Invalid_Index);
   end Create;

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
      Pre => Initialized (C);

   procedure Put (C    : in out Client_Session;
                  Char :        Character)
   is
      SI : constant CIM.Session_Index            := CIM.Session_Index (C);
      MI : constant Debuglog.Types.Message_Index := CIM.Session_Registry (SI).Message_Index;
   begin
      if Char /= ASCII.NUL and then Char /= ASCII.CR then
         CIM.Session_Registry (SI).Message_Buffer.Message (MI) := Char;
         if MI = Debuglog.Types.Message_Index'Last or else Char = ASCII.LF then
            Flush (C);
         else
            CIM.Session_Registry (SI).Message_Index := MI + 1;
         end if;
      end if;
   end Put;

   procedure Put (C   : in out Client_Session;
                  Str :        String) with
      Pre => Initialized (C);

   procedure Put (C   : in out Client_Session;
                  Str :        String)
   is
   begin
      for Char of Str loop
         Put (C, Char);
      end loop;
   end Put;

   procedure Initialize (C     : in out Client_Session;
                         Cap   :        Componolit.Interfaces.Types.Capability;
                         Label :        String)
   is
      use type CIM.Session_Type;
      use type CIM.Session_Index;
      use type Musinfo.Memregion_Type;
      pragma Unreferenced (Cap);
      Name   : constant Musinfo.Name_Type := CIM.String_To_Name (Label);
      Index  : CIM.Session_Index := CIM.Invalid_Index;
      Memory : Musinfo.Memregion_Type;
   begin
      Memory := Musinfo.Instance.Memory_By_Name (Name);
      for I in CIM.Session_Registry'Range loop
         if CIM.Session_Registry (I).Session = CIM.None then
            Index := I;
            exit;
         end if;
      end loop;
      if Index /= CIM.Invalid_Index and then Memory /= Musinfo.Null_Memregion then
         CIM.Session_Registry (Index) := CIM.Session_Element'(Session        => CIM.Log,
                                                              Log_Name       => Name,
                                                              Log_Mem        => Memory,
                                                              Message_Index  => Debuglog.Types.Message_Index'First,
                                                              Message_Buffer => Debuglog.Types.Null_Data);
         Activate_Channel (Memory);
         C := Client_Session (Index);
      end if;
   end Initialize;

   procedure Finalize (C : in out Client_Session)
   is
   begin
      Deactivate_Channel (CIM.Session_Registry (CIM.Session_Index (C)).Log_Mem);
      CIM.Session_Registry (CIM.Session_Index (C)) := CIM.Session_Element'(Session => CIM.None);
      C := Client_Session (CIM.Invalid_Index);
   end Finalize;

   function Maximum_Message_Length (C : Client_Session) return Integer
   is
      pragma Unreferenced (C);
   begin
      return 200;
   end Maximum_Message_Length;

   function Get_Label (C : Client_Session) return String;

   function Get_Label (C : Client_Session) return String
   is
      I : constant CIM.Session_Index := CIM.Session_Index (C);
   begin
      return "[" & CIM.Name_To_String (CIM.Session_Registry (I).Log_Name) & "] ";
   end Get_Label;

   procedure Info (C       : in out Client_Session;
                   Msg     :        String;
                   Newline :        Boolean := True)
   is
   begin
      Put (C, Get_Label (C) & "Info: " & Msg);
      if Newline then
         Put (C, Character'Val (10));
      end if;
   end Info;

   procedure Warning (C       : in out Client_Session;
                      Msg     :        String;
                      Newline :        Boolean := True)
   is
   begin
      Put (C, Get_Label (C) & "Warning: " & Msg);
      if Newline then
         Put (C, Character'Val (10));
      end if;
   end Warning;

   procedure Error (C       : in out Client_Session;
                    Msg     :        String;
                    Newline :        Boolean := True)
   is
   begin
      Put (C, Get_Label (C) & "Error: " & Msg);
      if Newline then
         Put (C, Character'Val (10));
      end if;
   end Error;

   procedure Flush (C : in out Client_Session)
   is
      SI : constant CIM.Session_Index := CIM.Session_Index (C);
   begin
      CIM.Session_Registry (SI).Message_Buffer.Timestamp := Musinfo.Instance.TSC_Schedule_Start;
      Write_Channel (CIM.Session_Registry (SI).Log_Mem,
                     CIM.Session_Registry (SI).Message_Buffer);
      CIM.Session_Registry (SI).Message_Index  := Debuglog.Types.Message_Index'First;
      CIM.Session_Registry (SI).Message_Buffer := Debuglog.Types.Null_Data;
   end Flush;

end Componolit.Interfaces.Log.Client;
