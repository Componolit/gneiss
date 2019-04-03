
with Ada.Unchecked_Conversion;
with Cxx.Genode;

package body Cai.Block.Util is

   function Convert_Request (I : Instance_Request) return Cxx.Block.Request.Class
   is
      subtype Uid_Type is Cxx.Genode.Uint8_T_Array (1 .. 16);
      function Convert_Uid is new Ada.Unchecked_Conversion (Cai.Block.Private_Data, Uid_Type);
      Req : Cxx.Block.Request.Class;
   begin
      Req.Kind := (case Get_Kind (I) is
                   when Cai.Block.None  => Cxx.Block.None,
                   when Cai.Block.Sync  => Cxx.Block.Sync,
                   when Cai.Block.Read  => Cxx.Block.Read,
                   when Cai.Block.Write => Cxx.Block.Write,
                   when Cai.Block.Trim  => Cxx.Block.Trim);
      Req.Uid := Convert_Uid (Get_Priv (I));
      case Get_Kind (I) is
         when Cai.Block.None =>
            Req.Start  := 0;
            Req.Length := 0;
            Req.Status := Cxx.Block.Raw;
         when Cai.Block.Read .. Cai.Block.Trim =>
            Req.Start  := Cxx.Genode.Uint64_T (Get_Start (I));
            Req.Length := Cxx.Genode.Uint64_T (Get_Length (I));
            Req.Status := (case Get_Status (I) is
                           when Cai.Block.Raw          => Cxx.Block.Raw,
                           when Cai.Block.Ok           => Cxx.Block.Ok,
                           when Cai.Block.Error        => Cxx.Block.Error,
                           when Cai.Block.Acknowledged => Cxx.Block.Ack);
      end case;
      return Req;
   end Convert_Request;

   function Convert_Request (R : Cxx.Block.Request.Class) return Instance_Request
   is
      subtype Uid_Type is Cxx.Genode.Uint8_T_Array (1 .. 16);
      function Convert_Uid is new Ada.Unchecked_Conversion (Uid_Type, Cai.Block.Private_Data);
      Kind : constant Cai.Block.Request_Kind := (case R.Kind is
                                                 when Cxx.Block.None  => Cai.Block.None,
                                                 when Cxx.Block.Sync  => Cai.Block.Sync,
                                                 when Cxx.Block.Read  => Cai.Block.Read,
                                                 when Cxx.Block.Write => Cai.Block.Write,
                                                 when Cxx.Block.Trim  => Cai.Block.Trim);
      Status : constant Cai.Block.Request_Status := (case R.Status is
                                                     when Cxx.Block.Raw   => Cai.Block.Raw,
                                                     when Cxx.Block.Ok    => Cai.Block.Ok,
                                                     when Cxx.Block.Error => Cai.Block.Error,
                                                     when Cxx.Block.Ack   => Cai.Block.Acknowledged);
   begin
      return Create_Request (Kind   => Kind,
                             Priv   => Convert_Uid (R.Uid),
                             Start  => Cai.Block.Id (R.Start),
                             Length => Cai.Block.Count (R.Length),
                             Status => Status);
   end Convert_Request;

end Cai.Block.Util;
