pragma Ada_2012;
package body Cai.Log.Client is

   pragma Warnings (Off, "unimplemented");
   pragma Warnings (Off, "formal parameter");

   ------------
   -- Create --
   ------------

   function Create return Client_Session is
   begin
      --  Generated stub: replace with real body!
      pragma Compile_Time_Warning (Standard.True, "Create unimplemented");
      return raise Program_Error with "Unimplemented function Create";
   end Create;

   -----------------
   -- Initialized --
   -----------------

   function Initialized (C : Client_Session) return Boolean is
   begin
      --  Generated stub: replace with real body!
      pragma Compile_Time_Warning (Standard.True, "Initialized unimplemented");
      return raise Program_Error with "Unimplemented function Initialized";
   end Initialized;

   ----------------
   -- Initialize --
   ----------------

   procedure Initialize
     (C : in out Client_Session;
      Label : String;
      Message_Length : Integer := 0)
   is
   begin
      --  Generated stub: replace with real body!
      pragma Compile_Time_Warning (Standard.True, "Initialize unimplemented");
      raise Program_Error with "Unimplemented procedure Initialize";
   end Initialize;

   --------------
   -- Finalize --
   --------------

   procedure Finalize
     (C : in out Client_Session)
   is
   begin
      --  Generated stub: replace with real body!
      pragma Compile_Time_Warning (Standard.True, "Finalize unimplemented");
      raise Program_Error with "Unimplemented procedure Finalize";
   end Finalize;

   ----------------------------
   -- Maximal_Message_Length --
   ----------------------------

   function Maximal_Message_Length
     (C : Client_Session)
      return Integer
   is
   begin
      --  Generated stub: replace with real body!
      pragma Compile_Time_Warning (Standard.True,
                                   "Maximal_Message_Length unimplemented");
      return raise Program_Error with
        "Unimplemented function Maximal_Message_Length";
   end Maximal_Message_Length;

   ----------
   -- Info --
   ----------

   procedure Info
     (C : in out Client_Session;
      Msg : String;
      Newline : Boolean := True)
   is
   begin
      --  Generated stub: replace with real body!
      pragma Compile_Time_Warning (Standard.True, "Info unimplemented");
      raise Program_Error with "Unimplemented procedure Info";
   end Info;

   -------------
   -- Warning --
   -------------

   procedure Warning
     (C : in out Client_Session;
      Msg : String;
      Newline : Boolean := True)
   is
   begin
      --  Generated stub: replace with real body!
      pragma Compile_Time_Warning (Standard.True, "Warning unimplemented");
      raise Program_Error with "Unimplemented procedure Warning";
   end Warning;

   -----------
   -- Error --
   -----------

   procedure Error
     (C : in out Client_Session;
      Msg : String;
      Newline : Boolean := True)
   is
   begin
      --  Generated stub: replace with real body!
      pragma Compile_Time_Warning (Standard.True, "Error unimplemented");
      raise Program_Error with "Unimplemented procedure Error";
   end Error;

   -----------
   -- Flush --
   -----------

   procedure Flush
     (C : in out Client_Session)
   is
   begin
      --  Generated stub: replace with real body!
      pragma Compile_Time_Warning (Standard.True, "Flush unimplemented");
      raise Program_Error with "Unimplemented procedure Flush";
   end Flush;

end Cai.Log.Client;
