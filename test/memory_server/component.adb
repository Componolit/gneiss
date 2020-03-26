
with Gneiss.Memory;
with Gneiss.Memory.Dispatcher;
with Gneiss.Memory.Server;

package body Component with
   SPARK_Mode
is

   package Memory is new Gneiss.Memory (Character, Positive, String);

   type Server_Slot is record
      Ident : String (1 .. 513) := (others => ASCII.NUL);
      Ready : Boolean := False;
   end record;

   type Server_Reg is array (Gneiss.Session_Index range <>) of Memory.Server_Session;
   type Server_Meta is array (Gneiss.Session_Index range <>) of Server_Slot;

   procedure Modify (Session : in out Memory.Server_Session;
                     Data    : in out String) with
      Pre  => Memory.Initialized (Session),
      Post => Memory.Initialized (Session);

   procedure Initialize (Session : in out Memory.Server_Session) with
      Pre  => Memory.Initialized (Session),
      Post => Memory.Initialized (Session);

   procedure Finalize (Session : in out Memory.Server_Session) with
      Pre  => Memory.Initialized (Session),
      Post => Memory.Initialized (Session);

   function Ready (Session : Memory.Server_Session) return Boolean;

   procedure Dispatch (Session  : in out Memory.Dispatcher_Session;
                       Disp_Cap :        Memory.Dispatcher_Capability;
                       Name     :        String;
                       Label    :        String) with
      Pre  => Memory.Initialized (Session),
      Post => Memory.Initialized (Session);

   package Memory_Server is new Memory.Server (Modify, Initialize, Finalize, Ready);
   package Memory_Dispatcher is new Memory.Dispatcher (Memory_Server, Dispatch);

   Dispatcher  : Memory.Dispatcher_Session;
   Capability  : Gneiss.Capability;
   Servers     : Server_Reg (1 .. 2);
   Server_Data : Server_Meta (Servers'Range);

   procedure Construct (Cap : Gneiss.Capability)
   is
   begin
      Capability := Cap;
      Memory_Dispatcher.Initialize (Dispatcher, Cap);
      if Memory.Initialized (Dispatcher) then
         Memory_Dispatcher.Register (Dispatcher);
      else
         Main.Vacate (Capability, Main.Failure);
      end if;
   end Construct;

   procedure Destruct
   is
   begin
      null;
   end Destruct;

   procedure Modify (Session : in out Memory.Server_Session;
                     Data    : in out String)
   is
      pragma Unreferenced (Session);
   begin
      if Data'Length > 11 then
         Data (Data'First .. Data'First + 11) := "Hello World!";
      end if;
   end Modify;

   procedure Initialize (Session : in out Memory.Server_Session)
   is
   begin
      if Memory.Index (Session).Value in Server_Data'Range then
         Server_Data (Memory.Index (Session).Value).Ready := True;
      end if;
   end Initialize;

   procedure Finalize (Session : in out Memory.Server_Session)
   is
   begin
      if Memory.Index (Session).Value in Server_Data'Range then
         Server_Data (Memory.Index (Session).Value).Ready := False;
      end if;
   end Finalize;

   procedure Dispatch (Session  : in out Memory.Dispatcher_Session;
                       Disp_Cap :        Memory.Dispatcher_Capability;
                       Name     :        String;
                       Label    :        String)
   is
   begin
      if Memory_Dispatcher.Valid_Session_Request (Session, Disp_Cap) then
         for I in Servers'Range loop
            if
               not Ready (Servers (I))
               and then not Memory.Initialized (Servers (I))
               and then Name'Length < Server_Data (I).Ident'Last
               and then Label'Length < Server_Data (I).Ident'Last
               and then Name'Length + Label'Length + 1 <= Server_Data (I).Ident'Last
               and then Name'First < Integer'Last - Server_Data (I).Ident'Last
            then
               Memory_Dispatcher.Session_Initialize (Session, Disp_Cap, Servers (I), I);
               if Ready (Servers (I)) and then Memory.Initialized (Servers (I)) then
                  Server_Data (I).Ident (1 .. Name'Length + Label'Length + 1) := Name & ":" & Label;
                  Memory_Dispatcher.Session_Accept (Session, Disp_Cap, Servers (I));
                  exit;
               end if;
            end if;
         end loop;
      end if;
      for S of Servers loop
         Memory_Dispatcher.Session_Cleanup (Session, Disp_Cap, S);
      end loop;
      for S of Servers loop
         if Memory.Initialized (S) then
            Memory_Server.Modify (S);
         end if;
      end loop;
   end Dispatch;

   function Ready (Session : Memory.Server_Session) return Boolean is
      (if
          Memory.Index (Session).Valid
          and then Memory.Index (Session).Value in Server_Data'Range
       then Server_Data (Memory.Index (Session).Value).Ready
       else False);

end Component;
