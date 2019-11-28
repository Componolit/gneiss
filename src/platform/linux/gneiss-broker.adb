
with Ada.Unchecked_Conversion;
with Gneiss.Syscall;
with Gneiss.Main;
with Gneiss.Epoll;
with Basalt.Strings;
with Basalt.Strings_Generic;
with SXML.Parser;
with RFLX.Types;
with RFLX.Session;
with RFLX.Session.Packet;
with Componolit.Runtime.Debug;

package body Gneiss.Broker with
   SPARK_Mode
is
   use type Gneiss.Epoll.Epoll_Fd;

   Policy : Component_List (1 .. 1024);
   Efd    : Gneiss.Epoll.Epoll_Fd := -1;

   procedure Start_Components (Root   :     SXML.Query.State_Type;
                               Status : out Integer;
                               Parent : out Boolean);

   procedure Load (Fd   :        Integer;
                   Comp :        SXML.Query.State_Type;
                   Ret  :    out Integer);

   procedure Event_Loop (Status : out Integer);

   procedure Read_Message (Index : Positive);

   procedure Load_Labels (Context : in out RFLX.Session.Packet.Context;
                          Name    :    out String;
                          Label   :    out String);

   procedure Handle_Message (Source : Positive;
                             Action : RFLX.Session.Action_Type;
                             Kind   : RFLX.Session.Kind_Type;
                             Name   : String;
                             Label  : String);

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
         Componolit.Runtime.Debug.Log_Debug ("Broker Event");
         if Index in Policy'Range then
            if Ev.Epoll_In then
               Componolit.Runtime.Debug.Log_Debug ("Received command from "
                                                   & SXML.Query.Attribute (Policy (Index).Node, Document, "name"));
               Read_Message (Index);
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
         else
            Componolit.Runtime.Debug.Log_Warning ("Invalid index");
         end if;
      end loop;
   end Event_Loop;

   procedure Peek_Message (Socket    :     Integer;
                           Message   : out RFLX.Types.Bytes;
                           Last      : out RFLX.Types.Index;
                           Truncated : out Boolean);

   procedure Peek_Message (Socket    :     Integer;
                           Message   : out RFLX.Types.Bytes;
                           Last      : out RFLX.Types.Index;
                           Truncated : out Boolean) with
      SPARK_Mode => Off
   is
      use type RFLX.Types.Index;
      Ignore_Fd : Integer;
      Trunc     : Integer;
      Length    : Integer;
   begin
      Gneiss.Syscall.Peek_Message (Socket, Message'Address, Message'Length, Ignore_Fd, Length, Trunc);
      Truncated := Trunc = 1;
      if Length < 1 then
         Last := RFLX.Types.Index'First;
         return;
      end if;
      Componolit.Runtime.Debug.Log_Debug (Basalt.Strings.Image (Length));
      Last      := (Message'First + RFLX.Types.Index (Length)) - 1;
   end Peek_Message;

   type Bytes_Ptr is access all RFLX.Types.Bytes;
   function Convert is new Ada.Unchecked_Conversion (Bytes_Ptr, RFLX.Types.Bytes_Ptr);
   --  FIXME: We have to convert access to access all to use it with 'Access, we should not do this
   Read_Buffer : aliased RFLX.Types.Bytes := (1 .. 512 => 0);

   procedure Read_Message (Index : Positive)
   is
      function Image is new Basalt.Strings_Generic.Image_Modular (RFLX.Session.Length_Type);
      Truncated  : Boolean;
      Context    : RFLX.Session.Packet.Context;
      Buffer_Ptr : RFLX.Types.Bytes_Ptr := Convert (Read_Buffer'Access);
      Last       : RFLX.Types.Index;
   begin
      Peek_Message (Policy (Index).Fd, Read_Buffer, Last, Truncated);
      Gneiss.Syscall.Drop_Message (Policy (Index).Fd);
      if Truncated then
         Componolit.Runtime.Debug.Log_Warning ("Message too large, dropping");
         return;
      end if;
      Componolit.Runtime.Debug.Log_Debug ("Parsing...");
      RFLX.Session.Packet.Initialize (Context,
                                      Buffer_Ptr,
                                      RFLX.Types.First_Bit_Index (Read_Buffer'First),
                                      RFLX.Types.Last_Bit_Index (Last));
      RFLX.Session.Packet.Verify_Message (Context);
      Componolit.Runtime.Debug.Log_Debug
         ("Valid: "
          & " F_Action="
          & Basalt.Strings.Image (RFLX.Session.Packet.Valid (Context, RFLX.Session.Packet.F_Action))
          & " F_Kind="
          & Basalt.Strings.Image (RFLX.Session.Packet.Valid (Context, RFLX.Session.Packet.F_Kind))
          & " F_Name_Length="
          & Basalt.Strings.Image (RFLX.Session.Packet.Valid (Context, RFLX.Session.Packet.F_Name_Length))
          & " F_Name_Payload="
          & Basalt.Strings.Image (RFLX.Session.Packet.Valid (Context, RFLX.Session.Packet.F_Name_Payload))
          & " F_Label_Length="
          & Basalt.Strings.Image (RFLX.Session.Packet.Valid (Context, RFLX.Session.Packet.F_Label_Length))
          & " F_Label_Payload="
          & Basalt.Strings.Image (RFLX.Session.Packet.Valid (Context, RFLX.Session.Packet.F_Label_Payload))
          );
      Componolit.Runtime.Debug.Log_Debug
         ("Present: "
          & " F_Action="
          & Basalt.Strings.Image (RFLX.Session.Packet.Present (Context, RFLX.Session.Packet.F_Action))
          & " F_Kind="
          & Basalt.Strings.Image (RFLX.Session.Packet.Present (Context, RFLX.Session.Packet.F_Kind))
          & " F_Name_Length="
          & Basalt.Strings.Image (RFLX.Session.Packet.Present (Context, RFLX.Session.Packet.F_Name_Length))
          & " F_Name_Payload="
          & Basalt.Strings.Image (RFLX.Session.Packet.Present (Context, RFLX.Session.Packet.F_Name_Payload))
          & " F_Label_Length="
          & Basalt.Strings.Image (RFLX.Session.Packet.Present (Context, RFLX.Session.Packet.F_Label_Length))
          & " F_Label_Payload="
          & Basalt.Strings.Image (RFLX.Session.Packet.Present (Context, RFLX.Session.Packet.F_Label_Payload))
          );
      if
         not RFLX.Session.Packet.Valid (Context, RFLX.Session.Packet.F_Action)
         or else not RFLX.Session.Packet.Valid (Context, RFLX.Session.Packet.F_Kind)
         or else not RFLX.Session.Packet.Valid (Context, RFLX.Session.Packet.F_Name_Length)
         or else not RFLX.Session.Packet.Valid (Context, RFLX.Session.Packet.F_Label_Length)
         or else not RFLX.Session.Packet.Present (Context, RFLX.Session.Packet.F_Label_Payload)
      then
         Componolit.Runtime.Debug.Log_Warning ("Invalid message, dropping");
         return;
      end if;
      Componolit.Runtime.Debug.Log_Debug ("Name=" & Image (RFLX.Session.Packet.Get_Name_Length (Context))
                                          & " Label=" & Image (RFLX.Session.Packet.Get_Label_Length (Context)));
      declare
         Name : String (1 .. Integer (RFLX.Session.Packet.Get_Name_Length (Context)));
         Label : String (1 .. Integer (RFLX.Session.Packet.Get_Label_Length (Context)));
      begin
         Load_Labels (Context, Name, Label);
         Handle_Message (Index,
                         RFLX.Session.Packet.Get_Action (Context),
                         RFLX.Session.Packet.Get_Kind (Context),
                         Name, Label);
      end;
   end Read_Message;

   procedure Load_Labels (Context : in out RFLX.Session.Packet.Context;
                          Name    :    out String;
                          Label   :    out String)
   is
      use type RFLX.Types.Length;
      procedure Process_Name (Payload : RFLX.Types.Bytes);
      procedure Process_Name (Payload : RFLX.Types.Bytes)
      is
      begin
         for I in Name'Range loop
            Name (I) := Character'Val (Payload (Payload'First + RFLX.Types.Index (I) - 1));
         end loop;
      end Process_Name;
      procedure Process_Label (Payload : RFLX.Types.Bytes);
      procedure Process_Label (Payload : RFLX.Types.Bytes)
      is
      begin
         for I in Label'Range loop
            Label (I) := Character'Val (Payload (Payload'First + RFLX.Types.Index (I) - 1));
         end loop;
      end Process_Label;
      procedure Get_Name is new RFLX.Session.Packet.Get_Name_Payload (Process_Name);
      procedure Get_Label is new RFLX.Session.Packet.Get_Label_Payload (Process_Label);
   begin
      if RFLX.Session.Packet.Has_Buffer (Context) then
         if RFLX.Session.Packet.Present (Context, RFLX.Session.Packet.F_Name_Payload) then
            Get_Name (Context);
         end if;
         if RFLX.Session.Packet.Present (Context, RFLX.Session.Packet.F_Label_Payload) then
            Get_Label (Context);
         end if;
      end if;
   end Load_Labels;

   procedure Handle_Message (Source : Positive;
                             Action : RFLX.Session.Action_Type;
                             Kind   : RFLX.Session.Kind_Type;
                             Name   : String;
                             Label  : String)
   is
      pragma Unreferenced (Source);
      pragma Unreferenced (Action);
      pragma Unreferenced (Kind);
   begin
      Componolit.Runtime.Debug.Log_Debug ("Message:");
      Componolit.Runtime.Debug.Log_Debug (Name);
      Componolit.Runtime.Debug.Log_Debug (Label);
   end Handle_Message;

end Gneiss.Broker;
