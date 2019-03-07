
generic
   type State_Type is limited private;
   with procedure Callback (S : in out  State_Type);
package Cai.Block.Client
   with SPARK_Mode
is

   function Create_Device return Device;

   procedure Initialize_Device (D : in out Device; Path : String; S : in out State_Type);

   procedure Finalize_Device (D : in out Device);

   procedure Submit_Read (D : Device; R : Request)
      with
      Pre => R.Kind = Read and R.Status = Raw;

   procedure Submit_Write (D : Device; R : Request; B : Buffer)
      with
      Pre => R.Kind = Write and R.Status = Raw;

   procedure Sync (D : Device);

   function Next (D : Device) return Request
      with
      Post => (if Next'Result.Kind /= None then Next'Result.Status /= Acknowledged else True);

   procedure Read (D : Device; R : in out Request; B : out Buffer)
      with
      Pre => R.Kind = Read and R.Status = Ok,
      Post => R.Status = Ok or R.Status = Error;

   procedure Acknowledge (D : Device; R : in out Request)
      with
      Pre => R.Kind /= None and (R.Status = Error or R.Status = Ok),
      Post => R.Status = Acknowledged;

   function Writable (D : Device) return Boolean;
   function Block_Count (D : Device) return Count;
   function Block_Size (D : Device) return Size;
   function Maximal_Transfer_Size (D : Device) return Unsigned_Long;

private

   Callback_State : System.Address;

end Cai.Block.Client;
