
with RFLX.Session;
with Gneiss.Message.Generic_Client;

package body Gneiss.Message.Client with
   SPARK_Mode
is

   package Message_Client is new Gneiss.Message.Generic_Client
      (Event, RFLX.Session.Message);

   procedure Initialize (Session : in out Client_Session;
                         Cap     :        Capability;
                         Label   :        String;
                         Idx     :        Session_Index := 0)
   is
   begin
      Message_Client.Initialize (Session, Cap, Label, Idx);
   end Initialize;

   procedure Finalize (Session : in out Client_Session)
   is
   begin
      Message_Client.Finalize (Session);
   end Finalize;

   function Available (Session : Client_Session) return Boolean is
      (Message_Client.Available (Session));

   procedure Write (Session : in out Client_Session;
                    Content :        Message_Buffer)
   is
   begin
      Message_Client.Write (Session, Content);
   end Write;

   procedure Read (Session : in out Client_Session;
                   Content :    out Message_Buffer)
   is
   begin
      Message_Client.Read (Session, Content);
   end Read;

end Gneiss.Message.Client;
