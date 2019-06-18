
with Interfaces;
with Muchannel;
with Muchannel.Readers;
with Muchannel.Writer;

package Componolit.Interfaces.Muen_Block with
   SPARK_Mode
is
   Event_Block_Size : constant := 4096;

   type Count is range 0 .. 2 ** 63 - 1 with
      Size => 64;

   type Session_Name is new String (1 .. 59);
   Null_Name : constant Session_Name := (others => Character'First);

   type Event_Data_Type is array (1 .. Event_Block_Size) of Standard.Interfaces.Unsigned_8;

   type Command_Type is (Sync, Size) with
      Size => 32;
   for Command_Type use (Sync => 0, Size => 1);

   type Event_Type is (Read,
                       Write,
                       Command,
                       Last) with
      Size => 32;
   for Event_Type use (Read    => 0,
                       Write   => 1,
                       Command => 2,
                       Last    => 3);

   type Event is record
      Kind  : Event_Type;
      Error : Integer;
      Id    : Standard.Interfaces.Unsigned_64;
      Priv  : Standard.Interfaces.Unsigned_64;
      Data  : Event_Data_Type;
   end record;

   for Event use record
      Kind  at  0 range 0 .. 31;
      Error at  4 range 0 .. 31;
      Id    at  8 range 0 .. 63;
      Priv  at 16 range 0 .. 63;
      Data  at 24 range 0 .. 32767;
   end record;

   Null_Event : constant Event := (Kind  => Read,
                                   Error => 0,
                                   Id    => 0,
                                   Priv  => 0,
                                   Data  => (others => 0));

   package Request_Channel is new Muchannel (Element_Type => Event,
                                             Elements     => 16#0010_0000# / (Event'Size / 8),
                                             Null_Element => Null_Event,
                                             Protocol     => 16#9570_208d_ca77_db19#);

   package Response_Channel is new Muchannel (Element_Type => Event,
                                              Elements     => 16#0010_0000# / (Event'Size / 8),
                                              Null_Element => Null_Event,
                                              Protocol     => 16#9851_be32_82fe_f0dc#);

   package Request_Writer is new Request_Channel.Writer;

   package Response_Reader is new Response_Channel.Readers;

end Componolit.Interfaces.Muen_Block;
