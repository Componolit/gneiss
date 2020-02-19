
with Gneiss.Broker.Startup;
with Gneiss.Broker.Message;
with Gneiss.Config;
with Gneiss_Access;
with Gneiss_Syscall;
with Gneiss_Log;
with Basalt.Strings;
with SXML.Query;
with RFLX.Types;

package body Gneiss.Broker.Main with
   SPARK_Mode
is
   use type RFLX.Types.Bytes_Ptr;
   use type RFLX.Types.Length;

   State : Broker_State (1024, 128);
   Buffer_Size : constant RFLX.Types.Length := 512;
   package Read_Buffer is new Gneiss_Access (Buffer_Size);

   package Conf is new Gneiss.Config (Parse);

   function Valid_Read_Buffer return Boolean is
      (Read_Buffer.Ptr /= null
       and then Read_Buffer.Ptr.all'First = 1
       and then Read_Buffer.Ptr.all'Last = Buffer_Size);

   procedure Construct (Conf_Loc :     String;
                        Status   : out Integer)
   is
      Query      : SXML.Query.State_Type;
      Parent     : Boolean;
      Efd        : Gneiss_Epoll.Epoll_Fd;
   begin
      Gneiss_Log.Info ("Loading config from " & Conf_Loc);
      Status           := 1;
      Conf.Load (Conf_Loc);
      Query := SXML.Query.Init (State.Xml);
      if not SXML.Query.Is_Open (Query, State.Xml) then
         Gneiss_Log.Error ("Init failed");
         return;
      end if;
      Gneiss_Epoll.Create (Efd);
      if not Gneiss_Epoll.Valid_Fd (Efd) then
         Status := 1;
         return;
      end if;
      Startup.Parse_Resources (State.Resources, State.Xml, Query);
      Startup.Start_Components (State, Query, Parent, Status, Efd);
      if Parent and then Valid_Read_Buffer then
         Event_Loop (State, Status, Efd);
      end if;
   end Construct;

   procedure Event_Loop (B_State : in out Broker_State;
                         Status  :    out Integer;
                         Efd     :        Gneiss_Epoll.Epoll_Fd)
   is
      XML_Buf : String (1 .. 255);
      Ev      : Gneiss_Epoll.Event;
      Index   : Integer;
      Success : Integer;
      Result  : SXML.Result_Type;
      Last    : Natural;
   begin
      Status := 1;
      loop
         pragma Loop_Invariant (Valid_Read_Buffer);
         Gneiss_Epoll.Wait (Efd, Ev, Index);
         if Index in B_State.Components'Range and then B_State.Components (Index).Fd > -1 then
            SXML.Query.Attribute (B_State.Components (Index).Node, B_State.Xml, "name", Result, XML_Buf, Last);
            if Ev.Epoll_In then
               Message.Read_Message (B_State, Index, Read_Buffer.Ptr);
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
               Gneiss_Epoll.Remove (Efd, B_State.Components (Index).Fd, Success);
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
