
with Componolit.Gneiss.Message;
with Componolit.Gneiss.Message.Reader;
with Componolit.Gneiss.Strings;

package body Component with
   SPARK_Mode
is

   type Unsigned_Char is mod 2 ** 8;
   type C_String is array (Positive range <>) of Unsigned_Char;

   procedure Event;

   package Message_Client is new Gns.Message.Reader (Unsigned_Char, Positive, C_String, 4096, Event);

   type Client_Registry is array (Integer range <>) of Gns.Message.Reader_Session;

   Client  : Client_Registry (1 .. 3);
   Message : Message_Client.Message_Buffer;
   M_Str   : String (1 .. 4097);

   procedure Construct (Cap : Gns.Types.Capability)
   is
   begin
      for I in Client'Range loop
         Message_Client.Initialize (Client (I), Cap, Gns.Strings.Image (I));
      end loop;
   end Construct;

   procedure Destruct
   is
   begin
      for I in Client'Range loop
         Message_Client.Finalize (Client (I));
      end loop;
   end Destruct;

   procedure Check_And_Print (I : Integer);

   procedure Check_And_Print (I : Integer)
   is
      procedure Print (S1 : in out String;
                       S2 : in out String) with
         Import,
         Convention => C,
         External_Name => "print_message";
      Label : String := Gns.Strings.Image (I) & Character'First;
   begin
      if
         Gns.Message.Initialized (Client (I))
         and then Message_Client.Available (Client (I))
      then
         Message_Client.Read (Client (I), Message);
         for I in Message'Range loop
            M_Str (I) := Character'Val (Message (I));
         end loop;
         M_Str (M_Str'Last) := Character'First;
         Print (Label, M_Str);
      end if;
   end Check_And_Print;

   procedure Event
   is
   begin
      for I in Client'Range loop
         Check_And_Print (I);
      end loop;
   end Event;

end Component;
