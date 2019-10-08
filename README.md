# Gneiss

Many applications still follow a monolithic design pattern today. Often, their
size and complexity precludes thorough verification and increases the
likelihood of errors. The lack of isolation allows an errors in an uncritical
part of a software to impact other security critical parts.

A well-known solution to this problem are systems comprised of components which
only interact through well-defined communication channels. In such systems
functionality is split into complex untrusted components and simple trusted
components. While untrusted parts realize sophisticated application logic,
trusted components are typically small, implement mandatory policies, and
enforce security properties. An open question is how to implement such trusted
components correctly.

Gneiss is a SPARK/Ada library providing a component-based systems abstraction
for trusted components. Its main design goals are portability, performance and
verifiability. Components build against the library can be compiled for the
[Genode OS Framework](https://genode.org), the [Muen Separation Kernel](https://muen.sk)
and Linux without modification. Only a minimal runtime such as our
[ada-runtime](https://github.com/Componolit/ada-runtime) is required. To enable
high-performance implementations, Gneiss imposes a fully asynchronous
programming style where all work is done inside event handlers.  All language
constructs used in Gneiss can be analyzed by the SPARK proof tools to
facilitate formally verified components.

##  Architecture

The library consists of two parts: a platform independent interface and a platform implementation.
The interface consists mostly of specs that define the API and the SPARK contracts. It also contains utilities such as a custom `Image` function since this is not part of the runtime.
The platform implementation is required to implement those specs with platform specific mechanisms.
This can either be a native Ada platform or a binding to a different language.

Interfaces are implemented as regular or generic packages.
Since components built with this library use an asynchronous approach most interfaces trigger callbacks or events.
To avoid access procedures that are forbidden in SPARK event handlers and callbacks are provided as formal generic parameters to interface packages.

Instances of interfaces are called sessions. There are three session types, client, server and dispatcher.
The client uses a server session of its own type.
The specific implementation of the server is not visible for the client but determined by the platform.
The dispatcher is like a special purpose client that does not connect to any server but the platform itself.
It is responsible to register a server implementation on the platform and thereby making it available for clients.

## Building a component

A component is a collection of Ada packages that contain all its state and implementation.
To interact with the system the state needs to hold a system capability and interface instance objects.
To announce the component to the system it needs to instantiate a component package with an initializer procedure.
This must only be done once per component.
An empty component looks as follows:

```Ada
with Componolit.Gneiss.Types;
with Componolit.Gneiss.Component;

package Component is

   procedure Construct (Cap : Componolit.Gneiss.Types.Capability);
   procedure Destruct;
   
   package Main is new Componolit.Gneiss.Component (Construct, Destruct);
   
end Component;
```

The procedure `Construct` is the first called procedure of the component (except of elaboration code) and receives a valid system [capability](https://en.wikipedia.org/wiki/Capability-based_security).
This capability is required to initialize clients or register servers.
The procedure `Destruct` is called when the platform decides to stop the component and allows to finalize component state.
As a convention the components main package is always called `Component` and it must contain an instance of the generic package `Componolit.Gneiss.Component` that is named `Main`.

The simplest interfaces are used like regular libraries. An example is the `Log` client that provides standard logging facilities.
A hello world with the component described above looks as follows

```Ada
with Componolit.Gneiss.Log;
with Componolit.Gneiss.Log.Client;

package body Component is

   Log : Componolit.Gneiss.Log.Client_Session;

   procedure Construct (Cap : Componolit.Gneiss.Types.Capability)
   is
   begin
      if not Componolit.Gneiss.Log.Initialized (Log) then
         Componolit.Gneiss.Log.Client.Initialize (Log, Cap, "channel1");
      end if;
      if Componolit.Gneiss.Log.Initialized (Log) then 
         Componolit.Gneiss.Log.Client.Info (Log, "Hello World!");
         Componolit.Gneiss.Log.Client.Warning (Log, "Hello World!");
         Componolit.Gneiss.Log.Client.Error (Log, "Hello World!");
        Main.Vacate (Cap, Main.Success);
      else
        Main.Vacate (Cap, Main.Failure);
      end if;
   end Construct;

   procedure Destruct
   is
   begin
      if Componolit.Gneiss.Log.Initialized (Log) then
         Componolit.Gneiss.Log.Finalize (Log);
      end if;
   end Destruct;
   
end Component;
```

In `Construct` the component checks if the log session `Log` is already initialized and initializes it if that is not the case.
Initializing a session that has already been set up could lead to crashes or memory leaks on the platform.
Since the initialization can fail it checks again if it succeeded.
If this is the case it prints "Hello World!" as an info, warning and error message.
The component then calls `Vacate` to tell the platform that it has finished its work and can be terminated.
`Vacate` does not immediately kill the component but tell the platform that it can safely be stopped now.
The current method will still return normally.
There is no guarantee that a subprogram that called `Vacate` is not called again.
When the platform at some point decides to terminate the component it will call `Destruct`.
This procedure only checks if the `Log` session has been initialized and finalizes it if this is the case.
In more complex scenarios the `Destruct` procedure can be used to safely shut down hardware devices or write data to disk.

Posix:
```
[Hello_World] Info: Hello World!
[Hello_World] Warning: Hello World!
[Hello_World] Error: Hello World!
```
Genode:
```
[init -> test-hello_world -> Hello_World] Hello World!
[init -> test-hello_world -> Hello_World] Warning: Hello World!
[init -> test-hello_world -> Hello_World] Error: Hello World!
```

Since Gneiss is an asynchronous framework it often requires callbacks to be implemented.
The `Timer` interface is a good example and easy to show.
It only requires a single callback procedure that is called after a previously specified time.
The package spec is the same as in the previous example.

```Ada
with Componolit.Gneiss.Log;
with Componolit.Gneiss.Log.Client;
with Componolit.Gneiss.Timer;
with Componolit.Gneiss.Timer.Client;

package body Component is

   Log        : Componolit.Gneiss.Log.Client_Session;
   Timer      : Componolit.Gneiss.Timer.Client_Session;
   Capability : Componolit.Gneiss.Types.Capability;

   procedure Event;

   package Timer_Client is new Componolit.Gneiss.Timer.Client (Event);

   procedure Construct (Cap : Componolit.Gneiss.Types.Capability)
   is
   begin
      Capability := Cap;
      if not Componolit.Gneiss.Log.Initialized (Log) then
         Componolit.Gneiss.Log.Client.Initialize (Log, Cap, "Timer");
      end if;
      if not Componolit.Gneiss.Timer.Initialized (Timer) then
         Timer_Client.Initialize (Timer, Cap);
      end if;
      if
         Componolit.Gneiss.Log.Initialized (Log)
         and then Componolit.Timer.Initialized (Timer)
      then
         Componolit.Gneiss.Log.Client.Info (Log, "Start!");
         Timer_Client.Set_Timeout (Timer, 60.0);
      else
         Main.Vacate (Cap, Main.Failure);
      end if;
   end Construct;

   procedure Event
   is
   begin
      if
         Componolit.Gneiss.Log.Initialized (Log)
         and then Componolit.Gneiss.Timer.Initialized (Timer)
      then
         Componolit.Gneiss.Log.Client.Info ("60s passed!");
         Main.Vacate (Capability, Main.Success);
      else
         Main.Vacate (Capability, Main.Failure);
      end if;
   end Event;

   procedure Destruct
   is
   begin
      if Componolit.Gneiss.Log.Initialized (Log) then
         Componolit.Gneiss.Log.Client.Finalize (Log);
      end if;
      if Componolit.Gneiss.Timer.Initialized (Timer) then
         Timer_Client.Finalize (Timer);
      end if;
   end Destruct;

end Component;
```

The usage of the log session here is equivalent to the first example.
Also the initialization of the timer session is similar.
The main difference is that the `Timer.Client` package is a generic that needs to be instantiated with a procedure.
When `Set_Timeout` is called on this instance a timeout is set on the platform.
The platform will then call the `Event` procedure when this timeout triggers.
Since the `Event` procedure has no arguments and can be used in multiple contexts no preconditions can be set.
This requires an initialization check of the timer session.
Some interfaces need more than a simple event callback and require additional interface specific procedures or functions as generic arguments.
These more specialized callbacks can provide preconditions that provide certain guarantees about initialized arguments.

Furthermore the capability needs to be copied to be available in the Event for component termination.
The capability is a special object that can be copied but not created from scratch.
Only construct is called with a valid capability object which then must be kept somewhere to be used in other contexts.

## Implementing a new platform

The generic approach to implement a new platform is to create a new directory in `platform` and provide bodies for all specs in the `src` directory.
Some of those specs have private parts that include `Internal` packages and rename their types.
Those are platform specific types and there declaration together with the according `Internal` package spec need to be provided.
Platform specific types can be anything, as they're private to all components.

The log client for example consists of two (in this example simplified) specs:

```Ada
private with Componolit.Gneiss.Internal.Log;

package Componolit.Gneiss.Log is

   type Client_Session is limited private;

   function Initialized (C : Client_Session) return Boolean;

private

   type Client_Session is new Componolit.Gneiss.Internal.Log.Client_Session;

end Componolit.Gneiss.Log;
```
```Ada
with Componolit.Gneiss.Types;

package Componolit.Gneiss.Log.Client is

   procedure Initialize (C     : in out Client_Session;
                         Cap   :        Componolit.Gneiss.Types.Capability;
                         Label :        String) with
      Pre => not Initialized (C);
   
   procedure Info (C : in out Client_Session;
                   M :        String) with
      Pre  => Initialized (C),
      Post => Initialized (C);

end Componolit.Gneiss.Log.Client;
```

The client session is a limited private type that can neither be assigned nor copied.
Its state functions, such as the initialization in this case are provided by the `Log` package while all modifying
procedures are provided by `Log.Client`.
In case of a generic package this allows to use the state functions as function contracts for formal generic parameters.

An exmplary Posix implementation consists of three parts: the internal type package, a client body and a C implementation.
Since the label should be printed as a prefix infront of each message it needs to be saved in the `Client_Session` type.
As it can have any length it only is a record containing a pointer to the actual string object:

```Ada
with System;

package Componolit.Gneiss.Internal.Log is

   type Client_Session is limited record
      Label : System.Address := System.Null_Address;
   end record;
   
end Componolit.Gneiss.Internal.Log;
```

As the session type is limited and has no initialization operation it requires a default initializer.
The default value should be a state that marks the session as not initialized.
Before the package body can be implemented a C implementation must be present.
Since the session type is limited Ada will always pass it by reference, so pointers have to be used in the language binding.
This roughly represents the subprograms defined in the package spec:

```C
#include <string.h>
#include <stdlib.h>
#include <stdio.h>

typedef struct session
{
    char *label;
} session_t;

void initialize(session_t *session, char *label)
{
    session->label = malloc(strlen(label) + 1);
    if(session->label){
        memcpy(session->label, label, strlen(label) + 1);
    }
}

void info(session_t *session, char *msg)
{
    fputs("[", stderr);
    fputs(session->label, stderr);
    fputs("] ", stderr);
    fputs(msg, stderr);
    fputs("\n", stderr);
}
```

The `struct session` is equal to the Ada record. A pointer in C is what a `System.Address` is in Ada.
Also by using `in out` as passing mode or having a limited type Ada will use pointers so `session_t` will always be passed as a pointer.
Procedures in Ada have no return type so they all are void functions in C.

```Ada
with System;

package body Componolit.Gneiss.Log.Client is

   procedure Initialize (C     : in out Client_Session;
                         Cap   :        Componolit.Gneiss.Types.Capability;
                         Label :        String)
   is
      procedure C_Initialize (C_Client : in out Client_Session;
                              C_Label  :        System.Address) with
         Import,
         Convention => C,
         External_Name => "initialize";
      C_String : String := Label & Character'Val (0);
   begin
      C_Initialize (C, C_String'Address);
   end Initialize;
   
   procedure Info (C : in out Client_Session;
                   M :        String)
   is
      procedure C_Info (C_Client  : in out Client_Session;
                        C_Message :        System.Address) with
         Import,
         Convention => C,
         External_Name => "info";
      C_Msg : String := M & Character'Val (0);
   begin
      C_Info (C, C_Msg'Address);
   end Info;

end Componolit.Gneiss.Log.Client;
```

In the package body the C functions are imported.
The `Client_Session` can be `in out` as it is passed as a pointer and might be modified by C.
The message string is more complicated.
While C expects a pointer with a null terminated string, Ada uses an array of characters and passes meta data about the length of the string.
To convert an Ada string to a C string the string put on the stack and a NULL character is appended as termination.
Then the address of the first string element is passed to C.

The last part is the package body for `Log` which only needs to implement `Initialized`.
Since this functions properties are likely required in the proof context it should not be implemented in C.
Also since its contract is fixed it needs to be a expression function to get into the proof context:

```Ada
with System;

package body Componolit.Gneiss.Log is

   use type System.Address;

   function Initialized (C : Client_Session) return Boolean is
      (C.Label /= System.Null_Address);

end Componolit.Gneiss.Log;
```

The initialization checks if `Label` is a valid address.
This ensures that all procedures that have an `Initialized` precondition can safely use the label.
It also makes sure that if `malloc` fails in C the session will not be initialized.
