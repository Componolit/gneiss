
with SXML;
with SXML.Query;

package Gneiss.Broker with
   SPARK_Mode
is

   type Component is record
      Local_Fd  : Integer               := -1;
      Remote_Fd : Integer               := -1;
      Node      : SXML.Query.State_Type := SXML.Query.Invalid_State;
   end record;

   type Component_List is array (Positive range <>) of Component;

   Policy : Component_List (1 .. 1024);

   Document : SXML.Document_Type (1 .. 100) := (others => SXML.Null_Node);

   procedure Construct (Config : String);

end Gneiss.Broker;
