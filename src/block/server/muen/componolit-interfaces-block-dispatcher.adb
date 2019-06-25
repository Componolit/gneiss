with System;
with Componolit.Interfaces.Muen;
with Componolit.Interfaces.Muen_Block;
with Componolit.Interfaces.Muen_Registry;

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
                                                   Block_Dispatch_Event => System.Null_Address,
                                                   Current_Session_Name => Blk.Null_Name);
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
                              Valid :    out Boolean;
                              Label :    out String;
                              Last  :    out Natural)
   is
      Name : constant String := CIM.Str_Cut (String (Reg.Registry (D.Registry_Index).Current_Session_Name));
   begin
      if Name (Name'First) /= Character'First and then Label'Length >= Name'Length then
         Label (Label'First .. Label'First + Name'Length - 1) := Name (Name'First .. Name'Last);
         Valid := True;
         Last := Name'Last;
      else
         Valid := False;
      end if;
   end Session_Request;

   procedure Session_Accept (D : in out Dispatcher_Session;
                             I : in out Server_Session;
                             L :        String)
   is
      pragma Unreferenced (D);
      pragma Unreferenced (I);
      pragma Unreferenced (L);
   begin
      null;
   end Session_Accept;

   procedure Session_Cleanup (D : in out Dispatcher_Session;
                              I : in out Server_Session)
   is
      pragma Unreferenced (D);
      pragma Unreferenced (I);
   begin
      null;
   end Session_Cleanup;

   procedure Check_Channels
   is
   begin
      null;
   end Check_Channels;

end Componolit.Interfaces.Block.Dispatcher;
