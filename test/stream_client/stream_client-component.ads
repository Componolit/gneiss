
with Gneiss;
with Gneiss.Component;
with Gneiss_Internal;

package Stream_Client.Component with
   SPARK_Mode
is

   procedure Construct (Cap : Gneiss.Capability);

   procedure Destruct;

   package Main is new Gneiss.Component (Construct, Destruct);

end Stream_Client.Component;
