
with Ada.Unchecked_Conversion;
with Cxx.Genode;

package body Cai.Block.Util is

   function Convert_Request (I : Instance_Request) return Cxx.Block.Request.Class
   is
      subtype Uid_Type is Cxx.Genode.Uint8_T_Array (1 .. 16);
      function Convert_Uid is new Ada.Unchecked_Conversion (Cai.Block.Private_Data, Uid_Type);
      Req : Cxx.Block.Request.Class;
      R   : constant Request := Cast_Request (I);
   begin
      Req.Kind := (case R.Kind is
                   when Cai.Block.None  => Cxx.Block.None,
                   when Cai.Block.Sync  => Cxx.Block.Sync,
                   when Cai.Block.Read  => Cxx.Block.Read,
                   when Cai.Block.Write => Cxx.Block.Write,
                   when Cai.Block.Trim  => Cxx.Block.Trim);
      Req.Uid := Convert_Uid (R.Priv);
      case R.Kind is
         when Cai.Block.None =>
            Req.Start  := 0;
            Req.Length := 0;
            Req.Status := Cxx.Block.Ok;
         when Cai.Block.Read .. Cai.Block.Trim =>
            Req.Start  := Cxx.Genode.Uint64_T (R.Start);
            Req.Length := Cxx.Genode.Uint64_T (R.Length);
            Req.Status := (case R.Status is
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
      Req : Request ((case R.Kind is
                      when Cxx.Block.None  => Cai.Block.None,
                      when Cxx.Block.Sync  => Cai.Block.Sync,
                      when Cxx.Block.Read  => Cai.Block.Read,
                      when Cxx.Block.Write => Cai.Block.Write,
                      when Cxx.Block.Trim  => Cai.Block.Trim));
   begin
      Req.Priv := Convert_Uid (R.Uid);
      case Req.Kind is
         when Cai.Block.None =>
            null;
         when Cai.Block.Read .. Cai.Block.Trim =>
            Req.Start  := Cai.Block.Id (R.Start);
            Req.Length := Cai.Block.Count (R.Length);
            Req.Status := (case R.Status is
                           when Cxx.Block.Raw   => Cai.Block.Raw,
                           when Cxx.Block.Ok    => Cai.Block.Ok,
                           when Cxx.Block.Error => Cai.Block.Error,
                           when Cxx.Block.Ack   => Cai.Block.Acknowledged);
      end case;
      return Cast_Request (Req);
   end Convert_Request;

end Cai.Block.Util;
