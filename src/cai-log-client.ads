package Cai.Log.Client with
   SPARK_Mode
is

   function Initialized (C : Client_Session) return Boolean;

   function Create return Client_Session with
      Post => not Initialized (Create'Result);

   procedure Initialize (C              : in out Client_Session;
                         Label          :        String;
                         Message_Length :        Integer := 0);

   procedure Finalize (C : in out Client_Session) with
      Pre  => Initialized (C),
      Post => not Initialized (C);

   function Maximal_Message_Length (C : Client_Session) return Integer with
      Pre  => Initialized (C),
      Post => Maximal_Message_Length'Result > 78;

   function Valid_Message (C   : Client_Session;
                           Msg : String) return Boolean is
      (Msg'Length < Maximal_Message_Length (C)) with
      Pre => Initialized (C);

   procedure Info (C       : in out Client_Session;
                   Msg     :        String;
                   Newline :        Boolean := True) with
      Pre  => Initialized (C) and then Valid_Message (C, Msg),
      Post => Initialized (C);

   procedure Warning (C       : in out Client_Session;
                      Msg     :        String;
                      Newline :        Boolean := True) with
      Pre  => Initialized (C) and then Valid_Message (C, Msg),
      Post => Initialized (C);

   procedure Error (C       : in out Client_Session;
                    Msg     :        String;
                    Newline :        Boolean := True) with
      Pre  => Initialized (C) and then Valid_Message (C, Msg),
      Post => Initialized (C);

   procedure Flush (C : in out Client_Session) with
      Pre  => Initialized (C),
      Post => Initialized (C);

end Cai.Log.Client;
