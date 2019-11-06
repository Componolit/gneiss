
package body Componolit.Gneiss.Platform with
   SPARK_Mode => Off
is

   procedure Set_Status (C : Gns.Types.Capability;
                         S : Integer)
   is
      procedure Set (Cp : Gns.Types.Capability;
                     St : Integer) with
         Import,
         Convention => C,
         External_Name => "set_status";
   begin
      Set (C, S);
   end Set_Status;

   function Valid_Resource_Descriptor (R : Resource_Descriptor) return Boolean
   is
      function Rpv (R : Resource_Descriptor) return Integer with
         Import,
         Convention => C,
         External_Name => "resource_pointer_valid";
   begin
      return Rpv (R) = 1;
   end Valid_Resource_Descriptor;

   function Strlen (S : System.Address) return Integer with
      Import,
      Convention => C,
      External_Name => "strlen";

   function Resource_Type (R : Resource_Descriptor) return String
   is
      function Rpt (R : Resource_Descriptor) return System.Address with
         Import,
         Convention => C,
         External_Name => "resource_pointer_type";
      T : String (1 .. Strlen (Rpt (R))) with
         Import,
         Address => Rpt (R);
   begin
      return T;
   end Resource_Type;

   function Resource_Label (R : Resource_Descriptor) return String
   is
      function Rpl (R : Resource_Descriptor) return System.Address with
         Import,
         Convention => C,
         External_Name => "resource_pointer_label";
      L : String (1 .. Strlen (Rpl (R))) with
         Import,
         Address => Rpl (R);
   begin
      return L;
   end Resource_Label;

   function Resource_Mode (R : Resource_Descriptor) return Access_Mode
   is
      function Rpm (R : Resource_Descriptor) return Integer with
         Import,
         Convention => C,
         External_Name => "resource_pointer_mode";
   begin
      case Rpm (R) is
         when 2 =>
            return Write;
         when 3 =>
            return Read_Write;
         when others =>
            return Read;
      end case;
   end Resource_Mode;

   procedure Resource_Set_Event (R :     Resource_Descriptor;
                                 E :     System.Address;
                                 S : out Boolean)
   is
      procedure Rpse (R :     Resource_Descriptor;
                      E :     System.Address;
                      S : out Integer) with
         Import,
         Convention => C,
         External_Name => "resource_pointer_set_event";
      Success : Integer;
   begin
      Rpse (R, E, Success);
      S := Success = 1;
   end Resource_Set_Event;

   procedure Resource_Delete_Event (R :     Resource_Descriptor;
                                    E :     System.Address;
                                    S : out Boolean)
   is
      procedure Rpde (R :     Resource_Descriptor;
                      E :     System.Address;
                      S : out Integer) with
         Import,
         Convention => C,
         External_Name => "resource_pointer_delete_event";
      Success : Integer;
   begin
      Rpde (R, E, Success);
      S := Success = 1;
   end Resource_Delete_Event;

end Componolit.Gneiss.Platform;
