
package body Gneiss.Packet.Server with
   SPARK_Mode
is

   function Allocated (Session : Server_Session;
                       Desc    : Descriptor;
                       Ctx     : Context) return Boolean is
      (False);

   function Writable (Session : Server_Session;
                      Desc    : Descriptor;
                      Ctx     : Context) return Boolean is
      (False);

   procedure Allocate (Session : in out Server_Session;
                       Desc    : in out Descriptor;
                       Size    :        Buffer_Index;
                       Idx     :        Descriptor_Index;
                       Ctx     :        Context)
   is
   begin
      null;
   end Allocate;

   procedure Send (Session : in out Server_Session;
                   Desc    : in out Descriptor;
                   Ctx     :        Context)
   is
   begin
      null;
   end Send;

   procedure Receive (Session : in out Server_Session;
                      Desc    : in out Descriptor;
                      Idx     :        Descriptor_Index;
                      Ctx     :        Context)
   is
   begin
      null;
   end Receive;

   procedure Update (Session : in out Server_Session;
                     Desc    :        Descriptor;
                     Ctx     : in out Context)
   is
   begin
      null;
   end Update;

   procedure Read (Session : in out Server_Session;
                   Desc    :        Descriptor;
                   Ctx     : in out Context)
   is
   begin
      null;
   end Read;

   procedure Free (Session : in out Server_Session;
                   Desc    : in out Descriptor;
                   Ctx     :        Context)
   is
   begin
      null;
   end Free;

end Gneiss.Packet.Server;
