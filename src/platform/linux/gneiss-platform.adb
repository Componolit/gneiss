
with Ada.Unchecked_Conversion;
with Gneiss.Internal.Types;

package body Gneiss.Platform with
   SPARK_Mode
is

   function Convert is new Ada.Unchecked_Conversion
      (Gneiss.Types.Capability, Gneiss.Internal.Types.Capability);

   procedure Set_Status (C : Gneiss.Types.Capability;
                         S : Integer)
   is
      procedure Set (St : Integer) with
         Import,
         Address => Convert (C).Set_Status;
   begin
      Set (S);
   end Set_Status;

   function Get_Broker (C : Gneiss.Types.Capability) return Integer is
      (Convert (C).Filedesc);

   function Get_Epoll (C : Gneiss.Types.Capability) return Gneiss.Epoll.Epoll_Fd is
      (Convert (C).Epoll_Fd);

end Gneiss.Platform;
