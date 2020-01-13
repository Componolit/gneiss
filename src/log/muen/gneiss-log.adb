
with Gneiss.Muen;
with Musinfo;

package body Gneiss.Log with
   SPARK_Mode
is

   use type Gneiss.Muen.Session_Id;
   use type Musinfo.Name_Type;
   use type Musinfo.Memregion_Type;

   function Status (Session : Client_Session) return Session_Status is
      (if
            Session.Name /= Musinfo.Null_Name
            and then Session.Mem /= Musinfo.Null_Memregion
            and then Session.R_Index /= Gneiss.Muen.Invalid_Index
       then Initialized
       else Uninitialized);

   function Initialized (Session : Dispatcher_Session) return Boolean is
      (False);

   function Initialized (Session : Server_Session) return Boolean is
      (False);

   function Index (Session : Client_Session) return Session_Index is
      (Session.S_Index);

   function Index (Session : Dispatcher_Session) return Session_Index is
      (0);

   function Index (Session : Server_Session) return Session_Index is
      (0);

end Gneiss.Log;
