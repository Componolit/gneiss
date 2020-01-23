
with System;
with Gneiss.Message;
with Gneiss.Message.Dispatcher;
with Gneiss.Message.Server;
with Gneiss.Memory;
with Gneiss.Memory.Client;
with Gneiss.Log;
with Gneiss.Log.Client;

package body Component with
   SPARK_Mode
is

   package Memory is new Gneiss.Memory (Character, Positive, String);
   package Message is new Gneiss.Message (Positive, Character, String, 1, 1);

   type Server_Slot is record
      Ident : String (1 .. 513) := (others => ASCII.NUL);
      Ready : Boolean := False;
   end record;

   type Server_Reg is array (Gneiss.Session_Index range <>) of Message.Server_Session;
   type Server_Meta is array (Gneiss.Session_Index range <>) of Server_Slot;

   function Strlen (S : String) return Natural;

   procedure Initialize_Memory;

   procedure Read (Session : in out Memory.Client_Session;
                   Data    :        String);

   procedure Modify (Session : in out Memory.Client_Session;
                     Data    : in out String) is null;

   procedure Initialize_Log;

   procedure Register;

   package Memory_Client is new Memory.Client (Initialize_Memory, Read, Modify);

   package Log_Client is new Gneiss.Log.Client (Initialize_Log);

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
   Servers     : Server_Reg (1 .. 1);
   Server_Data : Server_Meta (Servers'Range);
   Log         : Gneiss.Log.Client_Session;
   Mem         : Memory.Client_Session;

   procedure Initialize_Memory
   is
   begin
      case Memory.Status (Mem) is
         when Gneiss.Initialized =>
            Register;
         when Gneiss.Pending =>
            Memory_Client.Initialize (Mem, Capability, "");
         when Gneiss.Uninitialized =>
            Main.Vacate (Capability, Main.Failure);
      end case;
   end Initialize_Memory;

   procedure Initialize_Log
   is
   begin
      case Gneiss.Log.Status (Log) is
         when Gneiss.Initialized =>
            Register;
         when Gneiss.Pending =>
            Log_Client.Initialize (Log, Capability, "");
         when Gneiss.Uninitialized =>
            Main.Vacate (Capability, Main.Failure);
      end case;
   end Initialize_Log;

   procedure Register
   is
      use type Gneiss.Session_Status;
   begin
      if Message.Initialized (Dispatcher) then
         if
            Gneiss.Log.Status (Log) = Gneiss.Initialized
            and then Memory.Status (Mem) = Gneiss.Initialized
         then
            Log_Client.Info (Log, "Registering...");
            Message_Dispatcher.Register (Dispatcher);
         end if;
      else
         Main.Vacate (Capability, Main.Failure);
      end if;
   end Register;

   procedure Construct (Cap : Gns.Capability)
   is
   begin
      Capability := Cap;
      Message_Dispatcher.Initialize (Dispatcher, Cap);
      if Message.Initialized (Dispatcher) then
         Log_Client.Initialize (Log, Capability, "server");
         Memory_Client.Initialize (Mem, Capability, "shared");
      else
         Main.Vacate (Capability, Main.Failure);
      end if;
   end Construct;

   procedure Destruct
   is
   begin
      Message_Dispatcher.Finalize (Dispatcher);
      Log_Client.Finalize (Log);
      Memory_Client.Finalize (Mem);
   end Destruct;

   procedure Event
   is
      Buf : String (1 .. 1);
   begin
      for I in Servers'Range loop
         if
            Message.Initialized (Servers (I))
            and then Message_Server.Available (Servers (I))
         then
            Message_Server.Read (Servers (I), Buf);
            Memory_Client.Update (Mem);
         end if;
      end loop;
   end Event;

   function Strlen (S : String) return Natural
   is
      L : Natural := 0;
   begin
      for C of S loop
         exit when C = ASCII.NUL;
         L := L + 1;
      end loop;
      return L;
   end Strlen;

   procedure Read (Session : in out Memory.Client_Session;
                   Data    :        String)
   is
      use type Gneiss.Session_Status;
   begin
      if Gneiss.Log.Status (Log) /= Gneiss.Initialized then
         return;
      end if;
      Log_Client.Info (Log, "Data: " & Data (Data'First .. Data'First + Strlen (Data) - 1));
   end Read;

   procedure Initialize (Session : in out Message.Server_Session)
   is
   begin
      if Message.Index (Session).Value in Server_Data'Range then
         Server_Data (Message.Index (Session).Value).Ready := True;
      end if;
   end Initialize;

   procedure Finalize (Session : in out Message.Server_Session)
   is
   begin
      if Message.Index (Session).Value in Server_Data'Range then
         Server_Data (Message.Index (Session).Value).Ready := False;
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
      (if
          Message.Index (Session).Valid
          and then Message.Index (Session).Value in Server_Data'Range
       then Server_Data (Message.Index (Session).Value).Ready
       else False);

end Component;
