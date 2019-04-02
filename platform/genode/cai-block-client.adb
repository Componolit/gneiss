
with Ada.Unchecked_Conversion;
with Cxx;
with Cxx.Block;
with Cxx.Block.Client;
with Cxx.Genode;
with Cai.Block.Util;
use all type Cxx.Bool;

package body Cai.Block.Client
is

   function Cast_Request (R : Request) return Block.Request is
      (Block.Request (R));

   function Cast_Request (R : Block.Request) return Request is
      (Request (R));

   package Client_Util is new Block.Util (Request, Cast_Request, Cast_Request);

   function Create return Client_Session
   is
   begin
      return Client_Session'(Instance => Cxx.Block.Client.Constructor);
   end Create;

   function Get_Instance (C : Client_Session) return Client_Instance
   is
   begin
      return Client_Instance (Cxx.Block.Client.Get_Instance (C.Instance));
   end Get_Instance;

   function Initialized (C : Client_Session) return Boolean
   is
   begin
      return Cxx.Block.Client.Initialized (C.Instance) = Cxx.Bool'Val (1);
   end Initialized;

   procedure Initialize (C : in out Client_Session;
                         Path : String;
                         Buffer_Size : Byte_Length := 0)
   is
      C_Path : constant String := Path & Character'Val (0);
      subtype C_Path_String is String (1 .. C_Path'Length);
      subtype C_String is Cxx.Char_Array (1 .. C_Path'Length);
      function To_C_String is new Ada.Unchecked_Conversion (C_Path_String,
                                                            C_String);
   begin
      Cxx.Block.Client.Initialize (C.Instance,
                                   To_C_String (C_Path),
                                   Event'Address,
                                   Cxx.Genode.Uint64_T (Buffer_Size));
   end Initialize;

   procedure Finalize (C : in out Client_Session)
   is
   begin
      Cxx.Block.Client.Finalize (C.Instance);
   end Finalize;

   function Ready (C : Client_Session; R : Request) return Boolean
   is
   begin
      return Cxx.Block.Client.Ready (C.Instance,
                                     Client_Util.Convert_Request (R)) =
                                        Cxx.Bool'Val (1);
   end Ready;

   function Supported (C : Client_Session; R : Request) return Boolean
   is
   begin
      return Cxx.Block.Client.Supported (C.Instance,
                                         Client_Util.Convert_Request (R)) =
                                            Cxx.Bool'Val (1);
   end Supported;

   procedure Enqueue_Read (C : in out Client_Session; R : Request)
   is
   begin
      Cxx.Block.Client.Enqueue_Read (C.Instance,
                                     Client_Util.Convert_Request (R));
   end Enqueue_Read;

   procedure Enqueue_Write (C : in out Client_Session; R : Request; B : Buffer)
   is
      subtype Local_Buffer is Buffer (B'First .. B'Last);
      subtype Local_U8_Array is Cxx.Genode.Uint8_T_Array (1 .. B'Length);
      function Convert_Buffer is new Ada.Unchecked_Conversion (Local_Buffer,
                                                               Local_U8_Array);
      Data : Local_U8_Array := Convert_Buffer (B);
   begin
      Cxx.Block.Client.Enqueue_Write (
         C.Instance,
         Client_Util.Convert_Request (R),
         Data);
   end Enqueue_Write;

   procedure Enqueue_Sync (C : in out Client_Session; R : Request)
   is
   begin
      Cxx.Block.Client.Enqueue_Sync (C.Instance,
                                     Client_Util.Convert_Request (R));
   end Enqueue_Sync;

   procedure Enqueue_Trim (C : in out Client_Session; R : Request)
   is
   begin
      Cxx.Block.Client.Enqueue_Trim (C.Instance,
                                     Client_Util.Convert_Request (R));
   end Enqueue_Trim;

   procedure Submit (C : in out Client_Session)
   is
   begin
      Cxx.Block.Client.Submit (C.Instance);
   end Submit;

   function Next (C : Client_Session) return Request
   is
   begin
      return Client_Util.Convert_Request (Cxx.Block.Client.Next (C.Instance));
   end Next;

   procedure Read (C : in out Client_Session; R : Request; B : out Buffer)
   is
      subtype Local_Buffer is Buffer (B'First .. B'Last);
      subtype Local_U8_Array is Cxx.Genode.Uint8_T_Array (1 .. B'Length);
      function Convert_Buffer is new Ada.Unchecked_Conversion (Local_U8_Array,
                                                               Local_Buffer);
      Data : Local_U8_Array := (others => 0);
   begin
      Cxx.Block.Client.Read (
         C.Instance,
         Client_Util.Convert_Request (R),
         Data);
      B := Convert_Buffer (Data);
   end Read;

   pragma Warnings (Off, "formal parameter ""R"" is not modified");
   procedure Release (C : in out Client_Session; R : in out Request)
   is
   pragma Warnings (On, "formal parameter ""R"" is not modified");
   begin
      Cxx.Block.Client.Release (C.Instance, Client_Util.Convert_Request (R));
   end Release;

   function Writable (C : Client_Session) return Boolean
   is
   begin
      return Cxx.Block.Client.Writable (C.Instance) /= Cxx.Bool'Val (0);
   end Writable;

   function Block_Count (C : Client_Session) return Count
   is
   begin
      return Count (Cxx.Block.Client.Block_Count (C.Instance));
   end Block_Count;

   function Block_Size (C : Client_Session) return Size
   is
   begin
      return Size (Cxx.Block.Client.Block_Size (C.Instance));
   end Block_Size;

   function Maximal_Transfer_Size (C : Client_Session) return Byte_Length
   is
   begin
      return Byte_Length (Cxx.Block.Client.Maximal_Transfer_Size (C.Instance));
   end Maximal_Transfer_Size;

end Cai.Block.Client;
