
generic
   pragma Warnings (Off, "* is not referenced");
   with procedure Write (Session : in out Server_Session;
                         Data    :        String);
   with procedure Initialize (Session : in out Server_Session);
   with procedure Finalize (Session : in out Server_Session);
   with function Ready (Session : Server_Session) return Boolean;
   pragma Warnings (On, "* is not referenced");
package Gneiss.Log.Server with
   SPARK_Mode
is

end Gneiss.Log.Server;
