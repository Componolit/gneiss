
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
      Ident : String (1 .. 513) := (others => ASCII.NUL);
      Ready : Boolean := False;
   end record;

   type Server_Reg is array (Gneiss.Session_Index range <>) of Message.Server_Session;
   type Server_Meta is array (Gneiss.Session_Index range <>) of Server_Slot;

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
   Buffer      : C_String (1 .. 129) := (others => 0);
   Servers     : Server_Reg (1 .. 2);
   Server_Data : Server_Meta (Servers'Range);

   procedure Construct (Cap : Gns.Capability)
   is
   begin
      Componolit.Runtime.Debug.Log_Debug ("Message Server");
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

   procedure Event with
      SPARK_Mode => Off
   is
   begin
      for I in Servers'Range loop
         if
            Message.Initialized (Servers (I))
            and then Message_Server.Available (Servers (I))
         then
            Message_Server.Read (Servers (I), Buffer (1 .. 128));
            Print_Message (Server_Data (I).Ident'Address, Buffer'Address);
         end if;
      end loop;
   end Event;

   procedure Initialize (Session : in out Message.Server_Session)
   is
   begin
      if Message.Index (Session) in Server_Data'Range then
         Server_Data (Message.Index (Session)).Ready := True;
      end if;
   end Initialize;

   procedure Finalize (Session : in out Message.Server_Session)
   is
   begin
      if Message.Index (Session) in Server_Data'Range then
         Server_Data (Message.Index (Session)).Ready := False;
      end if;
   end Finalize;

   procedure Dispatch (Session  : in out Message.Dispatcher_Session;
                       Disp_Cap :        Message.Dispatcher_Capability;
                       Name     :        String;
                       Label    :        String)
   is
   begin
      if Message_Dispatcher.Valid_Session_Request (Session, Disp_Cap) then
         for I in Servers'Range loop
            if not Ready (Servers (I)) then
               Message_Dispatcher.Session_Initialize (Session, Disp_Cap, Servers (I), I);
               if Ready (Servers (I)) and then Message.Initialized (Servers (I)) then
                  Server_Data (I).Ident (1 .. Name'Length + Label'Length + 1) := Name & ":" & Label;
                  Message_Dispatcher.Session_Accept (Session, Disp_Cap, Servers (I));
                  exit;
               end if;
            end if;
         end loop;
      end if;
      for S of Servers loop
         Message_Dispatcher.Session_Cleanup (Session, Disp_Cap, S);
      end loop;
   end Dispatch;

   function Ready (Session : Message.Server_Session) return Boolean is
      (if Message.Index (Session) in Server_Data'Range
       then Server_Data (Message.Index (Session)).Ready
       else False);

end Component;
