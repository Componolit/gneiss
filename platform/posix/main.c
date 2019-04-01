
extern void adainit(void);
extern void cai_component_construct(void);
extern void adafinal(void);

int main(int argc, char *argv[])
{
    adainit();
    cai_component_construct();
    adafinal();
}
