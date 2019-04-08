
with Ada.Unchecked_Conversion;
with Cai.Log.Client;

package body Iteration is

   use all type Block.Request_Kind;
   use all type Block.Request_Status;

   procedure Start (Item   :        Client.Request;
                    Offset :        Block.Count;
                    Data   : in out Burst) with
      Pre => Long_Integer (Item.Start - Offset) in Data'Range;

   procedure Finish (Item   :        Client.Request;
                     Offset :        Block.Count;
                     Data   : in out Burst) with
      Pre => Long_Integer (Item.Start - Offset) in Data'Range;

   procedure Start (Item   :        Client.Request;
                    Offset :        Block.Count;
                    Data   : in out Burst)
   is
   begin
      Data (Long_Integer (Item.Start - Offset)).Start := Ada.Real_Time.Clock;
   end Start;

   procedure Finish (Item   :        Client.Request;
                     Offset :        Block.Count;
                     Data   : in out Burst)
   is
   begin
      Data (Long_Integer (Item.Start - Offset)).Finish  := Ada.Real_Time.Clock;
      Data (Long_Integer (Item.Start - Offset)).Success := Item.Status = Block.Ok;
   end Finish;

   procedure Initialize (T      : out Test;
                         Offset :     Block.Count;
                         S      :     Boolean)
   is
   begin
      T.Sent      := -1;
      T.Received  := -1;
      T.Offset    := Offset;
      T.Finished  := False;
      T.Sync      := S;
      T.Buffer    := (others => Block.Byte'First);
      for I in T.Data'Range loop
         T.Data (I) := (Success => False, others => Ada.Real_Time.Time_First);
      end loop;
   end Initialize;

   procedure Send (C   : in out Block.Client_Session;
                   T   : in out Test;
                   Log : in out Cai.Log.Client_Session) is
      Read_Request : Client.Request := (Kind   => Block.Read,
                                        Priv   => Block.Null_Data,
                                        Start  => 0,
                                        Length => 1,
                                        Status => Block.Raw);
      Write_Request : Client.Request := (Kind   => Block.Write,
                                         Priv   => Block.Null_Data,
                                         Start  => 0,
                                         Length => 1,
                                         Status => Block.Raw);
   begin
      if T.Sent < T.Data'Last then
         if Client.Initialized (C) then
            for I in T.Sent .. T.Data'Last - 1 loop
               Read_Request.Start  := Block.Id (I + 1) + T.Offset;
               Write_Request.Start := Block.Id (I + 1) + T.Offset;
               if
                  Client.Ready (C, Write_Request)
                  and Client.Ready (C, Read_Request)
               then
                  case Operation is
                     pragma Warnings (Off, "this code can never be executed and has been deleted");
                     --  Operation is a generic parameter of this package
                     --  In a package instance the compiler deletes the branches that cannot be reached
                     when Block.Write =>
                        Start (Write_Request, T.Offset, T.Data);
                        Client.Enqueue_Write (C, Write_Request,
                                              T.Buffer (1 .. Block.Buffer_Index (Client.Block_Size (C))));
                     when Block.Read =>
                        Start (Read_Request, T.Offset, T.Data);
                        Client.Enqueue_Read (C, Read_Request);
                     when others =>
                        null;
                     pragma Warnings (On, "this code can never be executed and has been deleted");
                  end case;
                  T.Sent := T.Sent + 1;
               else
                  Client.Submit (C);
                  exit;
               end if;
            end loop;
         else
            Cai.Log.Client.Error (Log, "Failed to run test, client not initialized");
         end if;
      end if;
      if T.Sent = T.Data'Last and T.Received = T.Data'Last then
         if Operation = Block.Write and T.Sync then
            declare
               S : constant Client.Request := (Kind   => Block.Sync,
                                               Priv   => Block.Null_Data,
                                               Start  => 0,
                                               Length => 0,
                                               Status => Block.Raw);
            begin
               if Client.Supported (C, S) then
                  while not Client.Ready (C, S) loop
                     null;
                  end loop;
                  Client.Enqueue_Sync (C, S);
                  Client.Submit (C);
               end if;
            end;
         end if;
         T.Finished := True;
      end if;
   end Send;

   procedure Receive (C   : in out Block.Client_Session;
                      T   : in out Test;
                      Log : in out Cai.Log.Client_Session) is
   begin
      if Client.Initialized (C) then
         while T.Received < T.Data'Last loop
            declare
               R : Client.Request := Client.Next (C);
            begin
               if R.Kind = Operation then
                  if R.Kind = Block.Read then
                     Client.Read (C, R, T.Buffer (1 .. R.Length * Client.Block_Size (C)));
                  end if;
                  Finish (R, T.Offset, T.Data);
                  T.Received := T.Received + 1;
                  Client.Release (C, R);
               elsif R.Kind = Block.None then
                  exit;
               else
                  Cai.Log.Client.Warning (Log, "Received unexpected request");
               end if;
            end;
         end loop;
      else
         Cai.Log.Client.Error (Log, "Failed to run test, client not Initialized");
      end if;
      if T.Sent = T.Data'Last and T.Received = T.Data'Last then
         T.Finished := True;
      end if;
   end Receive;

   procedure Xml (Xml_Log : in out Cai.Log.Client_Session;
                  R       :        Request;
                  B       :        Block.Id);

   procedure Xml (Xml_Log : in out Cai.Log.Client_Session;
                  R       :        Request;
                  B       :        Block.Id)
   is
      function Time_Conversion is new Ada.Unchecked_Conversion (Ada.Real_Time.Time, Duration);
   begin
      Cai.Log.Client.Info (Xml_Log, "<request id=""" & Cai.Log.Image (Long_Integer (B))
                                    & """ sent=""" & Cai.Log.Image (Time_Conversion (R.Start))
                                    & """ received=""" & Cai.Log.Image (Time_Conversion (R.Finish))
                                    & """ status=""" & (if R.Success then "OK" else "ERROR")
                                    & """/>");
   end Xml;

   procedure Xml (Xml_Log : in out Cai.Log.Client_Session;
                  B       :        Burst;
                  Offset  :        Block.Count)
   is
   begin
      for I in B'Range loop
         Xml (Xml_Log, B (I), Block.Id (I) + Offset);
      end loop;
   end Xml;

end Iteration;
