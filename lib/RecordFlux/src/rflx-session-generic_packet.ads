with RFLX.Types;
use type RFLX.Types.Integer_Address;

generic
package RFLX.Session.Generic_Packet with
  SPARK_Mode
is

   pragma Unevaluated_Use_Of_Old (Allow);

   type Virtual_Field is (F_Initial, F_Action, F_Kind, F_Name_Length, F_Name_Payload, F_Label_Length, F_Label_Payload, F_Final);

   subtype Field is Virtual_Field range F_Action .. F_Label_Payload;

   type Context (Buffer_First, Buffer_Last : RFLX.Types.Index := RFLX.Types.Index'First; First, Last : RFLX.Types.Bit_Index := RFLX.Types.Bit_Index'First; Buffer_Address : RFLX.Types.Integer_Address := 0) is private with
     Default_Initial_Condition =>
       False;

   function Create return Context;

   procedure Initialize (Ctx : out Context; Buffer : in out RFLX.Types.Bytes_Ptr) with
     Pre =>
       not Ctx'Constrained
          and then Buffer /= null
          and then Buffer'Length > 0
          and then Buffer'Last <= RFLX.Types.Index'Last / 2,
     Post =>
       Valid_Context (Ctx)
          and then Has_Buffer (Ctx)
          and then Ctx.Buffer_First = RFLX.Types.Bytes_First (Buffer)'Old
          and then Ctx.Buffer_Last = RFLX.Types.Bytes_Last (Buffer)'Old
          and then Buffer = null;

   procedure Initialize (Ctx : out Context; Buffer : in out RFLX.Types.Bytes_Ptr; First, Last : RFLX.Types.Bit_Index) with
     Pre =>
       not Ctx'Constrained
          and then Buffer /= null
          and then Buffer'Length > 0
          and then RFLX.Types.Byte_Index (First) >= Buffer'First
          and then RFLX.Types.Byte_Index (Last) <= Buffer'Last
          and then First <= Last
          and then Last <= RFLX.Types.Bit_Index'Last / 2,
     Post =>
       Valid_Context (Ctx)
          and then Buffer = null
          and then Has_Buffer (Ctx)
          and then Ctx.Buffer_First = RFLX.Types.Bytes_First (Buffer)'Old
          and then Ctx.Buffer_Last = RFLX.Types.Bytes_Last (Buffer)'Old
          and then Ctx.Buffer_Address = RFLX.Types.Bytes_Address (Buffer)'Old
          and then Ctx.First = First
          and then Ctx.Last = Last;

   procedure Take_Buffer (Ctx : in out Context; Buffer : out RFLX.Types.Bytes_Ptr) with
     Pre =>
       Valid_Context (Ctx)
          and then Has_Buffer (Ctx),
     Post =>
       Valid_Context (Ctx)
          and then not Has_Buffer (Ctx)
          and then Buffer /= null
          and then Ctx.Buffer_First = Buffer'First
          and then Ctx.Buffer_Last = Buffer'Last
          and then Ctx.Buffer_Address = RFLX.Types.Bytes_Address (Buffer)
          and then Ctx.Buffer_First = Ctx.Buffer_First'Old
          and then Ctx.Buffer_Last = Ctx.Buffer_Last'Old
          and then Ctx.Buffer_Address = Ctx.Buffer_Address'Old
          and then Ctx.First = Ctx.First'Old
          and then Ctx.Last = Ctx.Last'Old
          and then Present (Ctx, F_Action) = Present (Ctx, F_Action)'Old
          and then Present (Ctx, F_Kind) = Present (Ctx, F_Kind)'Old
          and then Present (Ctx, F_Name_Length) = Present (Ctx, F_Name_Length)'Old
          and then Present (Ctx, F_Name_Payload) = Present (Ctx, F_Name_Payload)'Old
          and then Present (Ctx, F_Label_Length) = Present (Ctx, F_Label_Length)'Old
          and then Present (Ctx, F_Label_Payload) = Present (Ctx, F_Label_Payload)'Old;

   function Has_Buffer (Ctx : Context) return Boolean with
     Pre =>
       Valid_Context (Ctx);

   procedure Field_Range (Ctx : Context; Fld : Field; First : out RFLX.Types.Bit_Index; Last : out RFLX.Types.Bit_Index) with
     Pre =>
       Valid_Context (Ctx)
          and then Present (Ctx, Fld),
     Post =>
       Present (Ctx, Fld)
          and then Ctx.First <= First
          and then Ctx.Last >= Last
          and then First <= Last;

   function Index (Ctx : Context) return RFLX.Types.Bit_Index with
     Pre =>
       Valid_Context (Ctx),
     Post =>
       Index'Result >= Ctx.First
          and then Index'Result - Ctx.Last <= 1;

   procedure Verify (Ctx : in out Context; Fld : Field) with
     Pre =>
       Valid_Context (Ctx),
     Post =>
       Valid_Context (Ctx)
          and then (if Fld /= F_Action then (if Valid (Ctx, F_Action)'Old then Valid (Ctx, F_Action)))
          and then (if Fld /= F_Kind then (if Valid (Ctx, F_Kind)'Old then Valid (Ctx, F_Kind)))
          and then (if Fld /= F_Name_Length then (if Valid (Ctx, F_Name_Length)'Old then Valid (Ctx, F_Name_Length)))
          and then (if Fld /= F_Name_Payload then (if Valid (Ctx, F_Name_Payload)'Old then Valid (Ctx, F_Name_Payload)))
          and then (if Fld /= F_Label_Length then (if Valid (Ctx, F_Label_Length)'Old then Valid (Ctx, F_Label_Length)))
          and then (if Fld /= F_Label_Payload then (if Valid (Ctx, F_Label_Payload)'Old then Valid (Ctx, F_Label_Payload)))
          and then Has_Buffer (Ctx) = Has_Buffer (Ctx)'Old
          and then Ctx.Buffer_First = Ctx.Buffer_First'Old
          and then Ctx.Buffer_Last = Ctx.Buffer_Last'Old
          and then Ctx.Buffer_Address = Ctx.Buffer_Address'Old
          and then Ctx.First = Ctx.First'Old
          and then Ctx.Last = Ctx.Last'Old;

   procedure Verify_Message (Ctx : in out Context) with
     Pre =>
       Valid_Context (Ctx),
     Post =>
       Valid_Context (Ctx)
          and then Has_Buffer (Ctx) = Has_Buffer (Ctx)'Old
          and then Ctx.Buffer_First = Ctx.Buffer_First'Old
          and then Ctx.Buffer_Last = Ctx.Buffer_Last'Old
          and then Ctx.Buffer_Address = Ctx.Buffer_Address'Old
          and then Ctx.First = Ctx.First'Old
          and then Ctx.Last = Ctx.Last'Old;

   function Present (Ctx : Context; Fld : Field) return Boolean with
     Pre =>
       Valid_Context (Ctx);

   function Structural_Valid (Ctx : Context; Fld : Field) return Boolean with
     Pre =>
       Valid_Context (Ctx);

   function Valid (Ctx : Context; Fld : Field) return Boolean with
     Pre =>
       Valid_Context (Ctx),
     Post =>
       (if Valid'Result then Present (Ctx, Fld)
          and then Structural_Valid (Ctx, Fld));

   function Incomplete (Ctx : Context; Fld : Field) return Boolean with
     Pre =>
       Valid_Context (Ctx);

   function Structural_Valid_Message (Ctx : Context) return Boolean with
     Pre =>
       Valid_Context (Ctx);

   function Valid_Message (Ctx : Context) return Boolean with
     Pre =>
       Valid_Context (Ctx);

   function Incomplete_Message (Ctx : Context) return Boolean with
     Pre =>
       Valid_Context (Ctx);

   function Get_Action (Ctx : Context) return Action_Type with
     Pre =>
       Valid_Context (Ctx)
          and then Valid (Ctx, F_Action);

   function Get_Kind (Ctx : Context) return Kind_Type with
     Pre =>
       Valid_Context (Ctx)
          and then Valid (Ctx, F_Kind);

   function Get_Name_Length (Ctx : Context) return Length_Type with
     Pre =>
       Valid_Context (Ctx)
          and then Valid (Ctx, F_Name_Length);

   function Get_Label_Length (Ctx : Context) return Length_Type with
     Pre =>
       Valid_Context (Ctx)
          and then Valid (Ctx, F_Label_Length);

   generic
      with procedure Process_Name_Payload (Name_Payload : RFLX.Types.Bytes);
   procedure Get_Name_Payload (Ctx : Context) with
     Pre =>
       Valid_Context (Ctx)
          and then Has_Buffer (Ctx)
          and then Present (Ctx, F_Name_Payload);

   generic
      with procedure Process_Label_Payload (Label_Payload : RFLX.Types.Bytes);
   procedure Get_Label_Payload (Ctx : Context) with
     Pre =>
       Valid_Context (Ctx)
          and then Has_Buffer (Ctx)
          and then Present (Ctx, F_Label_Payload);

   function Valid_Context (Ctx : Context) return Boolean;

private

   type Cursor_State is (S_Valid, S_Structural_Valid, S_Invalid, S_Preliminary, S_Incomplete);

   type Field_Dependent_Value (Fld : Virtual_Field := F_Initial) is
      record
         case Fld is
            when F_Initial | F_Name_Payload | F_Label_Payload | F_Final =>
               null;
            when F_Action =>
               Action_Value : Action_Type_Base;
            when F_Kind =>
               Kind_Value : Kind_Type_Base;
            when F_Name_Length =>
               Name_Length_Value : Length_Type;
            when F_Label_Length =>
               Label_Length_Value : Length_Type;
         end case;
      end record;

   function Valid_Value (Value : Field_Dependent_Value) return Boolean is
     ((case Value.Fld is
         when F_Action =>
            Valid (Value.Action_Value),
         when F_Kind =>
            Valid (Value.Kind_Value),
         when F_Name_Length =>
            Valid (Value.Name_Length_Value),
         when F_Name_Payload =>
            True,
         when F_Label_Length =>
            Valid (Value.Label_Length_Value),
         when F_Label_Payload =>
            True,
         when F_Initial | F_Final =>
            False));

   type Field_Cursor (State : Cursor_State := S_Invalid) is
      record
         case State is
            when S_Valid | S_Structural_Valid | S_Preliminary =>
               First : RFLX.Types.Bit_Index;
               Last : RFLX.Types.Bit_Length;
               Value : Field_Dependent_Value;
            when S_Invalid | S_Incomplete =>
               null;
         end case;
      end record with
     Dynamic_Predicate =>
       (if State = S_Valid
          or State = S_Structural_Valid then Valid_Value (Value));

   type Field_Cursors is array (Field) of Field_Cursor;

   function Valid_Context (Buffer_First, Buffer_Last : RFLX.Types.Index; First, Last : RFLX.Types.Bit_Index; Buffer_Address : RFLX.Types.Integer_Address; Buffer : RFLX.Types.Bytes_Ptr; Index : RFLX.Types.Bit_Index; Fld : Virtual_Field; Cursors : Field_Cursors) return Boolean is
     ((if Buffer /= null then Buffer'First = Buffer_First
        and then Buffer'Last = Buffer_Last
        and then RFLX.Types.Bytes_Address (Buffer) = Buffer_Address)
      and then RFLX.Types.Byte_Index (First) >= Buffer_First
      and then RFLX.Types.Byte_Index (Last) <= Buffer_Last
      and then First <= Last
      and then Last <= RFLX.Types.Bit_Index'Last / 2
      and then Index >= First
      and then Index - Last <= 1
      and then (for all F in Field'First .. Field'Last =>
        (if Cursors (F).State = S_Valid
        or Cursors (F).State = S_Structural_Valid then Cursors (F).First >= First
        and then Cursors (F).Last <= Last
        and then Cursors (F).First <= (Cursors (F).Last + 1)
        and then Cursors (F).Value.Fld = F))
      and then (case Fld is
           when F_Initial =>
              True,
           when F_Action =>
              (Cursors (F_Action).State = S_Valid
                   or Cursors (F_Action).State = S_Structural_Valid)
                 and then (Cursors (F_Action).Last - Cursors (F_Action).First + 1) = Action_Type_Base'Size,
           when F_Kind =>
              (Cursors (F_Action).State = S_Valid
                   or Cursors (F_Action).State = S_Structural_Valid)
                 and then (Cursors (F_Kind).State = S_Valid
                   or Cursors (F_Kind).State = S_Structural_Valid)
                 and then (Cursors (F_Action).Last - Cursors (F_Action).First + 1) = Action_Type_Base'Size
                 and then (Cursors (F_Kind).Last - Cursors (F_Kind).First + 1) = Kind_Type_Base'Size,
           when F_Name_Length =>
              (Cursors (F_Action).State = S_Valid
                   or Cursors (F_Action).State = S_Structural_Valid)
                 and then (Cursors (F_Kind).State = S_Valid
                   or Cursors (F_Kind).State = S_Structural_Valid)
                 and then (Cursors (F_Name_Length).State = S_Valid
                   or Cursors (F_Name_Length).State = S_Structural_Valid)
                 and then (Cursors (F_Action).Last - Cursors (F_Action).First + 1) = Action_Type_Base'Size
                 and then (Cursors (F_Kind).Last - Cursors (F_Kind).First + 1) = Kind_Type_Base'Size
                 and then (Cursors (F_Name_Length).Last - Cursors (F_Name_Length).First + 1) = Length_Type'Size,
           when F_Name_Payload =>
              (Cursors (F_Action).State = S_Valid
                   or Cursors (F_Action).State = S_Structural_Valid)
                 and then (Cursors (F_Kind).State = S_Valid
                   or Cursors (F_Kind).State = S_Structural_Valid)
                 and then (Cursors (F_Name_Length).State = S_Valid
                   or Cursors (F_Name_Length).State = S_Structural_Valid)
                 and then (Cursors (F_Name_Payload).State = S_Valid
                   or Cursors (F_Name_Payload).State = S_Structural_Valid)
                 and then (Cursors (F_Action).Last - Cursors (F_Action).First + 1) = Action_Type_Base'Size
                 and then (Cursors (F_Kind).Last - Cursors (F_Kind).First + 1) = Kind_Type_Base'Size
                 and then (Cursors (F_Name_Length).Last - Cursors (F_Name_Length).First + 1) = Length_Type'Size,
           when F_Label_Length =>
              (Cursors (F_Action).State = S_Valid
                   or Cursors (F_Action).State = S_Structural_Valid)
                 and then (Cursors (F_Kind).State = S_Valid
                   or Cursors (F_Kind).State = S_Structural_Valid)
                 and then (Cursors (F_Name_Length).State = S_Valid
                   or Cursors (F_Name_Length).State = S_Structural_Valid)
                 and then (Cursors (F_Name_Payload).State = S_Valid
                   or Cursors (F_Name_Payload).State = S_Structural_Valid)
                 and then (Cursors (F_Label_Length).State = S_Valid
                   or Cursors (F_Label_Length).State = S_Structural_Valid)
                 and then (Cursors (F_Action).Last - Cursors (F_Action).First + 1) = Action_Type_Base'Size
                 and then (Cursors (F_Kind).Last - Cursors (F_Kind).First + 1) = Kind_Type_Base'Size
                 and then (Cursors (F_Name_Length).Last - Cursors (F_Name_Length).First + 1) = Length_Type'Size
                 and then (Cursors (F_Label_Length).Last - Cursors (F_Label_Length).First + 1) = Length_Type'Size,
           when F_Label_Payload | F_Final =>
              (Cursors (F_Action).State = S_Valid
                   or Cursors (F_Action).State = S_Structural_Valid)
                 and then (Cursors (F_Kind).State = S_Valid
                   or Cursors (F_Kind).State = S_Structural_Valid)
                 and then (Cursors (F_Name_Length).State = S_Valid
                   or Cursors (F_Name_Length).State = S_Structural_Valid)
                 and then (Cursors (F_Name_Payload).State = S_Valid
                   or Cursors (F_Name_Payload).State = S_Structural_Valid)
                 and then (Cursors (F_Label_Length).State = S_Valid
                   or Cursors (F_Label_Length).State = S_Structural_Valid)
                 and then (Cursors (F_Label_Payload).State = S_Valid
                   or Cursors (F_Label_Payload).State = S_Structural_Valid)
                 and then (Cursors (F_Action).Last - Cursors (F_Action).First + 1) = Action_Type_Base'Size
                 and then (Cursors (F_Kind).Last - Cursors (F_Kind).First + 1) = Kind_Type_Base'Size
                 and then (Cursors (F_Name_Length).Last - Cursors (F_Name_Length).First + 1) = Length_Type'Size
                 and then (Cursors (F_Label_Length).Last - Cursors (F_Label_Length).First + 1) = Length_Type'Size));

   type Context (Buffer_First, Buffer_Last : RFLX.Types.Index := RFLX.Types.Index'First; First, Last : RFLX.Types.Bit_Index := RFLX.Types.Bit_Index'First; Buffer_Address : RFLX.Types.Integer_Address := 0) is
      record
         Buffer : RFLX.Types.Bytes_Ptr := null;
         Index : RFLX.Types.Bit_Index := RFLX.Types.Bit_Index'First;
         Fld : Virtual_Field := F_Initial;
         Cursors : Field_Cursors := (others => (State => S_Invalid));
      end record with
     Dynamic_Predicate =>
       Valid_Context (Buffer_First, Buffer_Last, First, Last, Buffer_Address, Buffer, Index, Fld, Cursors);

   function Valid_Context (Ctx : Context) return Boolean is
     (Valid_Context (Ctx.Buffer_First, Ctx.Buffer_Last, Ctx.First, Ctx.Last, Ctx.Buffer_Address, Ctx.Buffer, Ctx.Index, Ctx.Fld, Ctx.Cursors));

end RFLX.Session.Generic_Packet;
