--
--  @summary Message dispatcher interface declarations
--  @author  Johannes Kliemann
--  @date    2019-11-12
--
--  Copyright (C) 2019 Componolit GmbH
--
--  This file is part of Gneiss, which is distributed under the terms of the
--  GNU Affero General Public License version 3.
--

with Gneiss.Message.Server;
with Gneiss_Internal;

generic
   pragma Warnings (Off, "* is not referenced");
   --  Supress unreferenced warnings since not every platform needs each subprogram/package

   --  Server implementation to be registered
   with package Server_Instance is new Gneiss.Message.Server (<>);
   --  Called when a client connects or disconnects
   --
   --  @param Session  Dispatcher session instance
   --  @param Cap      Dispatcher capability
   --  @param Name     Name of the requesting component
   --  @param Label    Label of the requested connection
   with procedure Dispatch (Session : in out Dispatcher_Session;
                            Cap     :        Dispatcher_Capability;
                            Name    :        String;
                            Label   :        String);
   pragma Warnings (On, "* is not referenced");
package Gneiss.Message.Dispatcher with
   SPARK_Mode
is
   pragma Unevaluated_Use_Of_Old (Allow);

   --  Initialize dispatcher session with the system capability Cap
   --
   --  @param Session  Dispatcher session instance
   --  @param Cap      System capability
   --  @param Idx      Session index
   procedure Initialize (Session : in out Dispatcher_Session;
                         Cap     :        Capability;
                         Idx     :        Session_Index := 1) with
      Global => (In_Out => Gneiss_Internal.Platform_State);

   --  Register the server implementation Serv on the platform
   --
   --  @param Session  Dispatcher session instance
   procedure Register (Session : in out Dispatcher_Session) with
      Pre    => Initialized (Session),
      Post   => Initialized (Session),
      Global => (In_Out => Gneiss_Internal.Platform_State);

   --  Check if the passed dispatcher capability contains a valid session request
   --
   --  @param Session  Dispatcher session instance
   --  @param Cap      Unique capability for this session request
   --  @return         Dispatcher capability contains a valid request
   function Valid_Session_Request (Session : Dispatcher_Session;
                                   Cap     : Dispatcher_Capability) return Boolean with
      Pre    => Initialized (Session),
      Global => null;

   --  Initialize session that should accept the request
   --
   --  It initializes the server on the platform and calls Serv.Initialize.
   --
   --  @param Session   Dispatcher session instance
   --  @param Cap       Unique capability for this session request
   --  @param Server_S  Server session instance to be initialized
   --  @param Idx       Session index to be given to server
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

   --  Accept session request
   --
   --  @param Session   Dispatcher session instance
   --  @param Cap       Unique capability for this session request
   --  @param Server_S  Server session instance to handle client connection with
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
   --  Server_Session will be finalized if the client disconnected on the platform.
   --
   --  @param Session   Dispatcher session instance
   --  @param Cap       Unique capability for this session request
   --  @param Server_S  Server session instance to check for removal
   procedure Session_Cleanup (Session  : in out Dispatcher_Session;
                              Cap      :        Dispatcher_Capability;
                              Server_S : in out Server_Session;
                              Ctx      : in out Server_Instance.Context) with
      Pre    => Initialized (Session)
                and then Registered (Session),
      Post   => Initialized (Session)
                and then Registered (Session),
      Global => (In_Out => Gneiss_Internal.Platform_State);

end Gneiss.Message.Dispatcher;
