
with Ada.Unchecked_Conversion;
with Cxx;
with Cxx.Block;
with Cxx.Block.Client;
with Cxx.Genode;
use all type Cxx.Bool;

package body Cai.Block.Client is

   function Create return Client_Session
   is
   begin
      return Client_Session' (Instance => Cxx.Block.Client.Constructor);
   end Create;

   function Get_Instance (C : Client_Session) return Client_Instance
   is
   begin
      return Client_Instance (Cxx.Block.Client.Get_Instance (C.Instance));
   end Get_Instance;

   function Initialized (C : Client_Session) return Boolean
   is
   begin
      return Cxx.Block.Client.Initialized (C.Instance) = 1;
   end Initialized;

   procedure Initialize (C : in out Client_Session; Path : String; Buffer_Size : Byte_Length := 0)
   is
      C_Path : constant String := Path & Character'Val(0);
      subtype C_Path_String is String (1 .. C_Path'Length);
      subtype C_String is Cxx.Char_Array (1 .. C_Path'Length);
      function To_C_String is new Ada.Unchecked_Conversion (C_Path_String, C_String);
   begin
      Cxx.Block.Client.Initialize (C.Instance, To_C_String (C_Path), Event'Address, Cxx.Genode.Uint64_T (Buffer_Size));
   end Initialize;

   procedure Finalize (C : in out Client_Session)
   is
   begin
      Cxx.Block.Client.Finalize (C.Instance);
   end Finalize;

   function Convert_Request (R : Request) return Cxx.Block.Request.Class
   is
      Cr : Cxx.Block.Request.Class := Cxx.Block.Request.Class' (
         Kind => Cxx.Block.None,
         Uid => Cxx.Unsigned_Char_Array (R.Priv),
         Start => 0,
         Length => 0,
         Status => Cxx.Block.Raw);
   begin
      case R.Kind is
         when None =>
            Cr.Kind := Cxx.Block.None;
         when Sync =>
            Cr.Kind := Cxx.Block.Sync;
         when Read | Write | Trim =>
            Cr.Kind := (case R.Kind is
                        when Read => Cxx.Block.Read,
                        when Write => Cxx.Block.Write,
                        when Trim => Cxx.Block.Trim,
                        when others => Cxx.Block.None);
            Cr.Start := Cxx.Genode.Uint64_T (R.Start);
            Cr.Length := Cxx.Genode.Uint64_T (R.Length);
            if R.Status = Raw then
               Cr.Status := Cxx.Block.Raw;
            end if;
            if R.Status = Ok then
               Cr.Status := Cxx.Block.Ok;
            end if;
            if R.Status = Error then
               Cr.Status := Cxx.Block.Error;
            end if;
            if R.Status = Acknowledged then
               Cr.Status := Cxx.Block.Ack;
            end if;
      end case;
      return Cr;
   end Convert_Request;

   function Convert_Request (CR : Cxx.Block.Request.Class) return Request
   is
      R : Request ((case CR.Kind is
                     when Cxx.Block.None => None,
                     when Cxx.Block.Sync => Sync,
                     when Cxx.Block.Read => Read,
                     when Cxx.Block.Write => Write,
                     when Cxx.Block.Trim => Trim));
   begin
      R.Priv := Private_Data (CR.Uid);
      case R.Kind is
         when None | Sync =>
            null;
         when Read | Write | Trim =>
            R.Start := Id (CR.Start);
            R.Length := Count (CR.Length);
            R.Status :=
               (case CR.Status is
                  when Cxx.Block.Raw => Raw,
                  when Cxx.Block.Ok => Ok,
                  when Cxx.Block.Error => Error,
                  when Cxx.Block.Ack => Acknowledged);
      end case;
      return R;
   end Convert_Request;

   function Ready (C : Client_Session; R : Request) return Boolean
   is
   begin
      return Cxx.Block.Client.Ready (C.Instance, Convert_Request (R)) = 1;
   end Ready;

   procedure Enqueue_Read (C : in out Client_Session; R : Request)
   is
   begin
      Cxx.Block.Client.Enqueue_Read (C.Instance, Convert_Request (R));
   end Enqueue_Read;

   procedure Enqueue_Write (C : in out Client_Session; R : Request; B : Buffer)
   is
      subtype Local_Buffer is Buffer (B'First .. B'Last);
      subtype Local_U8_Array is Cxx.Genode.Uint8_T_Array (1 .. B'Length);
      function Convert_Buffer is new Ada.Unchecked_Conversion (Local_Buffer, Local_U8_Array);
      Data : Local_U8_Array := Convert_Buffer (B);
   begin
      Cxx.Block.Client.Enqueue_Write (
         C.Instance,
         Convert_Request (R),
         Data);
   end Enqueue_Write;

   procedure Enqueue_Sync (C : in out Client_Session; R : Request)
   is
   begin
      Cxx.Block.Client.Enqueue_Sync (C.Instance, Convert_Request (R));
   end Enqueue_Sync;

   procedure Enqueue_Trim (C : in out Client_Session; R : Request)
   is
   begin
      Cxx.Block.Client.Enqueue_Trim (C.Instance, Convert_Request (R));
   end Enqueue_Trim;

   procedure Submit (C : in out Client_Session)
   is
   begin
      Cxx.Block.Client.Submit (C.Instance);
   end Submit;

   function Next (C : Client_Session) return Request
   is
   begin
      return Convert_Request (Cxx.Block.Client.Next (C.Instance));
   end Next;

   procedure Read (C : in out Client_Session; R : Request; B : out Buffer)
   is
      subtype Local_Buffer is Buffer (B'First .. B'Last);
      subtype Local_U8_Array is Cxx.Genode.Uint8_T_Array (1 .. B'Length);
      function Convert_Buffer is new Ada.Unchecked_Conversion (Local_U8_Array, Local_Buffer);
      Data : Local_U8_Array := (others => 0);
   begin
      Cxx.Block.Client.Read (
         C.Instance,
         Convert_Request (R),
         Data);
      B := Convert_Buffer (Data);
   end Read;

   procedure Release (C : in out Client_Session; R : in out Request)
   is
   begin
      Cxx.Block.Client.Release (C.Instance, Convert_Request (R));
   end Release;

   function Writable (C : Client_Session) return Boolean
   is
   begin
      return Cxx.Block.Client.Writable (C.Instance) /= 0;
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
