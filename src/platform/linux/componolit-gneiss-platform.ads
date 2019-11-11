
with System;
with Componolit.Gneiss.Types;

package Componolit.Gneiss.Platform with
   SPARK_Mode
is
   package Gns renames Componolit.Gneiss;

   type Resource_Descriptor is private;

   type Access_Mode is (Read, Write, Read_Write);

   --  Set the application return state
   --
   --  @param C  System capability
   --  @param S  Status code (0 - Success, 1 - Failure)
   procedure Set_Status (C : Gns.Types.Capability;
                         S : Integer);

   function Get_Resource_Descriptor (C : Gns.Types.Capability) return Resource_Descriptor with
      Import,
      Convention => C,
      External_Name => "get_resource_pointer";

   function Valid_Resource_Descriptor (R : Resource_Descriptor) return Boolean;

   function Next_Resource_Descriptor (R : Resource_Descriptor) return Resource_Descriptor with
      Pre => Valid_Resource_Descriptor (R),
      Import,
      Convention => C,
      External_Name => "next_resource_pointer";

   function Resource_Type (R : Resource_Descriptor) return String with
      Pre => Valid_Resource_Descriptor (R);

   function Resource_Label (R : Resource_Descriptor) return String with
      Pre => Valid_Resource_Descriptor (R);

   function Resource_Mode (R : Resource_Descriptor) return Access_Mode with
      Pre => Valid_Resource_Descriptor (R);

   procedure Resource_Set_Event (R :     Resource_Descriptor;
                                 E :     System.Address;
                                 S : out Boolean);

   procedure Resource_Delete_Event (R :     Resource_Descriptor;
                                    E :     System.Address;
                                    S : out Boolean);

   function Invalid_Resource return Resource_Descriptor with
      Import,
      Convention => C,
      External_Name => "invalid_resource_pointer";

private

   type Resource_Descriptor is new System.Address;

end Componolit.Gneiss.Platform;
