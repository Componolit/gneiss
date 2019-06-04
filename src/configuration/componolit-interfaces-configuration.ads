
private with Componolit.Interfaces.Internal.Configuration;

package Componolit.Interfaces.Configuration with
   SPARK_Mode
is

   type Client_Session is limited private;

private

   type Client_Session is new Componolit.Interfaces.Internal.Configuration.Client_Session;

end Componolit.Interfaces.Configuration;
