
pragma Warnings (Off, "procedure ""Event"" is not referenced");
pragma Warnings (Off, "function ""Block_Count"" is not referenced");
pragma Warnings (Off, "function ""Block_Size"" is not referenced");
pragma Warnings (Off, "function ""Writable"" is not referenced");
pragma Warnings (Off, "function ""Maximal_Transfer_Size"" is not referenced");
pragma Warnings (Off, "procedure ""Initialize"" is not referenced");
pragma Warnings (Off, "procedure ""Finalize"" is not referenced");
--  Supress unreferenced warnings since not every platform needs each subprogram

generic
   with procedure Event;
   with function Block_Count (S : Server_Instance) return Count;
   with function Block_Size (S : Server_Instance) return Size;
   with function Writable (S : Server_Instance) return Boolean;
   with function Maximal_Transfer_Size (S : Server_Instance) return Byte_Length;
   with procedure Initialize (S : Server_Instance;
                              L : String);
   with procedure Finalize (S : Server_Instance);
package Cai.Block.Server with
   SPARK_Mode
is

   --  Redefinition of Cai.Block.Client.Request since SPARK does not allow discriminants of derived types
   --  SPARK RM 3.7 (2)
   type Request (Kind : Request_Kind := None) is record
      Priv : Private_Data;
      case Kind is
         when None =>
            null;
         when Read .. Trim =>
            Start  : Id;
            Length : Count;
            Status : Request_Status;
      end case;
   end record;

   function Initialized (S : Server_Session) return Boolean;

   function Create return Server_Session with
      Post => not Initialized (Create'Result);

   function Get_Instance (S : Server_Session) return Server_Instance with
      Pre => Initialized (S);

   function Head (S : Server_Session) return Request with
      Volatile_Function,
      Pre => Initialized (S);

   procedure Discard (S : in out Server_Session) with
      Pre  => Initialized (S),
      Post => Initialized (S);

   procedure Read (S : in out Server_Session;
                   R :        Request;
                   B :        Buffer) with
      Pre  => Initialized (S)
              and R.Kind = Read
              and B'Length = R.Length * Block_Size (Get_Instance (S)),
      Post => Initialized (S);

   procedure Write (S : in out Server_Session;
                    R :        Request;
                    B :    out Buffer) with
      Pre  => Initialized (S)
              and R.Kind = Write
              and B'Length = R.Length * Block_Size (Get_Instance (S)),
      Post => Initialized (S);

   procedure Acknowledge (S : in out Server_Session;
                          R : in out Request) with
      Pre  => Initialized (S),
      Post => Initialized (S);

end Cai.Block.Server;
