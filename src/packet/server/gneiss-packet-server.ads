
generic
   pragma Warnings (Off, "* is not referenced");
   type Context is limited private;
   with procedure Initialize (Session : in out Server_Session;
                              Ctx     : in out Context);
   with procedure Finalize (Session : in out Server_Session;
                            Ctx     : in out Context);
   with procedure Event;
   with function Ready (Session : Server_Session;
                        Ctx     : Context) return Boolean;
   pragma Warnings (Off, "* is not referenced");
package Gneiss.Packet.Server with
   SPARK_Mode
is

   pragma Unevaluated_Use_Of_Old (Allow);

   procedure Send (Session : in out Server_Session;
                   Data    :        Buffer;
                   Success :    out Boolean;
                   Ctx     :        Context) with
      Pre  => Ready (Session, Ctx)
              and then Initialized (Session),
      Post => Ready (Session, Ctx)
              and then Initialized (Session);

   procedure Receive (Session : in out Server_Session;
                      Data    :    out Buffer;
                      Length  :    out Natural;
                      Ctx     :        Context) with
      Pre  => Ready (Session, Ctx)
              and then Initialized (Session),
      Post => Ready (Session, Ctx)
              and then Initialized (Session);

end Gneiss.Packet.Server;
