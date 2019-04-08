
with System;
with Cxx.Block.Dispatcher;
with Cxx.Block.Server;

use all type System.Address;
use all type Cxx.Bool;

package body Cai.Block.Dispatcher with
   SPARK_Mode => Off
is

   function Initialized (D : Dispatcher_Session) return Boolean
   is
   begin
      return D.Instance /= System.Null_Address;
   end Initialized;

   function Get_Instance (D : Dispatcher_Session) return Dispatcher_Instance
   is
   begin
      return Dispatcher_Instance (D.Instance);
   end Get_Instance;

   procedure Initialize (D   : out Dispatcher_Session;
                         Cap :     Cai.Types.Capability)
   is
   begin
      Cxx.Block.Dispatcher.Initialize (D.Instance, Cap, Dispatch'Address);
   end Initialize;

   procedure Finalize (D : in out Dispatcher_Session)
   is
   begin
      Cxx.Block.Dispatcher.Finalize (D.Instance);
   end Finalize;

   procedure Register (D : in out Dispatcher_Session)
   is
   begin
      Cxx.Block.Dispatcher.Announce (D.Instance);
   end Register;

   procedure Session_Request (D     : in out Dispatcher_Session;
                              Valid :    out Boolean;
                              Label :    out String;
                              Last  :    out Natural)
   is
      Label_Address : constant System.Address := Cxx.Block.Dispatcher.Label_Content (D.Instance);
      Label_Length  : constant Natural        := Natural (Cxx.Block.Dispatcher.Label_Length (D.Instance));
   begin
      Valid := False;
      Label := (others => Character'Val (0));
      Last  := 0;
      if
         Label_Address /= System.Null_Address
         and Label_Length <= Label'Length
      then
         declare
            Lbl : String (1 .. Label_Length)
            with Address => Label_Address;
         begin
            Valid                                               := True;
            Label (Label'First .. Label'First + Lbl'Length - 1) := Lbl;
            Last                                                := Label'First + Lbl'Length - 1;
         end;
      end if;
   end Session_Request;

   procedure Session_Accept (D : in out Dispatcher_Session;
                             I : in out Server_Session;
                             L :        String)
   is
   begin
      Serv.Initialize (Serv.Get_Instance (I), L);
      Cxx.Block.Server.Initialize (I.Instance,
                                   Cxx.Block.Dispatcher.Get_Capability (D.Instance),
                                   Cxx.Block.Dispatcher.Session_Size (D.Instance),
                                   Serv.Event'Address,
                                   Serv.Block_Count'Address,
                                   Serv.Block_Size'Address,
                                   Serv.Maximal_Transfer_Size'Address,
                                   Serv.Writable'Address);
      Cxx.Block.Dispatcher.Session_Accept (D.Instance, I.Instance);
   end Session_Accept;

   procedure Session_Cleanup (D : in out Dispatcher_Session;
                              I : in out Server_Session)
   is
   begin
      if
         Cxx.Block.Dispatcher.Session_Cleanup (D.Instance, I.Instance) = Cxx.Bool'Val (1)
      then
         Serv.Finalize (Serv.Get_Instance (I));
         Cxx.Block.Server.Finalize (I.Instance);
      end if;
   end Session_Cleanup;

end Cai.Block.Dispatcher;
