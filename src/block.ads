
package Block
   with SPARK_Mode
is

   type Block_Id is mod 2 ** 64;
   type Block_Count is mod 2 ** 64;
   type Byte is mod 2 ** 8;
   type Buffer is array (Long_Integer range <>) of Byte;

end Block;
