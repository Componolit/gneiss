
with Gneiss;
with Gneiss.Component;

package Linux_Log_Server.Component with
   SPARK_Mode
is

   procedure Construct (Cap : Gneiss.Capability);
   procedure Destruct;

   package Main is new Gneiss.Component (Construct, Destruct);

end Linux_Log_Server.Component;
