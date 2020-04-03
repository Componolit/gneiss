
with Gneiss.Command_Line;
with Gneiss.Broker;
with Gneiss.Broker.Main;

procedure Main with
   SPARK_Mode
is
   Status : Gneiss.Broker.Return_Code := 1;
begin
   case Gneiss.Command_Line.Argument_Count is
      when 1 =>
         Gneiss.Broker.Main.Construct ("/etc/gneiss/config.xml", Status);
      when 2 =>
         Gneiss.Broker.Main.Construct (Gneiss.Command_Line.Argument (1), Status);
      when others =>
         null;
   end case;
   Gneiss.Command_Line.Set_Exit_Status (Status);
end Main;
