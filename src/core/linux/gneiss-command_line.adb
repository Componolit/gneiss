
with System;
with Gneiss_Internal.Libc;

package body Gneiss.Command_Line with
   SPARK_Mode => Off
is

   type Ptr_List is array (Natural range <>) of System.Address;

   Argc : Natural with
      Import,
      Convention    => C,
      External_Name => "gnat_argc";

   Argv : System.Address with
      Import,
      Convention => C,
      External_Name => "gnat_argv";

   Argvl : Ptr_List (0 .. Argc - 1) with
      Import,
      Address => Argv;

   function Argument_Count return Natural is
      (Argc);

   function Argument (Number : Natural) return String
   is
      Arg : String (1 .. Gneiss_Internal.Libc.Strlen (Argvl (Number))) with
         Import,
         Address => Argvl (Number);
   begin
      return Arg;
   end Argument;

end Gneiss.Command_Line;
