with System;

package Componolit.Gneiss.Internal.Types is

   type Capability is record
      Component     : System.Address;
      Set_Status    : System.Address;
      Find_Resource : System.Address;
   end record;

end Componolit.Gneiss.Internal.Types;
