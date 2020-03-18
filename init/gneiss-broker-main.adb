
with Gneiss.Broker.Startup;
with Gneiss.Broker.Message;
with Gneiss.Config;
with Gneiss_Syscall;
with Gneiss_Log;
with Gneiss_Epoll;
with Basalt.Strings;
with SXML.Query;

package body Gneiss.Broker.Main with
   SPARK_Mode
is

   State : Broker_State (1024, 128);

   package Conf is new Gneiss.Config (Parse);

   function Get_Dest (B_State : Broker_State;
                      Fd      : Integer) return Natural;

   function Get_Dest (B_State : Broker_State;
                      Fd      : Integer) return Natural
   is
   begin
      if Fd < 0 then
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
                        Status   : out Integer)
   is
      Query      : SXML.Query.State_Type;
      Parent     : Boolean;
   begin
      Gneiss_Log.Info ("Loading config from " & Conf_Loc);
      Status           := 1;
      Conf.Load (Conf_Loc);
      Query := SXML.Query.Init (State.Xml);
      if not SXML.Query.Is_Open (Query, State.Xml) then
         Gneiss_Log.Error ("Init failed");
         return;
      end if;
      Gneiss_Epoll.Create (State.Epoll_Fd);
      if not Gneiss_Epoll.Valid_Fd (State.Epoll_Fd) then
         Status := 1;
         return;
      end if;
      Startup.Parse_Resources (State.Resources, State.Xml, Query);
      Startup.Start_Components (State, Query, Parent, Status);
      if Parent then
         Event_Loop (State, Status);
      end if;
   end Construct;

   procedure Event_Loop (B_State : in out Broker_State;
                         Status  :    out Integer)
   is
      XML_Buf : String (1 .. 255);
      Ev      : Gneiss_Epoll.Event;
      Index   : Integer;
      Fd      : Integer;
      Success : Integer;
      Result  : SXML.Result_Type;
      Last    : Natural;
   begin
      Status := 1;
      loop
         Gneiss_Epoll.Wait (State.Epoll_Fd, Ev, Fd);
         Index := Get_Dest (State, Fd);
         if Index in B_State.Components'Range and then B_State.Components (Index).Fd > -1 then
            SXML.Query.Attribute (B_State.Components (Index).Node, B_State.Xml, "name", Result, XML_Buf, Last);
            if Ev.Epoll_In then
               Message.Read_Message (B_State, Index, Fd);
            end if;
            if Ev.Epoll_Hup or else Ev.Epoll_Rdhup then
               Gneiss_Syscall.Waitpid (B_State.Components (Index).Pid, Success);
               if Result = SXML.Result_OK then
                  Gneiss_Log.Info ("Component "
                                   & XML_Buf (XML_Buf'First .. Last)
                                   & " exited with status "
                                   & Basalt.Strings.Image (Success));
               else
                  Gneiss_Log.Info ("Component PID "
                                   & Basalt.Strings.Image (B_State.Components (Index).Pid)
                                   & " exited with status "
                                   & Basalt.Strings.Image (Success));
               end if;
               Gneiss_Epoll.Remove (State.Epoll_Fd, B_State.Components (Index).Fd, Success);
               Gneiss_Syscall.Close (B_State.Components (Index).Fd);
               State.Components (Index).Node := SXML.Query.Init (B_State.Xml);
               State.Components (Index).Pid  := -1;
            end if;
         else
            Gneiss_Log.Warning ("Invalid index");
         end if;
      end loop;
   end Event_Loop;

   procedure Parse (Data : String)
   is
   begin
      Startup.Parse (Data, State.Xml);
   end Parse;

end Gneiss.Broker.Main;
