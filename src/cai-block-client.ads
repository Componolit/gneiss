
generic
   with procedure Event;
package Cai.Block.Client
   with SPARK_Mode
is

   type Request is new Block.Request;

   function Create return Client_Session;

   function Get_Instance (C : Client_Session) return Client_Instance;

   function Initialized (C : Client_Session) return Boolean;

   procedure Initialize (C : in out Client_Session; Path : String; Buffer_Size : Byte_Length := 0);

   procedure Finalize (C : in out Client_Session);

   function Ready (C : Client_Session; R : Request) return Boolean with
      Volatile_Function;

   function Supported (C : Client_Session; R : Request) return Boolean;

   procedure Enqueue_Read (C : in out Client_Session; R : Request) with
      Pre => R.Kind = Read
             and R.Status = Raw
             and Ready (C, R)
             and Supported (C, R);

   procedure Enqueue_Write (C : in out Client_Session; R : Request; B : Buffer) with
      Pre => R.Kind = Write
             and R.Status = Raw
             and B'Length = R.Length * Block_Size (C)
             and Ready (C, R)
             and Supported (C, R);

   procedure Enqueue_Sync (C : in out Client_Session; R : Request) with
      Pre => R.Kind = Sync
             and R.Status = Raw
             and Ready (C, R)
             and Supported (C, R);

   procedure Enqueue_Trim (C : in out Client_Session; R : Request) with
      Pre => R.Kind = Trim
             and R.Status = Raw
             and Ready (C, R)
             and Supported (C, R);

   procedure Submit (C : in out Client_Session);

   function Next (C : Client_Session) return Request with
      Volatile_Function,
      Post => (if
                  Next'Result.Kind /= None
               then
                  Next'Result.Status = Ok
                  or Next'Result.Status = Error
               else
                  True);

   procedure Read (C : in out Client_Session; R : Request; B : out Buffer) with
      Pre => R.Kind = Read
             and R.Status = Ok
             and B'Length >= R.Length * Block_Size (C);

   procedure Release (C : in out Client_Session; R : in out Request) with
      Pre => R.Kind /= None
             and (R.Status = Ok or R.Status = Error);

   function Writable (C : Client_Session) return Boolean;
   function Block_Count (C : Client_Session) return Count;
   function Block_Size (C : Client_Session) return Size;
   function Maximal_Transfer_Size (C : Client_Session) return Byte_Length;

end Cai.Block.Client;
