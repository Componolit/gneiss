
with Ada.Unchecked_Conversion;
with Cxx.Genode;

package body Componolit.Interfaces.Block.Util is

   function Convert_Request (I : Instance_Request) return Cxx.Block.Request.Class
   is
      subtype Uid_Type is Cxx.Genode.Uint8_T_Array (1 .. 16);
      function Convert_Uid is new Ada.Unchecked_Conversion (Componolit.Interfaces.Block.Private_Data, Uid_Type);
      Req : Cxx.Block.Request.Class;
   begin
      Req.Kind := (case Get_Kind (I) is
                   when Componolit.Interfaces.Block.None      => Cxx.Block.None,
                   when Componolit.Interfaces.Block.Sync      => Cxx.Block.Sync,
                   when Componolit.Interfaces.Block.Read      => Cxx.Block.Read,
                   when Componolit.Interfaces.Block.Write     => Cxx.Block.Write,
                   when Componolit.Interfaces.Block.Trim      => Cxx.Block.Trim,
                   when Componolit.Interfaces.Block.Undefined => Cxx.Block.None);
      Req.Uid := Convert_Uid (Get_Priv (I));
      case Get_Kind (I) is
         when Componolit.Interfaces.Block.None | Componolit.Interfaces.Block.Undefined =>
            Req.Start  := 0;
            Req.Length := 0;
            Req.Status := Cxx.Block.Raw;
         when Componolit.Interfaces.Block.Read .. Componolit.Interfaces.Block.Trim =>
            Req.Start  := Cxx.Genode.Uint64_T (Get_Start (I));
            Req.Length := Cxx.Genode.Uint64_T (Get_Length (I));
            Req.Status := (case Get_Status (I) is
                           when Componolit.Interfaces.Block.Raw          => Cxx.Block.Raw,
                           when Componolit.Interfaces.Block.Ok           => Cxx.Block.Ok,
                           when Componolit.Interfaces.Block.Error        => Cxx.Block.Error,
                           when Componolit.Interfaces.Block.Acknowledged => Cxx.Block.Ack,
                           when others => raise Constraint_Error);
      end case;
      return Req;
   end Convert_Request;

   function Convert_Request (R : Cxx.Block.Request.Class) return Instance_Request
   is
      subtype Uid_Type is Cxx.Genode.Uint8_T_Array (1 .. 16);
      function Convert_Uid is new Ada.Unchecked_Conversion (Uid_Type, Componolit.Interfaces.Block.Private_Data);
      Kind : constant Componolit.Interfaces.Block.Request_Kind := (case R.Kind is
                                                 when Cxx.Block.None  => Componolit.Interfaces.Block.None,
                                                 when Cxx.Block.Sync  => Componolit.Interfaces.Block.Sync,
                                                 when Cxx.Block.Read  => Componolit.Interfaces.Block.Read,
                                                 when Cxx.Block.Write => Componolit.Interfaces.Block.Write,
                                                 when Cxx.Block.Trim  => Componolit.Interfaces.Block.Trim);
      Status : constant Componolit.Interfaces.Block.Request_Status := (case R.Status is
                                                     when Cxx.Block.Raw   => Componolit.Interfaces.Block.Raw,
                                                     when Cxx.Block.Ok    => Componolit.Interfaces.Block.Ok,
                                                     when Cxx.Block.Error => Componolit.Interfaces.Block.Error,
                                                     when Cxx.Block.Ack   => Componolit.Interfaces.Block.Acknowledged);
   begin
      return Create_Request (Kind   => Kind,
                             Priv   => Convert_Uid (R.Uid),
                             Start  => Componolit.Interfaces.Block.Id (R.Start),
                             Length => Componolit.Interfaces.Block.Count (R.Length),
                             Status => Status);
   end Convert_Request;

end Componolit.Interfaces.Block.Util;
