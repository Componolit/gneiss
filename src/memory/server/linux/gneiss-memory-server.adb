
with Gneiss_Internal.Syscall;
with Gneiss_Internal.Util;

package body Gneiss.Memory.Server with
   SPARK_Mode
is

   function Get_First is new Gneiss_Internal.Util.Get_First (Buffer_Index);
   function Get_Last is new Gneiss_Internal.Util.Get_Last (Buffer_Index);

   procedure Modify (Session : in out Server_Session;
                     Ctx     : in out Context)
   is
      Length : constant Integer      := Gneiss_Internal.Syscall.Stat_Size (Session.Fd);
      Last   : constant Buffer_Index := Get_Last (Length);
      First  : constant Buffer_Index := Get_First (Length);
      B      : Buffer (First .. Last) with
         Import,
         Address => Session.Map;
   begin
      Gneiss_Internal.Syscall.Modify_Platform;
      Generic_Modify (Session, B, Ctx);
   end Modify;

end Gneiss.Memory.Server;
