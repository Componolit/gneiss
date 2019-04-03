
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
package Cai.Block.Server is

   pragma Warnings (Off, "declaration hides ""Request""");
   --  Hide Cai.Block.Request to prevent Cai.Block.Server.Server_Request
   type Request is new Block.Request;

   function Create return Server_Session;

   function Initialized (S : Server_Session) return Boolean;

   function Get_Instance (S : Server_Session) return Server_Instance with
      Pre => Initialized (S);

   function Head (S : Server_Session) return Request with
      Volatile_Function,
      Pre => Initialized (S);

   procedure Discard (S : in out Server_Session) with
      Pre => Initialized (S);

   procedure Read (S : in out Server_Session;
                   R :        Request;
                   B :        Buffer) with
      Pre => Initialized (S)
             and R.Kind = Read
             and B'Length = R.Length * Block_Size (Get_Instance (S));

   procedure Write (S : in out Server_Session;
                    R :        Request;
                    B :    out Buffer) with
      Pre => Initialized (S)
             and R.Kind = Write
             and B'Length = R.Length * Block_Size (Get_Instance (S));

   procedure Acknowledge (S : in out Server_Session;
                          R : in out Request) with
      Pre => Initialized (S);

end Cai.Block.Server;
