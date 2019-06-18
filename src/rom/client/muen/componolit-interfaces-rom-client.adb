
with System;
with Interfaces;
with Componolit.Interfaces.Muen;
with Musinfo;
with Musinfo.Instance;

package body Componolit.Interfaces.Rom.Client with
   SPARK_Mode
is
   package CIM renames Componolit.Interfaces.Muen;

   function Create return Client_Session
   is
   begin
      return Client_Session'(Mem => Musinfo.Null_Memregion);
   end Create;

   function Initialized (C : Client_Session) return Boolean
   is
      use type Musinfo.Memregion_Type;
   begin
      return C.Mem /= Musinfo.Null_Memregion;
   end Initialized;

   procedure Initialize (C    : in out Client_Session;
                         Cap  :        Componolit.Interfaces.Types.Capability;
                         Name :        String := "")
   is
      pragma Unreferenced (Cap);
      Rom_Name : constant Musinfo.Name_Type :=
         (if Name = "" then CIM.String_To_Name ("config") else CIM.String_To_Name (Name));
   begin
      C.Mem := Musinfo.Instance.Memory_By_Name (Rom_Name);
   end Initialize;

   procedure Load (C : in out Client_Session)
   is
      use type Standard.Interfaces.Unsigned_64;
      function Max_Index (Size : Standard.Interfaces.Unsigned_64) return Index is
         (if Standard.Interfaces.Unsigned_64 (Index'Last) > Size then Index (Size) else Index'Last);
      I : constant Index := Max_Index (C.Mem.Size / (Element'Size / 8));
      B : Buffer (Index'First .. Index'First + I - 1) with
         Address => System'To_Address (C.Mem.Address);
   begin
      Parse (B);
   end Load;

   procedure Finalize (C : in out Client_Session)
   is
   begin
      C.Mem := Musinfo.Null_Memregion;
   end Finalize;

end Componolit.Interfaces.Rom.Client;
