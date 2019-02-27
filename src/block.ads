
package Block
   with SPARK_Mode
is

   type Unsigned_Long is range 0 .. 2 ** 63 - 1
      with Size => 64;
   type Id is mod 2 ** 64
      with Size => 64;
   type Count is range 0 .. 2 ** 63 - 1
      with Size => 64;
   type Size is range 0 .. 2 ** 32 - 1
      with Size => 64;
   type Byte is mod 2 ** 8
      with Size => 8;
   type Buffer is array (Unsigned_Long range <>) of Byte;

end Block;
