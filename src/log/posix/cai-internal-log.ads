with System;

package Cai.Internal.Log is

   type Client_Session is limited record
      Label          : System.Address;
      Length         : Integer;
      Prev_Nl        : Boolean;
   end record;

end Cai.Internal.Log;
