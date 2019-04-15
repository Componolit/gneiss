package body Cai.Block.Client.Jobs with
   SPARK_Mode
is

   function Status (J : Job) return Job_Status
   is
   begin
      return J.Status;
   end Status;

   function Get_Client (J : Job) return Client_Instance
   is
   begin
      return J.Client;
   end Get_Client;

   function Get_Id (J : Job) return Job_Id
   is
   begin
      return Job_Id (J'Address);
   end Get_Id;

   function Create return Job
   is
   begin
      return Job'(Client    => Null_Client,
                  Kind      => None,
                  Status    => Raw,
                  Start     => 0,
                  Length    => 0,
                  Sent      => 0,
                  Acked     => 0,
                  Processed => 0);
   end Create;

   procedure Initialize (J      : in out Job;
                         C      :        Client_Session;
                         Kind   :        Request_Kind;
                         Start  :        Id;
                         Length :        Count)
   is
   begin
      J.Client    := Get_Instance (C);
      J.Kind      := Kind;
      J.Status    := Pending;
      J.Start     := Start;
      J.Length    := Length;
      J.Sent      := 0;
      J.Acked     := 0;
      J.Processed := 0;
   end Initialize;

   procedure Run (J : in out Job;
                  C : in out Client_Session)
   is
   begin
      null;
   end Run;

   procedure Release (J : in out Job;
                      C : in out Client_Session)
   is
   begin
      null;
   end Release;

   procedure Checked_Write (Jid    :        Job_Id;
                            Bsize  :        Size;
                            Data   :    out Buffer;
                            Length : in out Count;
                            Offset :        Count)
   is
   begin
      Write (Jid, Bsize, Data, Length, Offset);
   end Checked_Write;

   procedure Checked_Read (Jid    :        Job_Id;
                           Bsize  :        Size;
                           Data   :        Buffer;
                           Length : in out Count;
                           Offset :        Count)
   is
   begin
      Read (Jid, Bsize, Data, Length, Offset);
   end Checked_Read;
end Cai.Block.Client.Jobs;
