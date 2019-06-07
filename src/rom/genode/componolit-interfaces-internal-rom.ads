
with Cxx.Configuration.Client;

package Componolit.Interfaces.Internal.Rom is

   type Client_Session is limited record
      Instance : Cxx.Configuration.Client.Class;
   end record;

end Componolit.Interfaces.Internal.Rom;
