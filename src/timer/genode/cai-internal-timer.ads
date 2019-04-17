
with Cxx.Timer.Client;

package Cai.Internal.Timer is

   type Client_Session is limited record
      Instance : Cxx.Timer.Client.Class;
   end record;

end Cai.Internal.Timer;
