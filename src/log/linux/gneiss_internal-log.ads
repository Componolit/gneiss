
with Gneiss.Message;
with Gneiss_Internal.Message;

package Gneiss_Internal.Log is

   package Message_Log is new Gneiss.Message
      (Positive, Character, String, 1, 1024);

   type Client_Session is limited record
      Message : Message_Log.Client_Session;
      Buffer  : Message_Log.Message_Buffer := (others => ASCII.NUL);
      Cursor  : Natural                    := 0;
      Newline : Boolean                    := True;
   end record;

   type Dispatcher_Session is new Gneiss_Internal.Message.Dispatcher_Session;

   type Server_Session is limited record
      Fd     : Integer                    := -1;
      Index  : Gneiss.Session_Index       := 0;
      Buffer : Message_Log.Message_Buffer := (others => ASCII.NUL);
      Cursor : Positive                   := 1;
   end record;

   type Dispatcher_Capability is new Gneiss_Internal.Message.Dispatcher_Capability;

end Gneiss_Internal.Log;
