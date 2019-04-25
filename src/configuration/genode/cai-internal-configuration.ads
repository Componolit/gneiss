
with Cxx.Configuration.Client;

package Cai.Internal.Configuration is

   type Client_Session is limited record
      Instance : Cxx.Configuration.Client.Class;
   end record;

end Cai.Internal.Configuration;
