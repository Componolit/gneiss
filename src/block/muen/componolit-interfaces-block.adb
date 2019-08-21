with Interfaces;
with Componolit.Interfaces.Muen;
with Componolit.Interfaces.Muen_Block;
with Componolit.Interfaces.Muen_Registry;
with Musinfo;
with Musinfo.Instance;

package body Componolit.Interfaces.Block with
   SPARK_Mode
is
   package CIM renames Componolit.Interfaces.Muen;
   package Blk renames Componolit.Interfaces.Muen_Block;
   package Reg renames Componolit.Interfaces.Muen_Registry;

   use type Standard.Interfaces.Unsigned_32;
   use type Standard.Interfaces.Unsigned_64;
   use type Blk.Count;
   use type Blk.Session_Name;
   use type CIM.Session_Index;
   use type Musinfo.Memregion_Type;
   use type Blk.Event_Header;
   use type CIM.Async_Session_Type;

   ------------
   -- Client --
   ------------

   function Kind (R : Client_Request) return Request_Kind is
      (case R.Event.Header.Kind is
          when Blk.Read  => Read,
          when Blk.Write => Write,
          when others    => None);

   function Status (R : Client_Request) return Request_Status is
      (if
          R.Event.Header.Priv <= Request_Id'Pos (Request_Id'Last)
       then
          (case R.Status is
              when Componolit.Interfaces.Internal.Block.Raw       => Raw,
              when Componolit.Interfaces.Internal.Block.Allocated => Allocated,
              when Componolit.Interfaces.Internal.Block.Pending   => Pending,
              when Componolit.Interfaces.Internal.Block.Ok        => Ok,
              when Componolit.Interfaces.Internal.Block.Error     => Error)
       else
          Error);

   function Start (R : Client_Request) return Id is
      (Id (R.Event.Header.Id));

   function Length (R : Client_Request) return Count is
      (1);

   function Identifier (R : Client_Request) return Request_Id is
      (Request_Id'Val (R.Event.Header.Priv));

   function Assigned (C : Client_Session;
                      R : Client_Request) return Boolean is
      (C.Tag = R.Session);

   function Initialized (C : Client_Session) return Boolean is
      (Musinfo.Instance.Is_Valid
       and then C.Name /= Componolit.Interfaces.Muen_Block.Null_Name
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

   function Kind (R : Server_Request) return Request_Kind is
      (case R.Event.Header.Kind is
         when Blk.Read  => Read,
         when Blk.Write => Write,
         when others    => None);

   function Status (R : Server_Request) return Request_Status is
      (if
          R.Event.Header /= Blk.Null_Event_Header
       then
          (if
                 R.Length <= Standard.Interfaces.Unsigned_64 (Count'Last)
           then
              Pending
           else
              Error)
       else
          Raw);

   function Start (R : Server_Request) return Id is
      (Id (R.Event.Header.Id));

   function Length (R : Server_Request) return Count is
      (Count (R.Length));  --  PROOF steps: 400

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

   function Assigned (S : Server_Session;
                      R : Server_Request) return Boolean is
      (S.Tag = R.Session);

end Componolit.Interfaces.Block;
