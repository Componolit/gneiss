
with Gneiss_Epoll;
with SXML;
with SXML.Query;

package Gneiss.Broker.Startup with
   SPARK_Mode
is

   procedure Start_Components (State  : in out Broker_State;
                               Root   :        SXML.Query.State_Type;
                               Parent :    out Boolean;
                               Status :    out Integer;
                               Efd    : in out Gneiss_Epoll.Epoll_Fd);

   procedure Parse (Data     :        String;
                    Document : in out SXML.Document_Type);

   procedure Parse_Resources (Resources : in out Resource_List;
                              Document  :        SXML.Document_Type;
                              Root      :        SXML.Query.State_Type);

private

   procedure Load (State : in out Broker_State;
                   Fd    :        Integer;
                   Comp  :        SXML.Query.State_Type;
                   Ret   :    out Integer);

end Gneiss.Broker.Startup;
