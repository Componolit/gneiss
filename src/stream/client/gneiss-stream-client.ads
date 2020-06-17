
generic
   pragma Warnings (Off, "* is not referenced");
   with procedure Generic_Receive (Session : in out Client_Session;
                                   Data    :        Buffer;
                                   Read    :    out Natural);
   pragma Warnings (On, "* is not referenced");
package Gneiss.Stream.Client with
   SPARK_Mode
is

   procedure Initialize (Session : in out Client_Session;
                         Cap     :        Capability;
                         Label   :        String;
                         Idx     :        Session_Index := 1);

   procedure Finalize (Session : in out Client_Session) with
      Post => not Initialized (Session);

   procedure Send (Session : in out Client_Session;
                   Data    :        Buffer;
                   Sent    :    out Natural) with
      Pre => Initialized (Session);

end Gneiss.Stream.Client;
