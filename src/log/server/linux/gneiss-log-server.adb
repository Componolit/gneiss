
with Gneiss_Internal.Message;

package body Gneiss.Log.Server with
   SPARK_Mode
is

   procedure Read_Buffer (Session : in out Server_Session) with
      Pre =>  Initialized (Session)
              and then Gneiss_Internal.Message.Peek (Session.Fd)
                       >= Gneiss_Internal.Log.Message_Log.Message_Buffer'Length,
      Post => Initialized (Session)
              and then Session.Cursor = Session.Buffer'Last;

   function Available (Session : Server_Session) return Boolean is
      ((Session.Cursor <= Session.Buffer'Last
        and then Session.Buffer (Session.Cursor) /= ASCII.NUL)
       or else Gneiss_Internal.Message.Peek (Session.Fd)
          >= Gneiss_Internal.Log.Message_Log.Message_Buffer'Length);

   procedure Get (Session : in out Server_Session;
                  Char    :    out Character)
   is
   begin
      if
         Session.Cursor > Session.Buffer'Last
         or else Session.Buffer (Session.Cursor) = ASCII.NUL
      then
         Read_Buffer (Session);
      end if;
      Char := Session.Buffer (Session.Cursor);
      Session.Cursor := Session.Cursor + 1;
   end Get;

   procedure Read_Buffer (Session : in out Server_Session) with
      SPARK_Mode => Off
   is
   begin
      Gneiss_Internal.Message.Read (Session.Fd, Session.Buffer'Address, Session.Buffer'Length);
      Session.Cursor := Session.Buffer'First;
   end Read_Buffer;

end Gneiss.Log.Server;
