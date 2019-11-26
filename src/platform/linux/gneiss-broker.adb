
with Gneiss.Syscall;
with Gneiss.Main;
with SXML.Parser;
with Componolit.Runtime.Debug;

package body Gneiss.Broker with
   SPARK_Mode
is

   procedure Construct (Config :     String;
                        Status : out Integer)
   is
      use type SXML.Parser.Match_Type;
      use type SXML.Result_Type;
      P_Result : SXML.Parser.Match_Type := SXML.Parser.Match_Invalid;
      F_Result : Pid_Status;
      Position : Natural;
      State    : SXML.Query.State_Type;
      Index    : Positive := Policy'First;
      Pid      : Integer;
      Fd       : Integer;
   begin
      if not SXML.Valid_Content (Config'First, Config'Last) then
         Componolit.Runtime.Debug.Log_Error ("Invalid content");
         Status := 1;
         return;
      end if;
      SXML.Parser.Parse (Config, Document, P_Result, Position);
      if
         P_Result /= SXML.Parser.Match_OK
      then
         case P_Result is
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
         Status := 1;
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
      Status := 0;
      while State.Result = SXML.Result_OK loop
         if
            SXML.Query.Has_Attribute (State, Document, "name")
            and then SXML.Query.Has_Attribute (State, Document, "file")
         then
            Componolit.Runtime.Debug.Log_Debug
               ("Name : " & SXML.Query.Attribute (State, Document, "name"));
            Componolit.Runtime.Debug.Log_Debug
               ("File : " & SXML.Query.Attribute (State, Document, "file"));
            Policy (Index).Node := State;
            Gneiss.Syscall.Socketpair (Policy (Index).Fd, Fd);
            Gneiss.Syscall.Fork (Pid);
            Load (Pid, Fd, State, F_Result);
            case F_Result is
               when Parent =>
                  null;
               when Child_Success =>
                  Status := 0;
                  return;
               when Child_Error | Error =>
                  Status := 1;
                  return;
            end case;
            State := SXML.Query.Sibling (State, Document);
            exit when Index = Policy'Last;
            Index := Index + 1;
         else
            State := SXML.Query.Sibling (State, Document);
         end if;
      end loop;
   end Construct;

   procedure Load (Pid  :        Integer;
                   Fd   : in out Integer;
                   Comp :        SXML.Query.State_Type;
                   Ret  :    out Pid_Status)
   is
      Status : Integer;
   begin
      if Pid < 0 then
         Componolit.Runtime.Debug.Log_Error ("Fork failed.");
         Ret := Error;
         return;
      elsif Pid > 0 then
         Gneiss.Syscall.Close (Fd);
         Ret := Parent;
         return;
      end if;
      for I in Policy'Range loop
         Policy (I).Node := SXML.Query.Invalid_State;
         Gneiss.Syscall.Close (Policy (I).Fd);
      end loop;
      Gneiss.Main.Run (SXML.Query.Attribute (Comp, Document, "file"), Fd, Status);
      Ret := (if Status = 0 then Child_Success else Child_Error);
   end Load;

end Gneiss.Broker;
