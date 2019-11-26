
with SXML;
with SXML.Query;

package Gneiss.Broker with
   SPARK_Mode
is

   type Component is record
      Fd   : Integer               := -1;
      Node : SXML.Query.State_Type := SXML.Query.Invalid_State;
      Pid  : Integer               := -1;
   end record;

   type Component_List is array (Positive range <>) of Component;

   Document : SXML.Document_Type (1 .. 100) := (others => SXML.Null_Node);

   procedure Construct (Config :     String;
                        Status : out Integer);

private

   procedure Start_Components (Root   :     SXML.Query.State_Type;
                               Status : out Integer;
                               Parent : out Boolean);

   procedure Load (Fd   :        Integer;
                   Comp :        SXML.Query.State_Type;
                   Ret  :    out Integer);

end Gneiss.Broker;
