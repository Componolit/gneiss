with Cxx.Genode;

package Cxx.Block
   with SPARK_Mode => On
is
   type Kind is (None, Read, Write, Sync, Trim)
   with Size => Cxx.Unsigned_Int'Size;
   for Kind use (None => 0, Read => 1, Write => 2, Sync => 3, Trim => 4);
   type Status is (Raw, Ok, Error, Ack)
   with Size => Cxx.Unsigned_Int'Size;
   for Status use (Raw => 0, Ok => 1, Error => 2, Ack => 3);

   package Request
      with SPARK_Mode => On
   is
      type Class is
      record
         Kind   : Cxx.Block.Kind;
         Uid    : Cxx.Genode.Uint8_T_Array (1 .. 16);
         Start  : Cxx.Genode.Uint64_T;
         Length : Cxx.Genode.Uint64_T;
         Status : Cxx.Block.Status;
      end record;
      pragma Convention (C_Pass_By_Copy, Class);

   end Request;

end Cxx.Block;
