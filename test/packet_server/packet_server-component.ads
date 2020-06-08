
with Gneiss;
with Gneiss.Component;

package Packet_Server.Component with
   SPARK_Mode
is

   procedure Construct (Cap : Gneiss.Capability);

   procedure Destruct;

   package Main is new Gneiss.Component (Construct, Destruct);

end Packet_Server.Component;
