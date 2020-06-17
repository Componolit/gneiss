
private with Gneiss_Internal.Stream;

generic
   pragma Warnings (Off, "* is not referenced");
   type Buffer_Index is range <>;
   type Byte is (<>);
   type Buffer is array (Buffer_Index range <>) of Byte;
   pragma Warnings (On, "* is not referenced");
package Gneiss.Stream with
   SPARK_Mode
is

   type Client_Session is limited private with
      Default_Initial_Condition => True;

   type Server_Session is limited private with
      Default_Initial_Condition => True;

   type Dispatcher_Session is limited private with
      Default_Initial_Condition => True;

   type Dispatcher_Capability is limited private;

   function Initialized (Session : Client_Session) return Boolean;

   function Initialized (Session : Server_Session) return Boolean;

   function Initialized (Session : Dispatcher_Session) return Boolean;

   function Index (Session : Client_Session) return Session_Index_Option with
      Post => (if Initialized (Session) then Index'Result.Valid);

   function Index (Session : Server_Session) return Session_Index_Option with
      Post => (if Initialized (Session) then Index'Result.Valid);

   function Index (Session : Dispatcher_Session) return Session_Index_Option with
      Post => (if Initialized (Session) then Index'Result.Valid);

   function Registered (Session : Dispatcher_Session) return Boolean with
      Ghost,
      Pre => Initialized (Session);

private

   type Client_Session is new Gneiss_Internal.Stream.Client_Session;
   type Server_Session is new Gneiss_Internal.Stream.Server_Session;
   type Dispatcher_Session is new Gneiss_Internal.Stream.Dispatcher_Session;
   type Dispatcher_Capability is new Gneiss_Internal.Stream.Dispatcher_Capability;

end Gneiss.Stream;
