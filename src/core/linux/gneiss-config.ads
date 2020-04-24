
generic
   with procedure Parse (Data : String);
package Gneiss.Config with
   SPARK_Mode
is

   procedure Load (Location : String);

end Gneiss.Config;
