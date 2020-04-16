
with Gneiss_Syscall;

package body Gneiss.Memory.Server with
   SPARK_Mode
is

   procedure Modify (Session : in out Server_Session;
                     Ctx     : in out Context)
   is
      Last : constant Buffer_Index := Buffer_Index (Gneiss_Syscall.Stat_Size (Session.Fd));
      B    : Buffer (1 .. Last) with
         Import,
         Address => Session.Map;
   begin
      Generic_Modify (Session, B, Ctx);
   end Modify;

end Gneiss.Memory.Server;
