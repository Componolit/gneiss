package st7798 is

private
   
   type Colour_Mode is (65K, 262K, 12BIT, 16BIT, 18BIT, 16M);
   
   for Colour_Mode use (65K   => 16#50#,
                        262K  => 16#60#,
                        12BIT => 16#03#,
                        16BIT => 16#05#,
                        18BIT => 16#06#,
                        16M   => 16#07#);
   
   type Commands is (NOP, SWRESET, RDDID, RDDST, SLPIN, SLPOUT, PTLON, NORON,
                     INVOFF, INVON, DISPOFF, DISPON, CASET, RASET, RAMWR, RAMRD,
                     PTLAR, COLMOD, MADCTL, MADCTL_MY, MADCTL_MX, MADCTL_MV,
                     MADCTL_ML, MADCTL_MH, MADCTL_RGB, MADCTL_BGR, RDID1, RDID2,
                     RDID3, RDID4);
   
   for Commands use (NOP        => 16#00#,
                     SWRESET    => 16#01#,
                     RDDID      => 16#04#,
                     RDDST      => 16#09#,
                     SLPIN      => 16#10#,
                     SLPOUT     => 16#11#,
                     PTLON      => 16#12#,
                     NORON      => 16#13#,
                     INVOFF     => 16#20#,
                     INVON      => 16#21#,
                     DISPOFF    => 16#28#,
                     DISPON     => 16#29#,
                     CASET      => 16#2A#,
                     RASET      => 16#2B#,
                     RAMWR      => 16#2C#,
                     RAMRD      => 16#2E#,
                     PTLAR      => 16#30#,
                     COLMOD     => 16#3A#,
                     MADCTL     => 16#36#,
                     MADCTL_MY  => 16#80#,
                     MADCTL_MX  => 16#40#,
                     MADCTL_MV  => 16#20#,
                     MADCTL_ML  => 16#10#,
                     MADCTL_MH  => 16#04#,
                     MADCTL_RGB => 16#00#,
                     MADCTL_BGR => 16#08#,
                     RDID1      => 16#DA#,
                     RDID2      => 16#DB#,
                     RDID3      => 16#DC#,
                     RDID4      => 16#DD#);
   
   type Colours is (BLACK, BLUE, RED, GREEN, CYAN, MAGENTA, YELLOW, WHITE);
   
   for Colours use (BLACK   => 16#0000#,
                    BLUE    => 16#001F#,
                    RED     => 16#F800#,
                    GREEN   => 16#07E0#,
                    CYAN    => 16#07FF#,
                    MAGENTA => 16#F81F#,
                    YELLOW  => 16#FFE0#,
                    WHITE   => 16#FFFF#);

end st7798;
