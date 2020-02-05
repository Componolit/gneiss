--
--  @summary Log dispatcher interface
--  @author  Johannes Kliemann
--  @date    2020-02-05
--
--  Copyright (C) 2019 Componolit GmbH
--
--  This file is part of Gneiss, which is distributed under the terms of the
--  GNU Affero General Public License version 3.
--

with Gneiss.Memory.Server;

generic
   pragma Warnings (Off, "* is not referenced");
   with package Server_Instance is new Gneiss.Memory.Server (<>);
   with procedure Dispatch (Session : in out Dispatcher_Session;
                            Cap     :        Dispatcher_Capability;
                            Name    :        String;
                            Label   :        String);
   pragma Warnings (On, "* is not referenced");
package Gneiss.Memory.Dispatcher with
   SPARK_Mode
is
   pragma Unevaluated_Use_Of_Old (Allow);

   procedure Initialize (Session : in out Dispatcher_Session;
                         Cap     :        Capability;
                         Idx     :        Session_Index := 1);

   procedure Register (Session : in out Dispatcher_Session) with
      Pre  => Initialized (Session),
      Post => Initialized (Session);

   function Valid_Session_Request (Session : Dispatcher_Session;
                                   Cap     : Dispatcher_Capability) return Boolean with
      Pre => Initialized (Session);

   procedure Session_Initialize (Session  : in out Dispatcher_Session;
                                 Cap      :        Dispatcher_Capability;
                                 Server_S : in out Server_Session;
                                 Idx      :        Session_Index := 1) with
      Pre  => Initialized (Session)
              and then Valid_Session_Request (Session, Cap)
              and then not Server_Instance.Ready (Server_S)
              and then not Initialized (Server_S),
      Post => Initialized (Session)
              and then Valid_Session_Request (Session, Cap);

   procedure Session_Accept (Session  : in out Dispatcher_Session;
                             Cap      :        Dispatcher_Capability;
                             Server_S : in out Server_Session) with
      Pre  => Initialized (Session)
              and then Valid_Session_Request (Session, Cap)
              and then Server_Instance.Ready (Server_S)
              and then Initialized (Server_S),
      Post => Initialized (Session)
              and then Server_Instance.Ready (Server_S)
              and then Initialized (Server_S);

   procedure Session_Cleanup (Session  : in out Dispatcher_Session;
                              Cap      :        Dispatcher_Capability;
                              Server_S : in out Server_Session) with
      Pre  => Initialized (Session),
      Post => Initialized (Session);

end Gneiss.Memory.Dispatcher;
