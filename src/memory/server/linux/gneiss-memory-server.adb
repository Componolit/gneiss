
with Gneiss_Internal.Syscall;

package body Gneiss.Memory.Server with
   SPARK_Mode
is

   function Get_First (Length : Integer) return Buffer_Index;
   function Get_Last (Length : Integer) return Buffer_Index;

   function Get_First (Length : Integer) return Buffer_Index is
      (if Length < 1 then Buffer_Index'First + 1 else Buffer_Index'First);

   function Get_Last (Length : Integer) return Buffer_Index
   is
   begin
      if Length < 1 then
         return Buffer_Index'First;
      end if;
      if Long_Integer (Length) < Long_Integer (Buffer_Index'Last - Buffer_Index'First + 1) then
         return Buffer_Index (Long_Integer (Buffer_Index'First) + Long_Integer (Length) - 1);
      else
         return Buffer_Index'Last;
      end if;
   end Get_Last;

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
      Generic_Modify (Session, B, Ctx);
   end Modify;

end Gneiss.Memory.Server;
