
with Componolit.Interfaces.Types;

generic
   type Element is private;
   type Index is range <>;
   type Buffer is array (Index range <>) of Element;
   with procedure Parse (Data : Buffer);
package Componolit.Interfaces.Rom.Client with
   SPARK_Mode
is
   pragma Warnings (Off, "procedure ""Parse"" is not referenced");

   procedure Initialize (C    : in out Client_Session;
                         Cap  :        Componolit.Interfaces.Types.Capability;
                         Name :        String := "") with
     Pre => not Initialized (C);

   procedure Load (C : in out Client_Session) with
      Pre  => Initialized (C),
      Post => Initialized (C);

   procedure Finalize (C : in out Client_Session) with
      Pre  => Initialized (C),
      Post => not Initialized (C);

   pragma Warnings (On, "procedure ""Parse"" is not referenced");
end Componolit.Interfaces.Rom.Client;
