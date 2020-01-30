
package body Gneiss.Broker.Lookup with
   SPARK_Mode
is

   procedure Match_Service (Document :     SXML.Document_Type;
                            Comp     :     SXML.Query.State_Type;
                            Kind     :     String;
                            Label    :     String;
                            Dest     : out SXML.Query.State_Type)
   is
      use type SXML.Result_Type;
      Default_State : SXML.Query.State_Type := SXML.Query.Invalid_State;
      Query_State   : SXML.Query.State_Type := SXML.Query.Child (Comp, Document);
      Last          : Natural;
      Buffer        : String (1 .. 255);
      Result        : SXML.Result_Type;
   begin
      Dest := SXML.Query.Invalid_State;
      while SXML.Query.State_Result (Query_State) = SXML.Result_OK loop
         Query_State := SXML.Query.Find_Sibling (Query_State, Document, "service", "name", Kind);
         exit when SXML.Query.State_Result (Query_State) /= SXML.Result_OK;
         SXML.Query.Attribute (Query_State, Document, "label", Result, Buffer, Last);
         if Result = SXML.Result_OK and then Compare (Buffer, Last, Label) then
            --  Exact label match
            Dest := Query_State;
            return;
         elsif Result = SXML.Result_Not_Found then
            --  Default match which has no label
            Default_State := Query_State;
         end if;
         Query_State := SXML.Query.Sibling (Query_State, Document);
      end loop;
      Dest := Default_State;
   end Match_Service;

   procedure Find_Component_By_Name (State :     Broker_State;
                                     Name  :     String;
                                     Index : out Positive;
                                     Valid : out Boolean)
   is
      use type SXML.Result_Type;
      XML_Buf : String (1 .. 255);
      Result  : SXML.Result_Type;
      Last    : Natural;
   begin
      Index := Positive'Last;
      Valid := False;
      if Name'Last < Name'First then
         return;
      end if;
      for I in State.Components'Range loop
         if State.Components (I).Fd > -1 then
            SXML.Query.Attribute (State.Components (I).Node, State.Xml, "name", Result, XML_Buf, Last);
            Valid := Result = SXML.Result_OK and then Compare (XML_Buf, Last, Name);
            Index := I;
            exit when Valid;
         end if;
      end loop;
   end Find_Component_By_Name;

   procedure Find_Resource_By_Name (State :     Broker_State;
                                    Name  :     String;
                                    Index : out Positive;
                                    Valid : out Boolean)
   is
      use type SXML.Result_Type;
      XML_Buf : String (1 .. 255);
      Result  : SXML.Result_Type;
      Last    : Natural;
   begin
      Index := Positive'Last;
      Valid := False;
      if Name'Last < Name'First then
         return;
      end if;
      for I in State.Resources'Range loop
         if State.Resources (I).Node not in SXML.Query.Invalid_State | SXML.Query.Initial_State then
            SXML.Query.Attribute (State.Resources (I).Node, State.Xml, "name", Result, XML_Buf, Last);
            Index := I;
            Valid := Result = SXML.Result_OK and then Compare (XML_Buf, Last, Name);
            exit when Valid;
         end if;
      end loop;
   end Find_Resource_By_Name;

   procedure Lookup_Request (State       :     Broker_State;
                             Kind        :     RFLX.Session.Kind_Type;
                             Service     :     SXML.Query.State_Type;
                             Destination : out Integer;
                             Found       : out Boolean)
   is
      pragma Unreferenced (Kind);
      use type SXML.Result_Type;
      Buffer : String (1 .. 255);
      Last   : Natural;
      Result : SXML.Result_Type;
   begin
      SXML.Query.Attribute (Service, State.Xml, "server", Result, Buffer, Last);
      if Result = SXML.Result_OK then
         --  Service name found
         Find_Component_By_Name (State, Buffer (Buffer'First .. Last), Destination, Found);
      else
         --  No service name found, broker should handle itself
         Destination := -1;
         Found       := True;
      end if;
   end Lookup_Request;

   procedure Find_Resource_Location (State    :     Broker_State;
                                     Serv     :     SXML.Query.State_Type;
                                     Location : out String;
                                     Last     : out Positive;
                                     Valid    : out Boolean)
   is
      use type SXML.Result_Type;
      Res_Buf  : String (1 .. 255);
      Res_Last : Natural;
      Res_Node : SXML.Query.State_Type;
      Result   : SXML.Result_Type;
   begin
      Location := (others => Character'First);
      Last     := Positive'Last;
      SXML.Query.Attribute (Serv, State.Xml, "resource", Result, Location, Last);
      Valid := Result = SXML.Result_OK;
      if not Valid then
         return;
      end if;
      for R of State.Resources loop
         SXML.Query.Attribute (R.Node, State.Xml, "name", Result, Res_Buf, Res_Last);
         Valid    := Result = SXML.Result_OK and then Compare (Res_Buf, Res_Last,
                                                               Location (Location'First .. Last));
         Res_Node := R.Node;
         exit when Valid;
      end loop;
      if not Valid then
         return;
      end if;
      SXML.Query.Attribute (Res_Node, State.Xml, "type", Result, Res_Buf, Res_Last);
      Valid := Result = SXML.Result_OK and then Compare (Res_Buf, Res_Last, "File");
      if not Valid then
         return;
      end if;
      SXML.Query.Attribute (Res_Node, State.Xml, "location", Result, Location, Last);
      Valid := Result = SXML.Result_OK;
   end Find_Resource_Location;

   function Compare (Unconstrained : String;
                     U_Last        : Natural;
                     Constrained   : String) return Boolean is
      (Constrained'Last > 0
       and then U_Last in Unconstrained'Range
       and then U_Last - Unconstrained'First = Constrained'Last - Constrained'First
       and then Unconstrained (Unconstrained'First .. U_Last) = Constrained);

end Gneiss.Broker.Lookup;
