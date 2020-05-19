
with Gneiss.Broker.Startup;
with Gneiss.Broker.Message;
with Gneiss.Config;
with Gneiss_Internal.Syscall;
with Gneiss_Internal.Print;
with Gneiss_Internal.Epoll;
with Basalt.Strings;
with SXML.Query;

package body Gneiss.Broker.Main with
   SPARK_Mode
is

   State : Broker_State (1024, 128);

   package Conf is new Gneiss.Config (Parse);

   function Get_Dest (B_State : Broker_State;
                      Fd      : Gneiss_Internal.File_Descriptor) return Natural;

   function Get_Dest (B_State : Broker_State;
                      Fd      : Gneiss_Internal.File_Descriptor) return Natural
   is
   begin
      if not Gneiss_Internal.Valid (Fd) then
         return 0;
      end if;
      for I in B_State.Components'Range loop
         if
            B_State.Components (I).Fd = Fd
            or else (for some S of B_State.Components (I).Serv => S.Broker = Fd)
         then
            return I;
         end if;
      end loop;
      return 0;
   end Get_Dest;

   procedure Construct (Conf_Loc :     String;
                        Status   : out Return_Code)
   is
      Query      : SXML.Query.State_Type;
      Parent     : Boolean;
   begin
      Gneiss_Internal.Print.Info ("Loading config from " & Conf_Loc);
      Status := 1;
      Conf.Load (Conf_Loc);
      Query := SXML.Query.Init (State.Xml);
      if not SXML.Query.Is_Open (Query, State.Xml) then
         Gneiss_Internal.Print.Error ("Init failed");
         return;
      end if;
      Gneiss_Internal.Epoll.Create (State.Epoll_Fd);
      if not Gneiss_Internal.Valid (State.Epoll_Fd) then
         Status := 1;
         return;
      end if;
      State.Resources := (others => (Fd => -1,
                                     Node => SXML.Query.Invalid_State));
      Startup.Parse_Resources (State.Resources, State.Xml, Query);
      State.Components := (others => (Fd   => -1,
                                      Node => SXML.Query.Initial_State,
                                      Pid  => -1,
                                      Serv => (others => (others => -1))));
      Startup.Start_Components (State, Query, Parent, Status);
      if Parent then
         Event_Loop (State, Status);
      end if;
   end Construct;

   procedure Event_Loop (B_State : in out Broker_State;
                         Status  :    out Return_Code)
   is
      XML_Buf        : String (1 .. 255);
      Ev             : Gneiss_Internal.Epoll.Event;
      Index          : Integer;
      Fd             : Gneiss_Internal.File_Descriptor;
      Exit_Status    : Integer;
      Ignore_Success : Boolean;
      Result         : SXML.Result_Type;
      Last           : Natural;
   begin
      Status := 1;
      loop
         pragma Loop_Invariant (Is_Valid (B_State.Xml, B_State.Components));
         pragma Loop_Invariant (Is_Valid (B_State.Xml, B_State.Resources));
         pragma Loop_Invariant (Gneiss_Internal.Valid (B_State.Epoll_Fd));
         Gneiss_Internal.Epoll.Wait (B_State.Epoll_Fd, Ev, Integer (Fd));
         Index := Get_Dest (B_State, Fd);
         if Index in B_State.Components'Range and then Gneiss_Internal.Valid (B_State.Components (Index).Fd) then
            SXML.Query.Attribute (B_State.Components (Index).Node, B_State.Xml, "name", Result, XML_Buf, Last);
            if Ev.Epoll_In and then Gneiss_Internal.Valid (Fd) then
               Message.Read_Message (B_State, Index, Fd);
            end if;
            if Ev.Epoll_Hup or else Ev.Epoll_Rdhup then
               Gneiss_Internal.Syscall.Waitpid (B_State.Components (Index).Pid, Exit_Status);
               if Result = SXML.Result_OK then
                  Gneiss_Internal.Print.Info ("Component "
                                              & XML_Buf (XML_Buf'First .. Last)
                                              & " exited with status "
                                              & Basalt.Strings.Image (Exit_Status));
               else
                  Gneiss_Internal.Print.Info ("Component PID "
                                              & Basalt.Strings.Image (B_State.Components (Index).Pid)
                                              & " exited with status "
                                              & Basalt.Strings.Image (Exit_Status));
               end if;
               if Gneiss_Internal.Valid (B_State.Components (Index).Fd) then
                  Gneiss_Internal.Epoll.Remove (B_State.Epoll_Fd, B_State.Components (Index).Fd, Ignore_Success);
               end if;
               Gneiss_Internal.Syscall.Close (B_State.Components (Index).Fd);
               B_State.Components (Index).Node := SXML.Query.Init (B_State.Xml);
               B_State.Components (Index).Pid  := -1;
            end if;
         else
            Gneiss_Internal.Print.Warning ("Invalid index");
         end if;
      end loop;
   end Event_Loop;

   procedure Parse (Data : String)
   is
   begin
      Startup.Parse (Data, State.Xml);
   end Parse;

end Gneiss.Broker.Main;
