
with Cai.Types;

generic
   type Element is private;
   type Index is range <>;
   type Buffer is array (Index range <>) of Element;
   with procedure Parse (Data : Buffer);
package Cai.Configuration.Client with
   SPARK_Mode
is

   function Create return Client_Session;

   function Initialized (C : Client_Session) return Boolean;

   procedure Initialize (C   : in out Client_Session;
                         Cap :        Cai.Types.Capability);

   procedure Load (C : in out Client_Session) with
      Pre  => Initialized (C),
      Post => Initialized (C);

   procedure Finalize (C : in out Client_Session) with
      Pre  => Initialized (C),
      Post => not Initialized (C);

end Cai.Configuration.Client;
