
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

   procedure Initialize (C : in out Client_Session; Path : String)
   is
      C_Path : constant String := Path & Character'Val(0);
      subtype C_Path_String is String (1 .. C_Path'Length);
      subtype C_String is Cxx.Char_Array (1 .. C_Path'Length);
      function To_C_String is new Ada.Unchecked_Conversion (C_Path_String, C_String);
   begin
      Cxx.Block.Client.Initialize (C.Instance, To_C_String (C_Path), Event'Address);
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
            null;
         when Read | Write =>
            Cr.Kind := (if R.Kind = Read then Cxx.Block.Read else Cxx.Block.Write);
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
                     when Cxx.Block.Read => Read,
                     when Cxx.Block.Write => Write));
   begin
      R.Priv := Private_Data (CR.Uid);
      case R.Kind is
         when None =>
            null;
         when Read | Write =>
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

   procedure Submit_Read (C : Client_Session; R : Request)
   is
   begin
      Cxx.Block.Client.Submit_Read (C.Instance, Convert_Request (R));
   end Submit_Read;

   procedure Submit_Write (C : Client_Session; R : Request; B : Buffer)
   is
      subtype Local_Buffer is Buffer (1 .. B'Length);
      subtype Local_U8_Array is Cxx.Genode.Uint8_T_Array (1 .. B'Length);
      function Convert_Buffer is new Ada.Unchecked_Conversion (Local_Buffer, Local_U8_Array);
      Data : Local_U8_Array := Convert_Buffer (B);
   begin
      Cxx.Block.Client.Submit_Write (
         C.Instance,
         Convert_Request (R),
         Data,
         Cxx.Genode.Uint64_T (B'Length));
   end Submit_Write;

   procedure Sync (C : Client_Session)
   is
   begin
      Cxx.Block.Client.Sync (C.Instance);
   end Sync;

   function Next (C : Client_Session) return Request
   is
   begin
      return Convert_Request (Cxx.Block.Client.Next (C.Instance));
   end Next;

   procedure Read (C : Client_Session; R : in out Request; B : out Buffer)
   is
      subtype Local_Buffer is Buffer (1 .. B'Length);
      subtype Local_U8_Array is Cxx.Genode.Uint8_T_Array (1 .. B'Length);
      function Convert_Buffer is new Ada.Unchecked_Conversion (Local_U8_Array, Local_Buffer);
      Data : Local_U8_Array := (others => 0);
      Req : Cxx.Block.Request.Class := Convert_Request (R);
   begin
      Cxx.Block.Client.Read (
         C.Instance,
         Req,
         Data,
         Cxx.Genode.Uint64_T (B'Length));
      B := Convert_Buffer (Data);
      R := Convert_Request (Req);
   end Read;

   procedure Acknowledge (C : Client_Session; R : in out Request)
   is
   begin
      Cxx.Block.Client.Acknowledge (C.Instance, Convert_Request (R));
      R.Status := Ok;
   end Acknowledge;

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

   function Maximal_Transfer_Size (C : Client_Session) return Unsigned_Long
   is
      pragma Unreferenced (C);
   begin
      return 1024 * 1024;
   end Maximal_Transfer_Size;

end Cai.Block.Client;
