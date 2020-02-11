
package body Gneiss.Memory.Server with
   SPARK_Mode
is

   procedure Modify (Session : in out Server_Session)
   is
      Buf : Buffer (Buffer_Index'First ..
                    Buffer_Index'Val (Buffer_Index'Pos (Buffer_Index'First)
                                      + Long_Integer'Pos (Session.Size) - 1)) with
         Import,
         Address => Session.Addr;
   begin
      Modify (Session, Buf);
   end Modify;

end Gneiss.Memory.Server;
