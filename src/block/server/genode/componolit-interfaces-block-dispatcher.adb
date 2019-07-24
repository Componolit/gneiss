
with System;
with Cxx.Block.Dispatcher;
with Cxx.Block.Server;
with Cxx.Genode;
use all type System.Address;
use all type Cxx.Bool;

package body Componolit.Interfaces.Block.Dispatcher
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

   function Instance (D : Dispatcher_Session) return Dispatcher_Instance
   is
   begin
      return Dispatcher_Instance (Cxx.Block.Dispatcher.Get_Instance (D.Instance));
   end Instance;

   procedure Initialize (D   : in out Dispatcher_Session;
                         Cap :        Componolit.Interfaces.Types.Capability) with
      SPARK_Mode => Off
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
                              Valid :    out Boolean)
   is
      use type Cxx.Genode.Uint64_T;
   begin
      Valid := Cxx.Block.Dispatcher.Label_Content (D.Instance, Cap.Instance) /= System.Null_Address
               and then Cxx.Block.Dispatcher.Label_Length (D.Instance, Cap.Instance) > 0;
   end Session_Request;

   procedure Session_Accept (D : in out Dispatcher_Session;
                             C :        Dispatcher_Capability;
                             I : in out Server_Session) with
      SPARK_Mode => Off
   is
      Label_Address : constant System.Address := Cxx.Block.Dispatcher.Label_Content (D.Instance, C.Instance);
      Label_Length  : constant Positive       := Positive (Cxx.Block.Dispatcher.Label_Length (D.Instance, C.Instance));
      Label : String (1 .. Label_Length) with
         Address => Label_Address;
   begin
      Serv.Initialize (Serv.Instance (I),
                       Label,
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
         Serv.Finalize (Serv.Instance (I));
         Cxx.Block.Server.Finalize (I.Instance);
      end if;
   end Session_Cleanup;

end Componolit.Interfaces.Block.Dispatcher;
