
with Gneiss_Syscall;

package body Gneiss.Memory.Server with
   SPARK_Mode
is

   procedure Modify (Session : in out Server_Session)
   is
      B : Buffer (1 .. Buffer_Index (Gneiss_Syscall.Stat_Size (Session.Fd))) with
         Import,
         Address => Session.Map;
   begin
      Modify (Session, B);
   end Modify;

end Gneiss.Memory.Server;
