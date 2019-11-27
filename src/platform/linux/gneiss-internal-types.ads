
with System;
with Gneiss.Epoll;

package Gneiss.Internal.Types is

   type Capability is record
      Filedesc   : Integer;
      Set_Status : System.Address;
      Epoll_Fd   : Gneiss.Epoll.Epoll_Fd;
   end record;

end Gneiss.Internal.Types;
