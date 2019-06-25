
with Musinfo;
with Componolit.Interfaces.Muen;
with Componolit.Interfaces.Muen_Block;
--  with Componolit.Interfaces.Muen_Registry;

package body Componolit.Interfaces.Block.Server with
   SPARK_Mode
is
   package CIM renames Componolit.Interfaces.Muen;
   package Blk renames Componolit.Interfaces.Muen_Block;

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
      pragma Unreferenced (S);
   begin
      return Request'(Kind => None, Priv => Null_Data);
   end Head;

   procedure Discard (S : in out Server_Session)
   is
      pragma Unreferenced (S);
   begin
      null;
   end Discard;

   procedure Read (S : in out Server_Session;
                   R :        Request;
                   B :        Buffer)
   is
      pragma Unreferenced (S);
      pragma Unreferenced (R);
      pragma Unreferenced (B);
   begin
      null;
   end Read;

   procedure Write (S : in out Server_Session;
                    R :        Request;
                    B :    out Buffer)
   is
      pragma Unreferenced (S);
      pragma Unreferenced (R);
      pragma Unreferenced (B);
   begin
      null;
   end Write;

   procedure Acknowledge (S : in out Server_Session;
                          R : in out Request)
   is
      pragma Unreferenced (S);
      pragma Unreferenced (R);
   begin
      null;
   end Acknowledge;

   procedure Unblock_Client (S : in out Server_Session)
   is
      pragma Unreferenced (S);
   begin
      null;
   end Unblock_Client;

end Componolit.Interfaces.Block.Server;
