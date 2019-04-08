
with Cai.Log.Client;

package body Run is

   use all type Block.Count;
   use all type Block.Request_Kind;

   procedure Initialize (R : out Run_Type;
                         S :     Boolean)
   is
   begin
      for I in R'Range loop
         Iter.Initialize (R (I), Block.Count (I - 1) * R (I).Data'Length, S);
      end loop;
   end Initialize;

   function First (R : Run_Type) return Integer;

   function First (R : Run_Type) return Integer
   is
   begin
      for I in R'Range loop
         if R (I).Finished = False then
            return I;
         end if;
      end loop;
      return -1;
   end First;

   Printed : Boolean := False;

   procedure Run (C   : in out Block.Client_Session;
                  R   : in out Run_Type;
                  Log : in out Cai.Log.Client_Session)
   is
      F : constant Integer := First (R);
   begin
      if F in R'Range then
         if not Printed then
            Cai.Log.Client.Info (Log, Cai.Log.Image (F)  & " .. ", False);
            Printed := True;
         end if;
         Iter.Receive (C, R (F), Log);
         Iter.Send (C, R (F), Log);
         if R (F).Finished and F + 1 in R'Range then
            Printed := False;
            Iter.Receive (C, R (F + 1), Log);
            Iter.Send (C, R (F + 1), Log);
         end if;
      end if;
   end Run;

   function Finished (R : Run_Type) return Boolean
   is
      Fin : Boolean := True;
   begin
      for T of R loop
         Fin := Fin and T.Finished;
      end loop;
      return Fin;
   end Finished;

   procedure Xml (Xml_Log : in out Cai.Log.Client_Session;
                  R       :        Run_Type;
                  Cold    :        Boolean;
                  Log     : in out Cai.Log.Client_Session)
   is
   begin
      Cai.Log.Client.Info (Xml_Log, "<run burst_size=""" & Cai.Log.Image (Long_Integer (R (R'First).Data'Length))
                                    & """ iterations=""" & Cai.Log.Image (Long_Integer (R'Length))
                                    & """ operation=""" & (case Operation is
                                                           when Block.Read  => "READ",
                                                           when Block.Write => "WRITE",
                                                           when others      => "INVALID")
                                    & (if Operation = Block.Read then """ cold=""" & Cai.Log.Image (Cold) else "")
                                    & """ transfer_size=""1"">");
      for I in R'Range loop
         Cai.Log.Client.Info (Log, Cai.Log.Image (I) & " .. ", False);
         Cai.Log.Client.Info (Xml_Log, "<iteration num=""" & Cai.Log.Image (I) & """>");
         Iter.Xml (Xml_Log, R (I).Data, R (I).Offset);
         Cai.Log.Client.Info (Xml_Log, "</iteration>");
      end loop;
      Cai.Log.Client.Info (Xml_Log, "</run>");
   end Xml;

end Run;
