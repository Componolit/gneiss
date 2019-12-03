
with System;
with Gneiss.Epoll;

package Gneiss.Internal.Types is

   type Session_Label is record
      Last  : Natural           := 0;
      Value : String (1 .. 255) := (others => Character'First);
   end record;

   type Capability is record
      Filedesc             : Integer;
      Set_Status           : System.Address;
      Register_Service     : System.Address;
      Register_Initializer : System.Address;
      Epoll_Fd             : Gneiss.Epoll.Epoll_Fd;
   end record;

end Gneiss.Internal.Types;
