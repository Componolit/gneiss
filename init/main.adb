
with Gneiss.Command_Line;
with Gneiss.Broker;

procedure Main
is
   Status : Integer := 1;
begin
   case Gneiss.Command_Line.Argument_Count is
      when 1 =>
         Gneiss.Broker.Construct ("/etc/gneiss/config.xml", Status);
      when 2 =>
         Gneiss.Broker.Construct (Gneiss.Command_Line.Argument (1), Status);
      when others =>
         null;
   end case;
   Gneiss.Command_Line.Set_Exit_Status (Status);
end Main;
