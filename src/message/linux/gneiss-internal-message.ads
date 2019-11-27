
package Gneiss.Internal.Message with
   SPARK_Mode
is

   type Client_Session is record
      File_Descriptor : Integer := -1;
      Broker          : Integer := -1;
   end record;

   type Server_Session is record
      null;
   end record;

   type Dispatcher_Session is record
      null;
   end record;

   type Dispatcher_Capability is null record;

end Gneiss.Internal.Message;
