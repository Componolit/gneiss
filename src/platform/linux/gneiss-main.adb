
with Gneiss.Epoll;
with Gneiss.Linker;
with Gneiss.Internal.Types;
with System;
with Componolit.Runtime.Debug;

package body Gneiss.Main with
   SPARK_Mode
is
   use type Gneiss.Epoll.Epoll_Fd;
   use type System.Address;

   function Create_Cap (Fd : Integer) return Gneiss.Internal.Types.Capability;
   procedure Set_Status (S : Integer);
   procedure Event_Handler;
   procedure Call_Event (Fp : System.Address) with
      Pre => Fp /= System.Null_Address;
   procedure Construct (Symbol     : System.Address;
                        Capability : Gneiss.Internal.Types.Capability);
   procedure Destruct (Symbol : System.Address);

   Running : constant Integer := -1;
   Success : constant Integer := 0;
   Failure : constant Integer := 1;

   Component_Status : Integer               := Running;
   Epoll_Fd         : Gneiss.Epoll.Epoll_Fd := -1;

   procedure Call_Event (Fp : System.Address)
   is
      procedure Event with
         Import,
         Address => Fp;
   begin
      Event;
   end Call_Event;

   procedure Run (Name       :     String;
                  Fd         :     Integer;
                  Status     : out Integer)
   is
      use type Gneiss.Linker.Dl_Handle;
      Capability    : constant Gneiss.Internal.Types.Capability := Create_Cap (Fd);
      Handle        : Gneiss.Linker.Dl_Handle;
      Construct_Sym : System.Address;
      Destruct_Sym  : System.Address;
   begin
      Componolit.Runtime.Debug.Log_Debug ("Main: " & Name);
      Gneiss.Linker.Open (Name, Handle);
      if Handle = Gneiss.Linker.Invalid_Handle then
         Componolit.Runtime.Debug.Log_Error ("Linker handle failed");
         Status := 1;
         return;
      end if;
      Construct_Sym := Gneiss.Linker.Symbol (Handle, "component__construct");
      Destruct_Sym  := Gneiss.Linker.Symbol (Handle, "component__destruct");
      if
         Construct_Sym = System.Null_Address
         or else Destruct_Sym = System.Null_Address
      then
         Componolit.Runtime.Debug.Log_Error ("Linker symbols failed");
         Status := 1;
         return;
      end if;
      Gneiss.Epoll.Create (Epoll_Fd);
      if Epoll_Fd < 0 then
         Componolit.Runtime.Debug.Log_Error ("Epoll creation failed");
         Status := 1;
         return;
      end if;
      Gneiss.Epoll.Add (Epoll_Fd, Fd, System.Null_Address, Status);
      if Status /= 0 then
         Componolit.Runtime.Debug.Log_Error ("Failed to add epoll fd");
         Status := 1;
         return;
      end if;
      Construct (Construct_Sym, Capability);
      while Component_Status = Running loop
         Event_Handler;
      end loop;
      Destruct (Destruct_Sym);
      Status := Component_Status;
   end Run;

   procedure Event_Handler
   is
      Event_Ptr : System.Address;
      Event     : Gneiss.Epoll.Event;
   begin
      Gneiss.Epoll.Wait (Epoll_Fd, Event, Event_Ptr);
      if Event.Epoll_In then
         Componolit.Runtime.Debug.Log_Debug ("Received event");
         if Event_Ptr /= System.Null_Address then
            Call_Event (Event_Ptr);
         end if;
      end if;
   end Event_Handler;

   function Create_Cap (Fd : Integer) return Gneiss.Internal.Types.Capability with
      SPARK_Mode => Off
   is
   begin
      return Gneiss.Internal.Types.Capability'(Filedesc   => Fd,
                                               Set_Status => Set_Status'Address);
   end Create_Cap;

   procedure Set_Status (S : Integer)
   is
   begin
      Component_Status := (if S = 0 then Success else Failure);
   end Set_Status;

   procedure Construct (Symbol     : System.Address;
                        Capability : Gneiss.Internal.Types.Capability)
   is
      procedure Component_Construct (C : Gneiss.Internal.Types.Capability) with
         Import,
         Address => Symbol;
   begin
      Component_Construct (Capability);
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
