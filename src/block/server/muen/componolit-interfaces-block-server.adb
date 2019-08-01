
with Componolit.Interfaces.Muen;
with Componolit.Interfaces.Muen_Block;
with Musinfo;

package body Componolit.Interfaces.Block.Server with
   SPARK_Mode
is

   package CIM renames Componolit.Interfaces.Muen;
   package Blk renames Componolit.Interfaces.Muen_Block;

   use type Blk.Session_Name;
   use type CIM.Session_Index;
   use type Musinfo.Memregion_Type;

   function Null_Request return Request is
      (Request'(Event => Blk.Null_Event));

   function Kind (R : Request) return Request_Kind is
      (case R.Event.Header.Kind is
         when Blk.Read  => Read,
         when Blk.Write => Write,
         when others    => None);

   function Status (R : Request) return Request_Status is
      (if R.Event.Header.Valid then Pending else Raw);

   function Start (R : Request) return Id is
      (Id (R.Event.Header.Id));

   function Length (R : Request) return Count is
      (1);

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
                       Response_Memory => Musinfo.Null_Memregion,
                       Queued          => 0,
                       Latest_Request  => Blk.Null_Event));

   function Instance (S : Server_Session) return Server_Instance is
      (Server_Instance (S.Name));

   procedure Process (S : in out Server_Session;
                      R : in out Request)
   is
      pragma Unreferenced (S);
      pragma Unreferenced (R);
   begin
      null;
   end Process;

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

   procedure Acknowledge (S      : in out Server_Session;
                          R      : in out Request;
                          Result :        Request_Status)
   is
      pragma Unreferenced (S);
      pragma Unreferenced (R);
      pragma Unreferenced (Result);
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
