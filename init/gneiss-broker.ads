
with SXML;
with SXML.Query;

package Gneiss.Broker with
   SPARK_Mode
is

   type Component_Definition is record
      Fd   : Integer               := -1;
      Node : SXML.Query.State_Type := SXML.Query.Initial_State;
      Pid  : Integer               := -1;
   end record;

   type Resource_Definition is record
      Fd   : Integer               := -1;
      Node : SXML.Query.State_Type := SXML.Query.Initial_State;
   end record;

   type Component_List is array (Positive range <>) of Component_Definition;
   type Resource_List is array (Positive range <>) of Resource_Definition;

   type Broker_State (Xml_Size : SXML.Index_Type; Reg_Size : Positive) is limited record
      Xml        : SXML.Document_Type (1 .. Xml_Size) := (others => SXML.Null_Node);
      Components : Component_List (1 .. Reg_Size);
      Resources  : Resource_List (1 .. Reg_Size);
   end record;

end Gneiss.Broker;
