
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
      Aunit.Assertions.Assert (F.Count (Q) = 0, "Count not 0");
      F.Put (Q, 1);
      Aunit.Assertions.Assert (F.Count (Q) = 1, "Count not 1 after Put");
      F.Put (Q, 2);
      Aunit.Assertions.Assert (F.Count (Q) = 2, "Count not 2 after Put");
      F.Drop (Q);
      Aunit.Assertions.Assert (F.Count (Q) = 1, "Count not 1 after Drop");
      F.Drop (Q);
      Aunit.Assertions.Assert (F.Count (Q) = 0, "Count not 0 after Drop");
   end Test_Full_Empty;

   procedure Test_Single_Element (T : in out Aunit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      Q : F.Queue (1);
      J : Integer;
   begin
      F.Initialize (Q, 0);
      Aunit.Assertions.Assert (F.Count (Q) = 0, "Queue not empty");
      F.Put (Q, 1);
      Aunit.Assertions.Assert (F.Count (Q) = 1, "Queue not full");
      F.Peek (Q, J);
      Aunit.Assertions.Assert (J = 1, "Invalid item value");
      F.Drop (Q);
      Aunit.Assertions.Assert (F.Count (Q) = 0, "Queue not empty after drop");
   end Test_Single_Element;

   procedure Test_Count (T : in out Aunit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      Q : F.Queue (100);
   begin
      F.Initialize (Q, 0);
      Aunit.Assertions.Assert (F.Count (Q) = 0, "Count should be 0");
      for I in Integer range 1 .. 20 loop
         F.Put (Q, I);
      end loop;
      Aunit.Assertions.Assert (F.Count (Q) = 20, "Count should be 20");
      for I in Integer range 1 .. 40 loop
         F.Put (Q, I);
      end loop;
      Aunit.Assertions.Assert (F.Count (Q) = 60, "Count should be 60");
      for I in Integer range 1 .. 50 loop
         F.Drop (Q);
      end loop;
      Aunit.Assertions.Assert (F.Count (Q) = 10, "Count should be 10");
      for I in Integer range 1 .. 80 loop
         F.Put (Q, I);
      end loop;
      Aunit.Assertions.Assert (F.Count (Q) = 90, "Count should be 90");
      for I in Integer range 1 .. 90 loop
         F.Drop (Q);
      end loop;
      Aunit.Assertions.Assert (F.Count (Q) = 0, "Count should be 0");
   end Test_Count;

   procedure Test_Size (T : in out Aunit.Test_Cases.Test_Case'Class)
   is
      pragma Unreferenced (T);
      Q1 : F.Queue (1);
      Q2 : F.Queue (50);
      Q3 : F.Queue (200);
      Q4 : F.Queue (13000);
   begin
      F.Initialize (Q1, 0);
      F.Initialize (Q2, 0);
      F.Initialize (Q3, 0);
      F.Initialize (Q4, 0);
      Aunit.Assertions.Assert (F.Size (Q1) = 1, "Size of Q1 should be 1");
      Aunit.Assertions.Assert (F.Size (Q2) = 50, "Size of Q2 should be 50");
      Aunit.Assertions.Assert (F.Size (Q3) = 200, "Size of Q3 should be 200");
      Aunit.Assertions.Assert (F.Size (Q4) = 13000, "Size of Q4 should be 13000");
   end Test_Size;

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
      Register_Routine (T, Test_Count'Access, "Test count");
      Register_Routine (T, Test_Size'Access, "Test size");
   end Register_Tests;

   function Name (T : Test_Case) return Aunit.Message_String
   is
   begin
      return Aunit.Format ("Componolit.Gneiss.Containers.Fifo");
   end Name;

end Fifo_Tests;
