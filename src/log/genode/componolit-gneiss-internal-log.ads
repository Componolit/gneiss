
with Cxx;
with Cxx.Log.Client;

package Componolit.Gneiss.Internal.Log is

   type Client_Session is limited record
      Instance : Cxx.Log.Client.Class := Cxx.Log.Client.Constructor;
      Buffer   : String (1 .. 4096)   := (others => Character'First);
      Cursor   : Positive             := 1;
   end record;

end Componolit.Gneiss.Internal.Log;
