
package body Gneiss.Stream.Client with
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

   procedure Send (Session : in out Client_Session;
                   Data    :        Buffer;
                   Sent    :    out Natural)
   is
   begin
      null;
   end Send;

end Gneiss.Stream.Client;
