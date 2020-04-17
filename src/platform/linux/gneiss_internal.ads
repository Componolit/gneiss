with Gneiss_Epoll;
with Gneiss_Platform;

package Gneiss_Internal is

   type Session_Label is record
      Last  : Natural           := 0;
      Value : String (1 .. 255) := (others => Character'First);
   end record with
      Dynamic_Predicate => Last <= Value'Last;

   type Capability is record
      Broker_Fd  : Integer;
      Set_Status : Gneiss_Platform.Set_Status_Cap;
      Epoll_Fd   : Gneiss_Epoll.Epoll_Fd;
   end record with
      Dynamic_Predicate => Capability.Broker_Fd > -1
                           and then Gneiss_Epoll.Valid_Fd (Capability.Epoll_Fd);

end Gneiss_Internal;
