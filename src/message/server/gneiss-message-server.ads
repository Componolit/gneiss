
generic
   with procedure Event;
   with Procedure Initialize (Session : in out Server_Session;
                              Label   :        String);
   with procedure Finalize (Session : in out Server_Session);
   with function Ready (Session : Server_Session) return Boolean;
package Gneiss.Message.Server with
   SPARK_Mode
is

   function Available (Session : Server_Session) return Boolean with
      Pre => Ready (Session)
             and then State (Session) = Initialized;

   procedure Write (Session : in out Server_Session;
                    Message :        Message_Buffer) with
      Pre  => Ready (Session)
              and then State (Session) = Initialized,
      Post => Ready (Session)
              and then State (Session) = Initialized
              and then Available (Session)'Old = Available (Session);

   procedure Read (Session : in out Server_Session;
                   Message :    out Message_Buffer) with
      Pre  => Ready (Session)
              and then State (Session) = Initialized,
              and then Available (Session),
      Post => Ready (Session)
              and then State (Session) = Initialized;

end Gneiss.Message.Server;
