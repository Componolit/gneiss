
with Interfaces.C;
with Interfaces.C.Extensions;
package Cxx
   with SPARK_Mode => On
is
   subtype Bool is Interfaces.C.Extensions.bool;
   type Bool_Array is array (Natural range <>) of Bool;
   subtype Unsigned_Char is Interfaces.C.unsigned_char;
   type Unsigned_Char_Array is array (Natural range <>) of Unsigned_Char;
   subtype Unsigned_Short is Interfaces.C.unsigned_short;
   type Unsigned_Short_Array is array (Natural range <>) of Unsigned_Short;
   subtype Unsigned_Int is Interfaces.C.unsigned;
   type Unsigned_Int_Array is array (Natural range <>) of Unsigned_Int;
   subtype Unsigned_Long is Interfaces.C.unsigned_long;
   type Unsigned_Long_Array is array (Natural range <>) of Unsigned_Long;
   subtype Unsigned_Long_Long is Interfaces.C.Extensions.unsigned_long_long;
   type Unsigned_Long_Long_Array is array (Natural range <>) of Unsigned_Long_Long;
   subtype Char is Interfaces.C.char;
   type Char_Array is array (Natural range <>) of Char;
   subtype Signed_Char is Interfaces.C.signed_char;
   type Signed_Char_Array is array (Natural range <>) of Signed_Char;
   subtype Wchar_t is Interfaces.C.wchar_t;
   type Wchar_t_Array is array (Natural range <>) of Wchar_t;
   subtype Short is Interfaces.C.short;
   type Short_Array is array (Natural range <>) of Short;
   subtype Int is Interfaces.C.int;
   type Int_Array is array (Natural range <>) of Int;
   subtype C_X_Int128 is Interfaces.C.Extensions.Signed_128;
   type C_X_Int128_Array is array (Natural range <>) of C_X_Int128;
   --  unsigned __int128 is not defined in Interfaces.C.Extensions
   subtype Long is Interfaces.C.long;
   type Long_Array is array (Natural range <>) of Long;
   subtype Long_Long is Interfaces.C.Extensions.long_long;
   type Long_Long_Array is array (Natural range <>) of Long_Long;
   subtype C_float is Interfaces.C.C_float;
   type C_float_Array is array (Natural range <>) of C_float;
   subtype Double is Interfaces.C.double;
   type Double_Array is array (Natural range <>) of Double;
   subtype Void is Interfaces.C.Extensions.void;
   type Void_Array is array (Natural range <>) of Void;
   subtype Void_Address is Interfaces.C.Extensions.void_ptr;
   type Void_Address_Array is array (Natural range <>) of Void_Address;

   type Bool_Address is private;
   type Bool_Address_Array is array (Natural range <>) of Bool_Address;
   type Unsigned_Char_Address is private;
   type Unsigned_Char_Address_Array is array (Natural range <>) of Unsigned_Char_Address;
   type Unsigned_Short_Address is private;
   type Unsigned_Short_Address_Array is array (Natural range <>) of Unsigned_Short_Address;
   type Unsigned_Int_Address is private;
   type Unsigned_Int_Address_Array is array (Natural range <>) of Unsigned_Int_Address;
   type Unsigned_Long_Address is private;
   type Unsigned_Long_Address_Array is array (Natural range <>) of Unsigned_Long_Address;
   type Unsigned_Long_Long_Address is private;
   type Unsigned_Long_Long_Address_Array is array (Natural range <>) of Unsigned_Long_Long_Address;
   type Char_Address is private;
   type Char_Address_Array is array (Natural range <>) of Char_Address;
   type Signed_Char_Address is private;
   type Signed_Char_Address_Array is array (Natural range <>) of Signed_Char_Address;
   type Wchar_t_Address is private;
   type Wchar_t_Address_Array is array (Natural range <>) of Wchar_t_Address;
   type Short_Address is private;
   type Short_Address_Array is array (Natural range <>) of Short_Address;
   type Int_Address is private;
   type Int_Address_Array is array (Natural range <>) of Int_Address;
   type C_X_Int128_Address is private;
   type C_X_Int128_Address_Array is array (Natural range <>) of C_X_Int128_Address;
   type Long_Address is private;
   type Long_Address_Array is array (Natural range <>) of Long_Address;
   type Long_Long_Address is private;
   type Long_Long_Address_Array is array (Natural range <>) of Long_Long_Address;
   type C_float_Address is private;
   type C_float_Address_Array is array (Natural range <>) of C_float_Address;
   type Double_Address is private;
   type Double_Address_Array is array (Natural range <>) of Double_Address;
   type Long_Double_Address is private;
   type Long_Double_Address_Array is array (Natural range <>) of Long_Double_Address;

   subtype Genode_Int8_T is Cxx.Signed_Char;
   subtype Genode_Int8_T_Array is Cxx.Signed_Char_Array;
   subtype Genode_Uint8_T is Cxx.Unsigned_Char;
   subtype Genode_Uint8_T_Array is Cxx.Unsigned_Char_Array;
   subtype Genode_Int16_T is Cxx.Short;
   subtype Genode_Int16_T_Array is Cxx.Short_Array;
   subtype Genode_Uint16_T is Cxx.Unsigned_Short;
   subtype Genode_Uint16_T_Array is Cxx.Unsigned_Short_Array;
   subtype Genode_Int32_T is Cxx.Int;
   subtype Genode_Int32_T_Array is Cxx.Int_Array;
   subtype Genode_Uint32_T is Cxx.Unsigned_Int;
   subtype Genode_Uint32_T_Array is Cxx.Unsigned_Int_Array;
   subtype Genode_Int64_T is Cxx.Long_Long;
   subtype Genode_Int64_T_Array is Cxx.Long_Long_Array;
   subtype Genode_Uint64_T is Cxx.Unsigned_Long_Long;
   subtype Genode_Uint64_T_Array is Cxx.Unsigned_Long_Long_Array;
private

   pragma SPARK_Mode(Off);

   type Bool_Address is access all Bool;
   type Unsigned_Char_Address is access all Unsigned_Char;
   type Unsigned_Short_Address is access all Unsigned_Short;
   type Unsigned_Int_Address is access all Unsigned_Int;
   type Unsigned_Long_Address is access all Unsigned_Long;
   type Unsigned_Long_Long_Address is access all Unsigned_Long_Long;
   type Char_Address is access all Char;
   type Signed_Char_Address is access all Signed_Char;
   type Wchar_t_Address is access all Wchar_t;
   type Short_Address is access all Short;
   type Int_Address is access all Int;
   type C_X_Int128_Address is access all C_X_Int128;
   type Long_Address is access all Long;
   type Long_Long_Address is access all Long_Long;
   type C_float_Address is access all C_float;
   type Double_Address is access all Double;
   type Long_Double_Address is access all Interfaces.C.long_double;

end Cxx;
