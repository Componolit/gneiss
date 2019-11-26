
with Gneiss.Linker;
with System;
with Componolit.Runtime.Debug;
with Gneiss.Internal.Types;

package body Gneiss.Main with
   SPARK_Mode
is

   function Create_Cap (Fd : Integer) return Gneiss.Internal.Types.Capability;
   procedure Set_Status (S : Integer);
   procedure Construct (Symbol     : System.Address;
                        Capability : Gneiss.Internal.Types.Capability);
   procedure Destruct (Symbol : System.Address);

   Running : constant Integer := -1;
   Success : constant Integer := 0;
   Failure : constant Integer := 1;
   Component_Status : Integer := Running;

   procedure Run (Name       :     String;
                  Fd         :     Integer;
                  Status     : out Integer)
   is
      use type System.Address;
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
      Construct (Construct_Sym, Capability);
      while Component_Status = Running loop
         null;
      end loop;
      Destruct (Destruct_Sym);
      Status := Component_Status;
   end Run;

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
