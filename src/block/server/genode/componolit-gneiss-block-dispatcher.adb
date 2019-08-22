
with System;
with Cxx.Genode;
with Cxx.Block.Dispatcher;
with Cxx.Block.Server;
use all type System.Address;
use all type Cxx.Bool;

package body Componolit.Gneiss.Block.Dispatcher with
   SPARK_Mode
is

   function Dispatch_Address return System.Address;

   function Dispatch_Address return System.Address with
      SPARK_Mode => Off
   is
   begin
      return Dispatch'Address;
   end Dispatch_Address;

   procedure Initialize (D   : in out Dispatcher_Session;
                         Cap :        Componolit.Gneiss.Types.Capability;
                         Tag :        Session_Id)
   is
   begin
      Cxx.Block.Dispatcher.Initialize (D.Instance, Cap, Dispatch_Address);
      if Initialized (D) then
         D.Instance.Tag := Session_Id'Pos (Tag);
      end if;
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

   function Internal_Writable (S : Server_Session) return Cxx.Bool is
      (if Serv.Writable (S) then Cxx.Bool'Val (1) else Cxx.Bool'Val (0)) with
         Pre => Initialized (S);

   function Serv_Event_Address return System.Address;
   function Serv_Block_Count_Address return System.Address;
   function Serv_Block_Size_Address return System.Address;
   function Serv_Writable_Address return System.Address;

   function Serv_Event_Address return System.Address with
      SPARK_Mode => Off
   is
   begin
      return Serv.Event'Address;
   end Serv_Event_Address;

   function Serv_Block_Count_Address return System.Address with
      SPARK_Mode => Off
   is
   begin
      return Serv.Block_Count'Address;
   end Serv_Block_Count_Address;

   function Serv_Block_Size_Address return System.Address with
      SPARK_Mode => Off
   is
   begin
      return Serv.Block_Size'Address;
   end Serv_Block_Size_Address;

   function Serv_Writable_Address return System.Address with
      SPARK_Mode => Off
   is
   begin
      return Internal_Writable'Address;
   end Serv_Writable_Address;

   procedure Session_Initialize (D : in out Dispatcher_Session;
                                 C :        Dispatcher_Capability;
                                 S : in out Server_Session;
                                 I :        Session_Id)
   is
      Label_Address : constant System.Address := Cxx.Block.Dispatcher.Label_Content (D.Instance, C.Instance);
      Label_Length  : constant Natural       := Natural (Cxx.Block.Dispatcher.Label_Length (D.Instance, C.Instance));
      Label : String (1 .. Label_Length) with
         Address => Label_Address;
   begin
      S.Instance.Tag := Cxx.Genode.Uint32_T'Val (Session_Id'Pos (I) - Session_Id'Pos (Session_Id'First));
      if Label_Length = 0 then
         Serv.Initialize (S,
                          "",
                          Byte_Length (Cxx.Block.Dispatcher.Session_Size (D.Instance, C.Instance)));
      else
         Serv.Initialize (S,
                          Label,
                          Byte_Length (Cxx.Block.Dispatcher.Session_Size (D.Instance, C.Instance)));
      end if;
      if not Serv.Ready (S) then
         return;
      end if;
      Cxx.Block.Server.Initialize (S.Instance,
                                   Cxx.Block.Dispatcher.Get_Capability (D.Instance),
                                   Cxx.Block.Dispatcher.Session_Size (D.Instance, C.Instance),
                                   Serv_Event_Address,
                                   Serv_Block_Count_Address,
                                   Serv_Block_Size_Address,
                                   Serv_Writable_Address);
      if not Initialized (S) then
         Serv.Finalize (S);
      end if;
   end Session_Initialize;

   procedure Session_Accept (D : in out Dispatcher_Session;
                             C :        Dispatcher_Capability;
                             S : in out Server_Session)
   is
   begin
      Cxx.Block.Dispatcher.Session_Accept (D.Instance, C.Instance, S.Instance);
   end Session_Accept;

   procedure Session_Cleanup (D : in out Dispatcher_Session;
                              C :        Dispatcher_Capability;
                              S : in out Server_Session)
   is
   begin
      if
         Cxx.Block.Dispatcher.Session_Cleanup (D.Instance, C.Instance, S.Instance) = Cxx.Bool'Val (1)
      then
         Serv.Finalize (S);
         Cxx.Block.Server.Finalize (S.Instance);
      end if;
   end Session_Cleanup;

   procedure Lemma_Dispatch (D : in out Dispatcher_Session;
                             C :        Dispatcher_Capability)
   is
   begin
      Dispatch (D, C);
   end Lemma_Dispatch;

end Componolit.Gneiss.Block.Dispatcher;
