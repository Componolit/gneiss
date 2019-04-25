
private with Cai.Internal.Configuration;

package Cai.Configuration with
   SPARK_Mode
is

   type Client_Session is limited private;

private

   type Client_Session is new Cai.Internal.Configuration.Client_Session;

end Cai.Configuration;
