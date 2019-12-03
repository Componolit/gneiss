
with RFLX.Types;

package Gneiss.Main with
   SPARK_Mode
is

   procedure Run (Name       :     String;
                  Fd         :     Integer;
                  Status     : out Integer);

   procedure Peek_Message (Socket    :     Integer;
                           Message   : out RFLX.Types.Bytes;
                           Last      : out RFLX.Types.Index;
                           Truncated : out Boolean;
                           Fd        : out Integer);

end Gneiss.Main;
