#!/bin/sh

cd /ada-interfaces
git submodule update --init --recursive
make -C ada-runtime && make -C ada-runtime platform

gnatprove -P ada_interface.gpr -j0 --level=2 --checks-as-errors -XPLATFORM=linux -u componolit-interfaces-log
gnatprove -P ada_interface.gpr -j0 --level=2 --checks-as-errors -XPLATFORM=linux --clean
gnatprove -P ada_interface.gpr -j0 --level=2 --checks-as-errors -XPLATFORM=linux -XTEST=hello_world -u component
gnatprove -P ada_interface.gpr -j0 --level=2 --checks-as-errors -XPLATFORM=linux -XTEST=hello_world -u component --clean
gnatprove -P ada_interface.gpr -j0 --level=2 --checks-as-errors -XPLATFORM=linux -XTEST=block_client -u component
gnatprove -P ada_interface.gpr -j0 --level=2 --checks-as-errors -XPLATFORM=linux -XTEST=block_client -u component --clean
gnatprove -P ada_interface.gpr -j0 --level=2 --checks-as-errors -XPLATFORM=linux -XTEST=timer -u component
gnatprove -P ada_interface.gpr -j0 --level=2 --checks-as-errors -XPLATFORM=linux -XTEST=timer -u component --clean
gnatprove -P ada_interface.gpr -j0 --level=2 --checks-as-errors -XPLATFORM=linux -XTEST=rom -u component
gnatprove -P ada_interface.gpr -j0 --level=2 --checks-as-errors -XPLATFORM=linux -XTEST=rom -u component --clean

set -e

gprbuild -P ada_interface.gpr -XPLATFORM=linux
gprclean -P ada_interface.gpr -XPLATFORM=linux
gprbuild -P ada_interface.gpr -XPLATFORM=linux -XTEST=hello_world
./build/hello_world
gprclean -P ada_interface.gpr -XPLATFORM=linux -XTEST=hello_world
dd if=/dev/zero of=/tmp/test_disk.img bs=4k count=64
gprbuild -P ada_interface.gpr -XPLATFORM=linux -XTEST=block_client
./build/block_client
gprclean -P ada_interface.gpr -XPLATFORM=linux -XTEST=block_client
gprbuild -P ada_interface.gpr -XPLATFORM=linux -XTEST=timer
./build/timer
gprclean -P ada_interface.gpr -XPLATFORM=linux -XTEST=timer
gprbuild -P ada_interface.gpr -XPLATFORM=linux -XTEST=rom
./build/rom test/rom/cai.conf & (sleep 2 && touch test/rom/cai.conf)
gprclean -P ada_interface.gpr -XPLATFORM=linux -XTEST=rom

gprbuild -P test/aunit/test.gpr
./test/aunit/test
