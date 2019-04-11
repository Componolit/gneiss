pragma Ada_2012;
package body Cai.Block.Server is

   pragma Warnings (Off, "unimplemented");
   pragma Warnings (Off, "formal parameter");

   ------------
   -- Create --
   ------------

   function Create return Server_Session is
   begin
      --  Generated stub: replace with real body!
      pragma Compile_Time_Warning (Standard.True, "Create unimplemented");
      return raise Program_Error with "Unimplemented function Create";
   end Create;

   -----------------
   -- Initialized --
   -----------------

   function Initialized (S : Server_Session) return Boolean is
   begin
      --  Generated stub: replace with real body!
      pragma Compile_Time_Warning (Standard.True, "Initialized unimplemented");
      return raise Program_Error;
   end Initialized;

   ------------------
   -- Get_Instance --
   ------------------

   function Get_Instance (S : Server_Session) return Server_Instance
   is
   begin
      --  Generated stub: replace with real body!
      pragma Compile_Time_Warning (Standard.True,
                                   "Get_Instance unimplemented");
      return raise Program_Error;
   end Get_Instance;

   ----------
   -- Head --
   ----------

   function Head (S : Server_Session) return Request
   is
   begin
      --  Generated stub: replace with real body!
      pragma Compile_Time_Warning (Standard.True, "Head unimplemented");
      return raise Program_Error;
   end Head;

   -------------
   -- Discard --
   -------------

   procedure Discard (S : in out Server_Session)
   is
   begin
      --  Generated stub: replace with real body!
      pragma Compile_Time_Warning (Standard.True, "Discard unimplemented");
      raise Program_Error;
   end Discard;

   ----------
   -- Read --
   ----------

   procedure Read (S : in out Server_Session;
                   R :        Request;
                   B :        Buffer)
   is
   begin
      --  Generated stub: replace with real body!
      pragma Compile_Time_Warning (Standard.True, "Read unimplemented");
      raise Program_Error;
   end Read;

   -----------
   -- Write --
   -----------

   procedure Write (S : in out Server_Session;
                    R :        Request;
                    B :    out Buffer)
   is
   begin
      --  Generated stub: replace with real body!
      pragma Compile_Time_Warning (Standard.True, "Write unimplemented");
      raise Program_Error;
   end Write;

   -----------------
   -- Acknowledge --
   -----------------

   procedure Acknowledge (S : in out Server_Session;
                          R : in out Request)
   is
   begin
      --  Generated stub: replace with real body!
      pragma Compile_Time_Warning (Standard.True, "Acknowledge unimplemented");
      raise Program_Error;
   end Acknowledge;

end Cai.Block.Server;
