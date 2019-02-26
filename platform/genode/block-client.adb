
with Ada.Unchecked_Conversion;
with Cxx;
with Cxx.Block;
with Cxx.Genode;
use all type Cxx.Bool;

package body Block.Client is

   function Create_Device return Device
   is
   begin
      return Device' (Instance => Cxx.Block.Client.Constructor);
   end Create_Device;

   procedure Initialize_Device (D : in out Device; Path : String)
   is
      C_Path : constant String := Path & Character'Val(0);
      subtype C_Path_String is String (1 .. C_Path'Length);
      subtype C_String is Cxx.Char_Array (1 .. C_Path'Length);
      function To_C_String is new Ada.Unchecked_Conversion (C_Path_String, C_String);
   begin

      Cxx.Block.Client.Initialize (D.Instance, To_C_String (C_Path));
   end Initialize_Device;

   procedure Finalize_Device (D : in out Device)
   is
   begin
      Cxx.Block.Client.Finalize (D.Instance);
   end Finalize_Device;

   function Convert_Request (R : Request) return Cxx.Block.Client.Request.Class
   is
   begin
      return Cxx.Block.Client.Request.Class'(
         Kind => (case R.Kind is
                  when None => Cxx.Block.Client.None,
                  when Read => Cxx.Block.Client.Read,
                  when Write => Cxx.Block.Client.Write,
                  when Sync => Cxx.Block.Client.Sync),
         Uid => Cxx.Unsigned_Char_Array (R.Priv),
         Start => (case R.Kind is
                  when None | Sync => 0,
                  when Read | Write => Cxx.Genode.Uint64_T (R.Start)),
         Length => (case R.Kind is
                  when None | Sync => 0,
                  when Read | Write => Cxx.Genode.Uint64_T (R.Length)),
         Success => (case R.Kind is
                  when None | Sync => 0,
                  when Read | Write => Cxx.Bool (if R.Success then 1 else 0)));
   end Convert_Request;

   function Convert_Request (CR : Cxx.Block.Client.Request.Class) return Request
   is
      R : Request ((case CR.Kind is
                     when Cxx.Block.Client.None => None,
                     when Cxx.Block.Client.Read => Read,
                     when Cxx.Block.Client.Write => Write,
                     when Cxx.Block.Client.Sync => Sync));
   begin
      R.Priv := Private_Data (CR.Uid);
      case R.Kind is
         when None | Sync =>
            null;
         when Read | Write =>
            R.Start := Block_Id (CR.Start);
            R.Length := Block_Count (CR.Length);
            R.Success := (if CR.Success = 0 then False else True);
      end case;
      return R;
   end Convert_Request;

   procedure Submit_Read (D : Device; R : Request)
   is
   begin
      Cxx.Block.Client.Submit_Read (D.Instance, Convert_Request (R));
   end Submit_Read;

   procedure Submit_Sync (D : Device; R : Request)
   is
   begin
      Cxx.Block.Client.Submit_Sync (D.Instance, Convert_Request (R));
   end Submit_Sync;

   procedure Submit_Write (D : Device; R : Request; B : Buffer)
   is
      subtype Local_Buffer is Buffer (1 .. B'Length);
      subtype Local_U8_Array is Cxx.Genode.Uint8_T_Array (1 .. B'Length);
      function Convert_Buffer is new Ada.Unchecked_Conversion (Local_Buffer, Local_U8_Array);
      Data : Local_U8_Array := Convert_Buffer (B);
   begin
      Cxx.Block.Client.Submit_Write (
         D.Instance,
         Convert_Request (R),
         Data,
         Cxx.Genode.Uint64_T (B'Length));
   end Submit_Write;

   function Next (D : Device) return Request
   is
   begin
      return Convert_Request (Cxx.Block.Client.Next (D.Instance));
   end Next;

   procedure Acknowledge_Read (D : Device; R : Request; B : out Buffer)
   is
      subtype Local_Buffer is Buffer (1 .. B'Length);
      subtype Local_U8_Array is Cxx.Genode.Uint8_T_Array (1 .. B'Length);
      function Convert_Buffer is new Ada.Unchecked_Conversion (Local_U8_Array, Local_Buffer);
      Data : Local_U8_Array := (others => 0);
   begin
      Cxx.Block.Client.Acknowledge_Read (
         D.Instance,
         Convert_Request (R),
         Data,
         Cxx.Genode.Uint64_T (B'Length));
      B := Convert_Buffer (Data);
   end Acknowledge_Read;

   procedure Acknowledge_Sync (D : Device; R : Request)
   is
   begin
      Cxx.Block.Client.Acknowledge_Sync (D.Instance, Convert_Request (R));
   end Acknowledge_Sync;

   procedure Acknowledge_Write (D : Device; R : Request)
   is
   begin
      Cxx.Block.Client.Acknowledge_Write (D.Instance, Convert_Request (R));
   end Acknowledge_Write;

end Block.Client;
