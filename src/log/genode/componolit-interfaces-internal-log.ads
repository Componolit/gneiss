
with Cxx;
with Cxx.Log.Client;

package Componolit.Interfaces.Internal.Log is

   type Client_Session is limited record
      Instance : Cxx.Log.Client.Class;
   end record;

end Componolit.Interfaces.Internal.Log;
