
with Componolit.Gneiss.Types;

generic
   type Element is private;
   type Index is range <>;
   type Buffer is array (Index range <>) of Element;
   with procedure Parse (Data : Buffer);
package Componolit.Gneiss.Rom.Client with
   SPARK_Mode
is
   pragma Warnings (Off, "procedure ""Parse"" is not referenced");

   procedure Initialize (C    : in out Client_Session;
                         Cap  :        Componolit.Gneiss.Types.Capability;
                         Name :        String := "");

   procedure Load (C : in out Client_Session) with
      Pre  => Initialized (C),
      Post => Initialized (C);

   procedure Finalize (C : in out Client_Session) with
      Post => not Initialized (C);

   pragma Warnings (On, "procedure ""Parse"" is not referenced");
end Componolit.Gneiss.Rom.Client;
