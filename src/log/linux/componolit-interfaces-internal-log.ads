with System;

package Componolit.Interfaces.Internal.Log is

   type Client_Session is limited record
      Label   : System.Address := System.Null_Address;
      Length  : Integer        := 0;
      Prev_Nl : Boolean        := True;
   end record;

end Componolit.Interfaces.Internal.Log;
