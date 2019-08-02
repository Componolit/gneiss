
with Ada.Unchecked_Conversion;
with Interfaces;
with Componolit.Interfaces.Muen;
with Componolit.Interfaces.Muen_Block;
with Musinfo;

package body Componolit.Interfaces.Block.Server with
   SPARK_Mode
is

   package CIM renames Componolit.Interfaces.Muen;
   package Blk renames Componolit.Interfaces.Muen_Block;

   use type Blk.Session_Name;
   use type Blk.Event_Header;
   use type CIM.Session_Index;
   use type Musinfo.Memregion_Type;

   subtype Block_Buffer is Buffer (1 .. 4096);
   function Convert_Buffer is new Ada.Unchecked_Conversion (Blk.Raw_Data_Type, Block_Buffer);
   function Convert_Buffer is new Ada.Unchecked_Conversion (Block_Buffer, Blk.Raw_Data_Type);

   function Null_Request return Request is
      (Request'(Event  => Blk.Null_Event,
                Length => 0));

   function Kind (R : Request) return Request_Kind is
      (case R.Event.Header.Kind is
         when Blk.Read  => Read,
         when Blk.Write => Write,
         when others    => None);

   function Status (R : Request) return Request_Status is
      (if R.Event.Header /= Blk.Null_Event_Header then Pending else Raw);

   function Start (R : Request) return Id is
      (Id (R.Event.Header.Id));

   function Length (R : Request) return Count is
      (Count (R.Length));

   function Initialized (S : Server_Session) return Boolean is
      (Initialized (Instance (S))
       and then S.Name /= Blk.Null_Name
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

   Size_Data : Blk.Size_Command_Data_Type := (Value => 0,
                                              Pad   => (others => 0));

   procedure Process (S : in out Server_Session;
                      R : in out Request)
   is
      use type Blk.Event_Type;
      use type Blk.Sector;
      use type Blk.Server_Request_Channel.Result_Type;
      Result : Blk.Server_Request_Channel.Result_Type;
      Index  : Positive       := S.Read_Select'First;
   begin
      loop
         if S.Read_Select (Index) = Blk.Null_Event_Header then
            Blk.Server_Request_Channel.Read (S.Request_Memory,
                                             S.Request_Reader,
                                             R.Event,
                                             Result);
            if Result /= Blk.Server_Request_Channel.Success then
               R.Event.Header := Blk.Null_Event_Header;
               return;
            end if;
            if
               R.Event.Header.Kind = Blk.Command
               and then R.Event.Header.Id = Blk.Size
            then
               Size_Data.Value := Blk.Count (Block_Count (Instance (S)) * (Count (Block_Size (Instance (S))) / 512));
               R.Event.Data := Blk.Set_Size_Command_Data (Size_Data);
               Blk.Server_Response_Channel.Write (S.Response_Memory, R.Event);
               R.Event.Header := Blk.Null_Event_Header;
            else
               if R.Event.Header.Kind = Blk.Read then
                  S.Read_Select (Index) := R.Event.Header;
               end if;
               R.Length := Standard.Interfaces.Unsigned_64 (4096 / Block_Size (Instance (S)));
               return;
            end if;
         else
            exit when Index = S.Read_Select'Last;
            Index := Index + 1;
         end if;
      end loop;
   end Process;

   procedure Read (S : in out Server_Session;
                   R :        Request;
                   B :        Buffer)
   is
   begin
      for I in S.Read_Select'Range loop
         if S.Read_Select (I) = R.Event.Header then
            S.Read_Data (I) := Convert_Buffer (B);
            return;
         end if;
      end loop;
   end Read;

   procedure Write (S : in out Server_Session;
                    R :        Request;
                    B :    out Buffer)
   is
      pragma Unreferenced (S);
   begin
      B := Convert_Buffer (R.Event.Data);
   end Write;

   procedure Acknowledge (S      : in out Server_Session;
                          R      : in out Request;
                          Result :        Request_Status)
   is
      use type Blk.Event_Type;
   begin
      if R.Event.Header.Kind = Blk.Read then
         for I in S.Read_Select'Range loop
            if S.Read_Select (I) = R.Event.Header then
               R.Event.Data := S.Read_Data (I);
               S.Read_Select (I) := Blk.Null_Event_Header;
               exit;
            end if;
         end loop;
      end if;
      R.Event.Header.Error := (if Result = Ok then 0 else 1);
      Blk.Server_Response_Channel.Write (S.Response_Memory, R.Event);
      R.Event.Header := Blk.Null_Event_Header;
   end Acknowledge;

   procedure Unblock_Client (S : in out Server_Session)
   is
      pragma Unreferenced (S);
   begin
      null;
   end Unblock_Client;

   pragma Warnings (On);
end Componolit.Interfaces.Block.Server;
