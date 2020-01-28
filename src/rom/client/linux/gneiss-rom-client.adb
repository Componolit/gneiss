
with System;
with Gneiss.Protocol;
with Gneiss_Platform;
with Gneiss_Syscall;
with RFLX.Session;

package body Gneiss.Rom.Client with
   SPARK_Mode
is

   type RFLX_String is array (RFLX.Session.Length_Type range <>) of Character;
   package Proto is new Gneiss.Protocol (Character, RFLX_String);

   procedure Init (Session : in out Client_Session;
                   Label   :        String;
                   Success :        Boolean;
                   Fd      :        Integer);

   function Init_Cap is new Gneiss_Platform.Create_Initializer_Cap (Client_Session, Init);

   procedure Init (Session : in out Client_Session;
                   Label   :        String;
                   Success :        Boolean;
                   Fd      :        Integer)
   is
      use type System.Address;
   begin
      if Label /= Session.Label.Value (Session.Label.Value'First .. Session.Label.Last) then
         return;
      end if;
      if Success then
         Session.Fd := Fd;
         Gneiss_Syscall.Mmap (Session.Fd, Session.Map, Boolean'Pos (False));
         if Session.Map = System.Null_Address then
            Session.Index := Session_Index_Option'(Valid => False);
            Gneiss_Syscall.Close (Session.Fd);
         end if;
      else
         Session.Index := Session_Index_Option'(Valid => False);
      end if;
      Event;
   end Init;

   procedure Initialize (Session : in out Client_Session;
                         Cap     :        Gneiss.Capability;
                         Label   :        String;
                         Idx     :        Session_Index := 1)
   is
      Succ : Boolean;
   begin
      if
         Status (Session) in Initialized | Pending
         or else Label'Length > 255
      then
         return;
      end if;
      Session.Index      := Session_Index_Option'(Valid => True, Value => Idx);
      Session.Label.Last := Session.Label.Value'First + Label'Length - 1;
      Session.Label.Value (Session.Label.Value'First .. Session.Label.Last) := Label;
      Gneiss_Platform.Call (Cap.Register_Initializer,
                            Init_Cap (Session),
                            RFLX.Session.Rom,
                            Succ);
      if not Succ then
         Init (Session, Label, False, -1);
         return;
      end if;
      declare
         C_Label : RFLX_String (RFLX.Session.Length_Type (Label'First)
                                .. RFLX.Session.Length_Type (Label'Last));
      begin
         for I in Label'Range loop
            C_Label (RFLX.Session.Length_Type (I)) := Label (I);
         end loop;
         Proto.Send_Message (Cap.Broker_Fd,
                             Proto.Message'(Length      => C_Label'Length,
                                            Action      => RFLX.Session.Request,
                                            Kind        => RFLX.Session.Rom,
                                            Name_Length => 0,
                                            Payload     => C_Label));
      end;
   end Initialize;

   procedure Update (Session : in out Client_Session)
   is
      Size  : constant Integer      := Gneiss_Syscall.Stat_Size (Session.Fd);
      First : constant Buffer_Index := Buffer_Index'First;
      Last  : constant Buffer_Index := Buffer_Index (Long_Integer (First) + Long_Integer (Size - 1));
      Buf   : Buffer (First .. Last) with
         Import,
         Address => Session.Map;
   begin
      Read (Session, Buf);
   end Update;

   procedure Finalize (Session : in out Client_Session)
   is
   begin
      if Status (Session) = Uninitialized then
         return;
      end if;
      Gneiss_Syscall.Munmap (Session.Fd, Session.Map);
      Gneiss_Syscall.Close (Session.Fd);
      Session.Index := Session_Index_Option'(Valid => False);
   end Finalize;

end Gneiss.Rom.Client;
