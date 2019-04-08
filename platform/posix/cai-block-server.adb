pragma Ada_2012;
package body Cai.Block.Server is

   pragma Warnings (Off, "unimplemented");
   pragma Warnings (Off, "formal parameter");

   -----------------
   -- Initialized --
   -----------------

   function Initialized (S : Server_Session) return Boolean is
   begin
      --  Generated stub: replace with real body!
      pragma Compile_Time_Warning (Standard.True, "Initialized unimplemented");
      return raise Program_Error with "Unimplemented function Initialized";
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
      return raise Program_Error with "Unimplemented function Get_Instance";
   end Get_Instance;

   ----------
   -- Head --
   ----------

   function Head (S : Server_Session) return Request
   is
   begin
      --  Generated stub: replace with real body!
      pragma Compile_Time_Warning (Standard.True, "Head unimplemented");
      return raise Program_Error with "Unimplemented function Head";
   end Head;

   -------------
   -- Discard --
   -------------

   procedure Discard (S : in out Server_Session)
   is
   begin
      --  Generated stub: replace with real body!
      pragma Compile_Time_Warning (Standard.True, "Discard unimplemented");
      raise Program_Error with "Unimplemented procedure Discard";
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
      raise Program_Error with "Unimplemented procedure Read";
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
      raise Program_Error with "Unimplemented procedure Write";
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
      raise Program_Error with "Unimplemented procedure Acknowledge";
   end Acknowledge;

end Cai.Block.Server;
