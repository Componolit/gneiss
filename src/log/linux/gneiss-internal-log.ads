with Gneiss.Message;

package Gneiss.Internal.Log is

   type Unsigned_Character is mod 2 ** 8;
   type Message_String is array (Positive range <>) of Unsigned_Character;
   Message_Size : constant := 4096;

   type Client_Session is limited record
      Session : Gneiss.Message.Writer_Session;
      Buffer  : Message_String (1 .. Message_Size) := (others => 0);
      Cursor  : Positive := 1;
   end record;

end Gneiss.Internal.Log;
