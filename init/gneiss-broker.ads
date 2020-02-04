
with SXML;
with SXML.Query;

package Gneiss.Broker with
   SPARK_Mode
is
   use type SXML.Result_Type;

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

   function Is_Valid (Doc  : SXML.Document_Type;
                      Comp : Component_List) return Boolean is
      (for all C of Comp => (if C.Fd > -1 then
                                SXML.Query.State_Result (C.Node) = SXML.Result_OK
                                and then SXML.Query.Is_Valid (C.Node, Doc)
                                and then SXML.Query.Is_Open (C.Node, Doc))) with
      Ghost;

   function Is_Valid (Doc : SXML.Document_Type;
                      Res : Resource_List) return Boolean is
      (for all R of Res => (if R.Node not in SXML.Query.Invalid_State | SXML.Query.Initial_State then
                               SXML.Query.State_Result (R.Node) = SXML.Result_OK
                               and then SXML.Query.Is_Valid (R.Node, Doc)
                               and then SXML.Query.Is_Open (R.Node, Doc))) with
      Ghost;

   type Broker_State (Xml_Size : SXML.Index_Type; Reg_Size : Positive) is limited record
      Xml        : SXML.Document_Type (1 .. Xml_Size) := (others => SXML.Null_Node);
      Components : Component_List (1 .. Reg_Size);
      Resources  : Resource_List (1 .. Reg_Size);
   end record;

end Gneiss.Broker;
