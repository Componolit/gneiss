
with System;
with Cxx;
with Cxx.Genode;
with Cxx.Block.Client;
with Cxx.Block.Dispatcher;
with Cxx.Block.Server;

package Componolit.Gneiss.Internal.Block is

   type Request_Status is (Raw, Allocated, Pending, Ok, Error);

   type Client_Session is limited record
      Instance : Cxx.Block.Client.Class := (Block_Count => 0,
                                            Block_Size  => 0,
                                            Device      => System.Null_Address,
                                            Callback    => System.Null_Address,
                                            Write       => System.Null_Address,
                                            Env         => System.Null_Address,
                                            Tag         => 0);
   end record;

   type Dispatcher_Session is limited record
      Instance : Cxx.Block.Dispatcher.Class := (Root    => System.Null_Address,
                                                Handler => System.Null_Address,
                                                Tag     => 0);
   end record;

   type Server_Session is limited record
      Instance : Cxx.Block.Server.Class := (Session     => System.Null_Address,
                                            Callback    => System.Null_Address,
                                            Block_Count => System.Null_Address,
                                            Block_Size  => System.Null_Address,
                                            Writable    => System.Null_Address,
                                            Tag         => 0);
   end record;

   type Client_Request is limited record
      Packet   : Cxx.Block.Client.Packet_Descriptor := (Offset       => 0,
                                                        Bytes        => 0,
                                                        Opcode       => 0,
                                                        Tag          => 0,
                                                        Block_Number => 0,
                                                        Block_Count  => 0);
      Status   : Request_Status      := Raw;
      Session  : Cxx.Genode.Uint32_T := 0;
   end record;

   type Server_Request is limited record
      Request  : Cxx.Block.Server.Request := (Kind         => 0,
                                              Block_Number => 0,
                                              Block_Count  => 0,
                                              Success      => Cxx.Bool'Pos (0),
                                              Offset       => 0,
                                              Tag          => 0);
      Status   : Request_Status;
      Session  : Cxx.Genode.Uint32_T := 0;
   end record;

   type Dispatcher_Capability is limited record
      Instance : Cxx.Block.Dispatcher.Dispatcher_Capability;
   end record;

end Componolit.Gneiss.Internal.Block;
