
with System;
with Cxx.Block.Dispatcher;
with Cxx.Block.Server;
use all type System.Address;
use all type Cxx.Bool;

package body Componolit.Interfaces.Block.Dispatcher
is

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

   function Valid_Session_Request (D : Dispatcher_Session;
                                   C : Dispatcher_Capability) return Boolean
   is
   begin
      return Cxx.Block.Dispatcher.Label_Content (D.Instance, C.Instance) /= System.Null_Address;
   end Valid_Session_Request;

   function Internal_Block_Count (S : Server_Session) return Count is
      (Serv.Block_Count (Instance (S)));

   function Internal_Block_Size (S : Server_Session) return Size is
      (Serv.Block_Size (Instance (S)));

   function Internal_Writable (S : Server_Session) return Cxx.Bool is
      (if Serv.Writable (Instance (S)) then Cxx.Bool'Val (1) else Cxx.Bool'Val (0));

   procedure Session_Initialize (D : in out Dispatcher_Session;
                                 C :        Dispatcher_Capability;
                                 I : in out Server_Session) with
      SPARK_Mode => Off
   is
      Label_Address : constant System.Address := Cxx.Block.Dispatcher.Label_Content (D.Instance, C.Instance);
      Label_Length  : constant Natural       := Natural (Cxx.Block.Dispatcher.Label_Length (D.Instance, C.Instance));
      Label : String (1 .. Label_Length) with
         Address => Label_Address;
   begin
      if Label_Length = 0 then
         Serv.Initialize (Instance (I),
                          "",
                          Byte_Length (Cxx.Block.Dispatcher.Session_Size (D.Instance, C.Instance)));
      else
         Serv.Initialize (Instance (I),
                          Label,
                          Byte_Length (Cxx.Block.Dispatcher.Session_Size (D.Instance, C.Instance)));
      end if;
      if not Serv.Ready (Instance (I)) then
         return;
      end if;
      Cxx.Block.Server.Initialize (I.Instance,
                                   Cxx.Block.Dispatcher.Get_Capability (D.Instance),
                                   Cxx.Block.Dispatcher.Session_Size (D.Instance, C.Instance),
                                   Serv.Event'Address,
                                   Internal_Block_Count'Address,
                                   Internal_Block_Size'Address,
                                   Internal_Writable'Address);
      if not Initialized (I) then
         Serv.Finalize (Instance (I));
      end if;
   end Session_Initialize;

   procedure Session_Accept (D : in out Dispatcher_Session;
                             C :        Dispatcher_Capability;
                             I : in out Server_Session)
   is
   begin
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
         Serv.Finalize (Instance (I));
         Cxx.Block.Server.Finalize (I.Instance);
      end if;
   end Session_Cleanup;

   procedure Lemma_Dispatch (D : Dispatcher_Instance;
                             C : Dispatcher_Capability)
   is
   begin
      Dispatch (D, C);
   end Lemma_Dispatch;

end Componolit.Interfaces.Block.Dispatcher;
