
with Ada.Unchecked_Conversion;
with Musinfo;
with Componolit.Interfaces.Muen;
with Componolit.Interfaces.Muen_Block;
with Componolit.Interfaces.Internal.Block;

with Debuglog.Client;
with Componolit.Interfaces.Log;

package body Componolit.Interfaces.Block.Server with
   SPARK_Mode
is
   package CIM renames Componolit.Interfaces.Muen;
   package Blk renames Componolit.Interfaces.Muen_Block;

   package CIL renames Componolit.Interfaces.Log;

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
      return Server_Session'(Name               => Blk.Null_Name,
                             Registry_Index     => CIM.Invalid_Index,
                             Request_Memory     => Musinfo.Null_Memregion,
                             Request_Reader     => Blk.Server_Request_Channel.Null_Reader,
                             Response_Memory    => Musinfo.Null_Memregion,
                             Queued             => 0,
                             Latest_Request     => Blk.Null_Event,
                             Latest_Cache_Index => 0,
                             Request_Cache      => (others => Blk.Null_Block_Entry));
   end Create;

   procedure Cache_Allocate (S     : in out Server_Session;
                             Index :    out Natural);

   procedure Cache_Allocate (S     : in out Server_Session;
                             Index :    out Natural)
   is
      --  LRU_Index : Positive := 1;
      LRU_Age   : Natural  := 0;
   begin
      Index := 0;
      for I in S.Request_Cache'Range loop
         if S.Request_Cache (I).Age > LRU_Age then
            LRU_Age   := S.Request_Cache (I).Age;
            --  LRU_Index := I;
         end if;
         if S.Request_Cache (I).Age = 0 then
            if Index = 0 then
               Index := I;
            end if;
         else
            S.Request_Cache (I).Age := S.Request_Cache (I).Age;
         end if;
      end loop;
   end Cache_Allocate;

   procedure Cache_Get_Element (S       : in out Server_Session;
                                Index   :        Positive;
                                Element :    out Blk.Raw_Data_Type);

   procedure Cache_Get_Element (S       : in out Server_Session;
                                Index   :        Positive;
                                Element :    out Blk.Raw_Data_Type)
   is
   begin
      Element := S.Request_Cache (Index).Data;
      S.Request_Cache (Index).Age := 0;
   end Cache_Get_Element;

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
      pragma Warnings (Off, "unreachable code");
      Debuglog.Client.Put_Line ("Head");
      case S.Latest_Request.Kind is
         when Blk.Read =>
            declare
               R : constant Request := (Kind   => Read,
                               Priv   => Private_Data (S.Latest_Cache_Index),
                               Start  => Id (Count (S.Latest_Request.Id) * Factor),
                               Length => Factor,
                               Status => (if S.Latest_Request.Error = 0 then Raw else Error));
            begin
               Debuglog.Client.Put_Line ("Read");
               if S.Latest_Request = Blk.Null_Event then
                  Debuglog.Client.Put_Line ("None");
                  return Request'(Kind => None, Priv => Null_Data);
               end if;
               Debuglog.Client.Put_Line (CIL.Image (CIL.Unsigned (S.Latest_Request.Id)));
               return R;
            end;
         when Blk.Write =>
            Debuglog.Client.Put_Line ("Write");
            loop
               null;
            end loop;
            return Request'(Kind   => Write,
                            Priv   => Private_Data (S.Latest_Cache_Index),
                            Start  => Id (Count (S.Latest_Request.Id) * Factor),
                            Length => Factor,
                            Status => (if S.Latest_Request.Error = 0 then Raw else Error));
         when others =>
            Debuglog.Client.Put_Line ("Other");
            return Request'(Kind => Undefined,
                            Priv => Private_Data (S.Latest_Cache_Index));
      end case;
      pragma Warnings (On, "unreachable code");
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
      Index  : Natural;
   begin
      Debuglog.Client.Put_Line ("Discard");
      pragma Warnings (Off, "unreachable code");
      if S.Latest_Request.Kind = Blk.Command and then S.Latest_Request.Id = Blk.Size then
         Debuglog.Client.Put_Line ("Size");
         Size_Data.Value := Blk.Count (Block_Count (Get_Instance (S)) * Factor);
         S.Latest_Request.Data := Blk.Set_Size_Command_Data (Size_Data);
         Blk.Server_Response_Channel.Write (S.Response_Memory, S.Latest_Request);
         Debuglog.Client.Put_Line ("Sized");
      end if;
      Cache_Allocate (S, Index);
      if Index in S.Request_Cache'Range then
         Debuglog.Client.Put_Line ("Index");
         pragma Warnings (Off, """Result"" modified by call, but value might not be referenced");
         Blk.Server_Request_Channel.Read (S.Request_Memory,
                                          S.Request_Reader,
                                          S.Latest_Request,
                                          Result);
         pragma Warnings (On, """Result"" modified by call, but value might not be referenced");
         S.Request_Cache (Index).Data := S.Latest_Request.Data;
         S.Latest_Cache_Index         := Componolit.Interfaces.Internal.Block.Private_Data (Index);
      else
         Debuglog.Client.Put_Line ("No Index");
         loop
            null;
         end loop;
         S.Latest_Request     := Blk.Null_Event;
         S.Latest_Cache_Index := 0;
      end if;
      pragma Warnings (On, "unreachable code");
   end Discard;

   procedure Read (S : in out Server_Session;
                   R :        Request;
                   B :        Buffer)
   is
   begin
      S.Request_Cache (Positive (R.Priv)).Data := Convert_Buffer (B);
   end Read;

   procedure Write (S : in out Server_Session;
                    R :        Request;
                    B :    out Buffer)
   is
   begin
      B := Convert_Buffer (S.Request_Cache (Positive (R.Priv)).Data);
   end Write;

   procedure Acknowledge (S : in out Server_Session;
                          R : in out Request)
   is
      Blk_Sz : constant Size := Block_Size (Get_Instance (S));
      Factor : constant Id   := Id (Blk.Event_Block_Size / Blk_Sz);
      Ev     : Blk.Event     := Blk.Null_Event;
   begin
      Debuglog.Client.Put_Line ("Acknowledge");
      Debuglog.Client.Put_Line (CIL.Image (CIL.Unsigned (R.Start / Factor)));
      Ev.Id := Blk.Sector (R.Start / Factor);
      case R.Kind is
         when Read =>
            Ev.Kind := Blk.Read;
         when Write =>
            Ev.Kind := Blk.Write;
         when Sync =>
            Ev.Kind := Blk.Command;
            Ev.Id   := Blk.Sync;
         when others =>
            null;
      end case;
      Ev.Error := (if R.Status = Ok then 0 else -1);
      Cache_Get_Element (S, Positive (R.Priv), Ev.Data);
      Blk.Server_Response_Channel.Write (S.Response_Memory, Ev);
      R.Status := Acknowledged;
   end Acknowledge;

   procedure Unblock_Client (S : in out Server_Session)
   is
   begin
      null;
   end Unblock_Client;

end Componolit.Interfaces.Block.Server;
