
with Cxx;
with Cxx.Log.Client;

package Cai.Internal.Log is

   type Client_Session is limited record
      Instance : Cxx.Log.Client.Class;
   end record;

end Cai.Internal.Log;
