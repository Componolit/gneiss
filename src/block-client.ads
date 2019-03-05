
private with Internals.Block;

package Block.Client
   with SPARK_Mode
is

   type Device is limited private;

   function Create_Device return Device;

   procedure Initialize_Device (D : in out Device; Path : String);

   procedure Finalize_Device (D : in out Device);

   procedure Submit_Read (D : Device; R : Request)
      with
      Pre => R.Kind = Read and R.Status = Raw;

   procedure Submit_Sync (D : Device; R : Request)
      with
      Pre => R.Kind = Sync and R.Status = Raw;

   procedure Submit_Write (D : Device; R : Request; B : Buffer)
      with
      Pre => R.Kind = Write and R.Status = Raw;

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

   type Device is new Internals.Block.Device;

end Block.Client;
