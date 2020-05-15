
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

   function Allocated (Session : Server_Session;
                       Desc    : Descriptor;
                       Ctx     : Context) return Boolean with
      Pre  => Ready (Session, Ctx)
              and then Initialized (Session),
      Post => (if Allocated'Result then Assigned (Desc))
              and then (if not Assigned (Desc) then not Allocated'Result);

   function Writable (Session : Server_Session;
                      Desc    : Descriptor;
                      Ctx     : Context) return Boolean with
      Pre  => Ready (Session, Ctx)
              and then Initialized (Session);

   procedure Allocate (Session : in out Server_Session;
                       Desc    : in out Descriptor;
                       Size    :        Buffer_Index;
                       Idx     :        Descriptor_Index;
                       Ctx     :        Context) with
      Pre  => Ready (Session, Ctx)
              and then Initialized (Session)
              and then not Assigned (Desc),
      Post => Ready (Session, Ctx)
              and then Initialized (Session)
              and then (if Allocated (Session, Desc, Ctx) then Writable (Session, Desc, Ctx));

   procedure Send (Session : in out Server_Session;
                   Desc    : in out Descriptor;
                   Ctx     :        Context) with
      Pre  => Ready (Session, Ctx)
              and then Initialized (Session)
              and then Allocated (Session, Desc, Ctx),
      Post => Ready (Session, Ctx)
              and then Initialized (Session)
              and then not Allocated (Session, Desc, Ctx)
              and then not Assigned (Desc);

   procedure Receive (Session : in out Server_Session;
                      Desc    : in out Descriptor;
                      Idx     :        Descriptor_Index;
                      Ctx     :        Context) with
      Pre  => Ready (Session, Ctx)
              and then Initialized (Session)
              and then not Assigned (Desc),
      Post => Ready (Session, Ctx)
              and then Initialized (Session)
              and then (if Allocated (Session, Desc, Ctx) then not Writable (Session, Desc, Ctx));

   procedure Update (Session : in out Server_Session;
                     Desc    :        Descriptor;
                     Ctx     : in out Context) with
      Pre  => Ready (Session, Ctx)
              and then Initialized (Session)
              and then Allocated (Session, Desc, Ctx)
              and then Writable (Session, Desc, Ctx),
      Post => Ready (Session, Ctx)
              and then Initialized (Session);

   procedure Read (Session : in out Server_Session;
                   Desc    :        Descriptor;
                   Ctx     : in out Context) with
      Pre  => Ready (Session, Ctx)
              and then Initialized (Session)
              and then Allocated (Session, Desc, Ctx),
      Post => Ready (Session, Ctx)
              and then Initialized (Session);

   procedure Free (Session : in out Server_Session;
                   Desc    : in out Descriptor;
                   Ctx     :        Context) with
      Pre  => Ready (Session, Ctx)
              and then Initialized (Session),
      Post => Ready (Session, Ctx)
              and then Initialized (Session)
              and then not Allocated (Session, Desc, Ctx)
              and then not Assigned (Desc);

end Gneiss.Packet.Server;
