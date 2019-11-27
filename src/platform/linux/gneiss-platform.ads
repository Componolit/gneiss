
with Gneiss.Types;
with Gneiss.Epoll;

package Gneiss.Platform with
   SPARK_Mode
is

   --  Set the application return state
   --
   --  @param C  System capability
   --  @param S  Status code (0 - Success, 1 - Failure)
   procedure Set_Status (C : Gneiss.Types.Capability;
                         S : Integer);

   function Get_Broker (C : Gneiss.Types.Capability) return Integer;

   function Get_Epoll (C : Gneiss.Types.Capability) return Gneiss.Epoll.Epoll_Fd;

end Gneiss.Platform;
