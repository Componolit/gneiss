with RFLX.Types;
use type RFLX.Types.Bytes, RFLX.Types.Bytes_Ptr, RFLX.Types.Index, RFLX.Types.Length, RFLX.Types.Bit_Index, RFLX.Types.Bit_Length;

package RFLX.Session with
  SPARK_Mode
is

   type Action_Type_Base is mod 2**8;

   type Action_Type is (Request, Confirm, Reject) with
     Size =>
       8;
   for Action_Type use (Request => 0, Confirm => 1, Reject => 2);

   pragma Warnings (Off, "precondition is statically false");

   function Unreachable_Action_Type return Action_Type is
     (Action_Type'First)
    with
     Pre =>
       False;

   pragma Warnings (On, "precondition is statically false");

   function Extract is new RFLX.Types.Extract (RFLX.Types.Index, RFLX.Types.Byte, RFLX.Types.Bytes, RFLX.Types.Offset, Action_Type_Base);

   function Valid (Value : Action_Type_Base) return Boolean is
     ((case Value is
         when 0 | 1 | 2 =>
            True,
         when others =>
            False));

   function Convert (Value : Action_Type_Base) return Action_Type is
     ((case Value is
         when 0 =>
            Request,
         when 1 =>
            Confirm,
         when 2 =>
            Reject,
         when others =>
            Unreachable_Action_Type))
    with
     Pre =>
       Valid (Value);

   function Convert (Enum : Action_Type) return Action_Type_Base is
     ((case Enum is
         when Request =>
            0,
         when Confirm =>
            1,
         when Reject =>
            2));

   type Kind_Type_Base is mod 2**8;

   type Kind_Type is (Message) with
     Size =>
       8;
   for Kind_Type use (Message => 0);

   pragma Warnings (Off, "precondition is statically false");

   function Unreachable_Kind_Type return Kind_Type is
     (Kind_Type'First)
    with
     Pre =>
       False;

   pragma Warnings (On, "precondition is statically false");

   function Extract is new RFLX.Types.Extract (RFLX.Types.Index, RFLX.Types.Byte, RFLX.Types.Bytes, RFLX.Types.Offset, Kind_Type_Base);

   function Valid (Value : Kind_Type_Base) return Boolean is
     ((case Value is
         when 0 =>
            True,
         when others =>
            False));

   function Convert (Value : Kind_Type_Base) return Kind_Type is
     ((case Value is
         when 0 =>
            Message,
         when others =>
            Unreachable_Kind_Type))
    with
     Pre =>
       Valid (Value);

   function Convert (Enum : Kind_Type) return Kind_Type_Base is
     ((case Enum is
         when Message =>
            0));

   type Length_Type is mod 2**8;

   pragma Warnings (Off, "precondition is statically false");

   function Unreachable_Length_Type return Length_Type is
     (Length_Type'First)
    with
     Pre =>
       False;

   pragma Warnings (On, "precondition is statically false");

   function Extract is new RFLX.Types.Extract (RFLX.Types.Index, RFLX.Types.Byte, RFLX.Types.Bytes, RFLX.Types.Offset, Length_Type);

   pragma Warnings (Off, "unused variable ""Value""");

   function Valid (Value : Length_Type) return Boolean is
     (True);

   pragma Warnings (On, "unused variable ""Value""");

   function Convert (Value : Length_Type) return Length_Type is
     (Value)
    with
     Pre =>
       Valid (Value);

end RFLX.Session;
