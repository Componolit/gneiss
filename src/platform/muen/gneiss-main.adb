with Interfaces;
with Component;
with SK.CPU;
with Gneiss.Muen;
with Gneiss.Muen_Registry;

package body Gneiss.Main with
   SPARK_Mode
is

   procedure Run with
      SPARK_Mode
   is
      package CIM renames Gneiss.Muen;
      package Reg renames Gneiss.Muen_Registry;
      use type CIM.Status;
      Null_Cap : constant Capability := (null record);
      Epoch : Standard.Interfaces.Unsigned_64 := 0;
   begin
      Component.Main.Construct (Null_Cap);
      while CIM.Component_Status = CIM.Running loop
         for I in Reg.Registry'Range loop
            case Reg.Registry (I).Kind is
               when CIM.Block_Client =>
                  Reg.Call_Block_Client_Event (Reg.Registry (I));
               when CIM.Timer_Client =>
                  Reg.Call_Timer_Event (Reg.Registry (I), I);
               when CIM.Block_Dispatcher =>
                  Reg.Call_Block_Dispatcher_Event (Reg.Registry (I));
               when CIM.Block_Server =>
                  Reg.Call_Block_Server_Event (Reg.Registry (I));
               when CIM.Log_Client =>
                  Reg.Call_Log_Client_Event (Reg.Registry (I));
               when others =>
                  null;
            end case;
         end loop;
         CIM.Yield (Epoch);
      end loop;
      Component.Main.Destruct;
      SK.CPU.Stop;
   end Run;

end Gneiss.Main;
