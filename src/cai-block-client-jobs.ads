
generic
   --  Write procedure that is called once data to write is required
   --  Pre => Data'Length = Length * Bsize
   --  Post => Length <= Length'Old
   --  Jid      Id of the Job passed to Run
   --  Bsize    Block size of the used client
   --  Data     Write buffer
   --  Length   Length of the buffer in blocks
   with procedure Write (Jid        :        Job_Id;
                         Bsize      :        Size;
                         Data       :    out Buffer;
                         Length     : in out Count);
package Cai.Block.Client.Jobs with
   SPARK_Mode
is

   --  Status of a Job
   --
   --  @value Raw     Uninitialized or released job
   --  @value Pending Initialized job, currently in progress
   --  @value Ok      Initialized job, successfully finished
   --  @value Error   Initialized job, failed
   type Job_Status is (Raw, Pending, Ok, Error);

   --  Job state object
   type Job is limited private;

   --  Get status of job
   --
   --  @parameter J  Job
   --  @return       Job status
   function Status (J : Job) return Job_Status;

   --  Get client the job is bound to
   --
   --  @param J Job
   --  @return  Client instance
   function Get_Client (J : Job) return Client_Instance;

   --  Get unique Id of job
   --
   --  @param J  Job
   --  @return   Job Id
   function Get_Id (J : Job) return Job_Id;

   --  Create new job
   --
   --  @return Raw job
   function Create return Job with
      Post => Status (Create'Result) = Raw;

   --  Initialize job
   --
   --  @param J      Job to initialize
   --  @param C      Client to bind on the job
   --  @param Kind   Job type
   --  @param Start  First block to process
   --  @param Length Number of consecutive blocks to process, starting from and including Start
   procedure Initialize (J      : in out Job;
                         C      :        Client_Session;
                         Kind   :        Request_Kind;
                         Start  :        Id;
                         Length :        Count) with
      Pre  => Status (J) = Raw and Kind /= None and Initialized (C),
      Post => Status (J) = Pending;

   --  Process job, handles sending requests and mapping acknowledgements
   --
   --  @param J  Job to process
   --  @param C  Block client to run the job on
   procedure Run (J : in out Job;
                  C : in out Client_Session) with
      Pre  => Status (J) = Pending
              and then Initialized (C)
              and then Get_Client (J) = Get_Instance (C),
      Post => Status (J) in Pending .. Error
              and Get_Id (J) = Get_Id (J)'Old;

   --  Read data from job if available, can be called on pending jobs,
   --  if the available data is not read completely Run will not continue the job
   --
   --  @param J       Job to read from
   --  @param C       Client the job is bound to
   --  @param Data    Buffer to read into
   --  @param Length  in Length of the read buffer in blocks, out Length of the read data in blocks
   --  @param Offset  Offset in blocks of the first block
   procedure Read (J      : in out Job;
                   C      : in out Client_Session;
                   Data   :    out Buffer;
                   Length : in out Count;
                   Offset :        Count) with
      Pre  => Data'Length = Length * Block_Size (C)
              and then Initialized (C)
              and then Get_Client (J) = Get_Instance (C)
              and then Offset < Length
              and then Status (J) in Pending .. Ok,
      Post => Length <= Length'Old
              and Status (J) = Status (J)'Old
              and Get_Id (J) = Get_Id (J)'Old;

   --  Release a finished job, frees resources on the platform
   --
   --  @param J  Job to release
   --  @param C  Client the job is bound to
   procedure Release (J : in out Job;
                      C : in out Client_Session) with
      Pre  => Initialized (C)
              and then Get_Client (J) = Get_Instance (C)
              and then Status (J) in Ok .. Error,
      Post => Status (J) = Raw;

private

   procedure Checked_Write (Jid    :        Job_Id;
                            Bsize  :        Size;
                            Data   :    out Buffer;
                            Length : in out Count) with
      Pre  => Data'Length = Length * Bsize,
      Post => Length <= Length'Old;

   type Job is limited record
      Client    : Client_Instance;
      Kind      : Request_Kind;
      Status    : Job_Status;
      Start     : Id;
      Length    : Count;
      Processed : Count;
   end record;

end Cai.Block.Client.Jobs;
