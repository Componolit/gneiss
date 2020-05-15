
package body Gneiss.Packet.Client with
   SPARK_Mode
is

   procedure Initialize (Session : in out Client_Session;
                         Cap     :        Capability;
                         Label   :        String;
                         Idx     :        Session_Index := 1)
   is
   begin
      null;
   end Initialize;

   procedure Finalize (Session : in out Client_Session)
   is
   begin
      null;
   end Finalize;

   function Allocated (Session : Client_Session;
                       Desc    : Descriptor) return Boolean is
      (False);

   function Writable (Session : Client_Session;
                      Desc    : Descriptor) return Boolean is
      (False);

   procedure Allocate (Session : in out Client_Session;
                       Desc    : in out Descriptor;
                       Size    :        Buffer_Index;
                       Idx     :        Descriptor_Index)
   is
   begin
      null;
   end Allocate;

   procedure Send (Session : in out Client_Session;
                   Desc    : in out Descriptor)
   is
   begin
      null;
   end Send;

   procedure Receive (Session : in out Client_Session;
                      Desc    : in out Descriptor;
                      Idx     :        Descriptor_Index)
   is
   begin
      null;
   end Receive;

   procedure Update (Session : in out Client_Session;
                     Desc    :        Descriptor;
                     Ctx     : in out Context)
   is
   begin
      null;
   end Update;

   procedure Read (Session : in out Client_Session;
                   Desc    :        Descriptor;
                   Ctx     : in out Context)
   is
   begin
      null;
   end Read;

   procedure Free (Session : in out Client_Session;
                   Desc    : in out Descriptor)
   is
   begin
      null;
   end Free;

end Gneiss.Packet.Client;
