
with RFLX.Types;
with Gneiss.Syscall;
with Gneiss_Epoll;
with Gneiss.Linker;

package Gneiss.Main with
   SPARK_Mode,
   Abstract_State => Component_State,
   Initializes    => Component_State
is

   procedure Run (Name   :     String;
                  Fd     :     Integer;
                  Status : out Integer) with
      Global => (In_Out => (Component_State,
                            Gneiss.Syscall.Linux,
                            Gneiss_Epoll.Linux,
                            Gneiss.Linker.Linux));

   procedure Peek_Message (Socket    :     Integer;
                           Message   : out RFLX.Types.Bytes;
                           Last      : out RFLX.Types.Index;
                           Truncated : out Boolean;
                           Fd        : out Integer) with
      Global => (In_Out => Gneiss.Syscall.Linux);

end Gneiss.Main;
