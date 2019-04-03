
pragma Warnings (Off, "procedure ""Event"" is not referenced");
--  Supress unreferenced warnings since not every platform needs this procedure

generic
   with procedure Event;
package Cai.Block.Client
   with SPARK_Mode
is

   --  Redefinition of Cai.Block.Client.Request since SPARK does not allow discriminants of derived types
   --  SPARK RM 3.7 (2)
   type Request (Kind : Request_Kind := None) is record
      Priv : Private_Data;
      case Kind is
         when None =>
            null;
         when Read .. Trim =>
            Start  : Id;
            Length : Count;
            Status : Request_Status;
      end case;
   end record;

   function Create return Client_Session;

   function Initialized (C : Client_Session) return Boolean;

   function Get_Instance (C : Client_Session) return Client_Instance with
      Pre => Initialized (C);

   procedure Initialize (C           : in out Client_Session;
                         Path        :        String;
                         Buffer_Size :        Byte_Length := 0);

   procedure Finalize (C : in out Client_Session) with
      Pre => Initialized (C);

   function Ready (C : Client_Session;
                   R : Request) return Boolean with
      Pre => Initialized (C);

   function Supported (C : Client_Session;
                       R : Request) return Boolean with
      Pre => Initialized (C);

   procedure Enqueue_Read (C : in out Client_Session;
                           R :        Request) with
      Pre => Initialized (C)
             and then R.Kind = Read
             and then R.Status = Raw
             and then Ready (C, R)
             and then Supported (C, R);

   procedure Enqueue_Write (C : in out Client_Session;
                            R :        Request;
                            B :        Buffer) with
      Pre => Initialized (C)
             and then R.Kind = Write
             and then R.Status = Raw
             and then B'Length = R.Length * Block_Size (C)
             and then Ready (C, R)
             and then Supported (C, R);

   procedure Enqueue_Sync (C : in out Client_Session;
                           R :        Request) with
      Pre => Initialized (C)
             and then R.Kind = Sync
             and then R.Status = Raw
             and then Ready (C, R)
             and then Supported (C, R);

   procedure Enqueue_Trim (C : in out Client_Session;
                           R :        Request) with
      Pre => Initialized (C)
             and then R.Kind = Trim
             and then R.Status = Raw
             and then Ready (C, R)
             and then Supported (C, R);

   procedure Submit (C : in out Client_Session) with
      Pre => Initialized (C);

   function Next (C : Client_Session) return Request with
      Volatile_Function,
      Pre => Initialized (C),
      Post => (if Next'Result.Kind /= None
               then Next'Result.Status = Ok or Next'Result.Status = Error
               else True);

   procedure Read (C : in out Client_Session;
                   R :        Request;
                   B : out    Buffer) with
      Pre => Initialized (C)
             and then R.Kind = Read
             and then R.Status = Ok
             and then B'Length >= R.Length * Block_Size (C);

   procedure Release (C : in out Client_Session;
                      R : in out Request) with
      Pre => Initialized (C)
             and then R.Kind /= None
             and then (R.Status = Ok or R.Status = Error);

   function Writable (C : Client_Session) return Boolean with
      Pre => Initialized (C);
   function Block_Count (C : Client_Session) return Count with
      Pre => Initialized (C);
   function Block_Size (C : Client_Session) return Size with
      Pre => Initialized (C);
   function Maximal_Transfer_Size (C : Client_Session) return Byte_Length with
      Pre => Initialized (C);

end Cai.Block.Client;
