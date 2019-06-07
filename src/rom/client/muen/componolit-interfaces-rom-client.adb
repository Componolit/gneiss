
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
      return Client_Session (CIM.Invalid_Index);
   end Create;

   function Initialized (C : Client_Session) return Boolean
   is
      use type CIM.Session_Index;
      use type CIM.Session_Type;
      I : constant CIM.Session_Index := CIM.Session_Index (C);
   begin
      return I /= CIM.Invalid_Index and then CIM.Session_Registry (I).Session = CIM.Rom;
   end Initialized;

   procedure Initialize (C    : in out Client_Session;
                         Cap  :        Componolit.Interfaces.Types.Capability;
                         Name :        String := "")
   is
      pragma Unreferenced (Cap);
      use type CIM.Session_Index;
      use type CIM.Session_Type;
      use type Musinfo.Memregion_Type;
      Rom_Name : constant Musinfo.Name_Type :=
         (if Name = "" then CIM.String_To_Name ("config") else CIM.String_To_Name (Name));
      SI : CIM.Session_Index := CIM.Invalid_Index;
      Memory : constant Musinfo.Memregion_Type := Musinfo.Instance.Memory_By_Name (Rom_Name);
   begin
      for I in CIM.Session_Registry'Range loop
         if CIM.Session_Registry (I).Session = CIM.None then
            SI := I;
            exit;
         end if;
      end loop;
      if SI /= CIM.Invalid_Index and then Memory /= Musinfo.Null_Memregion then
         CIM.Session_Registry (SI) := CIM.Session_Element'(Session  => CIM.Rom,
                                                              Rom_Mem  => Memory);
         C := Client_Session (SI);
      end if;
   end Initialize;

   procedure Load (C : in out Client_Session)
   is
      use type Standard.Interfaces.Unsigned_64;
      function Max_Index (Size : Standard.Interfaces.Unsigned_64) return Index is
         (if Standard.Interfaces.Unsigned_64 (Index'Last) > Size then Index (Size) else Index'Last);
      I : constant Index :=
         Max_Index (CIM.Session_Registry (CIM.Session_Index (C)).Rom_Mem.Size / (Element'Size / 8));
      B : Buffer (Index'First .. Index'First + I - 1) with
         Address => System'To_Address (CIM.Session_Registry (CIM.Session_Index (C)).Rom_Mem.Address);
   begin
      Parse (B);
   end Load;

   procedure Finalize (C : in out Client_Session)
   is
   begin
      CIM.Session_Registry (CIM.Session_Index (C)) := CIM.Session_Element'(Session => CIM.None);
      C := Client_Session (CIM.Invalid_Index);
   end Finalize;

end Componolit.Interfaces.Rom.Client;
