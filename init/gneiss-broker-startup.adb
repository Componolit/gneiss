
with Gneiss.Main;
with Gneiss_Log;
with Gneiss_Syscall;
with SXML.Parser;
with Basalt.Strings;

package body Gneiss.Broker.Startup with
   SPARK_Mode
is

   procedure Start_Components (State  : in out Broker_State;
                               Root   :        SXML.Query.State_Type;
                               Parent :    out Boolean;
                               Status :    out Return_Code)
   is
      XML_Buf : String (1 .. 255);
      Pid     : Integer;
      Fd      : Integer;
      Success : Integer;
      Index   : Positive := State.Components'First;
      Query   : SXML.Query.State_Type;
      Result  : SXML.Result_Type;
      Last    : Natural;
   begin
      Status := 1;
      Parent := True;
      Query  := SXML.Query.Path (Root, State.Xml, "/config/component");
      while SXML.Query.State_Result (Query) = SXML.Result_OK loop
         pragma Loop_Invariant (SXML.Query.Is_Open (Query, State.Xml)
                                or else SXML.Query.Is_Content (Query, State.Xml));
         pragma Loop_Invariant (SXML.Query.Is_Valid (Query, State.Xml));
         pragma Loop_Invariant (Index in State.Components'Range);
         pragma Loop_Invariant (Gneiss_Epoll.Valid_Fd (State.Epoll_Fd));
         pragma Loop_Invariant (Is_Valid (State.Xml, State.Components));
         pragma Loop_Invariant (Is_Valid (State.Xml, State.Resources));
         pragma Loop_Invariant (Parent);
         Query := SXML.Query.Find_Sibling (Query, State.Xml, "component");
         exit when SXML.Query.State_Result (Query) /= SXML.Result_OK
                   or else not SXML.Query.Is_Open (Query, State.Xml);
         SXML.Query.Attribute (Query, State.Xml, "name", Result, XML_Buf, Last);
         if Result = SXML.Result_OK then
            Gneiss_Syscall.Socketpair (State.Components (Index).Fd, Fd);
            if State.Components (Index).Fd > -1 then
               Gneiss_Epoll.Add (State.Epoll_Fd, State.Components (Index).Fd, State.Components (Index).Fd, Success);
               Gneiss_Syscall.Fork (Pid);
               if Pid < 0 then
                  Gneiss_Log.Error ("Fork failed");
                  State.Components (Index).Fd := -1;
                  return;
               elsif Pid > 0 then --  parent
                  State.Components (Index).Pid  := Pid;
                  State.Components (Index).Node := Query;
                  pragma Warnings (Off, "unused assignment to ""Fd""");
                  Gneiss_Syscall.Close (Fd);
                  pragma Warnings (On, "unused assignment to ""Fd""");
                  Parent := True;
                  Gneiss_Log.Info ("Started " & XML_Buf (XML_Buf'First .. Last)
                                   & " with PID " & Basalt.Strings.Image (Pid));
               else --  Pid = 0, Child
                  Gneiss_Syscall.Close (Integer (State.Epoll_Fd));
                  Load (State, Fd, Query, Status);
                  Parent := False;
                  return;
               end if;
            end if;
         else
            Gneiss_Log.Error ("Failed to load component name");
         end if;
         exit when Index = State.Components'Last;
         Index := Index + 1;
         Query := SXML.Query.Sibling (Query, State.Xml);
      end loop;
   end Start_Components;

   procedure Parse_Resources (Resources : in out Resource_List;
                              Document  :        SXML.Document_Type;
                              Root      :        SXML.Query.State_Type)
   is
      Index   : Integer := Resources'First;
      State   : SXML.Query.State_Type;
   begin
      State := SXML.Query.Path (Root, Document, "/config/resource");
      while
         SXML.Query.State_Result (State) = SXML.Result_OK
         and then SXML.Query.Is_Open (State, Document)
      loop
         pragma Loop_Invariant (SXML.Query.State_Result (State) = SXML.Result_OK);
         pragma Loop_Invariant (SXML.Query.Is_Valid (State, Document));
         pragma Loop_Invariant (Index in Resources'Range);
         pragma Loop_Invariant (Is_Valid (Document, Resources));
         State := SXML.Query.Find_Sibling (State, Document, "resource");
         exit when SXML.Query.State_Result (State) /= SXML.Result_OK;
         Resources (Index).Node := State;
         exit when Index = Resources'Last;
         Index := Index + 1;
         State := SXML.Query.Sibling (State, Document);
      end loop;
   end Parse_Resources;

   procedure Load (State : in out Broker_State;
                   Fd    :        Integer;
                   Comp  :        SXML.Query.State_Type;
                   Ret   :    out Return_Code)
   is
      Result         : SXML.Result_Type;
      Last           : Natural;
      Load_File_Name : String (1 .. 4096);
   begin
      Ret := 1;
      for C of State.Components loop
         C.Node := SXML.Query.Invalid_State;
         Gneiss_Syscall.Close (C.Fd);
      end loop;
      SXML.Query.Attribute (Comp, State.Xml, "file", Result, Load_File_Name, Last);
      if Result /= SXML.Result_OK and then Last not in Load_File_Name'Range then
         Gneiss_Log.Error ("No file to load");
         return;
      end if;
      Gneiss.Main.Run (Load_File_Name (Load_File_Name'First .. Last), Fd, Ret);
   end Load;

   procedure Parse (Data     : String;
                    Document : in out SXML.Document_Type)
   is
      use type SXML.Parser.Match_Type;
      Result     : SXML.Parser.Match_Type;
      Ignore_Pos : Natural;
   begin
      if not SXML.Valid_Content (Data'First, Data'Last) then
         Gneiss_Log.Error ("Invalid content");
         return;
      end if;
      SXML.Parser.Parse (Data, Document, Ignore_Pos, Result);
      if Result /= SXML.Parser.Match_OK then
         case Result is
            when SXML.Parser.Match_OK =>
               Gneiss_Log.Error ("XML document parsed successfully");
            when SXML.Parser.Match_None =>
               Gneiss_Log.Error ("No XML data found");
            when SXML.Parser.Match_Invalid =>
               Gneiss_Log.Error ("Malformed XML data found");
            when SXML.Parser.Match_Out_Of_Memory =>
               Gneiss_Log.Error ("Out of context buffer memory");
            when SXML.Parser.Match_None_Wellformed =>
               Gneiss_Log.Error ("Document is not wellformed");
            when SXML.Parser.Match_Trailing_Data =>
               Gneiss_Log.Warning ("Document successful parsed, but there is trailing data after it");
            when SXML.Parser.Match_Depth_Limit =>
               Gneiss_Log.Error ("Recursion depth exceeded");
         end case;
      end if;
   end Parse;

end Gneiss.Broker.Startup;
