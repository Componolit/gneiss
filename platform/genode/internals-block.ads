
with Cxx;
with Cxx.Block;

package Internals.Block is

   type Private_Data is new Cxx.Genode_Uint8_T_Array (1 .. 16);
   type Device is limited record
      Instance : Cxx.Block.Client.Class;
   end record;

end Internals.Block;
