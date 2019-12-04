with System;
with Gneiss_Epoll;

package Gneiss_Internal is

   type Session_Label is record
      Last  : Natural           := 0;
      Value : String (1 .. 255) := (others => Character'First);
   end record;

   type Capability is record
      Broker_Fd            : Integer;
      Set_Status           : System.Address;
      Register_Service     : System.Address;
      Register_Initializer : System.Address;
      Epoll_Fd             : Gneiss_Epoll.Epoll_Fd;
   end record;

end Gneiss_Internal;
