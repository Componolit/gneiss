
with SXML;
with SXML.Query;
with Gneiss_Protocol.Session;
with Gneiss_Internal;

package Gneiss.Broker.Lookup with
   SPARK_Mode
is
   use type SXML.Query.State_Type;

   procedure Match_Service (Document :     SXML.Document_Type;
                            Comp     :     SXML.Query.State_Type;
                            Kind     :     String;
                            Label    :     String;
                            Dest     : out SXML.Query.State_Type) with
      Pre    => SXML.Query.Is_Valid (Comp, Document)
                and then SXML.Query.State_Result (Comp) = SXML.Result_OK,
      Post   => Dest = SXML.Query.Invalid_State
                or else (SXML.Query.State_Result (Dest) = SXML.Result_OK
                and then SXML.Query.Is_Valid (Dest, Document)),
      Global => null;

   procedure Lookup_Request (State       :     Broker_State;
                             Kind        :     Gneiss_Protocol.Session.Kind_Type;
                             Service     :     SXML.Query.State_Type;
                             Destination : out Integer;
                             Found       : out Boolean) with
      Pre    => Is_Valid (State.Xml, State.Components)
                and then SXML.Query.State_Result (Service) = SXML.Result_OK
                and then SXML.Query.Is_Valid (Service, State.Xml)
                and then SXML.Query.Is_Open (Service, State.Xml),
      Global => null;

   procedure Find_Component_By_Name (State :     Broker_State;
                                     Name  :     String;
                                     Index : out Positive;
                                     Valid : out Boolean) with
      Pre    => Is_Valid (State.Xml, State.Components),
      Post   => (if Valid then (Index in State.Components'Range
                 and then Gneiss_Internal.Valid (State.Components (Index).Fd))),
      Global => null;

   procedure Find_Resource_By_Name (State :     Broker_State;
                                    Name  :     String;
                                    Index : out Positive;
                                    Valid : out Boolean) with
      Pre    => Is_Valid (State.Xml, State.Resources),
      Global => null;

   procedure Find_Resource_Location (State    :     Broker_State;
                                     Serv     :     SXML.Query.State_Type;
                                     Location : out String;
                                     Last     : out Natural;
                                     Valid    : out Boolean) with
      Pre    => Is_Valid (State.Xml, State.Resources)
                and then SXML.Query.State_Result (Serv) = SXML.Result_OK
                and then SXML.Query.Is_Valid (Serv, State.Xml)
                and then SXML.Query.Is_Open (Serv, State.Xml)
                and then Location'Length > 0
                and then Location'Last <= Natural'Last - SXML.Chunk_Length,
      Post   => (if Valid then Last in Location'Range),
      Global => null;

private

   function Compare (Unconstrained : String;
                     U_Last        : Natural;
                     Constrained   : String) return Boolean;

end Gneiss.Broker.Lookup;
