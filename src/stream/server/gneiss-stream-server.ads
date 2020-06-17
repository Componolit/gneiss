
generic
   pragma Warnings (Off, "* is not referenced");
   type Context is limited private;
   with procedure Initialize (Session : in out Server_Session;
                              Ctx     : in out Context);
   with procedure Finalize (Session : in out Server_Session;
                            Ctx     : in out Context);
   with function Ready (Session : Server_Session;
                        Ctx     : Context) return Boolean;
   with procedure Generic_Receive (Session : in out Server_Session;
                                   Data    :        Buffer;
                                   Read    :    out Natural);
   pragma Warnings (Off, "* is not referenced");
package Gneiss.Stream.Server with
   SPARK_Mode
is

   pragma Unevaluated_Use_Of_Old (Allow);

   procedure Send (Session : in out Server_Session;
                   Data    :        Buffer;
                   Sent    :    out Natural;
                   Ctx     :        Context) with
      Pre  => Ready (Session, Ctx)
              and then Initialized (Session),
      Post => Ready (Session, Ctx)
              and then Initialized (Session);

end Gneiss.Stream.Server;
