
with RFLX.Session;

generic
   with procedure Event;
   Session_Type : RFLX.Session.Kind_Type;
package Gneiss.Message.Generic_Client with
   SPARK_Mode
is
   pragma Unevaluated_Use_Of_Old (Allow);

   procedure Initialize (Session : in out Client_Session;
                         Cap     :        Capability;
                         Label   :        String;
                         Idx     :        Session_Index := 0);

   procedure Finalize (Session : in out Client_Session);

   function Available (Session : Client_Session) return Boolean with
      Pre => Status (Session) = Initialized;

   procedure Write (Session : in out Client_Session;
                    Content :        Message_Buffer) with
      Pre  => Status (Session) = Initialized,
      Post => Status (Session) = Initialized
              and then Available (Session)'Old = Available (Session);

   procedure Read (Session : in out Client_Session;
                   Content :    out Message_Buffer) with
      Pre  => Status (Session) = Initialized
              and then Available (Session),
      Post => Status (Session) = Initialized;

end Gneiss.Message.Generic_Client;