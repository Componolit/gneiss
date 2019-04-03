with Cai.Block.Server;

pragma Warnings (Off, "package ""Serv"" is not referenced");
pragma Warnings (Off, "procedure ""Dispatch"" is not referenced");

generic
   with package Serv is new Cai.Block.Server (<>);
   with procedure Dispatch;
package Cai.Block.Dispatcher
is

   function Create return Dispatcher_Session;

   function Initialized (D : Dispatcher_Session) return Boolean;

   function Get_Instance (D : Dispatcher_Session) return Dispatcher_Instance with
      Pre => Initialized (D);

   procedure Initialize (D : in out Dispatcher_Session);

   procedure Register (D : in out Dispatcher_Session) with
      Pre => Initialized (D);

   procedure Finalize (D : in out Dispatcher_Session) with
      Pre => Initialized (D);

   procedure Session_Request (D     : in out Dispatcher_Session;
                              Valid :    out Boolean;
                              Label :    out String;
                              Last  :    out Natural) with
      Pre => Initialized (D);

   procedure Session_Accept (D : in out Dispatcher_Session;
                             I : in out Server_Session;
                             L :        String) with
      Pre => Initialized (D);

   procedure Session_Cleanup (D : in out Dispatcher_Session;
                              I : in out Server_Session) with
      Pre => Initialized (D);

end Cai.Block.Dispatcher;
