
with Gneiss.Log;
with Gneiss.Log.Server;
with Gneiss.Log.Dispatcher;

package body Linux_Log_Server.Component with
   SPARK_Mode
is

   package Log is new Gneiss.Log;

   type Server_Slot is record
      Ident   : String (1 .. 513) := (others => ASCII.NUL);
      Last    : Natural           := 0;
      Ready   : Boolean           := False;
      Newline : Boolean           := True;
   end record;

   subtype Server_Index is Gneiss.Session_Index range 1 .. 10;
   type Server_Reg is array (Server_Index'Range) of Log.Server_Session;
   type Server_Meta is array (Server_Index'Range) of Server_Slot;

   Dispatcher  : Log.Dispatcher_Session;
   Capability  : Gneiss.Capability;
   Servers     : Server_Reg;
   Server_Data : Server_Meta;

   procedure Write (Session : in out Log.Server_Session;
                    Data    :        String);
   procedure Initialize (Session : in out Log.Server_Session;
                         Context : in out Server_Meta);
   procedure Finalize (Session : in out Log.Server_Session;
                       Context : in out Server_Meta);
   function Ready (Session : Log.Server_Session;
                   Context : Server_Meta) return Boolean;
   procedure Dispatch (Session : in out Log.Dispatcher_Session;
                       Cap     :        Log.Dispatcher_Capability;
                       Name    :        String;
                       Label   :        String);

   package Log_Server is new Log.Server (Server_Meta, Write, Initialize, Finalize, Ready);
   package Log_Dispatcher is new Log.Dispatcher (Log_Server, Dispatch);

   procedure Construct (Cap : Gneiss.Capability)
   is
   begin
      Capability := Cap;
      Log_Dispatcher.Initialize (Dispatcher, Cap);
      if Log.Initialized (Dispatcher) then
         Log_Dispatcher.Register (Dispatcher);
      else
         Main.Vacate (Capability, Main.Failure);
      end if;
   end Construct;

   procedure Write (Session : in out Log.Server_Session;
                    Data    :        String)
   is
      procedure Put (C : Character) with
         Import,
         Convention    => C,
         External_Name => "put";
      I : constant Gneiss.Session_Index_Option := Log.Index (Session);
   begin
      if not I.Valid or else I.Value not in Server_Data'Range then
         return;
      end if;
      if Server_Data (I.Value).Newline then
         Put (Character'Val (8#33#));
         Put ('[');
         Put ('0');
         Put ('m');
         Put ('[');
         for C of Server_Data (I.Value).Ident (1 .. Server_Data (I.Value).Last) loop
            Put (C);
         end loop;
         Put (']');
         Put (' ');
      end if;
      for C of Data loop
         Put (C);
         Server_Data (I.Value).Newline := Server_Data (I.Value).Newline or else C = ASCII.NUL;
      end loop;
   end Write;

   procedure Destruct
   is
   begin
      null;
   end Destruct;

   procedure Initialize (Session : in out Log.Server_Session;
                         Context : in out Server_Meta)
   is
   begin
      if
         Log.Index (Session).Valid
         and then Log.Index (Session).Value in Context'Range
      then
         Context (Log.Index (Session).Value).Ready := True;
      end if;
   end Initialize;

   procedure Finalize (Session : in out Log.Server_Session;
                       Context : in out Server_Meta)
   is
   begin
      if
         Log.Index (Session).Valid
         and then Log.Index (Session).Value in Context'Range
      then
         Context (Log.Index (Session).Value).Ready := False;
      end if;
   end Finalize;

   procedure Dispatch (Session : in out Log.Dispatcher_Session;
                       Cap     :        Log.Dispatcher_Capability;
                       Name    :        String;
                       Label   :        String)
   is
   begin
      if Log_Dispatcher.Valid_Session_Request (Session, Cap) then
         for I in Servers'Range loop
            if not Ready (Servers (I), Server_Data) then
               Log_Dispatcher.Session_Initialize (Session, Cap, Servers (I), Server_Data, I);
               if Ready (Servers (I), Server_Data) and then Log.Initialized (Servers (I)) then
                  Server_Data (I).Last := Name'Length + Label'Length + 1;
                  Server_Data (I).Ident (1 .. Server_Data (I).Last) := Name & ":" & Label;
                  Log_Dispatcher.Session_Accept (Session, Cap, Servers (I), Server_Data);
                  exit;
               end if;
            end if;
         end loop;
      end if;
      for S of Servers loop
         Log_Dispatcher.Session_Cleanup (Session, Cap, S, Server_Data);
      end loop;
   end Dispatch;

   function Ready (Session : Log.Server_Session;
                   Context : Server_Meta) return Boolean is
      (if
          Log.Index (Session).Valid
          and then Log.Index (Session).Value in Context'Range
       then Context (Log.Index (Session).Value).Ready
       else False);

end Linux_Log_Server.Component;
