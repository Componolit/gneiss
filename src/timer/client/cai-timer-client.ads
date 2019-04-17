with Cai.Types;

package Cai.Timer.Client with
   SPARK_Mode
is

   function Create return Client_Session;

   function Initialized (C : Client_Session) return Boolean;

   procedure Initialize (C : in out Client_Session; Cap : Cai.Types.Capability) with
      Pre => not Initialized (C);

   function Clock (C : Client_Session) return Time with
      Pre => Initialized (C);

   procedure Finalize (C : in out Client_Session) with
      Pre  => Initialized (C),
      Post => not Initialized (C);

end Cai.Timer.Client;
