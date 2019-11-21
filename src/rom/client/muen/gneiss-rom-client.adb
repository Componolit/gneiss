
with System;
with Interfaces;
with Gneiss.Muen;
with Musinfo;
with Musinfo.Instance;

package body Gneiss.Rom.Client with
   SPARK_Mode
is
   package CIM renames Gneiss.Muen;

   procedure Initialize (C    : in out Client_Session;
                         Cap  :        Gneiss.Types.Capability;
                         Name :        String := "")
   is
      pragma Unreferenced (Cap);
      Rom_Name : constant Musinfo.Name_Type :=
         (if Name = "" then CIM.String_To_Name ("config") else CIM.String_To_Name (Name));
   begin
      if Initialized (C) or else not Musinfo.Instance.Is_Valid then
         return;
      end if;
      C.Mem := Musinfo.Instance.Memory_By_Name (Rom_Name);
   end Initialize;

   procedure Load (C : in out Client_Session)
   is
      use type Standard.Interfaces.Unsigned_64;
      function Max_Index (Size : Standard.Interfaces.Unsigned_64) return Index is
         (if Standard.Interfaces.Unsigned_64 (Index'Last - Index'First) > Size
          and then Standard.Interfaces.Unsigned_64 (Index'Last) <= Size then Index (Size) else Index'Last);
      I : constant Index := Max_Index (C.Mem.Size / (Element'Size / 8));
      B : Buffer (Index'First .. Index'First + I - 1) with
         Import,
         Address => System'To_Address (C.Mem.Address);
   begin
      Parse (B);
   end Load;

   procedure Finalize (C : in out Client_Session)
   is
   begin
      if not Initialized (C) then
         return;
      end if;
      C.Mem := Musinfo.Null_Memregion;
   end Finalize;

end Gneiss.Rom.Client;
