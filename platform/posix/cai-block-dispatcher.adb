pragma Ada_2012;
package body Cai.Block.Dispatcher is

   pragma Warnings (Off, "unimplemented");
   pragma Warnings (Off, "formal parameter");

   ------------
   -- Create --
   ------------

   function Create return Dispatcher_Session is
   begin
      --  Generated stub: replace with real body!
      pragma Compile_Time_Warning (Standard.True, "Create unimplemented");
      return raise Program_Error;
   end Create;

   -----------------
   -- Initialized --
   -----------------

   function Initialized (D : Dispatcher_Session) return Boolean is
   begin
      --  Generated stub: replace with real body!
      pragma Compile_Time_Warning (Standard.True, "Initialized unimplemented");
      return raise Program_Error;
   end Initialized;

   ------------------
   -- Get_Instance --
   ------------------

   function Get_Instance (D : Dispatcher_Session) return Dispatcher_Instance
   is
   begin
      --  Generated stub: replace with real body!
      pragma Compile_Time_Warning (Standard.True,
                                   "Get_Instance unimplemented");
      return raise Program_Error;
   end Get_Instance;

   ----------------
   -- Initialize --
   ----------------

   procedure Initialize (D   : in out Dispatcher_Session;
                         Cap :        Cai.Types.Capability)
   is
      pragma Unreferenced (Cap);
   begin
      --  Generated stub: replace with real body!
      pragma Compile_Time_Warning (Standard.True, "Initialize unimplemented");
      raise Program_Error;
   end Initialize;

   --------------
   -- Register --
   --------------

   procedure Register (D : in out Dispatcher_Session) is
   begin
      --  Generated stub: replace with real body!
      pragma Compile_Time_Warning (Standard.True, "Register unimplemented");
      raise Program_Error;
   end Register;

   --------------
   -- Finalize --
   --------------

   procedure Finalize (D : in out Dispatcher_Session) is
   begin
      --  Generated stub: replace with real body!
      pragma Compile_Time_Warning (Standard.True, "Finalize unimplemented");
      raise Program_Error;
   end Finalize;

   ---------------------
   -- Session_Request --
   ---------------------

   procedure Session_Request (D     : in out Dispatcher_Session;
                              Valid :    out Boolean;
                              Label :    out String;
                              Last  :    out Natural)
   is
   begin
      --  Generated stub: replace with real body!
      pragma Compile_Time_Warning (Standard.True,
                                   "Session_Request unimplemented");
      raise Program_Error;
   end Session_Request;

   --------------------
   -- Session_Accept --
   --------------------

   procedure Session_Accept (D : in out Dispatcher_Session;
                             I : in out Server_Session;
                             L :        String)
   is
   begin
      --  Generated stub: replace with real body!
      pragma Compile_Time_Warning (Standard.True,
                                   "Session_Accept unimplemented");
      raise Program_Error;
   end Session_Accept;

   ---------------------
   -- Session_Cleanup --
   ---------------------

   procedure Session_Cleanup (D : in out Dispatcher_Session;
                              I : in out Server_Session)
   is
   begin
      --  Generated stub: replace with real body!
      pragma Compile_Time_Warning (Standard.True,
                                   "Session_Cleanup unimplemented");
      raise Program_Error;
   end Session_Cleanup;

end Cai.Block.Dispatcher;
