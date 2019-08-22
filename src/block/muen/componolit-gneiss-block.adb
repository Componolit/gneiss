with Interfaces;
with Componolit.Gneiss.Muen;
with Componolit.Gneiss.Muen_Block;
with Componolit.Gneiss.Muen_Registry;
with Musinfo;
with Musinfo.Instance;

package body Componolit.Gneiss.Block with
   SPARK_Mode
is
   package CIM renames Componolit.Gneiss.Muen;
   package Blk renames Componolit.Gneiss.Muen_Block;
   package Reg renames Componolit.Gneiss.Muen_Registry;

   use type Standard.Interfaces.Unsigned_64;
   use type Blk.Count;
   use type Blk.Session_Name;
   use type CIM.Session_Index;
   use type Musinfo.Memregion_Type;
   use type CIM.Async_Session_Type;

   ------------
   -- Client --
   ------------

   function Initialized (C : Client_Session) return Boolean is
      (Musinfo.Instance.Is_Valid
       and then C.Name /= Componolit.Gneiss.Muen_Block.Null_Name
       and then C.Count > 0
       and then C.Request_Memory /= Musinfo.Null_Memregion
       and then C.Response_Memory /= Musinfo.Null_Memregion
       and then C.Request_Memory.Size = Blk.Channel_Size
       and then C.Response_Memory.Size = Blk.Channel_Size
       and then C.Registry_Index /= CIM.Invalid_Index);

   function Identifier (C : Client_Session) return Session_Id is
      (Session_Id'Val (Standard.Interfaces.Unsigned_32'Pos (C.Tag) + Session_Id'Pos (Session_Id'First)));

   function Writable (C : Client_Session) return Boolean is
      (True);

   function Block_Count (C : Client_Session) return Count is
      (Count (C.Count));

   function Block_Size (C : Client_Session) return Size is
      (Blk.Event_Block_Size);

   ----------------
   -- Dispatcher --
   ----------------

   function Initialized (D : Dispatcher_Session) return Boolean is
      (Musinfo.Instance.Is_Valid
       and then D.Registry_Index /= CIM.Invalid_Index
       and then Reg.Registry (D.Registry_Index).Kind = CIM.Block_Dispatcher);

   function Identifier (D : Dispatcher_Session) return Session_Id is
      (Session_Id'Val (Standard.Interfaces.Unsigned_32'Pos (Reg.Registry (D.Registry_Index).Tag)
                       + Session_Id'Pos (Session_Id'First)));

   ------------
   -- Server --
   ------------

   function Initialized (S : Server_Session) return Boolean is
      (Musinfo.Instance.Is_Valid
       and then S.Name /= Blk.Null_Name
       and then S.Registry_Index /= CIM.Invalid_Index
       and then S.Request_Memory /= Musinfo.Null_Memregion
       and then S.Response_Memory /= Musinfo.Null_Memregion
       and then S.Request_Memory.Size = Blk.Channel_Size
       and then S.Response_Memory.Size = Blk.Channel_Size);

   function Valid (S : Server_Session) return Boolean is
      (True); --  TODO: Range check for Session_Id

   function Identifier (S : Server_Session) return Session_Id is
      (Session_Id'Val (Standard.Interfaces.Unsigned_32'Pos (S.Tag) + Session_Id'Pos (Session_Id'Last)));

end Componolit.Gneiss.Block;
