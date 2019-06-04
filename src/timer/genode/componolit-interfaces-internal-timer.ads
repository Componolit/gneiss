
with Cxx.Timer.Client;

package Componolit.Interfaces.Internal.Timer is

   type Client_Session is limited record
      Instance : Cxx.Timer.Client.Class;
   end record;

end Componolit.Interfaces.Internal.Timer;
