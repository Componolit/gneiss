
generic
   pragma Warnings (Off, "* is not referenced");
   with procedure Event;
   with procedure Initialize (Session : in out Server_Session;
                              Label   :        String);
   with procedure Finalize (Session : in out Server_Session);
   with function Ready (Session : Server_Session) return Boolean;
   pragma Warnings (On, "* is not referenced");
package Gneiss.Message.Server with
   SPARK_Mode
is
   pragma Unevaluated_Use_Of_Old (Allow);

   function Available (Session : Server_Session) return Boolean with
      Pre => Ready (Session)
             and then Status (Session) = Initialized;

   procedure Write (Session : in out Server_Session;
                    Data    :        Message_Buffer) with
      Pre  => Ready (Session)
              and then Status (Session) = Initialized,
      Post => Ready (Session)
              and then Status (Session) = Initialized
              and then Available (Session)'Old = Available (Session);

   procedure Read (Session : in out Server_Session;
                   Data    :    out Message_Buffer) with
      Pre  => Ready (Session)
              and then Status (Session) = Initialized
              and then Available (Session),
      Post => Ready (Session)
              and then Status (Session) = Initialized;

end Gneiss.Message.Server;
