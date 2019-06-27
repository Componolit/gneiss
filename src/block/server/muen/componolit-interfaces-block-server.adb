
with Ada.Unchecked_Conversion;
with Musinfo;
with Componolit.Interfaces.Muen;
with Componolit.Interfaces.Muen_Block;

package body Componolit.Interfaces.Block.Server with
   SPARK_Mode
is
   package CIM renames Componolit.Interfaces.Muen;
   package Blk renames Componolit.Interfaces.Muen_Block;

   subtype Block_Buffer is Buffer (1 .. 4096);
   function Convert_Buffer is new Ada.Unchecked_Conversion (Blk.Raw_Data_Type, Block_Buffer);
   function Convert_Buffer is new Ada.Unchecked_Conversion (Block_Buffer, Blk.Raw_Data_Type);

   function Initialized (S : Server_Session) return Boolean
   is
      use type Musinfo.Memregion_Type;
      use type Blk.Session_Name;
      use type CIM.Session_Index;
   begin
      return S.Name /= Blk.Null_Name
             and S.Registry_Index /= CIM.Invalid_Index
             and S.Request_Memory /= Musinfo.Null_Memregion
             and S.Response_Memory /= Musinfo.Null_Memregion;
   end Initialized;

   function Create return Server_Session
   is
   begin
      return Server_Session'(Name            => Blk.Null_Name,
                             Registry_Index  => CIM.Invalid_Index,
                             Request_Memory  => Musinfo.Null_Memregion,
                             Request_Reader  => Blk.Server_Request_Channel.Null_Reader,
                             Response_Memory => Musinfo.Null_Memregion,
                             Queued          => 0,
                             Latest_Request  => Blk.Null_Event);
   end Create;

   function Get_Instance (S : Server_Session) return Server_Instance
   is
   begin
      return Server_Instance (S.Name);
   end Get_Instance;

   function Head (S : Server_Session) return Request
   is
      use type Blk.Event;
      use type Blk.Event_Type;
      Blk_Sz : constant Size  := Block_Size (Get_Instance (S));
      Factor : constant Count := Count (Blk.Event_Block_Size / Blk_Sz);
   begin
      case S.Latest_Request.Kind is
         when Blk.Read =>
            if S.Latest_Request = Blk.Null_Event then
               return Request'(Kind => None, Priv => Null_Data);
            end if;
            return Request'(Kind   => Read,
                            Priv   => Null_Data,
                            Start  => Id (Count (S.Latest_Request.Id) * Factor),
                            Length => Factor,
                            Status => (if S.Latest_Request.Error = 0 then Raw else Error));
         when Blk.Write =>
            return Request'(Kind   => Write,
                            Priv   => Null_Data,
                            Start  => Id (Count (S.Latest_Request.Id) * Factor),
                            Length => Factor,
                            Status => (if S.Latest_Request.Error = 0 then Raw else Error));
         when others =>
            return Request'(Kind => Undefined,
                            Priv => Null_Data);
      end case;
   end Head;

   Size_Data : Blk.Size_Command_Data_Type := (Value => 0,
                                              Pad   => (others => 0));

   procedure Discard (S : in out Server_Session)
   is
      use type Blk.Event_Type;
      use type Blk.Sector;
      Blk_Sz : constant Size  := Block_Size (Get_Instance (S));
      Factor : constant Count := Count (Blk_Sz) / 512;
      Result : Blk.Server_Request_Channel.Result_Type;
   begin
      if S.Latest_Request.Kind = Blk.Command and then S.Latest_Request.Id = Blk.Size then
         Size_Data.Value := Blk.Count (Block_Count (Get_Instance (S)) * Factor);
         S.Latest_Request.Data := Blk.Set_Size_Command_Data (Size_Data);
         Blk.Server_Response_Channel.Write (S.Response_Memory, S.Latest_Request);
      end if;
      pragma Warnings (Off, """Result"" modified by call, but value might not be referenced");
      Blk.Server_Request_Channel.Read (S.Request_Memory,
                                       S.Request_Reader,
                                       S.Latest_Request,
                                       Result);
      pragma Warnings (On, """Result"" modified by call, but value might not be referenced");
   end Discard;

   procedure Read (S : in out Server_Session;
                   R :        Request;
                   B :        Buffer)
   is
      pragma Unreferenced (R);
   begin
      S.Latest_Request.Data := Convert_Buffer (B);
   end Read;

   procedure Write (S : in out Server_Session;
                    R :        Request;
                    B :    out Buffer)
   is
      pragma Unreferenced (R);
   begin
      B := Convert_Buffer (S.Latest_Request.Data);
   end Write;

   procedure Acknowledge (S : in out Server_Session;
                          R : in out Request)
   is
   begin
      S.Latest_Request.Error := (if R.Status = Ok then 0 else -1);
      Blk.Server_Response_Channel.Write (S.Response_Memory, S.Latest_Request);
      R.Status := Acknowledged;
   end Acknowledge;

   procedure Unblock_Client (S : in out Server_Session)
   is
   begin
      null;
   end Unblock_Client;

end Componolit.Interfaces.Block.Server;
