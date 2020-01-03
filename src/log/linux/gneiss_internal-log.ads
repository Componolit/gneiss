
with Gneiss.Message;

package Gneiss_Internal.Log is

   package Message_Log is new Gneiss.Message
      (Positive, Character, String, 1, 1024);

   type Client_Session is limited record
      Message : Message_Log.Client_Session;
   end record;

   type Dispatcher_Session is limited record
      Message : Message_Log.Dispatcher_Session;
   end record;

   type Server_Session is limited record
      Message : Message_Log.Server_Session;
   end record;

   type Dispatcher_Capability is new Message_Log.Dispatcher_Capability;

end Gneiss_Internal.Log;
