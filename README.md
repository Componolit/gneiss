# ada-interface

Ada-interface is a Ada/SPARK library to provide a collection of interfaces to Ada components platform independently.
It only requires a minimal runtime such as the [ada-runtime](https://github.com/Componolit/ada-runtime).
Components built with this library are completely asynchronously.
For this approach all interfaces provide callable subprograms and and receive event handlers.
Its main design goals are portability, especially on for microkernel platforms, and complete SPARK compatibility.

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
with Cai.Types;
with Cai.Component;

package Component is

   procedure Initialize (Cap : Cai.Types.Capability);
   
   package My_Component is new Cai.Component (Initialize);
   
end Component;
```

The procedure `Initialize` is the first called procedure of the component (except of elaboration code) and receives a valid system capability. This capability is required to initialize clients or register servers.

### Using a client

Clients are used like regular libraries. The simples client is the `Log` client that provides standard logging facilities.
A hello world with the component described above looks as follows

```Ada
with Cai.Log;
with Cai.Log.Client;

package body Component is

   procedure Initialize (Cap : Cai.Types.Capability)
   is
      Log : Cai.Log.Client_Session;
   begin
      Cai.Log.Client.Initialize (Log, Cap, "Hello_World");
      Cai.Log.Client.Info (Log, "Hello World!");
      Cai.Log.Client.Warning (Log, "Hello World!");
      Cai.Log.Client.Error (Log, "Hello World!");
      Cai.Log.Client.Finalize (Log);
   end Initialize;
   
end Component;
```

This component opens a `Log` client session with its provided capability and then prints "Hello World!" as info, warning and error. Since there is only a initialize procedure that will only be called once the `Log` session is closed afterwards.
This produces partially different outputs on different platforms:

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

A more complex example is the [`Block`](https://en.wikipedia.org/wiki/Block_(data_storage)). It provides client, server and dispatcher.
Since this interface generates asynchronous events it requires an event handler:

```Ada
with Cai.Block;
with Cai.Block.Client;
with Cai.Log;
with Cai.Log.Client;

package body Component is

   procedure Event;
   
   package Block is new Cai.Block (Character, Positive, String);
   package Block_Client is new Block.Client (Event);
   
   Log : Cai.Log.Client_Session;
   Client : Block.Client_Session;
   
   procedure Initialize (Cap : Cai.Types.Capability)
   is
      Block_Request : Block_Client.Request (Kind => Block.Read,
                                            Start => 0,
                                            Length => 1,
                                            Status => Block.Raw);
   begin
      Cai.Log.Initialize (Log, Cap, "Block");
      Block_Client.Initialize (Client, Cap, "device id");
      if Block_Client.Ready (Client, Block_Request) then
         Block_Client.Enqueue (Client, Block_Request);
      end if;
      Block_Client.Submit (Client);
   end Initialize;
   
   procedure Event
   is
      Data : String (1 .. Block_Client.Block_Size (Client));
      Request : Block_Client.Request := Block_Client.Next (Client);
   begin
      if Request.Kind = Block.Read and then Request.Status = Block.Ok then
         Block_Client.Read (Client, Request, Data);
         Cai.Log.Client.Info (Log, Data);
      end if;
      Block_Client.Release (Client, Request);
   end Event;
   
end Component;
```

The whole `Block` session is generic. Since this session requires buffers to work on it would be inconvenient to always convert between different buffer types.
So it is instantiated at first with an element type, an index type and the resulting array type. In this case the standard Ada string is used.
Then the block client package is instantiated with the event handler procedure.
Since we need to keep state over multiple subprogram calls the session objects stay in the package state.

When the initializer is called first the sessions are initialized.
To create a possible event a request needs to be sent first.
In this case it is a `READ` request for block `0` with the length of one block.
If the platform is ready this (or more) request can be enqueued and then all enqueued requests are submitted.
The component now returns from this function and will stay inactive until an event happens.

Once the request has been handled by the platform the event handler is called.
A buffer of the size of one block is allocated and the next pending request is taken from the queue.
If this is a `READ` request and its has been handled correctly by the platform the the buffer can be filled via the `Read` procedure.
Before the `Event` procedure returns it releases the current request to make the next one availabel in the `Next` function.

In a real world application there are some more checks and loops but for the sake of simplicity this example was shortened a little bit. More complex examples reside in the `test` directory.

### Implementing a server

Implementing a server is quite similar to using a client.
It also consists of using a generic package and instantiating it with specific implementations of event handlers.
The main difference are additional initialization and property functions and the registration via the dispatcher.
For this example a simplified version of the block client will be used:

```Ada
generic
   with procedure Event;
   with function Block_Size (S : Server_Instance) return Size;
   with procedure Initialize (S : Server_Instance; L : String);
package Cai.Block.Server;
```

Another notable difference is that these subprograms receive a `Server_Instance` while called subprograms receive a `Server_Session`.
The reason is that the `Server_Session` object is kept in the local state but the callee of the passed function should be available.
To avoid aliasing that is forbidden in SPARK (two variable point to the same actual object) called subprograms only get an identifier passed which then can be associated with the actual object in the component state.
An empty block server implementation would look as follows:

```Ada
with Cai.Log;
with Cai.Log.Client;
with Cai.Block;
with Cai.Block.Dispatcher;
with Cai.Block.Server;

package body Component is

   package Block is new Cai.Block (Character, Positive, String);

   procedure Event;
   procedure Dispatch;
   function Block_Size (S : Block.Server_Instance) return Block.Size;
   procedure Initialize_Server (S : Block.Server_Instance; L : String);
   
   package Block_Server is new Block.Server (Event, Block_Size, Initialize_Server);
   package Block_Dispatcher is new Block.Dispatcher (Block_Server, Dispatch);
   
   Dispatcher : Block.Dispatcher_Session;
   Server : Block.Server_Session;
   Log : Cai.Log.Client_Session;

   procedure Initialize (Cap : Cai.Types.Capability)
   is
   begin
      Block_Dispatcher.Initialize (Dispatcher, Cap);
      Block_Dispatcher.Register (Dispatcher);
      Cai.Log.Client.Initialize (Log, Cap);
   end Initialize;
   
   procedure Dispatch
   is
      Label : String (1 .. 160);
      Last : Natural;
      Valid : Boolean;
   begin
      Block_Dispatcher.Session_Request (Dispatcher, Valid, Label, Last);
      if Valid and not Block_Server.Initialized (Server) then
         Cai.Log.Client.Info (Log, "Accepting block client with label " & Label (1 .. Last));
         Block_Dispatcher.Session_Accept (Dispatcher, Server);
      end if;
      Block_Dispatcher.Session_Cleanup (Dispatcher, Server);
   end if;

   procedure Event
   is
   begin
      null;
      --  Handle requests
   end Event;
   
   function Block_Size (S : Block.Server_Instance) return Block.Size
   is
   begin
      if Block_Server.Get_Instance (Server) = S then
         return 4096;
      end if;
      return 0;
   end Block_Size;
   
   procedure Initialize_Server (S : Block.Server_Instance; L : String)
   is
   begin
      if Block_Server.Get_Instance (Server) = S then
         Cai.Log.Client.Info ("Initializing server with label " & L);
      end if;
   end Initialize_Server;
   
end Component;
```

Similar to the client the generic packages are instantiated consecutively.
The dispatcher is then used like a regular client.
With the register method it announces its readiness to receive session requests.
When a clients want to open a session the `Dispatch` procedure is called.
It gets the session information and checks if a valid request is available and if it has a free slot to handle this request.
If this is the case it accepts the session.

When `Session_Accept` is called it will first initialize the server on the platform and then call the servers own `Initialize_Server` procedure.
The server can then initialize its own backend, e.g. a hard drive controller it drives.
Once this procedure returns the dispatcher will automatically announce the service on the platform.
If `Session_Accept` is not called the dispatcher will tell the platform that the request cannot be handled.
At last the `Session_Cleanup` procedure is called.
This happens always in the `Dispatch` procedure and will clean all servers where the client has disconnected, similar to a garbage collector.

The `Event` function is called once a request arrives.
The server interface provides subprograms similar to the client interface to consume and answer these requests but this is omitted here.

The `Block_Size` function is called when the client wants to know how large a single block is.
It checks first if it is called from the correct instance and returns a static size in this case.
If it has been called from another instance it will return `0`.
This instance checking functionality is especially useful if several instances with different properties run simultaneously.
The same accounts for the `Initialize_Server` procedure which in this case will only print the provided label.

## Implementing a new platform

The generic approach to implement a new platform is to create a new directory in `platform` and provide bodies for all specs in the `src` directory.
Some of those specs have private parts that include `Internal` packages and rename their types.
Those are platform specific types and there declaration together with the according `Internal` package spec need to be provided.
Platform specific types can be anything, as they're private to all components.
Their only limitation is that they must not be limited.

The log client for example consists of two (in this example simplified) specs:

```Ada
private with Cai.Internal.Log;

package Cai.Log is

   type Client_Session is private;
   
private

   type Client_Session is new Cai.Internal.Log.Client_Session;

end Cai.Log;
```
```Ada
with Cai.Types;

package Cai.Log.Client is

   procedure Initialize (C     : out Client_Session;
                         Cap   :     Cai.Types.Capability;
                         Label :     String);
   
   procedure Info (C : Client_Session;
                   M : String);

end Cai.Log.Client;
```

An exmplary Posix implementation consists of three parts: the internal type package, a client body and a C implementation.
Since the label should be printed as a prefix infront of each message it needs to be saved in the `Client_Session` type.
As it can have any length it only is a pointer to the actual string object:

```Ada
with System.Address;

package Cai.Internal.Log is

   type Client_Session is new System.Address;
   
end Cai.Internal.Log;
```

Before the package body can be implemented a C implementation must be present.
This roughly represents the subprograms defined in the package spec:
```C
#include <string.h>
#include <stdlib.h>
#include <stdio.h>

void initialize(char **session, char *label)
{
    *session = malloc(strlen(label) + 1);
    memcpy(*session, label, strlen(label) + 1);
}

void info(char *session, char *msg)
{
    fputs("[", stderr);
    fputs(session, stderr);
    fputs("] ", stderr);
    fputs(msg, stderr);
    fputs("\n", stderr);
}
```

Since the `Initialize` procedure uses an `out` parameter the argument in C is a pointer on the session object which is a char pointer.
The `in` parameter of the `Info` function is passed by value so the pointer can be used directly.
These mechanics may be different for different languages and type implementations.
Note that Posix doesn't require capabilities for this task so the C interfaces doesn't show them.

Now everything is available to implement the body that simply will glue both parts together:

```Ada
with System.Address;

package body Cai.Log.Client is

   procedure Initialize (C     : out Client_Session;
                         Cap   :     Cai.Types.Capability;
                         Label :     String)
   is
      procedure C_Initialize (C_Client : out Client_Session;
                              C_Label  : System.Address) with
         Import,
         Convention => C,
         External_Name => "initialize";
      C_String : String := Label & Character'Val (0);
   begin
      C_Initialize (C, C_String'Address);
   end Initialize;
   
   procedure Info (C : Client_Session;
                   M : String)
   is
      procedure C_Info (C_Client  : Client_Session;
                        C_Message : System.Address) with
         Import,
         Convention => C,
         External_Name => "info";
      C_Msg : String := M & Character'Val (0);
   begin
      C_Info (C, C_Msg'Address);
   end Info;

end Cai.Log.Client;
```

The body simply imports the C functions into each procedure and calls them with the session object.
To provide a pointer to a null terminated string in C the label and message are put on the stack and appended by a null byte.
Then the address of this object is passed to C.
