with System;

package Componolit.Gneiss.Internal.Types is

   type Capability is record
      Component  : System.Address;
      Set_Status : System.Address;
      Padding    : System.Address; --  FIXME: only padded to trigger pass by reference
   end record;

end Componolit.Gneiss.Internal.Types;
