
with Gneiss_Internal.Print;
with Gneiss_Internal.Epoll;
with Gneiss_Internal.Linker;
with System;

package body Gneiss.Main with
   SPARK_Mode
is
   use type Gneiss_Internal.Epoll_Fd;
   use type System.Address;

   subtype Status_Code is Integer range -1 .. 255;

   Running : constant Integer := -1;
   Success : constant Integer := 0;
   Failure : constant Integer := 1;

   Component_Status : Status_Code           := Running;
   Epoll_Fd         : Gneiss_Internal.Epoll_Fd := -1;

   procedure Event_Handler with
      Pre  => Gneiss_Internal.Valid (Epoll_Fd),
      Post => Gneiss_Internal.Valid (Epoll_Fd);

   procedure Set_Status (S : Integer) with
      Global => (Output => Component_Status);

   function Set_Status_Cap is new Gneiss_Internal.Create_Set_Status_Cap (Set_Status);

   procedure Construct (Symbol : System.Address;
                        Cap    : Capability) with
      Pre => Symbol /= System.Null_Address;

   procedure Destruct (Symbol : System.Address) with
      Pre => Symbol /= System.Null_Address;

   procedure Call_Event (Fp : System.Address;
                         Ev : Gneiss_Internal.Event_Type) with
      Pre => Fp /= System.Null_Address;

   function Create_Cap (Fd : Gneiss_Internal.File_Descriptor) return Capability is
      (Capability'(Broker_Fd  => Fd,
                   Set_Status => Set_Status_Cap,
                   Efd        => Epoll_Fd));

   procedure Call_Event (Fp : System.Address;
                         Ev : Gneiss_Internal.Event_Type)
   is
      Cap : Gneiss_Internal.Event_Cap with
         Import,
         Address => Fp;
   begin
      Gneiss_Internal.Call (Cap, Ev);
   end Call_Event;

   procedure Run (Name   :     String;
                  Fd     :     Gneiss_Internal.File_Descriptor;
                  Status : out Broker.Return_Code)
   is
      use type Gneiss_Internal.Linker.Dl_Handle;
      Handle        : Gneiss_Internal.Linker.Dl_Handle;
      Construct_Sym : System.Address;
      Destruct_Sym  : System.Address;
   begin
      Gneiss_Internal.Linker.Open (Name, Handle);
      if Handle = Gneiss_Internal.Linker.Invalid_Handle then
         Gneiss_Internal.Print.Error ("Linker handle failed");
         Status := 1;
         return;
      end if;
      Construct_Sym := Gneiss_Internal.Linker.Symbol (Handle, "component__construct");
      Destruct_Sym  := Gneiss_Internal.Linker.Symbol (Handle, "component__destruct");
      if
         Construct_Sym = System.Null_Address
         or else Destruct_Sym = System.Null_Address
      then
         Gneiss_Internal.Print.Error ("Linker symbols failed");
         Status := 1;
         return;
      end if;
      Gneiss_Internal.Epoll.Create (Epoll_Fd);
      if not Gneiss_Internal.Valid (Epoll_Fd) then
         Gneiss_Internal.Print.Error ("Epoll creation failed");
         Status := 1;
         return;
      end if;
      Construct (Construct_Sym, Create_Cap (Fd));
      while Component_Status = Running loop
         Event_Handler;
      end loop;
      Destruct (Destruct_Sym);
      Status := Component_Status;
   end Run;

   procedure Event_Handler
   is
      Event_Ptr : System.Address;
      Event     : Gneiss_Internal.Epoll.Event;
   begin
      Gneiss_Internal.Epoll.Wait (Epoll_Fd, Event, Event_Ptr);
      if Event_Ptr /= System.Null_Address then
         Call_Event (Event_Ptr, Gneiss_Internal.Epoll.Get_Type (Event));
      end if;
   end Event_Handler;

   procedure Set_Status (S : Integer)
   is
   begin
      Component_Status := (if S = 0 then Success else Failure);
   end Set_Status;

   procedure Construct (Symbol : System.Address;
                        Cap    : Capability)
   is
      procedure Component_Construct (C : Capability) with
         Import,
         Address => Symbol;
   begin
      Component_Construct (Cap);
   end Construct;

   procedure Destruct (Symbol : System.Address)
   is
      procedure Component_Destruct with
         Import,
         Address => Symbol;
   begin
      Component_Destruct;
   end Destruct;

end Gneiss.Main;
