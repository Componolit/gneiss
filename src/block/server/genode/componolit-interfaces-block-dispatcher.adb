
with System;
with Cxx.Block.Dispatcher;
with Cxx.Block.Server;
use all type System.Address;
use all type Cxx.Bool;

package body Componolit.Interfaces.Block.Dispatcher with
   SPARK_Mode => Off
is

   function Create return Dispatcher_Session
   is
   begin
      return Dispatcher_Session'(Instance => Cxx.Block.Dispatcher.Constructor);
   end Create;

   function Initialized (D : Dispatcher_Session) return Boolean
   is
   begin
      return Cxx.Block.Dispatcher.Initialized (D.Instance) = Cxx.Bool'Val (1);
   end Initialized;

   function Get_Instance (D : Dispatcher_Session) return Dispatcher_Instance
   is
   begin
      return Dispatcher_Instance (Cxx.Block.Dispatcher.Get_Instance (D.Instance));
   end Get_Instance;

   procedure Initialize (D   : in out Dispatcher_Session;
                         Cap :        Componolit.Interfaces.Types.Capability)
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
                              Cap   :        Dispatcher_Capability;
                              Valid :    out Boolean;
                              Label :    out String;
                              Last  :    out Natural)
   is
      Label_Address : constant System.Address :=
         Cxx.Block.Dispatcher.Label_Content (D.Instance, Cap.Instance);
      Label_Length  : Natural;
   begin
      Valid := False;
      Label := (others => Character'Val (0));
      Last  := 0;
      if Label_Address /= System.Null_Address then
         Label_Length := Natural (Cxx.Block.Dispatcher.Label_Length (D.Instance, Cap.Instance));
         if
            Label_Length <= Label'Length
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
      end if;
   end Session_Request;

   procedure Session_Accept (D : in out Dispatcher_Session;
                             C :        Dispatcher_Capability;
                             I : in out Server_Session;
                             L :        String)
   is
   begin
      Serv.Initialize (Serv.Get_Instance (I),
                       L,
                       Byte_Length (Cxx.Block.Dispatcher.Session_Size (D.Instance, C.Instance)));
      Cxx.Block.Server.Initialize (I.Instance,
                                   Cxx.Block.Dispatcher.Get_Capability (D.Instance),
                                   Cxx.Block.Dispatcher.Session_Size (D.Instance, C.Instance),
                                   Serv.Event'Address,
                                   Serv.Block_Count'Address,
                                   Serv.Block_Size'Address,
                                   Serv.Maximum_Transfer_Size'Address,
                                   Serv.Writable'Address);
      Cxx.Block.Dispatcher.Session_Accept (D.Instance, C.Instance, I.Instance);
   end Session_Accept;

   procedure Session_Cleanup (D : in out Dispatcher_Session;
                              C :        Dispatcher_Capability;
                              I : in out Server_Session)
   is
   begin
      if
         Cxx.Block.Dispatcher.Session_Cleanup (D.Instance, C.Instance, I.Instance) = Cxx.Bool'Val (1)
      then
         Serv.Finalize (Serv.Get_Instance (I));
         Cxx.Block.Server.Finalize (I.Instance);
      end if;
   end Session_Cleanup;

end Componolit.Interfaces.Block.Dispatcher;
