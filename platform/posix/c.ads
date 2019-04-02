
package C is

   type Uint8_T is mod 2 ** 8;
   type Uint32_T is mod 2 ** 32;
   type Uint64_T is mod 2 ** 64;

   type Uint8_T_Array is array (Integer range <>) of Uint8_T;

end C;
