with Gneiss_Epoll;
with Gneiss_Platform;

package Gneiss_Internal is

   type Session_Label is record
      Last  : Natural           := 0;
      Value : String (1 .. 255) := (others => Character'First);
   end record;

   type Capability is record
      Broker_Fd            : Integer;
      Set_Status           : Gneiss_Platform.Set_Status_Cap;
      Register_Service     : Gneiss_Platform.Register_Service_Cap;
      Register_Initializer : Gneiss_Platform.Register_Initializer_Cap;
      Epoll_Fd             : Gneiss_Epoll.Epoll_Fd;
   end record;

end Gneiss_Internal;
