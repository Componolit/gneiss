
with Componolit.Gneiss.Log;
with Componolit.Gneiss.Log.Client;
with Componolit.Gneiss.Strings_Generic;

package body Component is

   --  Print the content of each Read and Write package seen
   Print_Content : constant Boolean := False;

   use type Block.Request_Kind;
   use type Block.Request_Status;

   Dispatcher : Block.Dispatcher_Session;
   Client : Block.Client_Session;
   Server : Block.Server_Session;

   Capability : Componolit.Gneiss.Types.Capability;

   Log : Componolit.Gneiss.Log.Client_Session;

   function Image is new Componolit.Gneiss.Strings_Generic.Image_Modular (Byte);
   function Image is new Componolit.Gneiss.Strings_Generic.Image_Modular (Block.Id);
   function Image is new Componolit.Gneiss.Strings_Generic.Image_Ranged (Unsigned_Long);

   procedure Construct (Cap : Componolit.Gneiss.Types.Capability)
   is
   begin
      Capability := Cap;
      if not Componolit.Gneiss.Log.Initialized (Log) then
         Componolit.Gneiss.Log.Client.Initialize (Log, Cap, "log_block_proxy");
      end if;
      if Componolit.Gneiss.Log.Initialized (Log) then
         if not Block.Initialized (Dispatcher) then
            Block_Dispatcher.Initialize (Dispatcher, Cap, 42);
         end if;
         if Block.Initialized (Dispatcher) then
            Block_Dispatcher.Register (Dispatcher);
         else
            Componolit.Gneiss.Log.Client.Error (Log, "Failed to initialize Dispatcher");
            Main.Vacate (Capability, Main.Failure);
         end if;
      else
         Main.Vacate (Capability, Main.Failure);
      end if;
   end Construct;

   procedure Destruct
   is
   begin
      if Componolit.Gneiss.Log.Initialized (Log) then
         Componolit.Gneiss.Log.Client.Finalize (Log);
      end if;
      if Block.Initialized (Dispatcher) then
         Block_Dispatcher.Finalize (Dispatcher);
      end if;
   end Destruct;

   type Cache_Entry is record
      C : Block_Client.Request;
      S : Block_Server.Request;
      A : Boolean := False;
   end record;

   type Registry is array (Request_Index'Range) of Cache_Entry;

   Cache : Registry;

   procedure Print_Buffer (D : Buffer) with
      Pre => Componolit.Gneiss.Log.Initialized (Log);

   procedure Print_Buffer (D : Buffer)
   is
      I : Unsigned_Long := D'First;
      function Pad (S : String) return String is
         (if S'Length = 1 then '0' & S else S);
   begin
      while I < D'Last and then D'Last - I > 16 loop
         Componolit.Gneiss.Log.Client.Info
            (Log, Image (I - D'First, 16, False) & ": "
                  & Pad (Image (D (I), 16, False))      & Pad (Image (D (I + 1), 16, False)) & " "
                  & Pad (Image (D (I + 2), 16, False))  & Pad (Image (D (I + 3), 16, False)) & " "
                  & Pad (Image (D (I + 4), 16, False))  & Pad (Image (D (I + 5), 16, False)) & " "
                  & Pad (Image (D (I + 6), 16, False))  & Pad (Image (D (I + 7), 16, False)) & " "
                  & Pad (Image (D (I + 8), 16, False))  & Pad (Image (D (I + 9), 16, False)) & " "
                  & Pad (Image (D (I + 10), 16, False)) & Pad (Image (D (I + 11), 16, False)) & " "
                  & Pad (Image (D (I + 12), 16, False)) & Pad (Image (D (I + 13), 16, False)) & " "
                  & Pad (Image (D (I + 14), 16, False)) & Pad (Image (D (I + 15), 16, False)) & " "
                  );
         I := I + 16;
      end loop;
   end Print_Buffer;

   procedure Write (C : in out Block.Client_Session;
                    I :        Request_Index;
                    D :    out Buffer)
   is
      pragma Unreferenced (C);
   begin
      if
         Block_Server.Status (Cache (I).S) = Block.Pending
         and then Block_Server.Kind (Cache (I).S) = Block.Write
         and then Initialized (Server)
         and then Block.Initialized (Server)
         and then Block_Server.Assigned (Server, Cache (I).S)
         and then D'Length = Block_Size (Server) * Block_Server.Length (Cache (I).S)
      then
         Block_Server.Write (Server, Cache (I).S, D);
         pragma Warnings (Off, "*never be executed*");
         pragma Warnings (Off, "if statement has no effect");
         if Print_Content and then Componolit.Gneiss.Log.Initialized (Log) then
            Componolit.Gneiss.Log.Client.Info (Log, "Write @ " & Image (Block_Server.Start (Cache (I).S)));
            Print_Buffer (D);
         end if;
         if False then
            --  This is a construct to allow dead code which appears when Print_Content is set to False.
            --  In case it is set to True the first disabled Warning does not happen so dummy dead code
            --  has been inserted to trigger it again.
            null;
         end if;
         pragma Warnings (On, "if statement has no effect");
         pragma Warnings (On, "*never be executed*");
      else
         Cache (I).A := True;
      end if;
   end Write;

   procedure Read (C : in out Block.Client_Session;
                   I :        Request_Index;
                   D :        Buffer)
   is
      pragma Unreferenced (C);
   begin
      if
         Block_Server.Status (Cache (I).S) = Block.Pending
         and then Block_Server.Kind (Cache (I).S) = Block.Read
         and then Initialized (Server)
         and then Block.Initialized (Server)
         and then Block_Server.Assigned (Server, Cache (I).S)
         and then D'Length = Block_Size (Server) * Block_Server.Length (Cache (I).S)
      then
         pragma Warnings (Off, "*never be executed*");
         pragma Warnings (Off, "if statement has no effect");
         if Print_Content and then Componolit.Gneiss.Log.Initialized (Log) then
            Componolit.Gneiss.Log.Client.Info (Log, "Read @ " & Image (Block_Server.Start (Cache (I).S)));
            Print_Buffer (D);
         end if;
         if False and then Print_Content then
            --  This is a construct to allow dead code which appears when Print_Content is set to False.
            --  In case it is set to True the first disabled Warning does not happen so dummy dead code
            --  has been inserted to trigger it again.
            null;
         end if;
         pragma Warnings (On, "if statement has no effect");
         pragma Warnings (On, "*never be executed*");
         Block_Server.Read (Server, Cache (I).S, D);
      else
         Cache (I).A := True;
      end if;
   end Read;

   procedure Event
   is
      Re : Block.Result;
   begin
      if
         Block.Initialized (Client)
         and then Initialized (Server)
         and then Block.Initialized (Server)
      then
         pragma Assert (Block.Initialized (Server));
         for I in Cache'Range loop
            pragma Loop_Invariant (Block.Initialized (Client));
            pragma Loop_Invariant (Block.Initialized (Server));
            pragma Loop_Invariant (Initialized (Server));
            if Block_Server.Status (Cache (I).S) = Block.Raw then
               if
                  Block_Client.Status (Cache (I).C) in Block.Ok | Block.Error
                  and then Block_Client.Assigned (Client, Cache (I).C)
               then
                  Block_Client.Release (Client, Cache (I).C);
                  Cache (I).A := False;
               end if;
               if Block_Client.Status (Cache (I).C) = Block.Raw then
                  Block_Server.Process (Server, Cache (I).S);
               end if;
            end if;
            if
               Block_Server.Status (Cache (I).S) = Block.Error
               and then Block_Server.Assigned (Server, Cache (I).S)
            then
               Block_Server.Acknowledge (Server, Cache (I).S, Block.Error);
            end if;
            if Block_Server.Status (Cache (I).S) = Block.Pending then
               if
                  Block_Client.Status (Cache (I).C) = Block.Pending
                  and then Block_Client.Assigned (Client, Cache (I).C)
               then
                  Block_Client.Update_Request (Client, Cache (I).C);
               end if;
               if
                  Block_Client.Status (Cache (I).C) in Block.Ok | Block.Error
                  and then Block_Client.Assigned (Client, Cache (I).C)
               then
                  if
                     Block_Client.Status (Cache (I).C) = Block.Ok
                     and then Block_Client.Kind (Cache (I).C) = Block.Read
                  then
                     Block_Client.Read (Client, Cache (I).C);
                  end if;
                  if Block_Server.Assigned (Server, Cache (I).S) then
                     Block_Server.Acknowledge (Server, Cache (I).S, Block_Client.Status (Cache (I).C));
                  end if;
               end if;
               if Block_Client.Status (Cache (I).C) = Block.Raw then
                  Block_Client.Allocate_Request (Client,
                                                 Cache (I).C,
                                                 Block_Server.Kind (Cache (I).S),
                                                 Block_Server.Start (Cache (I).S),
                                                 Block_Server.Length (Cache (I).S),
                                                 I,
                                                 Re);
                  case Re is
                     when Block.Success =>
                        Block_Client.Enqueue (Client, Cache (I).C);
                        null;
                     when Block.Retry =>
                        null;
                     when others =>
                        Cache (I).A := True;
                  end case;
               end if;
               if
                  Block_Client.Status (Cache (I).C) = Block.Allocated
                  and then Block_Client.Assigned (Client, Cache (I).C)
               then
                  Block_Client.Enqueue (Client, Cache (I).C);
                  null;
               end if;
            end if;
         end loop;
         Block_Client.Submit (Client);
         Block_Server.Unblock_Client (Server);
      end if;
   end Event;

   procedure Dispatch (I : in out Block.Dispatcher_Session;
                       C :        Block.Dispatcher_Capability)
   is
   begin
      if Block_Dispatcher.Valid_Session_Request (I, C)
         and then not Initialized (Server)
         and then not Block.Initialized (Server)
      then
         Block_Dispatcher.Session_Initialize (I, C, Server, 42);
         if Initialized (Server) and then Block.Initialized (Server) then
            Block_Dispatcher.Session_Accept (I, C, Server);
         end if;
      end if;
      Block_Dispatcher.Session_Cleanup (I, C, Server);
   end Dispatch;

   procedure Initialize_Server (S : in out Block.Server_Session;
                                L :        String;
                                B :        Block.Byte_Length)
   is
   begin
      if not Block.Initialized (Client) then
         if L = "blockdev2" then  --  Muen
            Block_Client.Initialize (Client, Capability, "blockdev1", 42, B);
         else  --  Genode
            Block_Client.Initialize (Client, Capability, L, 42, B);
         end if;
      end if;
      if Block.Initialized (Client) and then not Initialized (S) then
         Block_Client.Finalize (Client);
      end if;
   end Initialize_Server;

   procedure Finalize_Server (S : in out Block.Server_Session)
   is
      pragma Unreferenced (S);
   begin
      Block_Client.Finalize (Client);
   end Finalize_Server;

   function Block_Count (S : Block.Server_Session) return Block.Count
   is
      pragma Unreferenced (S);
   begin
      return Block.Block_Count (Client);
   end Block_Count;

   function Block_Size (S : Block.Server_Session) return Block.Size
   is
      pragma Unreferenced (S);
   begin
      return Block.Block_Size (Client);
   end Block_Size;

   function Writable (S : Block.Server_Session) return Boolean
   is
      pragma Unreferenced (S);
   begin
      return Block.Writable (Client);
   end Writable;

   function Initialized (S : Block.Server_Session) return Boolean is
      (Block.Initialized (Client)
       and then Block.Block_Size (Client) in 512 | 1024 | 2048 | 4096
       and then Block.Block_Count (Client) > 0
       and then Block.Block_Count (Client) < Block.Count'Last / (Block.Count (Block.Block_Size (Client)) / 512));

end Component;
