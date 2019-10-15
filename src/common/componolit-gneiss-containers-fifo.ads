
generic
   type T is private;
package Componolit.Gneiss.Containers.Fifo with
   SPARK_Mode
is

   type Queue (Size : Positive) is private;

   function Valid (Q : Queue) return Boolean with
      Ghost;

   function Free (Q : Queue) return Boolean;

   function Avail (Q : Queue) return Boolean;

   procedure Initialize (Q            : out Queue;
                         Null_Element :     T) with
      Post => Valid (Q)
      and then Free (Q)
      and then not Avail (Q);

   procedure Put (Q       : in out Queue;
                  Element :        T) with
      Pre  => Valid (Q) and then Free (Q),
      Post => Valid (Q) and then Avail (Q);

   procedure Peek (Q       :     Queue;
                   Element : out T) with
      Pre => Valid (Q) and then Avail (Q);

   procedure Drop (Q : in out Queue) with
      Pre  => Valid (Q) and then Avail (Q),
      Post => Valid (Q) and then Free (Q);

   procedure Pop (Q       : in out Queue;
                  Element :    out T) with
      Pre  => Valid (Q) and then Avail (Q),
      Post => Valid (Q) and then Free (Q);

private

   type Simple_List is array (Natural range <>) of T;
   subtype Long_Natural is Long_Integer range 0 .. Long_Integer'Last;
   subtype Long_Positive is Long_Integer range 1 .. Long_Integer'Last;

   type Queue (Size : Positive) is record
      Index  : Long_Natural;
      Length : Long_Natural;
      List   : Simple_List (1 .. Size);
   end record;

end Componolit.Gneiss.Containers.Fifo;
