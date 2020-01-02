
with Gneiss.Command_Line;
with Gneiss.Config;
with Gneiss.Broker;

procedure Main
is
   Cap    : Gneiss.Config.Config_Capability;
   Status : Integer;
begin
   case Gneiss.Command_Line.Argument_Count is
      when 1 =>
         Gneiss.Config.Load ("/etc/gneiss/config.xml", Cap);
      when 2 =>
         Gneiss.Config.Load (Gneiss.Command_Line.Argument (1), Cap);
      when others =>
         Gneiss.Command_Line.Set_Exit_Status (1);
         return;
   end case;
   if Gneiss.Config.Valid (Cap) then
      declare
         Conf : String (1 .. Gneiss.Config.Get_Length (Cap)) with
            Import,
            Address => Gneiss.Config.Get_Address (Cap);
      begin
         Gneiss.Broker.Construct (Conf, Status);
         Gneiss.Command_Line.Set_Exit_Status (Status);
      end;
   else
      Gneiss.Command_Line.Set_Exit_Status (1);
   end if;
end Main;
