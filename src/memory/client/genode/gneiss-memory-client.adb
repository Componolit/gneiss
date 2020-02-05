
package body Gneiss.Memory.Client with
   SPARK_Mode
is

   procedure Initialize (Session : in out Client_Session;
                         Cap     :        Capability;
                         Label   :        String;
                         Size    :        Long_Integer;
                         Idx     :        Session_Index := 1)
   is
   begin
      null;
   end Initialize;

   procedure Update (Session : in out Client_Session)
   is
   begin
      null;
   end Update;

   procedure Finalize (Session : in out Client_Session)
   is
   begin
      null;
   end Finalize;

end Gneiss.Memory.Client;
