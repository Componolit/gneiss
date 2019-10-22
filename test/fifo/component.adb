
with Componolit.Gneiss.Log;
with Componolit.Gneiss.Log.Client;
with Componolit.Gneiss.Strings;
with Componolit.Gneiss.Containers.Fifo;

package body Component with
   SPARK_Mode
is
   package Fifo is new Gns.Containers.Fifo (Integer);

   Queue : Fifo.Queue (10);
   Log   : Gns.Log.Client_Session;

   procedure Construct (Cap : Gns.Types.Capability)
   is
      J : Integer;
   begin
      if not Gns.Log.Initialized (Log) then
         Gns.Log.Client.Initialize (Log, Cap, "log_fifo");
      end if;
      if not Gns.Log.Initialized (Log) then
         Main.Vacate (Cap, Main.Failure);
         return;
      end if;
      Fifo.Initialize (Queue, 0);
      for I in Integer range 7 .. 13 loop
         --  Componolit/Workarounds#2
         Gns.Log.Client.Info (Log, "Putting " & Gns.Strings.Image (I, 10, True));
         Fifo.Put (Queue, I);
         exit when Fifo.Count (Queue) >= Fifo.Size (Queue);
      end loop;
      pragma Assert (Fifo.Count (Queue) = 7);
      for I in Integer range 1 .. 7 loop
         Fifo.Pop (Queue, J);
         --  Componolit/Workarounds#2
         Gns.Log.Client.Info (Log, "Popped " & Gns.Strings.Image (J, 10, True));
      end loop;
      Main.Vacate (Cap, Main.Success);
   end Construct;

   procedure Destruct
   is
   begin
      if Gns.Log.Initialized (Log) then
         Gns.Log.Client.Finalize (Log);
      end if;
   end Destruct;

end Component;
