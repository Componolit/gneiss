
with System;
with Cxx.Block.Dispatcher;
with Cxx.Block.Server;
use all type System.Address;
use all type Cxx.Bool;

package body Cai.Block.Dispatcher
is

   function Create return Dispatcher_Session
   is
   begin
      return Dispatcher_Session' (Instance => Cxx.Block.Dispatcher.Constructor);
   end Create;

   procedure Initialize (D : in out Dispatcher_Session; C : in out Server.State)
   is
   begin
      Cxx.Block.Dispatcher.Initialize (D.Instance, Dispatch'Address, C'Address);
   end Initialize;

   procedure Finalize (D : in out Dispatcher_Session)
   is
   begin
      Cxx.Block.Dispatcher.Finalize (D.Instance);
   end Finalize;

   procedure Register (D : in out Dispatcher_Session) is
   begin
      Cxx.Block.Dispatcher.Announce (D.Instance);
   end Register;

   procedure Session_Request (D : in out Dispatcher_Session;
                              Valid : out Boolean;
                              Label : out String;
                              Last : out Natural)
   is
      Label_Address : constant System.Address := Cxx.Block.Dispatcher.Label_Content (D.Instance);
      Label_Length : constant Natural := Natural (Cxx.Block.Dispatcher.Label_Length (D.Instance));
   begin
      Valid := False;
      Label := (others => Character'Val (0));
      Last := 0;
      if
         Label_Address /= System.Null_Address
         and Label_Length <= Label'Length
      then
         declare
            Lbl : String (1 .. Label_Length)
            with Address => Label_Address;
         begin
            Valid := True;
            Label (Label'First .. Label'First + Lbl'Length - 1) := Lbl;
            Last := Label'First + Lbl'Length - 1;
         end;
      end if;
   end Session_Request;

   procedure Session_Accept (D : in out Dispatcher_Session;
                             I : in out Server_Session;
                             L : String;
                             S : in out Server.State)
   is
   begin
      Cxx.Block.Server.Initialize (I.Instance,
                                   Cxx.Block.Dispatcher.Session_Size (D.Instance),
                                   S'Address,
                                   Server.Event'Address,
                                   Server.Block_Count'Address,
                                   Server.Block_Size'Address,
                                   Server.Maximal_Transfer_Size'Address,
                                   Server.Writable'Address);
      Cxx.Block.Dispatcher.Session_Accept (D.Instance, I.Instance);
      Server.Initialize (I, L, S);
   end Session_Accept;

   procedure Session_Cleanup (D : in out Dispatcher_Session;
                              I : in out Server_Session)
   is
   begin
      if Cxx.Block.Dispatcher.Session_Cleanup (D.Instance, I.Instance) = 1 then
         Server.Finalize (I);
         Cxx.Block.Server.Finalize (I.Instance);
      end if;
   end Session_Cleanup;

end Cai.Block.Dispatcher;
