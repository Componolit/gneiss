--
--  @summary Block dispatcher interface
--  @author  Johannes Kliemann
--  @date    2019-04-10
--
--  Copyright (C) 2019 Componolit GmbH
--
--  This file is part of ada-interface, which is distributed under the terms of the
--  GNU Affero General Public License version 3.
--

with Cai.Types;
with Cai.Block.Server;

pragma Warnings (Off, "package ""Serv"" is not referenced");
pragma Warnings (Off, "procedure ""Dispatch"" is not referenced");
--  Supress unreferenced warnings since not every platform needs each subprogram/package

generic
   --  Server implementation to be registered
   with package Serv is new Cai.Block.Server (<>);

   --  Called when a client connects or disconnects
   with procedure Dispatch;
package Cai.Block.Dispatcher with
   SPARK_Mode
is

   --  Checks if D is initialized
   --
   --  @param D  Dispatcher session instance
   function Initialized (D : Dispatcher_Session) return Boolean;

   --  Create new dispatcher session
   --
   --  @return Uninitialized dispatcher session
   function Create return Dispatcher_Session with
      Post => not Initialized (Create'Result);

   --  Return the instance ID of D
   --
   --  @param D  Dispatcher session instance
   function Get_Instance (D : Dispatcher_Session) return Dispatcher_Instance with
      Pre => Initialized (D);

   --  Initialize dispatcher session with the system capability Cap
   --
   --  @param D    Dispatcher session instance
   --  @param Cap  System capability
   procedure Initialize (D   : in out Dispatcher_Session;
                         Cap :        Cai.Types.Capability);

   --  Register the server implementation Serv on the platform
   --
   --  @param D  Dispatcher session instance
   procedure Register (D : in out Dispatcher_Session) with
      Pre  => Initialized (D),
      Post => Initialized (D);

   --  Finalize dispatcher session
   --
   --  @param D  Dispatcher session instance
   procedure Finalize (D : in out Dispatcher_Session) with
      Pre  => Initialized (D),
      Post => not Initialized (D);

   --  Retrieve information about a session request, must only be used in Dispatch
   --
   --  If a request is available and Session_Accept is called the session is accepted on the platform.
   --  If Session_Accept is not called before the return of Dispatch the session is rejected.
   --
   --  @param D      Dispatcher session instance
   --  @param Valid  Session has been requested if True
   --  @param Label  Label/path of the session request
   --  @param Last   Last initialized element in Label
   procedure Session_Request (D     : in out Dispatcher_Session;
                              Valid :    out Boolean;
                              Label :    out String;
                              Last  :    out Natural) with
      Pre  => Initialized (D),
      Post => Initialized (D) and Last in Label'Range;

   --  Accept session request and provide the server label L
   --  This procedure must only be used in Dispatch.
   --  It also initializes the server on the platform and calls Serv.Initialize.
   --
   --  @param D  Dispatcher session instance
   --  @param I  Server session instance to handle client connection with
   --  @param L  Label passed to server session
   procedure Session_Accept (D : in out Dispatcher_Session;
                             I : in out Server_Session;
                             L :        String) with
      Pre  => Initialized (D),
      Post => Initialized (D);

   --  Garbage collects disconnected sessions
   --
   --  This procedure must only be used in Dispatch.
   --  It should be called on each session each time Dispatch is called.
   --  Server_Session will be finalized if the client disconnected on the platform.
   --
   --  @param D  Dispatcher session instance
   --  @param I  Server session instance to check for removal
   procedure Session_Cleanup (D : in out Dispatcher_Session;
                              I : in out Server_Session) with
      Pre  => Initialized (D) and Serv.Initialized (I),
      Post => Initialized (D) and not Serv.Initialized (I);

end Cai.Block.Dispatcher;
