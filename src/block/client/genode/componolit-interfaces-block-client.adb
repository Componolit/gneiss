
with Ada.Unchecked_Conversion;
with System;
with Cxx;
with Cxx.Block;
with Cxx.Block.Client;
with Cxx.Genode;
with Componolit.Interfaces.Block.Util;
use all type Cxx.Bool;

package body Componolit.Interfaces.Block.Client with
   SPARK_Mode => Off
is

   function Create_Request (Kind   : Componolit.Interfaces.Block.Request_Kind;
                            Priv   : Componolit.Interfaces.Block.Private_Data;
                            Start  : Componolit.Interfaces.Block.Id;
                            Length : Componolit.Interfaces.Block.Count;
                            Status : Componolit.Interfaces.Block.Request_Status) return Request;

   function Create_Request (Kind   : Componolit.Interfaces.Block.Request_Kind;
                            Priv   : Componolit.Interfaces.Block.Private_Data;
                            Start  : Componolit.Interfaces.Block.Id;
                            Length : Componolit.Interfaces.Block.Count;
                            Status : Componolit.Interfaces.Block.Request_Status) return Request
   is
      R : Request (Kind => (case Kind is
                            when Componolit.Interfaces.Block.None      => Componolit.Interfaces.Block.None,
                            when Componolit.Interfaces.Block.Read      => Componolit.Interfaces.Block.Read,
                            when Componolit.Interfaces.Block.Write     => Componolit.Interfaces.Block.Write,
                            when Componolit.Interfaces.Block.Sync      => Componolit.Interfaces.Block.Sync,
                            when Componolit.Interfaces.Block.Trim      => Componolit.Interfaces.Block.Trim,
                            when Componolit.Interfaces.Block.Undefined => Componolit.Interfaces.Block.Undefined));
   begin
      R.Priv := Priv;
      case R.Kind is
         when None =>
            null;
         when others =>
            R.Start  := Start;
            R.Length := Length;
            R.Status := Status;
      end case;
      return R;
   end Create_Request;

   function Get_Kind (R : Request) return Componolit.Interfaces.Block.Request_Kind is
      (R.Kind);

   function Get_Priv (R : Request) return Componolit.Interfaces.Block.Private_Data is
      (R.Priv);

   function Get_Start (R : Request) return Componolit.Interfaces.Block.Id is
      (if R.Kind = Componolit.Interfaces.Block.None then 0 else R.Start);

   function Get_Length (R : Request) return Componolit.Interfaces.Block.Count is
      (if R.Kind = Componolit.Interfaces.Block.None then 0 else R.Length);

   function Get_Status (R : Request) return Componolit.Interfaces.Block.Request_Status is
      (if R.Kind = Componolit.Interfaces.Block.None then Componolit.Interfaces.Block.Raw else R.Status);

   package Client_Util is new Block.Util (Request,
                                          Create_Request,
                                          Get_Kind,
                                          Get_Priv,
                                          Get_Start,
                                          Get_Length,
                                          Get_Status);

   function Create return Client_Session
   is
   begin
      return Client_Session'(Instance => Cxx.Block.Client.Constructor);
   end Create;

   function Get_Instance (C : Client_Session) return Client_Instance
   is
   begin
      return Client_Instance (Cxx.Block.Client.Get_Instance (C.Instance));
   end Get_Instance;

   function Initialized (C : Client_Session) return Boolean
   is
   begin
      return Cxx.Block.Client.Initialized (C.Instance) = Cxx.Bool'Val (1);
   end Initialized;

   procedure Crw (C : Client_Instance;
                  K : Cxx.Block.Kind;
                  B : Size;
                  S : Id;
                  L : Count;
                  D : System.Address);

   procedure Crw (C : Client_Instance;
                  K : Cxx.Block.Kind;
                  B : Size;
                  S : Id;
                  L : Count;
                  D : System.Address)
   is
      Data : Buffer (1 .. B * L) with
         Address => D;
   begin
      case K is
         when Cxx.Block.Write =>
            Write (C, B, S, L, Data);
         when Cxx.Block.Read =>
            Read (C, B, S, L, Data);
         when others =>
            null;
      end case;
   end Crw;

   procedure Initialize (C           : in out Client_Session;
                         Cap         :        Componolit.Interfaces.Types.Capability;
                         Path        :        String;
                         Buffer_Size :        Byte_Length := 0)
   is
      C_Path : constant String := Path & Character'Val (0);
      subtype C_Path_String is String (1 .. C_Path'Length);
      subtype C_String is Cxx.Char_Array (1 .. C_Path'Length);
      function To_C_String is new Ada.Unchecked_Conversion (C_Path_String,
                                                            C_String);
   begin
      Cxx.Block.Client.Initialize (C.Instance,
                                   Cap,
                                   To_C_String (C_Path),
                                   Event'Address,
                                   Crw'Address,
                                   Cxx.Genode.Uint64_T (Buffer_Size));
   end Initialize;

   procedure Finalize (C : in out Client_Session)
   is
   begin
      Cxx.Block.Client.Finalize (C.Instance);
   end Finalize;

   function Ready (C : Client_Session;
                   R : Request) return Boolean
   is
   begin
      return Cxx.Block.Client.Ready (C.Instance, Client_Util.Convert_Request (R)) = Cxx.Bool'Val (1);
   end Ready;

   function Supported (C : Client_Session;
                       R : Request_Kind) return Boolean
   is
   begin
      return Cxx.Block.Client.Supported (C.Instance, (case R is
                                                      when None      => Cxx.Block.None,
                                                      when Read      => Cxx.Block.Read,
                                                      when Write     => Cxx.Block.Write,
                                                      when Sync      => Cxx.Block.Sync,
                                                      when Trim      => Cxx.Block.Trim,
                                                      when Undefined => Cxx.Block.None)) = Cxx.Bool'Val (1);
   end Supported;

   procedure Enqueue (C : in out Client_Session;
                      R :        Request)
   is
   begin
      Cxx.Block.Client.Enqueue (C.Instance, Client_Util.Convert_Request (R));
   end Enqueue;

   procedure Submit (C : in out Client_Session)
   is
   begin
      Cxx.Block.Client.Submit (C.Instance);
   end Submit;

   function Next (C : Client_Session) return Request
   is
   begin
      return Client_Util.Convert_Request (Cxx.Block.Client.Next (C.Instance));
   end Next;

   procedure Read (C : in out Client_Session;
                   R :        Request)
   is
   begin
      Cxx.Block.Client.Read (C.Instance,
                             Client_Util.Convert_Request (R));
   end Read;

   pragma Warnings (Off, "formal parameter ""R"" is not modified");
   --  R is not modified but the platform state has changed and R becomes invalid on the platform
   procedure Release (C : in out Client_Session;
                      R : in out Request)
   is
   pragma Warnings (On, "formal parameter ""R"" is not modified");
   begin
      if R.Kind /= None and R.Kind /= Undefined then
         Cxx.Block.Client.Release (C.Instance, Client_Util.Convert_Request (R));
      end if;
   end Release;

   function Writable (C : Client_Session) return Boolean
   is
   begin
      return Cxx.Block.Client.Writable (C.Instance) /= Cxx.Bool'Val (0);
   end Writable;

   function Block_Count (C : Client_Session) return Count
   is
   begin
      return Count (Cxx.Block.Client.Block_Count (C.Instance));
   end Block_Count;

   function Block_Size (C : Client_Session) return Size
   is
   begin
      return Size (Cxx.Block.Client.Block_Size (C.Instance));
   end Block_Size;

   function Maximum_Transfer_Size (C : Client_Session) return Byte_Length
   is
   begin
      return Byte_Length (Cxx.Block.Client.Maximum_Transfer_Size (C.Instance));
   end Maximum_Transfer_Size;

end Componolit.Interfaces.Block.Client;
