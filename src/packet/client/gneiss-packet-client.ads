
generic
   pragma Warnings (Off, "* is not referenced");
   type Context is limited private;
   with procedure Event;
   with procedure Generic_Update (Session : in out Client_Session;
                                  Idx     :        Descriptor_Index;
                                  Buf     :    out Buffer;
                                  Ctx     : in out Context);
   with procedure Generic_Read (Session : in out Client_Session;
                                Idx     :        Descriptor_Index;
                                Buf     :        Buffer;
                                Ctx     : in out Context);
   pragma Warnings (Off, "* is not referenced");
package Gneiss.Packet.Client with
   SPARK_Mode
is

   pragma Unevaluated_Use_Of_Old (Allow);

   procedure Initialize (Session : in out Client_Session;
                         Cap     :        Capability;
                         Label   :        String;
                         Idx     :        Session_Index := 1);

   procedure Finalize (Session : in out Client_Session) with
      Post => not Initialized (Session);

   function Allocated (Session : Client_Session;
                       Desc    : Descriptor) return Boolean with
      Pre  => Initialized (Session),
      Post => (if Allocated'Result then Assigned (Desc))
              and then (if not Assigned (Desc) then not Allocated'Result);

   function Writable (Session : Client_Session;
                      Desc    : Descriptor) return Boolean with
      Pre => Initialized (Session)
             and then Allocated (Session, Desc);

   procedure Allocate (Session : in out Client_Session;
                       Desc    : in out Descriptor;
                       Size    :        Buffer_Index;
                       Idx     :        Descriptor_Index) with
      Pre  => Initialized (Session)
              and then not Assigned (Desc),
      Post => Initialized (Session)
              and then (if Allocated (Session, Desc) then Writable (Session, Desc));

   procedure Send (Session : in out Client_Session;
                   Desc    : in out Descriptor) with
      Pre  => Initialized (Session)
              and then Allocated (Session, Desc),
      Post => Initialized (Session)
              and then not Allocated (Session, Desc)
              and then not Assigned (Desc);

   procedure Receive (Session : in out Client_Session;
                      Desc    : in out Descriptor;
                      Idx     :        Descriptor_Index) with
      Pre  => Initialized (Session)
              and then not Assigned (Desc),
      Post => Initialized (Session)
              and then (if Allocated (Session, Desc) then not Writable (Session, Desc));

   procedure Update (Session : in out Client_Session;
                     Desc    :        Descriptor;
                     Ctx     : in out Context) with
      Pre => Initialized (Session)
             and then Allocated (Session, Desc)
             and then Writable (Session, Desc),
      Post => Initialized (Session);

   procedure Read (Session : in out Client_Session;
                   Desc    :        Descriptor;
                   Ctx     : in out Context) with
      Pre  => Initialized (Session)
              and then Allocated (Session, Desc),
      Post => Initialized (Session);

   procedure Free (Session : in out Client_Session;
                   Desc    : in out Descriptor) with
      Pre  => Initialized (Session),
      Post => Initialized (Session)
              and then not Allocated (Session, Desc)
              and then not Assigned (Desc);

end Gneiss.Packet.Client;
