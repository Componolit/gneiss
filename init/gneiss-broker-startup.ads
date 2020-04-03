
with SXML;
with SXML.Query;
with Gneiss_Epoll;

package Gneiss.Broker.Startup with
   SPARK_Mode
is

   procedure Start_Components (State  : in out Broker_State;
                               Root   :        SXML.Query.State_Type;
                               Parent :    out Boolean;
                               Status :    out Return_Code) with
      Pre  => Gneiss_Epoll.Valid_Fd (State.Epoll_Fd)
              and then SXML.Query.State_Result (Root) = SXML.Result_OK
              and then SXML.Query.Is_Valid (Root, State.Xml)
              and then Is_Valid (State.Xml, State.Components),
      Post => (if Parent then Gneiss_Epoll.Valid_Fd (State.Epoll_Fd)
                              and then Is_Valid (State.Xml, State.Components));

   procedure Parse (Data     :        String;
                    Document : in out SXML.Document_Type);

   procedure Parse_Resources (Resources : in out Resource_List;
                              Document  :        SXML.Document_Type;
                              Root      :        SXML.Query.State_Type) with
      Pre => SXML.Query.State_Result (Root) = SXML.Result_OK
             and then SXML.Query.Is_Valid (Root, Document)
             and then SXML.Query.Is_Open (Root, Document)
             and then Resources'Length > 0;

private

   procedure Load (State : in out Broker_State;
                   Fd    :        Integer;
                   Comp  :        SXML.Query.State_Type;
                   Ret   :    out Return_Code) with
      Pre => SXML.Query.State_Result (Comp) = SXML.Result_OK
             and then SXML.Query.Is_Valid (Comp, State.Xml)
             and then SXML.Query.Is_Open (Comp, State.Xml);

end Gneiss.Broker.Startup;
