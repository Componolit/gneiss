
with Gneiss.Message.Generic_Client;
with RFLX.Session;

package body Gneiss.Log.Client
is

   package Message_Client is new Gneiss_Internal.Log.Message_Log.Generic_Client
      (Event, RFLX.Session.Log);

   ----------------
   -- Initialize --
   ----------------

   procedure Initialize (Session : in out Client_Session;
                         Cap     :        Capability;
                         Label   :        String;
                         Idx     :        Session_Index := 0)
   is
   begin
      Message_Client.Initialize (Session.Message, Cap, Label, Idx);
   end Initialize;

   --------------
   -- Finalize --
   --------------

   procedure Finalize (Session : in out Client_Session)
   is
   begin
      Message_Client.Finalize (Session.Message);
   end Finalize;

   ----------
   -- Info --
   ----------

   procedure Info (Session       : in out Client_Session;
                   Msg     :        String;
                   Newline :        Boolean := True)
   is
   begin
      null;
   end Info;

   -------------
   -- Warning --
   -------------

   procedure Warning (Session       : in out Client_Session;
                      Msg     :        String;
                      Newline :        Boolean := True)
   is
   begin
      null;
   end Warning;

   -----------
   -- Error --
   -----------

   procedure Error (Session       : in out Client_Session;
                    Msg     :        String;
                    Newline :        Boolean := True)
   is
   begin
      null;
   end Error;

   -----------
   -- Flush --
   -----------

   procedure Flush (Session : in out Client_Session)
   is
   begin
      null;
   end Flush;

end Gneiss.Log.Client;
