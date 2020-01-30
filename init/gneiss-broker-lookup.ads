
with SXML;
with SXML.Query;
with RFLX.Session;

package Gneiss.Broker.Lookup with
   SPARK_Mode
is

   procedure Match_Service (Document :     SXML.Document_Type;
                            Comp     :     SXML.Query.State_Type;
                            Kind     :     String;
                            Label    :     String;
                            Dest     : out SXML.Query.State_Type);

   procedure Lookup_Request (State       :     Broker_State;
                             Kind        :     RFLX.Session.Kind_Type;
                             Service     :     SXML.Query.State_Type;
                             Destination : out Integer;
                             Found       : out Boolean);

   procedure Find_Component_By_Name (State :     Broker_State;
                                     Name  :     String;
                                     Index : out Positive;
                                     Valid : out Boolean);

   procedure Find_Resource_By_Name (State :     Broker_State;
                                    Name  :     String;
                                    Index : out Positive;
                                    Valid : out Boolean);

   procedure Find_Resource_Location (State    :     Broker_State;
                                     Serv     :     SXML.Query.State_Type;
                                     Location : out String;
                                     Last     : out Positive;
                                     Valid    : out Boolean);

private

   function Compare (Unconstrained : String;
                     U_Last        : Natural;
                     Constrained   : String) return Boolean;

end Gneiss.Broker.Lookup;
