
with Cai.Component;

package Hello_World is

   procedure Construct;

   package Hello_World_Component is new Cai.Component (Construct);

end Hello_World;
