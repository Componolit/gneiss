
generic
   type State is limited private;
   with procedure Event (S : in out  State);
package Cai.Block.Client
   with SPARK_Mode
is

   type Request is new Block.Request;

   function Create return Client_Session;

   procedure Initialize (C : in out Client_Session; Path : String; S : in out State);

   procedure Finalize (C : in out Client_Session);

   procedure Submit_Read (C : Client_Session; R : Request)
      with
      Pre => R.Kind = Read and R.Status = Raw;

   procedure Submit_Write (C : Client_Session; R : Request; B : Buffer)
      with
      Pre => R.Kind = Write and R.Status = Raw;

   procedure Sync (C : Client_Session);

   function Next (C : Client_Session) return Request
      with
      Post => (if Next'Result.Kind /= None then Next'Result.Status /= Acknowledged else True);

   procedure Read (C : Client_Session; R : in out Request; B : out Buffer)
      with
      Pre => R.Kind = Read and R.Status = Ok,
      Post => R.Status = Ok or R.Status = Error;

   procedure Acknowledge (C : Client_Session; R : in out Request)
      with
      Pre => R.Kind /= None and (R.Status = Error or R.Status = Ok),
      Post => R.Status = Acknowledged;

   function Writable (C : Client_Session) return Boolean;
   function Block_Count (C : Client_Session) return Count;
   function Block_Size (C : Client_Session) return Size;
   function Maximal_Transfer_Size (C : Client_Session) return Unsigned_Long;

end Cai.Block.Client;
