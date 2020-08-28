with System;
with Gneiss_Protocol;

package Gneiss_Internal.Main with
   SPARK_Mode
is

   subtype Index is Integer range -1 .. Integer'Last;

   type Permit is record
      Server : Index                     := 0;
      S_Type : Gneiss_Protocol.Kind_Type := Gneiss_Protocol.Kind_Type'First;
   end record;

   type Permit_List is array (1 .. 8) of Permit;

   type Provides is array (Gneiss_Protocol.Kind_Type) of System.Address;

   type Component is record
      Permits  : Permit_List;
      Services : Provides := (others => System.Null_Address);
   end record;

   type Component_Registry is array (Natural range <>) of Component;

   procedure Run;

end Gneiss_Internal.Main;
