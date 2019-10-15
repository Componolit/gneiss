
with Aunit.Assertions;
with Componolit.Gneiss.Containers.Fifo;

package body Fifo_Tests
is
   package F is new Componolit.Gneiss.Containers.Fifo (Integer);

   procedure Test_Fifo (T : in out Aunit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      Q : F.Queue (100);
      J : Integer;
   begin
      F.Initialize (Q, 0);
      for I in 70 .. 120 loop
         F.Put (Q, I);
      end loop;
      for I in 70 .. 120 loop
         F.Pop (Q, J);
         Aunit.Assertions.Assert (J = I, "Invalid order");
      end loop;
   end Test_Fifo;

   procedure Test_Full_Empty (T : in out Aunit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      Q : F.Queue (2);
   begin
      F.Initialize (Q, 0);
      Aunit.Assertions.Assert (F.Free (Q), "Queue not free");
      Aunit.Assertions.Assert (not F.Avail (Q), "Unexpected items available");
      F.Put (Q, 1);
      Aunit.Assertions.Assert (F.Free (Q), "Queue not free after first item");
      Aunit.Assertions.Assert (F.Avail (Q), "First item not available");
      F.Put (Q, 2);
      Aunit.Assertions.Assert (not F.Free (Q), "Queue not marked full");
      Aunit.Assertions.Assert (F.Avail (Q), "No item available");
      F.Drop (Q);
      Aunit.Assertions.Assert (F.Free (Q), "Queue not free after drop");
      Aunit.Assertions.Assert (F.Avail (Q), "Dropped too many items");
      F.Drop (Q);
      Aunit.Assertions.Assert (F.Free (Q), "Empty queue not free");
      Aunit.Assertions.Assert (not F.Avail (Q), "Queue not emtpy");
   end Test_Full_Empty;

   procedure Test_Single_Element (T : in out Aunit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      Q : F.Queue (1);
      J : Integer;
   begin
      F.Initialize (Q, 0);
      Aunit.Assertions.Assert (F.Free (Q), "Queue not free");
      Aunit.Assertions.Assert (not F.Avail (Q), "Queue not empty after initialization");
      F.Put (Q, 1);
      Aunit.Assertions.Assert (not F.Free (Q), "Queue not full");
      Aunit.Assertions.Assert (F.Avail (Q), "Queue errorneously empty");
      F.Peek (Q, J);
      Aunit.Assertions.Assert (J = 1, "Invalid item value");
      F.Drop (Q);
      Aunit.Assertions.Assert (F.Free (Q), "Queue not free after drop");
      Aunit.Assertions.Assert (not F.Avail (Q), "Invalid item available");
   end Test_Single_Element;

   procedure Test_Overflow (T : in out Aunit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      Q : F.Queue (10);
      J : Integer;
   begin
      F.Initialize (Q, 0);
      for I in Integer range 1 .. 7 loop
         F.Put (Q, I);
      end loop;
      for I in Integer range 1 .. 3 loop
         F.Pop (Q, J);
         Aunit.Assertions.Assert (I = J, "Invalid order before overflow");
      end loop;
      for I in Integer range 8 .. 13 loop
         F.Put (Q, I);
      end loop;
      for I in Integer range 4 .. 13 loop
         F.Pop (Q, J);
         Aunit.Assertions.Assert (I = J, "Invalid order after overflow");
      end loop;
   end Test_Overflow;

   procedure Register_Tests (T : in out Test_Case)
   is
      use Aunit.Test_Cases.Registration;
   begin
      Register_Routine (T, Test_Fifo'Access, "Test fifo");
      Register_Routine (T, Test_Full_Empty'Access, "Test full and emtpy");
      Register_Routine (T, Test_Single_Element'Access, "Test single element");
      Register_Routine (T, Test_Overflow'Access, "Test overflow");
   end Register_Tests;

   function Name (T : Test_Case) return Aunit.Message_String
   is
   begin
      return Aunit.Format ("Componolit.Gneiss.Containers.Fifo");
   end Name;

end Fifo_Tests;
