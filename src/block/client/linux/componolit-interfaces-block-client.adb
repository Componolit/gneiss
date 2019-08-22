
with C;
with System;

package body Componolit.Interfaces.Block.Client with
   SPARK_Mode
is
   --  pragma Assertion_Policy (Pre => Ignore, Post => Check);
   use type Componolit.Interfaces.Internal.Block.Request_Status;
   use type C.Uint32_T;
   use type C.Uint64_T;

   function Kind (R : Request) return Request_Kind is
      (case R.Kind is
          when Componolit.Interfaces.Internal.Block.Read  => Read,
          when Componolit.Interfaces.Internal.Block.Write => Write,
          when Componolit.Interfaces.Internal.Block.Sync  => Sync,
          when Componolit.Interfaces.Internal.Block.Trim  => Trim,
          when others                                     => None);

   function Status (R : Request) return Request_Status is
      (if
          R.Status = Componolit.Interfaces.Internal.Block.Raw
       then
          Raw
       else
          (if
              R.Length <= C.Uint64_T (Count'Last)
              and then Request_Id'Pos (Request_Id'First) <= R.Tag
              and then Request_Id'Pos (Request_Id'Last) >= R.Tag
           then
              (case R.Status is
                  when Componolit.Interfaces.Internal.Block.Allocated => Allocated,
                  when Componolit.Interfaces.Internal.Block.Pending   => Pending,
                  when Componolit.Interfaces.Internal.Block.Ok        => Ok,
                  when Componolit.Interfaces.Internal.Block.Error     => Error,
                  when others                                         => Raw)
           else
              Error));

   function Start (R : Request) return Id is
      (Id (R.Start));

   function Length (R : Request) return Count is
      (Count (R.Length));

   function Identifier (R : Request) return Request_Id is
      (Request_Id'Val (R.Tag));

   function Assigned (C : Client_Session; R : Request) return Boolean is
      (R.Session = C.Tag);

   ----------------------
   -- Allocate_Request --
   ----------------------

   procedure Allocate_Request (C : in out Client_Session;
                               R : in out Request;
                               K :        Request_Kind;
                               S :        Id;
                               L :        Count;
                               I :        Request_Id;
                               E :    out Result)
   is
      procedure C_Allocate_Request (Inst : in out Client_Session;
                                    Req  : in out Request;
                                    Ret  :    out Integer) with
         Import,
         Convention    => C,
         External_Name => "block_client_allocate_request",
         Global        => null,
         Post          => Status (Req) in Raw | Allocated;
      Retr : Integer;
   begin
      case K is
         when None      => R.Kind := Componolit.Interfaces.Internal.Block.None;
         when Read      => R.Kind := Componolit.Interfaces.Internal.Block.Read;
         when Write     => R.Kind := Componolit.Interfaces.Internal.Block.Write;
         when Sync      => R.Kind := Componolit.Interfaces.Internal.Block.Sync;
         when Trim      => R.Kind := Componolit.Interfaces.Internal.Block.Trim;
         when Undefined => R.Kind := Componolit.Interfaces.Internal.Block.None;
      end case;
      R.Start   := Standard.C.Uint64_T (S);
      R.Length  := Standard.C.Uint64_T (L);
      R.Tag     := Request_Id'Pos (I);
      R.Session := C.Tag;
      C_Allocate_Request (C, R, Retr);
      if Status (R) = Allocated then
         E      := Success;
         R.Tag     := Request_Id'Pos (I);
      else
         R.Status := Componolit.Interfaces.Internal.Block.Raw;
         case Retr is
            when 1 => E := Retry;
            when 2 => E := Out_Of_Memory;
            when others => E := Unsupported;
         end case;
      end if;
   end Allocate_Request;

   --------------------
   -- Update_Request --
   --------------------

   procedure Update_Request (C : in out Client_Session;
                             R : in out Request)
   is
      pragma Unevaluated_Use_Of_Old (Allow);
      procedure C_Update_Request (Inst : in out Client_Session;
                                  Req  : in out Request) with
         Import,
         Convention    => C,
         External_Name => "block_client_update_request",
         Global        => null,
         Post          => Status (Req) in Pending | Ok | Error
                          and then Assigned (Inst, Req);
   begin
      C_Update_Request (C, R);
   end Update_Request;

   ----------------
   -- Initialize --
   ----------------

   procedure Crw (C : in out Client_Session;
                  R :        Request;
                  D :        System.Address);

   procedure Crw (C : in out Client_Session;
                  R :        Request;
                  D :        System.Address) with
      SPARK_Mode => Off
   is
      Data : Buffer (1 .. Block_Size (C) * Count (R.Length)) with
         Address => D;
   begin
      case R.Kind is
         when Componolit.Interfaces.Internal.Block.Read =>
            Read (C, Request_Id'Val (R.Tag), Data);
         when Componolit.Interfaces.Internal.Block.Write =>
            Write (C, Request_Id'Val (R.Tag), Data);
         when others =>
            null;
      end case;
   end Crw;

   procedure Initialize (C           : in out Client_Session;
                         Cap         :        Componolit.Interfaces.Types.Capability;
                         Path        :        String;
                         Tag         :        Session_Id;
                         Buffer_Size :        Byte_Length := 0) with
      SPARK_Mode => Off
   is
      pragma Unreferenced (Cap);
      C_Path : String := Path & Character'Val (0);
      procedure C_Initialize (T : in out Client_Session;
                              P : System.Address;
                              B : Byte_Length;
                              E : System.Address;
                              W : System.Address) with
         Import,
         Convention    => C,
         External_Name => "block_client_initialize",
         Global        => null;
   begin
      C_Initialize (C, C_Path'Address, Buffer_Size, Event'Address, Crw'Address);
      C.Tag := Standard.C.Uint32_T'Val (Session_Id'Pos (Tag) - Session_Id'Pos (Session_Id'First));
   end Initialize;

   --------------
   -- Finalize --
   --------------

   procedure Finalize (C : in out Client_Session)
   is
      procedure C_Finalize (T : in out Client_Session) with
         Import,
         Convention    => C,
         External_Name => "block_client_finalize",
         Global        => null,
         Post          => not Initialized (T);
   begin
      C_Finalize (C);
   end Finalize;

   -------------
   -- Enqueue --
   -------------

   procedure Enqueue (C : in out Client_Session;
                      R : in out Request)
   is
      procedure C_Enqueue (T   : in out Client_Session;
                           Req : in out Request) with
         Import,
         Convention    => C,
         External_Name => "block_client_enqueue",
         Global        => null,
         Pre           => Status (Req) = Allocated
                          and then Assigned (T, Req),
         Post          => Status (Req) in Allocated | Pending
                          and then Assigned (T, Req);
   begin
      C_Enqueue (C, R);
   end Enqueue;

   ------------
   -- Submit --
   ------------

   procedure Submit (C : in out Client_Session) is
      procedure C_Submit (T : in out Client_Session) with
         Import,
         Convention    => C,
         External_Name => "block_client_submit",
         Global        => null;
   begin
      C_Submit (C);
   end Submit;

   ----------
   -- Read --
   ----------

   procedure Read (C : in out Client_Session;
                   R :        Request)
   is
      procedure C_Read (T   : in out Client_Session;
                        Req :        Request) with
         Import,
         Convention    => C,
         External_Name => "block_client_read",
         Global        => null;
   begin
      C_Read (C, R);
   end Read;

   -------------
   -- Release --
   -------------

   procedure Release (C : in out Client_Session;
                      R : in out Request)
   is
      procedure C_Release (T   : in out Client_Session;
                           Req : in out Request) with
         Import,
         Convention    => C,
         External_Name => "block_client_release",
         Global        => null,
         Post          => Status (Req) = Raw;
   begin
      C_Release (C, R);
   end Release;

   procedure Lemma_Read (C      : in out Client_Session;
                         Req    :        Request_Id;
                         Data   :        Buffer)
   is
   begin
      Read (C, Req, Data);
   end Lemma_Read;

   procedure Lemma_Write (C      : in out Client_Session;
                          Req    :        Request_Id;
                          Data   :    out Buffer)
   is
   begin
      Write (C, Req, Data);
   end Lemma_Write;

end Componolit.Interfaces.Block.Client;
