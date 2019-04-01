pragma Ada_2012;
package body Cai.Block.Client is

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

   ------------------
   -- Get_Instance --
   ------------------

   function Get_Instance (C : Client_Session) return Client_Instance is
   begin
      --  Generated stub: replace with real body!
      pragma Compile_Time_Warning (Standard.True,
                                   "Get_Instance unimplemented");
      return raise Program_Error with "Unimplemented function Get_Instance";
   end Get_Instance;

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
      Path : String;
      Buffer_Size : Byte_Length := 0)
   is
   begin
      --  Generated stub: replace with real body!
      pragma Compile_Time_Warning (Standard.True, "Initialize unimplemented");
      raise Program_Error with "Unimplemented procedure Initialize";
   end Initialize;

   --------------
   -- Finalize --
   --------------

   procedure Finalize (C : in out Client_Session) is
   begin
      --  Generated stub: replace with real body!
      pragma Compile_Time_Warning (Standard.True, "Finalize unimplemented");
      raise Program_Error with "Unimplemented procedure Finalize";
   end Finalize;

   -----------
   -- Ready --
   -----------

   function Ready
     (C : Client_Session;
      R : Request)
      return Boolean
   is
   begin
      --  Generated stub: replace with real body!
      pragma Compile_Time_Warning (Standard.True, "Ready unimplemented");
      return raise Program_Error with "Unimplemented function Ready";
   end Ready;

   ---------------
   -- Supported --
   ---------------

   function Supported (C : Client_Session; R : Request) return Boolean is
   begin
      --  Generated stub: replace with real body!
      pragma Compile_Time_Warning (Standard.True, "Supported unimplemented");
      return raise Program_Error with "Unimplemented function Supported";
   end Supported;

   ------------------
   -- Enqueue_Read --
   ------------------

   procedure Enqueue_Read
     (C : in out Client_Session;
      R : Request)
   is
   begin
      --  Generated stub: replace with real body!
      pragma Compile_Time_Warning (Standard.True,
                                   "Enqueue_Read unimplemented");
      raise Program_Error with "Unimplemented procedure Enqueue_Read";
   end Enqueue_Read;

   -------------------
   -- Enqueue_Write --
   -------------------

   procedure Enqueue_Write
     (C : in out Client_Session;
      R : Request;
      B : Buffer)
   is
   begin
      --  Generated stub: replace with real body!
      pragma Compile_Time_Warning (Standard.True,
                                   "Enqueue_Write unimplemented");
      raise Program_Error with "Unimplemented procedure Enqueue_Write";
   end Enqueue_Write;

   ------------------
   -- Enqueue_Sync --
   ------------------

   procedure Enqueue_Sync
     (C : in out Client_Session;
      R : Request)
   is
   begin
      --  Generated stub: replace with real body!
      pragma Compile_Time_Warning (Standard.True,
                                   "Enqueue_Sync unimplemented");
      raise Program_Error with "Unimplemented procedure Enqueue_Sync";
   end Enqueue_Sync;

   ------------------
   -- Enqueue_Trim --
   ------------------

   procedure Enqueue_Trim
     (C : in out Client_Session;
      R : Request)
   is
   begin
      --  Generated stub: replace with real body!
      pragma Compile_Time_Warning (Standard.True,
                                   "Enqueue_Trim unimplemented");
      raise Program_Error with "Unimplemented procedure Enqueue_Trim";
   end Enqueue_Trim;

   ------------
   -- Submit --
   ------------

   procedure Submit (C : in out Client_Session) is
   begin
      --  Generated stub: replace with real body!
      pragma Compile_Time_Warning (Standard.True, "Submit unimplemented");
      raise Program_Error with "Unimplemented procedure Submit";
   end Submit;

   ----------
   -- Next --
   ----------

   function Next
     (C : Client_Session)
      return Request
   is
   begin
      --  Generated stub: replace with real body!
      pragma Compile_Time_Warning (Standard.True, "Next unimplemented");
      return raise Program_Error with "Unimplemented function Next";
   end Next;

   ----------
   -- Read --
   ----------

   procedure Read
     (C : in out Client_Session;
      R : Request;
      B : out Buffer)
   is
   begin
      --  Generated stub: replace with real body!
      pragma Compile_Time_Warning (Standard.True, "Read unimplemented");
      raise Program_Error with "Unimplemented procedure Read";
   end Read;

   -------------
   -- Release --
   -------------

   procedure Release
     (C : in out Client_Session;
      R : in out Request)
   is
   begin
      --  Generated stub: replace with real body!
      pragma Compile_Time_Warning (Standard.True, "Release unimplemented");
      raise Program_Error with "Unimplemented procedure Release";
   end Release;

   --------------
   -- Writable --
   --------------

   function Writable (C : Client_Session) return Boolean is
   begin
      --  Generated stub: replace with real body!
      pragma Compile_Time_Warning (Standard.True, "Writable unimplemented");
      return raise Program_Error with "Unimplemented function Writable";
   end Writable;

   -----------------
   -- Block_Count --
   -----------------

   function Block_Count (C : Client_Session) return Count is
   begin
      --  Generated stub: replace with real body!
      pragma Compile_Time_Warning (Standard.True, "Block_Count unimplemented");
      return raise Program_Error with "Unimplemented function Block_Count";
   end Block_Count;

   ----------------
   -- Block_Size --
   ----------------

   function Block_Size (C : Client_Session) return Size is
   begin
      --  Generated stub: replace with real body!
      pragma Compile_Time_Warning (Standard.True, "Block_Size unimplemented");
      return raise Program_Error with "Unimplemented function Block_Size";
   end Block_Size;

   ---------------------------
   -- Maximal_Transfer_Size --
   ---------------------------

   function Maximal_Transfer_Size (C : Client_Session) return Byte_Length is
   begin
      --  Generated stub: replace with real body!
      pragma Compile_Time_Warning (Standard.True,
                                   "Maximal_Transfer_Size unimplemented");
      return raise Program_Error with
        "Unimplemented function Maximal_Transfer_Size";
   end Maximal_Transfer_Size;

end Cai.Block.Client;
