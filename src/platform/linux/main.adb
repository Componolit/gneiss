
with Gneiss.Command_Line;
with Gneiss.Config;
with Gneiss.Broker;

procedure Main
is
   Cap : Gneiss.Config.Config_Capability;
begin
   if Gneiss.Command_Line.Argument_Count = 2 then
      Gneiss.Config.Load (Gneiss.Command_Line.Argument (1), Cap);
      if Gneiss.Config.Valid (Cap) then
         declare
            Conf : String (1 .. Gneiss.Config.Get_Length (Cap)) with
               Import,
               Address => Gneiss.Config.Get_Address (Cap);
         begin
            Gneiss.Broker.Construct (Conf);
         end;
      end if;
   end if;
   Gneiss.Command_Line.Set_Exit_Status (1);
end Main;
