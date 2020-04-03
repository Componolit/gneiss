
with Gneiss_Platform;
with Gneiss_Log;
with Gneiss_Epoll;
with Gneiss.Linker;
with System;

package body Gneiss.Main with
   SPARK_Mode
is
   use type Gneiss_Epoll.Epoll_Fd;
   use type System.Address;

   subtype Status_Code is Integer range -1 .. 255;

   Running : constant Integer := -1;
   Success : constant Integer := 0;
   Failure : constant Integer := 1;

   Component_Status : Status_Code           := Running;
   Epoll_Fd         : Gneiss_Epoll.Epoll_Fd := -1;

   procedure Event_Handler with
      Pre  => Gneiss_Epoll.Valid_Fd (Epoll_Fd),
      Post => Gneiss_Epoll.Valid_Fd (Epoll_Fd);
   procedure Set_Status (S : Integer) with
      Global => (Output => Component_Status);
   function Set_Status_Cap is new Gneiss_Platform.Create_Set_Status_Cap (Set_Status);
   procedure Construct (Symbol : System.Address;
                        Cap    : Capability) with
      Pre => Symbol /= System.Null_Address;
   procedure Destruct (Symbol : System.Address) with
      Pre => Symbol /= System.Null_Address;
   procedure Call_Event (Fp : System.Address;
                         Ev : Gneiss_Epoll.Event_Type) with
      Pre => Fp /= System.Null_Address;

   function Create_Cap (Fd : Integer) return Capability is
      (Capability'(Broker_Fd            => Fd,
                   Set_Status           => Set_Status_Cap,
                   Epoll_Fd             => Epoll_Fd));

   procedure Call_Event (Fp : System.Address;
                         Ev : Gneiss_Epoll.Event_Type)
   is
      Cap : Gneiss_Platform.Event_Cap with
         Import,
         Address => Fp;
   begin
      Gneiss_Platform.Call (Cap, Ev);
   end Call_Event;

   procedure Run (Name   :     String;
                  Fd     :     Integer;
                  Status : out Broker.Return_Code)
   is
      use type Gneiss.Linker.Dl_Handle;
      Handle        : Gneiss.Linker.Dl_Handle;
      Construct_Sym : System.Address;
      Destruct_Sym  : System.Address;
   begin
      Gneiss.Linker.Open (Name, Handle);
      if Handle = Gneiss.Linker.Invalid_Handle then
         Gneiss_Log.Error ("Linker handle failed");
         Status := 1;
         return;
      end if;
      Construct_Sym := Gneiss.Linker.Symbol (Handle, "component__construct");
      Destruct_Sym  := Gneiss.Linker.Symbol (Handle, "component__destruct");
      if
         Construct_Sym = System.Null_Address
         or else Destruct_Sym = System.Null_Address
      then
         Gneiss_Log.Error ("Linker symbols failed");
         Status := 1;
         return;
      end if;
      Gneiss_Epoll.Create (Epoll_Fd);
      if Epoll_Fd < 0 then
         Gneiss_Log.Error ("Epoll creation failed");
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
      Event     : Gneiss_Epoll.Event;
   begin
      Gneiss_Epoll.Wait (Epoll_Fd, Event, Event_Ptr);
      if Event_Ptr /= System.Null_Address then
         Call_Event (Event_Ptr, Gneiss_Epoll.Get_Type (Event));
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
