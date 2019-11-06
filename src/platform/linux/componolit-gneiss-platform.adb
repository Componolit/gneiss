
with Ada.Unchecked_Conversion;
with Componolit.Gneiss.Internal.Types;

package body Componolit.Gneiss.Platform with
   SPARK_Mode => Off
is

   function Convert is new Ada.Unchecked_Conversion (Gns.Types.Capability, Gns.Internal.Types.Capability);

   procedure Set_Status (C : Gns.Types.Capability;
                         S : Integer)
   is
      procedure Set (Cp : Gns.Types.Capability;
                     St : Integer) with
         Import,
         Address => Convert (C).Set_Status;
   begin
      Set (C, S);
   end Set_Status;

   procedure Find_Resource (C :     Gns.Types.Capability;
                            T :     String;
                            N :     String;
                            M :     Integer;
                            E :     System.Address;
                            D : out Resource_Descriptor)
   is
      procedure Find_Res (Cap    :     Gns.Types.Capability;
                          R_Type :     System.Address;
                          Name   :     System.Address;
                          Mode   :     Integer;
                          Event  :     System.Address;
                          Res    : out Resource_Descriptor) with
         Import,
         Address => Convert (C).Find_Resource;
      C_Type : String := T & Character'First;
      C_Name : String := N & Character'First;
   begin
      Find_Res (C, C_Type'Address, C_Name'Address, M, E, D);
   end Find_Resource;

end Componolit.Gneiss.Platform;
