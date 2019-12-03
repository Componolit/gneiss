
with System;
with Gneiss.Types;
with Gneiss.Epoll;
with RFLX.Session;

package Gneiss.Platform with
   SPARK_Mode
is

   --  Set the application return state
   --
   --  @param C  System capability
   --  @param S  Status code (0 - Success, 1 - Failure)
   procedure Set_Status (C : Gneiss.Types.Capability;
                         S : Integer);

   procedure Register_Service (C       :     Gneiss.Types.Capability;
                               Kind    :     RFLX.Session.Kind_Type;
                               Fp      :     System.Address;
                               Success : out Boolean);

   generic
      type Session_Type is limited private;
      with procedure Initialize (Session  : in out Session_Type;
                                 Label    :        String;
                                 Success  :        Boolean;
                                 Filedesc :        Integer);
   procedure Register_Initializer (Session    : in out Session_Type;
                                   Capability :        Gneiss.Types.Capability;
                                   Kind       :        RFLX.Session.Kind_Type;
                                   Label      :        String);

   function Get_Broker (C : Gneiss.Types.Capability) return Integer;

   function Get_Epoll (C : Gneiss.Types.Capability) return Gneiss.Epoll.Epoll_Fd;

end Gneiss.Platform;
