
generic
   type T is private;
package Componolit.Gneiss.Containers.Fifo with
   SPARK_Mode
is

   type Queue (Size : Positive) is private;

   function Free (Q : Queue) return Boolean;

   function Avail (Q : Queue) return Boolean;

   procedure Initialize (Q            : out Queue;
                         Null_Element :     T) with
      Post => Free (Q) and then not Avail (Q);

   procedure Put (Q       : in out Queue;
                  Element :        T) with
      Pre  => Free (Q),
      Post => Avail (Q);

   procedure Peek (Q       :     Queue;
                   Element : out T) with
      Pre => Avail (Q);

   procedure Drop (Q : in out Queue) with
      Pre  => Avail (Q),
      Post => Free (Q);

   procedure Pop (Q       : in out Queue;
                  Element :    out T) with
      Pre  => Avail (Q),
      Post => Free (Q);

private

   type Simple_List is array (Natural range <>) of T;

   type Queue (Size : Positive) is record
      Index  : Positive;
      Length : Natural;
      List   : Simple_List (1 .. Size);
   end record;

end Componolit.Gneiss.Containers.Fifo;
