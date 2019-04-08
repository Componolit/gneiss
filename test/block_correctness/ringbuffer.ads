
with Cai.Block;

generic
   with package Block is new Cai.Block (<>);
   type Index is mod <>;
   type Buffer is private;
package Ringbuffer is

   type Item is record
      Block_Id : Block.Id;
      Set      : Boolean;
      Data     : Buffer;
   end record;

   type Ring is array (Index) of Item;

   type Cycle is record
      Read  : Index;
      Write : Index;
      Data  : Ring;
   end record;

   function Free (R : Cycle) return Boolean;

   function Has_Block (R : Cycle;
                       B : Block.Id) return Boolean;

   function Block_Ready (R : Cycle) return Boolean;

   procedure Initialize (R : out Cycle);

   procedure Add (R : in out Cycle;
                  B :        Block.Id) with
      Pre => Free (R) and not Has_Block (R, B);

   procedure Set_Data (R   : in out Cycle;
                       B   :        Block.Id;
                       Buf :        Buffer) with
      Pre => Has_Block (R, B);

   procedure Get_Block (R   : in out Cycle;
                        B   :    out Block.Id;
                        Buf :    out Buffer) with
      Pre => Block_Ready (R);

end Ringbuffer;
