with Ada.Unchecked_Conversion;
with Interfaces;
with Component;
with SK.CPU;
with Componolit.Interfaces.Types;
with Componolit.Interfaces.Internal.Types;
with Componolit.Interfaces.Muen;
with Componolit.Interfaces.Muen_Registry;

package body Componolit.Interfaces.Main with
   SPARK_Mode
is

   procedure Run with
      SPARK_Mode
   is
      package CIM renames Componolit.Interfaces.Muen;
      package Reg renames Componolit.Interfaces.Muen_Registry;
      use type CIM.Status;
      Null_Cap : constant Componolit.Interfaces.Internal.Types.Capability := (null record);
      function Gen_Cap is new Ada.Unchecked_Conversion (Componolit.Interfaces.Internal.Types.Capability,
                                                        Componolit.Interfaces.Types.Capability);
      Epoch : Standard.Interfaces.Unsigned_64 := 0;
   begin
      Component.Main.Construct (Gen_Cap (Null_Cap));
      while CIM.Component_Status = CIM.Running loop
         for I in Reg.Registry'Range loop
            case Reg.Registry (I).Kind is
               when CIM.Block_Client =>
                  Reg.Call_Block_Client_Event (Reg.Registry (I));
               when CIM.Timer_Client =>
                  Reg.Call_Timer_Event (Reg.Registry (I), I);
               when CIM.Block_Dispatcher =>
                  Reg.Call_Block_Dispatcher_Event (Reg.Registry (I), I);
               when CIM.Block_Server =>
                  Reg.Call_Block_Server_Event (Reg.Registry (I));
               when others =>
                  null;
            end case;
         end loop;
         CIM.Yield (Epoch);
      end loop;
      Component.Main.Destruct;
      SK.CPU.Stop;
   end Run;

end Componolit.Interfaces.Main;
