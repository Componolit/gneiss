
generic
   with procedure Write (Jid        :        Job_Id;
                         Bsize      :        Size;
                         Data       :    out Buffer;
                         Length     : in out Count);
package Cai.Block.Client.Jobs with
   SPARK_Mode
is

   type Job_Status is (Raw, Pending, Ok, Error);

   type Job is limited private;

   function Status (J : Job) return Job_Status;

   function Create return Job with
      Post => Status (Create'Result) = Raw;

   procedure Initialize (J      : in out Job;
                         Kind   :        Request_Kind;
                         Start  :        Id;
                         Length :        Count) with
      Pre  => Status (J) = Raw and Kind /= None,
      Post => Status (J) = Pending;

   procedure Run (J : in out Job;
                  C : in out Client_Session) with
      Pre  => Status (J) = Pending,
      Post => Status (J) in Pending .. Error;

   procedure Read (J      : in out Job;
                   C      : in out Client_Session;
                   Data   :    out Buffer;
                   Length : in out Count;
                   Offset :        Count) with
      Pre  => Data'Length = Length * Block_Size (C)
              and Offset < Length
              and Status (J) = Ok,
      Post => Length <= Length'Old
              and Status (J) = Ok;

   procedure Release (J : in out Job;
                      C : in out Client_Session) with
      Pre  => Status (J) in Ok .. Error,
      Post => Status (J) = Raw;

   function Get_Id (J : Job) return Job_Id;

private

   procedure Checked_Write (Jid    :        Job_Id;
                            Bsize  :        Size;
                            Data   :    out Buffer;
                            Length : in out Count) with
      Pre  => Data'Length = Length * Bsize,
      Post => Length <= Length'Old;

   type Job is limited record
      Kind      : Request_Kind;
      Status    : Job_Status;
      Start     : Id;
      Length    : Count;
      Processed : Count;
   end record;

end Cai.Block.Client.Jobs;
