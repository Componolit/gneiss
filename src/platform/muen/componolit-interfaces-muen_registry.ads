
with System;
with Componolit.Interfaces.Muen;
with Musinfo;

package Componolit.Interfaces.Muen_Registry with
   SPARK_Mode
is
   package CIM renames Componolit.Interfaces.Muen;

   type Session_Entry (Kind : CIM.Async_Session_Type := CIM.None) is record
      case Kind is
         when CIM.None =>
            null;
         when CIM.Block =>
            Response_Memory : Musinfo.Memregion_Type;
            Block_Event     : System.Address;
      end case;
   end record;

   type Session_Registry is array (CIM.Session_Index range 1 .. CIM.Session_Index'Last) of Session_Entry;
   Registry : Session_Registry := (others => Session_Entry'(Kind => CIM.None));

end Componolit.Interfaces.Muen_Registry;
