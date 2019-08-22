
package Componolit.Gneiss.Strings_Generic with
   SPARK_Mode
is

   type Base is new Integer range 2 .. 16;
   type Base_Size is array (Base'Range) of Positive;
   Base_Length : constant Base_Size := (2  => 64,
                                        3  => 41,
                                        4  => 32,
                                        5  => 28,
                                        6  => 25,
                                        7  => 23,
                                        8  => 22,
                                        9  => 21,
                                        10 => 20,
                                        11 => 19,
                                        12 => 18,
                                        13 => 18,
                                        14 => 17,
                                        15 => 17,
                                        16 => 16);

   --  Image function for ranged types
   --
   --  @param V  Ranged type value
   --  @param B  Image base, default is base 10
   --  @param C  Use capital letters if True
   --  @return   Image string
   generic
      type I is range <>;
   function Image_Ranged (V : I;
                          B : Base    := 10;
                          C : Boolean := True) return String with
      Post => Image_Ranged'Result'Length <= Base_Length (B) + 1 and Image_Ranged'Result'First = 1;

   --  Image function for modular types
   --
   --  @param V  Modular type value
   --  @param B  Image base, default is base 10
   --  @param C  Use capital letters if True
   --  @return   Image string
   generic
      type U is mod <>;
   function Image_Modular (V : U;
                           B : Base    := 10;
                           C : Boolean := True) return String with
      Post => Image_Modular'Result'Length <= Base_Length (B) and Image_Modular'Result'First = 1;

end Componolit.Gneiss.Strings_Generic;
