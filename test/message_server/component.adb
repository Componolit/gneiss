
with System;
with Gneiss.Message;
with Gneiss.Message.Dispatcher;
with Gneiss.Message.Server;
with Componolit.Runtime.Debug;

package body Component with
   SPARK_Mode
is

   type Unsigned_Char is mod 2 ** 8;
   type C_String is array (Positive range <>) of Unsigned_Char;

   procedure Print_Message (Prefix : System.Address;
                            Msg    : System.Address) with
      Import,
      Convention => C,
      External_Name => "print_message";

   package Message is new Gneiss.Message (Positive, Unsigned_Char, C_String, 1, 128);

   type Server_Slot is record
      Server : Message.Server_Session;
      Ident  : String (1 .. 513) := (others => ASCII.NUL);
   end record;

   type Server_Reg is array (Integer range <>) of Server_Slot;

   procedure Event;

   procedure Initialize (Session : in out Message.Server_Session);

   procedure Finalize (Session : in out Message.Server_Session);

   function Ready (Session : Message.Server_Session) return Boolean;

   procedure Dispatch (Session  : in out Message.Dispatcher_Session;
                       Disp_Cap :        Message.Dispatcher_Capability;
                       Name     :        String;
                       Label    :        String);

   package Message_Server is new Message.Server (Event, Initialize, Finalize, Ready);
   package Message_Dispatcher is new Message.Dispatcher (Message_Server, Dispatch);

   Dispatcher  : Message.Dispatcher_Session;
   Capability  : Gneiss.Capability;
   Initialized : Boolean := False;
   Buffer      : C_String (1 .. 129) := (others => 0);
   Servers     : Server_Reg (1 .. 1);

   procedure Construct (Cap : Gns.Capability)
   is
   begin
      Capability := Cap;
      Message_Dispatcher.Initialize (Dispatcher, Cap);
      if Message.Initialized (Dispatcher) then
         Message_Dispatcher.Register (Dispatcher);
         null;
      else
         Main.Vacate (Capability, Main.Failure);
      end if;
   end Construct;

   procedure Destruct
   is
   begin
      Message_Dispatcher.Finalize (Dispatcher);
   end Destruct;

   procedure Event
   is
   begin
      for S of Servers loop
         if
            Message.Initialized (S.Server)
            and then Message_Server.Available (S.Server)
         then
            Message_Server.Read (S.Server, Buffer (1 .. 128));
            Print_Message (S.Ident'Address, Buffer'Address);
         end if;
      end loop;
   end Event;

   procedure Initialize (Session : in out Message.Server_Session)
   is
      pragma Unreferenced (Session);
   begin
      Initialized := True;
   end Initialize;

   procedure Finalize (Session : in out Message.Server_Session)
   is
      pragma Unreferenced (Session);
   begin
      Initialized := False;
   end Finalize;

   procedure Dispatch (Session  : in out Message.Dispatcher_Session;
                       Disp_Cap :        Message.Dispatcher_Capability;
                       Name     :        String;
                       Label    :        String)
   is
   begin
      Componolit.Runtime.Debug.Log_Debug ("Dispatch " & Name & " " & Label);
      if Message_Dispatcher.Valid_Session_Request (Session, Disp_Cap) then
         for S of Servers loop
            if not Ready (S.Server) then
               Message_Dispatcher.Session_Initialize (Session, Disp_Cap, S.Server);
               if Ready (S.Server) and then Message.Initialized (S.Server) then
                  S.Ident (1 .. Name'Length + Label'Length + 1) := Name & ":" & Label;
                  Message_Dispatcher.Session_Accept (Session, Disp_Cap, S.Server);
                  exit;
               end if;
            end if;
         end loop;
      end if;
      for S of Servers loop
         Message_Dispatcher.Session_Cleanup (Session, Disp_Cap, S.Server);
      end loop;
   end Dispatch;

   function Ready (Session : Message.Server_Session) return Boolean is
      (Initialized);

end Component;
