
with SXML.Parser;
with Componolit.Runtime.Debug;

package body Gneiss.Broker with
   SPARK_Mode
is

   procedure Construct (Config : String)
   is
      use type SXML.Parser.Match_Type;
      use type SXML.Result_Type;
      Result   : SXML.Parser.Match_Type := SXML.Parser.Match_Invalid;
      Position : Natural;
      State    : SXML.Query.State_Type;
   begin
      if not SXML.Valid_Content (Config'First, Config'Last) then
         Componolit.Runtime.Debug.Log_Error ("Invalid content");
         return;
      end if;
      SXML.Parser.Parse (Config, Document, Result, Position);
      if
         Result /= SXML.Parser.Match_OK
      then
         case Result is
            when SXML.Parser.Match_OK =>
               Componolit.Runtime.Debug.Log_Error ("XML document parsed successfully");
            when SXML.Parser.Match_None =>
               Componolit.Runtime.Debug.Log_Error ("No XML data found");
            when SXML.Parser.Match_Invalid =>
               Componolit.Runtime.Debug.Log_Error ("Malformed XML data found");
            when SXML.Parser.Match_Out_Of_Memory =>
               Componolit.Runtime.Debug.Log_Error ("Out of context buffer memory");
            when SXML.Parser.Match_None_Wellformed =>
               Componolit.Runtime.Debug.Log_Error ("Document is not wellformed");
            when SXML.Parser.Match_Trailing_Data =>
               Componolit.Runtime.Debug.Log_Error ("Document successful parsed, but there is trailing data after it");
            when SXML.Parser.Match_Depth_Limit =>
               Componolit.Runtime.Debug.Log_Error ("Recursion depth exceeded");
         end case;
         return;
      end if;
      State := SXML.Query.Init (Document);
      if
         State.Result /= SXML.Result_OK
         or else not SXML.Query.Is_Open (Document, State)
      then
         Componolit.Runtime.Debug.Log_Error ("Init failed");
         return;
      end if;
      State := SXML.Query.Path (State, Document, "/config/component");
      while
         State.Result = SXML.Result_OK
         and then SXML.Query.Has_Attribute (State, Document, "name")
         and then SXML.Query.Has_Attribute (State, Document, "file")
      loop
         Componolit.Runtime.Debug.Log_Debug
            ("Name : " & SXML.Query.Attribute (State, Document, "name"));
         Componolit.Runtime.Debug.Log_Debug
            ("File : " & SXML.Query.Attribute (State, Document, "file"));
         State := SXML.Query.Sibling (State, Document);
      end loop;
   end Construct;

end Gneiss.Broker;
