
with Gneiss.Types;

generic
   with procedure Event;
package Gneiss.Message.Client with
   SPARK_Mode
is

   procedure Initialize (Session    : in out Client_Session;
                         Capability :        Gneiss.Types.Capability;
                         Label      :        String);

   procedure Finalize (Session : in out Client_Session);

   function Available (Session : Client_Session) return Boolean with
      Pre => State (Session) = Initialized;

   procedure Write (Session : in out Client_Session;
                    Message :        Message_Buffer) with
      Pre  => State (Session) = Initialized,
      Post => State (Session) = Initialized
              and then Available (Session)'Old = Available (Session);

   procedure Read (Session : in out Client_Session;
                   Message :    out Message_Buffer) with
      Pre  => State (Session) = Initialized
              and then Available (Session),
      Post => State (Session) = Initialized;

end Gneiss.Message.Client;
