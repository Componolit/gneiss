
with Musinfo;

package Componolit.Interfaces.Internal.Rom with
   SPARK_Mode
is

   type Client_Session is limited record
      Mem : Musinfo.Memregion_Type;
   end record;

end Componolit.Interfaces.Internal.Rom;
