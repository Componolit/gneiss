with Interfaces;
with Componolit.Interfaces.Muen;
with Componolit.Interfaces.Muen_Block;
with Musinfo;
with Musinfo.Instance;

package body Componolit.Interfaces.Block with
   SPARK_Mode
is
   package CIM renames Componolit.Interfaces.Muen;
   package Blk renames Componolit.Interfaces.Muen_Block;

   use type Standard.Interfaces.Unsigned_32;
   use type Standard.Interfaces.Unsigned_64;
   use type Blk.Count;
   use type Blk.Session_Name;
   use type Blk.Client_Response_Channel.Reader_Type;
   use type CIM.Session_Index;
   use type Musinfo.Memregion_Type;
   use type Blk.Event_Header;

   ------------
   -- Client --
   ------------

   function Null_Request return Client_Request is
      (Client_Request'(Status => Componolit.Interfaces.Internal.Block.Raw,
                       Event  => Blk.Null_Event));

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

   function Start (R : Client_Request) return Id
   is
      (Id (R.Event.Header.Id));

   function Length (R : Client_Request) return Count is
      (1);

   function Identifier (R : Client_Request) return Request_Id
   is
      (Request_Id'Val (R.Event.Header.Priv));

   function Initialized (C : Client_Session) return Boolean is
      (Musinfo.Instance.Is_Valid
       and then C.Name /= Componolit.Interfaces.Muen_Block.Null_Name
       and then C.Count > 0
       and then C.Request_Memory /= Musinfo.Null_Memregion
       and then C.Response_Memory /= Musinfo.Null_Memregion
       and then C.Registry_Index /= CIM.Invalid_Index);

   function Initialized (C : Client_Instance) return Boolean is
      (Musinfo.Instance.Is_Valid
       and then C.Name /= Componolit.Interfaces.Muen_Block.Null_Name
       and then C.Cnt > 0
       and then C.Req /= Musinfo.Null_Memregion
       and then C.Resp /= Musinfo.Null_Memregion
       and then C.Idx /= CIM.Invalid_Index);

   function Create return Client_Session is
      (Client_Session'(Name            => Blk.Null_Name,
                       Count           => 0,
                       Request_Memory  => Musinfo.Null_Memregion,
                       Response_Memory => Musinfo.Null_Memregion,
                       Response_Reader => Blk.Client_Response_Channel.Null_Reader,
                       Registry_Index  => CIM.Invalid_Index,
                       Queued          => 0,
                       Responses       => (others => Blk.Null_Event)));

   function Instance (C : Client_Session) return Client_Instance is
      (Client_Instance'(Name => C.Name,
                        Req  => C.Request_Memory,
                        Resp => C.Response_Memory,
                        Idx  => C.Registry_Index,
                        Cnt  => C.Count));

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
      (Musinfo.Instance.Is_Valid and then D.Registry_Index /= CIM.Invalid_Index);

   function Initialized (D : Dispatcher_Instance) return Boolean is
      (Musinfo.Instance.Is_Valid and then CIM.Session_Index (D) /= CIM.Invalid_Index);

   function Create return Dispatcher_Session is
      (Dispatcher_Session'(Registry_Index => Componolit.Interfaces.Muen.Invalid_Index));

   function Instance (D : Dispatcher_Session) return Dispatcher_Instance is
      (Dispatcher_Instance (D.Registry_Index));

   ------------
   -- Server --
   ------------

   function Null_Request return Server_Request is
      (Server_Request'(Event  => Blk.Null_Event,
                       Length => 0));

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
      (S.Name /= Blk.Null_Name
       and then S.Registry_Index /= CIM.Invalid_Index
       and then S.Request_Memory /= Musinfo.Null_Memregion
       and then S.Response_Memory /= Musinfo.Null_Memregion);

   function Create return Server_Session is
      (Server_Session'(Name            => Blk.Null_Name,
                       Registry_Index  => CIM.Invalid_Index,
                       Request_Memory  => Musinfo.Null_Memregion,
                       Request_Reader  => Blk.Server_Request_Channel.Null_Reader,
                       Response_Memory => Musinfo.Null_Memregion,
                       Read_Select     => (others => Blk.Null_Event_Header),
                       Read_Data       => (others => (others => 0))));

   function Instance (S : Server_Session) return Server_Instance is
      (Server_Instance (S.Name));

end Componolit.Interfaces.Block;
