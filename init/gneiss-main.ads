
with RFLX.Types;
with Gneiss_Syscall;
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
                            Gneiss_Syscall.Linux,
                            Gneiss_Epoll.Linux,
                            Gneiss.Linker.Linux));

   procedure Peek_Message (Socket    :     Integer;
                           Message   : out RFLX.Types.Bytes;
                           Last      : out RFLX.Types.Index;
                           Truncated : out Boolean;
                           Fd        : out Gneiss_Syscall.Fd_Array) with
      Global => (In_Out => Gneiss_Syscall.Linux);

end Gneiss.Main;
