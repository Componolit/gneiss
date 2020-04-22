
with Gneiss_Internal.Linux;

package body Gneiss_Internal.Epoll with
   SPARK_Mode
is

   procedure Create (Efd : out Epoll_Fd)
   is
   begin
      Linux.Create (Efd);
   end Create;

   procedure Add (Efd     :     Epoll_Fd;
                  Fd      :     File_Descriptor;
                  Index   :     Integer;
                  Success : out Boolean)
   is
      Result : Integer;
   begin
      Linux.Add (Efd, Fd, Index, Result);
      Success := Result = 0;
   end Add;

   procedure Add (Efd     :     Epoll_Fd;
                  Fd      :     File_Descriptor;
                  Ptr     :     System.Address;
                  Success : out Boolean)
   is
      Result : Integer;
   begin
      Linux.Add (Efd, Fd, Ptr, Result);
      Success := Result = 0;
   end Add;

   procedure Remove (Efd     :     Epoll_Fd;
                     Fd      :     File_Descriptor;
                     Success : out Boolean)
   is
      Result : Integer;
   begin
      Linux.Remove (Efd, Fd, Result);
      Success := Result = 0;
   end Remove;

   procedure Wait (Efd   :     Epoll_Fd;
                   Ev    : out Event;
                   Index : out Integer)
   is
   begin
      Linux.Wait (Efd, Ev, Index);
   end Wait;

   procedure Wait (Efd :     Epoll_Fd;
                   Ev  : out Event;
                   Ptr : out System.Address)
   is
   begin
      Linux.Wait (Efd, Ev, Ptr);
   end Wait;

end Gneiss_Internal.Epoll;
