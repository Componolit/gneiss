with Cxx.Genode;

package Cxx.Block
   with SPARK_Mode => On
is
   package Client
      with SPARK_Mode => On
   is
      type Kind is (None, Read, Write, Sync)
      with Size => Cxx.Unsigned_Int'Size;
      for Kind use (None => 0, Read => 1, Write => 2, Sync => 3);
      type Status is (Raw, Ok, Error, Ack)
      with Size => Cxx.Unsigned_Int'Size;
      for Status use (Raw => 0, Ok => 1, Error => 2, Ack => 3);

      package Request
         with SPARK_Mode => On
      is
         type Class is
         record
            Kind : Cxx.Block.Client.Kind;
            Uid : Cxx.Genode.Uint8_T_Array (1 .. 16);
            Start : Cxx.Genode.Uint64_T;
            Length : Cxx.Genode.Uint64_T;
            Status : Cxx.Block.Client.Status;
         end record;
         pragma Convention (C_Pass_By_Copy, Class);

         type Class_Address is private;
         type Class_Array is array (Natural range <>) of Class;
         type Class_Address_Array is array (Natural range <>) of Class_Address;

      private
         pragma SPARK_Mode (Off);

         type Class_Address is access Class;

      end Request;
      type Private_Uint64_T is limited private;
      type Private_Uint64_T_Address is limited private;
      type Private_Uint64_T_Array is array (Natural range <>) of Private_Uint64_T;
      type Private_Uint64_T_Address_Array is array (Natural range <>) of Private_Uint64_T_Address;

      type Class is
      limited record
         Private_X_Device : Private_Uint64_T;
      end record
      with Import, Convention => CPP;

      type Class_Address is private;
      type Class_Array is array (Natural range <>) of Class;
      type Class_Address_Array is array (Natural range <>) of Class_Address;

      function Constructor return Class
      with Global => null;
      pragma Cpp_Constructor (Constructor, "_ZN5Block6ClientC1Ev");

      procedure Initialize (This : Class; Device : Cxx.Char_Array)
      with Global => null, Import, Convention => CPP, External_Name => "_ZN5Block6Client10initializeEPKc";

      procedure Finalize (This : Class)
      with Global => null, Import, Convention => CPP, External_Name => "_ZN5Block6Client8finalizeEv";

      procedure Submit_Read (This : Class; Req : Cxx.Block.Client.Request.Class)
      with Global => null, Import, Convention => CPP, External_Name => "_ZN5Block6Client11submit_readENS0_7RequestE";

      procedure Submit_Sync (This : Class; Req : Cxx.Block.Client.Request.Class)
      with Global => null, Import, Convention => CPP, External_Name => "_ZN5Block6Client11submit_syncENS0_7RequestE";

      procedure Submit_Write (This : Class; Req : Cxx.Block.Client.Request.Class; Data : in out Cxx.Genode.Uint8_T_Array; Length : Cxx.Genode.Uint64_T)
      with Global => null, Import, Convention => CPP, External_Name => "_ZN5Block6Client12submit_writeENS0_7RequestEPhy";

      function Next (This : Class) return Cxx.Block.Client.Request.Class
      with Global => null, Import, Convention => CPP, External_Name => "_ZN5Block6Client4nextEv";

      procedure Read (This : Class; Req : in out Cxx.Block.Client.Request.Class; Data : in out Cxx.Genode.Uint8_T_Array; Length : Cxx.Genode.Uint64_T)
      with Global => null, Import, Convention => CPP, External_Name => "_ZN5Block6Client4readERNS0_7RequestEPhy";

      procedure Acknowledge (This : Class; Req : Cxx.Block.Client.Request.Class)
      with Global => null, Import, Convention => CPP, External_Name => "_ZN5Block6Client11acknowledgeENS0_7RequestE";

      function Writable (This : Class) return Cxx.Bool
      with Global => null, Import, Convention => CPP, External_Name => "_ZN5Block6Client8writableEv";

      function Block_Count (This : Class) return Cxx.Genode.Uint64_T
      with Global => null, Import, Convention => CPP, External_Name => "_ZN5Block6Client11block_countEv";

      function Block_Size (This : Class) return Cxx.Genode.Uint64_T
      with Global => null, Import, Convention => CPP, External_Name => "_ZN5Block6Client10block_sizeEv";

   private
      pragma SPARK_Mode (Off);

      type Class_Address is access Class;
      type Private_Uint64_T is new Cxx.Genode.Uint64_T;
      type Private_Uint64_T_Address is access Private_Uint64_T;
   end Client;

end Cxx.Block;
