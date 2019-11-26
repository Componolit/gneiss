
with Gneiss.Syscall;
with Gneiss.Main;
with Gneiss.Epoll;
with Basalt.Strings;
with SXML.Parser;
with Componolit.Runtime.Debug;

package body Gneiss.Broker with
   SPARK_Mode
is
   use type Gneiss.Epoll.Epoll_Fd;

   procedure Event_Loop (Status : out Integer);

   Policy : Component_List (1 .. 1024);
   Efd    : Gneiss.Epoll.Epoll_Fd := -1;

   procedure Construct (Config :     String;
                        Status : out Integer)
   is
      use type SXML.Parser.Match_Type;
      use type SXML.Result_Type;
      Result   : SXML.Parser.Match_Type := SXML.Parser.Match_Invalid;
      Position : Natural;
      State    : SXML.Query.State_Type;
      Parent   : Boolean;
   begin
      if not SXML.Valid_Content (Config'First, Config'Last) then
         Componolit.Runtime.Debug.Log_Error ("Invalid content");
         Status := 1;
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
         Status := 1;
         return;
      end if;
      Gneiss.Epoll.Create (Efd);
      if Efd < 0 then
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
      Start_Components (State, Status, Parent);
      if Parent then
         Event_Loop (Status);
      end if;
   end Construct;

   procedure Start_Components (Root   : SXML.Query.State_Type;
                               Status : out Integer;
                               Parent : out Boolean)
   is
      use type SXML.Result_Type;
      Pid     : Integer;
      Fd      : Integer;
      Success : Integer;
      Index   : Positive := Policy'First;
      State   : SXML.Query.State_Type;
   begin
      State := SXML.Query.Path (Root, Document, "/config/component");
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
            Gneiss.Epoll.Add (Efd, Policy (Index).Fd, Index, Success);
            Gneiss.Syscall.Fork (Pid);
            if Pid < 0 then
               Status := 1;
               Componolit.Runtime.Debug.Log_Error ("Fork failed");
               Parent := True;
               return;
            elsif Pid > 0 then --  parent
               Policy (Index).Pid := Pid;
               Gneiss.Syscall.Close (Fd);
               Parent := True;
            else --  Pid = 0, Child
               Load (Fd, State, Status);
               Parent := False;
               return;
            end if;
            State := SXML.Query.Sibling (State, Document);
            exit when Index = Policy'Last;
            Index := Index + 1;
         else
            State := SXML.Query.Sibling (State, Document);
         end if;
      end loop;
   end Start_Components;

   procedure Load (Fd   :        Integer;
                   Comp :        SXML.Query.State_Type;
                   Ret  :    out Integer)
   is
   begin
      Gneiss.Syscall.Close (Integer (Efd));
      for I in Policy'Range loop
         Policy (I).Node := SXML.Query.Invalid_State;
         Gneiss.Syscall.Close (Policy (I).Fd);
      end loop;
      if not SXML.Query.Has_Attribute (Comp, Document, "file") then
         Componolit.Runtime.Debug.Log_Error ("No file to load");
         Ret := 1;
         return;
      end if;
      Gneiss.Main.Run (SXML.Query.Attribute (Comp, Document, "file"), Fd, Ret);
   end Load;

   procedure Event_Loop (Status : out Integer)
   is
      Ev      : Gneiss.Epoll.Event;
      Index   : Integer;
      Success : Integer;
   begin
      Status := 1;
      loop
         Gneiss.Epoll.Wait (Efd, Ev, Index);
         if Index in Policy'Range then
            if Ev.Epoll_In then
               Componolit.Runtime.Debug.Log_Debug ("Received command from "
                                                   & SXML.Query.Attribute (Policy (Index).Node, Document, "name"));
            end if;
            if Ev.Epoll_Hup or else Ev.Epoll_Rdhup then
               Gneiss.Syscall.Waitpid (Policy (Index).Pid, Success);
               Componolit.Runtime.Debug.Log_Debug ("Component "
                                                   & SXML.Query.Attribute (Policy (Index).Node, Document, "name")
                                                   & " exited with status "
                                                   & Basalt.Strings.Image (Success));
               Gneiss.Epoll.Remove (Efd, Policy (Index).Fd, Success);
               Gneiss.Syscall.Close (Policy (Index).Fd);
               Policy (Index).Node := SXML.Query.Invalid_State;
            end if;
         end if;
      end loop;
   end Event_Loop;

end Gneiss.Broker;
