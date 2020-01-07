
generic
   pragma Warnings (Off, "* is not referenced");
   with procedure Event;
   with procedure Initialize (Session : in out Server_Session);
   with procedure Finalize (Session : in out Server_Session);
   with function Ready (Session : Server_Session) return Boolean;
   pragma Warnings (On, "* is not referenced");
package Gneiss.Log.Server with
   SPARK_Mode
is
   pragma Unevaluated_Use_Of_Old (Allow);

   function Available (Session : Server_Session) return Boolean with
      Pre => Ready (Session)
             and then Initialized (Session);

   procedure Get (Session : in out Server_Session;
                  Char    :    out Character) with
      Pre  => Ready (Session)
              and then Initialized (Session)
              and then Available (Session),
      Post => Ready (Session)
              and then Initialized (Session);

end Gneiss.Log.Server;
