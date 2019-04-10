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
   with package Serv is new Cai.Block.Server (<>);
   --  Server implementation to be registered
   with procedure Dispatch;
   --  Called when a client connects or disconnects
package Cai.Block.Dispatcher with
   SPARK_Mode
is

   function Initialized (D : Dispatcher_Session) return Boolean;
   --  Checks if D is initialized
   --
   --  @param D  Dispatcher session instance

   function Create return Dispatcher_Session with
      Post => not Initialized (Create'Result);

   function Get_Instance (D : Dispatcher_Session) return Dispatcher_Instance with
      Pre => Initialized (D);
   --  Get the instance ID of D
   --
   --  @param D  Dispatcher session instance

   procedure Initialize (D   : in out Dispatcher_Session;
                         Cap :        Cai.Types.Capability);
   --  Initialize dispatcher session with the system capability Cap
   --
   --  @param D    Dispatcher session instance
   --  @param Cap  System capability

   procedure Register (D : in out Dispatcher_Session) with
      Pre  => Initialized (D),
      Post => Initialized (D);
   --  Register the server implementation Serv on the platform
   --
   --  @param D  Dispatcher session instance

   procedure Finalize (D : in out Dispatcher_Session) with
      Pre  => Initialized (D),
      Post => not Initialized (D);
   --  Finalize dispatcher session
   --
   --  @param D  Dispatcher session instance

   procedure Session_Request (D     : in out Dispatcher_Session;
                              Valid :    out Boolean;
                              Label :    out String;
                              Last  :    out Natural) with
      Pre  => Initialized (D),
      Post => Initialized (D) and Last in Label'Range;
   --  Retrieve information about a session request, should only be used in Dispatch
   --  If a request is available and Session_Accept is called the session is accepted on the platform
   --  If Session_Accept is not called before the return of Dispatch the session is rejected
   --
   --  @param D      Dispatcher session instance
   --  @param Valid  session has been requested if True
   --  @param Label  label/path of the session request
   --  @param Last   Last initialized element in Label

   procedure Session_Accept (D : in out Dispatcher_Session;
                             I : in out Server_Session;
                             L :        String) with
      Pre  => Initialized (D),
      Post => Initialized (D);
   --  Accept session request and provide the server label L, should only be used in Dispatch
   --  This procedure also initializes the server on the platform and calls Serv.Initialize
   --
   --  @param D  Dispatcher session instance
   --  @param I  Server session instance to handle client connection with
   --  @param L  Label passed to server session

   procedure Session_Cleanup (D : in out Dispatcher_Session;
                              I : in out Server_Session) with
      Pre  => Initialized (D) and Serv.Initialized (I),
      Post => Initialized (D) and not Serv.Initialized (I);
   --  Garbage collects disconnected sessions, should only be used in Dispatch
   --  Can and should safely be called on each session each time Dispatch is called
   --  Server_Session will be finalized if the client disconnected on the platform
   --
   --  @param D  Dispatcher session instance
   --  @param I  Server session instance to check for removal

end Cai.Block.Dispatcher;
