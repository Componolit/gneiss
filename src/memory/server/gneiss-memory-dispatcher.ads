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
with Gneiss_Internal;

generic
   pragma Warnings (Off, "* is not referenced");

   --  Server implementation to be registered
   with package Server_Instance is new Gneiss.Memory.Server (<>);

   --  Called when a client connects or disconnects
   --
   --  @param Session  Dispatcher session
   --  @param Cap      Dispatcher capability that indicates if a client connected
   --  @param Name     Name of the connecting client, only set when Cap is valid
   --  @param Label    Label of the client connection, only set when Cap is valid
   with procedure Dispatch (Session : in out Dispatcher_Session;
                            Cap     :        Dispatcher_Capability;
                            Name    :        String;
                            Label   :        String);
   pragma Warnings (On, "* is not referenced");
package Gneiss.Memory.Dispatcher with
   SPARK_Mode
is
   pragma Unevaluated_Use_Of_Old (Allow);

   --  Initialize dispatcher
   --
   --  @param Session  Dispatcher session
   --  @param Cap      System capability
   --  @param Idx      Session index
   procedure Initialize (Session : in out Dispatcher_Session;
                         Cap     :        Capability;
                         Idx     :        Session_Index := 1) with
      Global => (In_Out => Gneiss_Internal.Platform_State);

   --  Register service to the platform, should be called when the component initialization is finished
   --
   --  @param Session  Dispatcher session
   procedure Register (Session : in out Dispatcher_Session) with
      Pre    => Initialized (Session),
      Post   => Initialized (Session),
      Global => (In_Out => Gneiss_Internal.Platform_State);

   --  Checks if a session request/dispatcher capability is valid
   --
   --  @param Session  Dispatcher session
   --  @param Cap      Dispatcher capability
   --  @return         True indicates that a client requested a connection
   function Valid_Session_Request (Session : Dispatcher_Session;
                                   Cap     : Dispatcher_Capability) return Boolean with
      Pre    => Initialized (Session),
      Global => null;

   --  Initialize server session
   --  @param Session   Dispatcher session
   --  @param Cap       Dispatcher capability
   --  @param Server_S  Server session that shall be initialized
   --  @param Idx       Session index given to the server session
   procedure Session_Initialize (Session  : in out Dispatcher_Session;
                                 Cap      :        Dispatcher_Capability;
                                 Server_S : in out Server_Session;
                                 Ctx      : in out Server_Instance.Context;
                                 Idx      :        Session_Index := 1) with
      Pre    => Initialized (Session)
                and then Registered (Session)
                and then Valid_Session_Request (Session, Cap)
                and then not Server_Instance.Ready (Server_S, Ctx)
                and then not Initialized (Server_S),
      Post   => Initialized (Session)
                and then Registered (Session)
                and then Valid_Session_Request (Session, Cap),
      Global => (In_Out => Gneiss_Internal.Platform_State);

   --  Accept initialized server session
   --  @param Session   Dispatcher session
   --  @param Cap       Dispatcher capability
   --  @param Server_S  Server session to accept the client request
   procedure Session_Accept (Session  : in out Dispatcher_Session;
                             Cap      :        Dispatcher_Capability;
                             Server_S : in out Server_Session;
                             Ctx      :        Server_Instance.Context) with
      Pre    => Initialized (Session)
                and then Registered (Session)
                and then Valid_Session_Request (Session, Cap)
                and then Server_Instance.Ready (Server_S, Ctx)
                and then Initialized (Server_S),
      Post   => Initialized (Session)
                and then Registered (Session)
                and then Server_Instance.Ready (Server_S, Ctx)
                and then Initialized (Server_S),
      Global => (In_Out => Gneiss_Internal.Platform_State);

   --  Garbage collects disconnected sessions
   --
   --  This procedure must only be used in Dispatch.
   --  It should be called on each session each time Dispatch is called.
   --  Server_S will be finalized if the client disconnected on the platform.
   --
   --  @param D  Dispatcher session instance
   --  @param C  Unique capability for this session request
   --  @param S  Server session instance to check for removal
   procedure Session_Cleanup (Session  : in out Dispatcher_Session;
                              Cap      :        Dispatcher_Capability;
                              Server_S : in out Server_Session;
                              Ctx      : in out Server_Instance.Context) with
      Pre    => Initialized (Session)
                and then Registered (Session),
      Post   => Initialized (Session)
                and then Registered (Session),
      Global => (In_Out => Gneiss_Internal.Platform_State);

end Gneiss.Memory.Dispatcher;
