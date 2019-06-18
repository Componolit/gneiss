
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
      use type Musinfo.Name_Type;
      use type Musinfo.Memregion_Type;
   begin
      return C.Name /= Musinfo.Null_Name and C.Mem /= Musinfo.Null_Memregion;
   end Initialized;

   function Create return Client_Session
   is
   begin
      return Client_Session'(Name   => Musinfo.Null_Name,
                             Mem    => Musinfo.Null_Memregion,
                             Index  => Debuglog.Types.Message_Index'First,
                             Buffer => Debuglog.Types.Null_Data);
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
      use type Musinfo.Name_Type;
      use type Musinfo.Memregion_Type;
      pragma Unreferenced (Cap);
      Name   : constant Musinfo.Name_Type := CIM.String_To_Name (Label);
      Memory : Musinfo.Memregion_Type;
   begin
      Memory := Musinfo.Instance.Memory_By_Name (Name);
      if Name /= Musinfo.Null_Name and Memory /= Musinfo.Null_Memregion then
         C.Name := Name;
         C.Mem  := Memory;
         Activate_Channel (Memory);
      end if;
   end Initialize;

   procedure Finalize (C : in out Client_Session)
   is
   begin
      Deactivate_Channel (C.Mem);
      C.Name   := Musinfo.Null_Name;
      C.Mem    := Musinfo.Null_Memregion;
      C.Index  := Debuglog.Types.Message_Index'First;
      C.Buffer := Debuglog.Types.Null_Data;
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
   begin
      return "[" & CIM.Name_To_String (C.Name) & "] ";
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
   begin
      C.Buffer.Timestamp := Musinfo.Instance.TSC_Schedule_Start;
      Write_Channel (C.Mem,
                     C.Buffer);
      C.Index  := Debuglog.Types.Message_Index'First;
      C.Buffer := Debuglog.Types.Null_Data;
   end Flush;

end Componolit.Interfaces.Log.Client;
