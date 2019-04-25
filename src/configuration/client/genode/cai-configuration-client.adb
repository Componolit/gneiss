
with System;
with Cxx;
with Cxx.Genode;
with Cxx.Configuration.Client;

package body Cai.Configuration.Client with
   SPARK_Mode => Off
is

   function Create return Client_Session
   is
   begin
      return Client_Session'(Instance => Cxx.Configuration.Client.Constructor);
   end Create;

   procedure C_Parse (Ptr : System.Address;
                      Len : Cxx.Genode.Uint64_T);

   procedure Initialize (C   : in out Client_Session;
                         Cap :        Cai.Types.Capability)
   is
   begin
      Cxx.Configuration.Client.Initialize (C.Instance, Cap, C_Parse'Address);
   end Initialize;

   function Initialized (C : Client_Session) return Boolean
   is
      use type Cxx.Bool;
   begin
      return Cxx.Configuration.Client.Initialized (C.Instance) = Cxx.Bool'Val (1);
   end Initialized;

   procedure Load (C : in out Client_Session)
   is
   begin
      Cxx.Configuration.Client.Load (C.Instance);
   end Load;

   procedure Finalize (C : in out Client_Session)
   is
   begin
      Cxx.Configuration.Client.Finalize (C.Instance);
   end Finalize;

   procedure C_Parse (Ptr : System.Address;
                      Len : Cxx.Genode.Uint64_T)
   is
      use type Cxx.Genode.Uint64_T;
      Data : Buffer (1 .. Index (Len / (Element'Size / 8))) with
         Address => Ptr;
   begin
      Parse (Data);
   end C_Parse;

end Cai.Configuration.Client;
