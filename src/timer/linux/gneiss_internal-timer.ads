
with Gneiss;

package Gneiss_Internal.Timer with
   SPARK_Mode
is

   type Client_Session is limited record
      Fd    : File_Descriptor             := -1;
      Index : Gneiss.Session_Index_Option := Gneiss.Session_Index_Option'(Valid => False);
      E_Cap : Event_Cap                   := Invalid_Event_Cap;
      Epoll : Epoll_Fd                    := -1;
   end record;

end Gneiss_Internal.Timer;
