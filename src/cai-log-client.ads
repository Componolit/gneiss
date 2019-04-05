package Cai.Log.Client with
   SPARK_Mode
is

   function Initialized (C : Client_Session) return Boolean;

   procedure Initialize (C              : out Client_Session;
                         Label          :     String;
                         Message_Length :     Integer := 0);

   procedure Finalize (C : in out Client_Session) with
      Pre  => Initialized (C),
      Post => not Initialized (C);

   Minimal_Message_Length : constant Positive := 78 with Ghost;

   function Maximal_Message_Length (C : Client_Session) return Integer with
      Pre  => Initialized (C),
      Post => Maximal_Message_Length'Result > Minimal_Message_Length;

   procedure Info (C       : in out Client_Session;
                   Msg     :        String;
                   Newline :        Boolean := True) with
      Pre  => Initialized (C) and then (Msg'Length <= Minimal_Message_Length
                                        or else Msg'Length <= Maximal_Message_Length (C)),
      Post => Initialized (C);

   procedure Warning (C       : in out Client_Session;
                      Msg     :        String;
                      Newline :        Boolean := True) with
      Pre  => Initialized (C) and then (Msg'Length <= Minimal_Message_Length
                                        or else Msg'Length <= Maximal_Message_Length (C)),
      Post => Initialized (C);

   procedure Error (C       : in out Client_Session;
                    Msg     :        String;
                    Newline :        Boolean := True) with
      Pre  => Initialized (C) and then (Msg'Length <= Minimal_Message_Length
                                        or else Msg'Length <= Maximal_Message_Length (C)),
      Post => Initialized (C);

   procedure Flush (C : in out Client_Session) with
      Pre  => Initialized (C),
      Post => Initialized (C);

end Cai.Log.Client;
