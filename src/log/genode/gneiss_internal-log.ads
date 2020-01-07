
with Gneiss;
with Cxx;
with Cxx.Log.Client;

package Gneiss_Internal.Log is

   type Client_Session is limited record
      Instance : Cxx.Log.Client.Class := Cxx.Log.Client.Constructor;
      Buffer   : String (1 .. 4096)   := (others => Character'First);
      Cursor   : Positive             := 1;
      Index    : Gneiss.Session_Index := 0;
   end record;

   type Dispatcher_Session is limited record
      null;
   end record;

   type Server_Session is limited record
      null;
   end record;

   type Dispatcher_Capability is limited record
      null;
   end record;

end Gneiss_Internal.Log;
