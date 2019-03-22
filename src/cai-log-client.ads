package Cai.Log.Client with
   SPARK_Mode
is

   function Create return Client_Session;

   function Initialized (C : Client_Session) return Boolean;

   procedure Initialize (C : in out Client_Session;
                         Label : String;
                         Message_Length : Integer := 0);

   procedure Finalize (C : in out Client_Session) with
      Pre => Initialized (C);

   function Maximal_Message_Length (C : Client_Session) return Integer with
      Pre => Initialized (C),
      Post => Maximal_Message_Length'Result > 78;

   procedure Info (C : in out Client_Session; Msg : String; Newline : Boolean := True) with
      Pre => Initialized (C)
             and Msg'Length <= Maximal_Message_Length (C);

   procedure Warning (C : in out Client_Session; Msg : String; Newline : Boolean := True) with
      Pre => Initialized (C)
             and Msg'Length <= Maximal_Message_Length (C);

   procedure Error (C : in out Client_Session; Msg : String; Newline : Boolean := True) with
      Pre => Initialized (C)
             and Msg'Length <= Maximal_Message_Length (C);

   procedure Flush (C : in out Client_Session) with
      Pre => Initialized (C);

end Cai.Log.Client;
