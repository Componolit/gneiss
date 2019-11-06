
with System;
with Componolit.Gneiss.Types;

package Componolit.Gneiss.Platform with
   SPARK_Mode => Off
is
   package Gns renames Componolit.Gneiss;

   type Resource_Descriptor is record
      R_Type : System.Address;
      Name   : System.Address;
      Label  : System.Address;
      Mode   : Integer;
      Fd     : Integer;
      Event  : System.Address;
   end record;

   --  Set the application return state
   --
   --  @param C  System capability
   --  @param S  Status code (0 - Success, 1 - Failure)
   procedure Set_Status (C : Gns.Types.Capability;
                         S : Integer);

   --  Acquire a system resource
   --
   --  @param C  System capability
   --  @param T  Resource type
   --  @param N  Resource name
   --  @param M  Resource Mode (1 - Read, 2 - Write, 3 - Read/Write)
   --  @param E  Event procedure address
   --  @param D  Resulting resource descriptor
   procedure Find_Resource (C :     Gns.Types.Capability;
                            T :     String;
                            N :     String;
                            M :     Integer;
                            E :     System.Address;
                            D : out Resource_Descriptor);

end Componolit.Gneiss.Platform;
