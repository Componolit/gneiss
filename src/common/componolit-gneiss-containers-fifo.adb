
package body Componolit.Gneiss.Containers.Fifo with
   SPARK_Mode
is

   function Free (Q : Queue) return Boolean is
      (Q.Length < Q.List'Length);

   function Avail (Q : Queue) return Boolean is
      (Q.Length > 0);

   procedure Initialize (Q            : out Queue;
                         Null_Element :     T)
   is
   begin
      Q.Index  := 1;
      Q.Length := 0;
      for I in Q.List'Range loop
         Q.List (I) := Null_Element;
      end loop;
   end Initialize;

   procedure Put (Q       : in out Queue;
                  Element :        T)
   is
      Index : Natural;
   begin
      Index          := (Q.Index + Q.Length) mod Q.List'Length;
      Q.Length       := Q.Length + 1;
      Q.List (Index) := Element;
   end Put;

   procedure Peek (Q       :     Queue;
                   Element : out T)
   is
   begin
      Element := Q.List (Q.Index);
   end Peek;

   procedure Drop (Q : in out Queue)
   is
   begin
      Q.Index  := (Q.Index + 1) mod Q.List'Length;
      Q.Length := Q.Length - 1;
   end Drop;

   procedure Pop (Q       : in out Queue;
                  Element :    out T)
   is
   begin
      Peek (Q, Element);
      Drop (Q);
   end Pop;

end Componolit.Gneiss.Containers.Fifo;
