
with Cai.Types;

pragma Warnings (Off, "procedure ""Event"" is not referenced");
--  Supress unreferenced warnings since not every platform needs this procedure

generic
   with procedure Event;
   --  Called when a read has been triggered and data is available
   --  Pre => Data'Length = Bsize * Length
   --
   --  C       Client session instance identifier
   --  Bsize   Block size of C
   --  Start   Start block that has been read from
   --  Length  number of blocks to read
   --  Data    Read data
   with procedure Read (C      : Client_Instance;
                        Bsize  : Size;
                        Start  : Id;
                        Length : Count;
                        Data   : Buffer);
   --  Write procedure called when the platform required data to write
   --  Pre => Data'Length = Bsize * Length
   --
   --  C       Client session instance identifier
   --  Bsize   Block size of C
   --  Start   Start block that is written to
   --  Length  number of blocks that will be written
   --  Data    Data that will be written
   with procedure Write (C      :     Client_Instance;
                         Bsize  :     Size;
                         Start  :     Id;
                         Length :     Count;
                         Data   : out Buffer);
package Cai.Block.Client with
   SPARK_Mode
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

   function Initialized (C : Client_Session) return Boolean;

   function Create return Client_Session with
      Post => not Initialized (Create'Result);

   function Get_Instance (C : Client_Session) return Client_Instance with
      Pre => Initialized (C);

   procedure Initialize (C           : in out Client_Session;
                         Cap         :        Cai.Types.Capability;
                         Path        :        String;
                         Buffer_Size :        Byte_Length := 0);

   procedure Finalize (C : in out Client_Session) with
      Pre  => Initialized (C),
      Post => not Initialized (C);

   function Ready (C : Client_Session;
                   R : Request) return Boolean with
      Pre => Initialized (C);

   function Supported (C : Client_Session;
                       R : Request_Kind) return Boolean with
      Pre => Initialized (C) and then Supported (C, R);

   --  Enqueue request
   --
   --  @param C  Client session instance
   --  @param R  Request to enqueue
   procedure Enqueue (C : in out Client_Session;
                           R :        Request) with
      Pre  => Initialized (C)
              and then R.Kind in Read .. Trim
              and then R.Status = Raw
              and then Supported (C, R.Kind)
              and then Ready (C, R),
      Post => Initialized (C)
              and Writable (C)'Old              = Writable (C)
              and Block_Count (C)'Old           = Block_Count (C)
              and Block_Size (C)'Old            = Block_Size (C)
              and Maximal_Transfer_Size (C)'Old = Maximal_Transfer_Size (C);

   procedure Submit (C : in out Client_Session) with
      Pre  => Initialized (C),
      Post => Initialized (C)
              and Writable (C)'Old              = Writable (C)
              and Block_Count (C)'Old           = Block_Count (C)
              and Block_Size (C)'Old            = Block_Size (C)
              and Maximal_Transfer_Size (C)'Old = Maximal_Transfer_Size (C);

   function Next (C : Client_Session) return Request with
      Volatile_Function,
      Pre  => Initialized (C),
      Post => (if Next'Result.Kind /= None
               then Next'Result.Status = Ok or Next'Result.Status = Error
               else True);

   --  Read the returned data from a successfully acknowledged read request
   --
   --  @param C  Client session instance
   --  @param R  Request to read data from
   procedure Read (C : in out Client_Session;
                   R :        Request) with
      Pre  => Initialized (C)
              and then R.Kind = Read
              and then R.Status = Ok,
      Post => Initialized (C)
              and Writable (C)'Old              = Writable (C)
              and Block_Count (C)'Old           = Block_Count (C)
              and Block_Size (C)'Old            = Block_Size (C)
              and Maximal_Transfer_Size (C)'Old = Maximal_Transfer_Size (C);

   procedure Release (C : in out Client_Session;
                      R : in out Request) with
      Pre  => Initialized (C)
              and then R.Kind /= None
              and then (R.Status = Ok or R.Status = Error),
      Post => Initialized (C)
              and Writable (C)'Old              = Writable (C)
              and Block_Count (C)'Old           = Block_Count (C)
              and Block_Size (C)'Old            = Block_Size (C)
              and Maximal_Transfer_Size (C)'Old = Maximal_Transfer_Size (C);

   function Writable (C : Client_Session) return Boolean with
      Pre => Initialized (C);
   function Block_Count (C : Client_Session) return Count with
      Pre => Initialized (C);
   function Block_Size (C : Client_Session) return Size with
      Pre => Initialized (C);
   function Maximal_Transfer_Size (C : Client_Session) return Byte_Length with
      Pre => Initialized (C);

end Cai.Block.Client;
