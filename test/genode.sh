#!/bin/sh

cd /ada-interfaces
git submodule update --init --recursive
make -C ada-runtime && make -C ada-runtime platform

gnatprove -P ada_interface.gpr -j0 --level=2 --checks-as-errors -XPLATFORM=genode -u componolit-interfaces-log
gnatprove -P ada_interface.gpr -j0 --level=2 --checks-as-errors -XPLATFORM=genode --clean
gnatprove -P ada_interface.gpr -j0 --level=2 --checks-as-errors -XPLATFORM=genode -XTEST=hello_world -u component
gnatprove -P ada_interface.gpr -j0 --level=2 --checks-as-errors -XPLATFORM=genode -XTEST=hello_world -u component --clean
gnatprove -P ada_interface.gpr -j0 --level=2 --checks-as-errors -XPLATFORM=genode -XTEST=block_client -u component
gnatprove -P ada_interface.gpr -j0 --level=2 --checks-as-errors -XPLATFORM=genode -XTEST=block_client -u component --clean
gnatprove -P ada_interface.gpr -j0 --level=2 --checks-as-errors -XPLATFORM=genode -XTEST=timer -u component
gnatprove -P ada_interface.gpr -j0 --level=2 --checks-as-errors -XPLATFORM=genode -XTEST=timer -u component --clean
gnatprove -P ada_interface.gpr -j0 --level=2 --checks-as-errors -XPLATFORM=genode -XTEST=rom -u component
gnatprove -P ada_interface.gpr -j0 --level=2 --checks-as-errors -XPLATFORM=genode -XTEST=rom -u component --clean

set -e
cd /genode
git remote add jklmnn https://github.com/jklmnn/genode.git
git fetch jklmnn
git checkout ada_runtime_1.1
git clone https://github.com/Componolit/ada-components.git /genode/repos/ada-components -b ada_interfaces_issue_69
cd /genode/repos/ada-components
rm -r /genode/repos/ada-components/libs/ada-interface
ln -fs /ada-interfaces /genode/repos/ada-components/libs/ada-interface
/genode/tool/create_builddir x86_64
cd /genode/build/x86_64
sed -i "s/^#REPOS/REPOS/g" etc/build.conf
echo 'REPOSITORIES += $(GENODE_DIR)/repos/ada-components/platform/genode' >> etc/build.conf
/genode/tool/ports/prepare_port ada-runtime
make JOBS=$(nproc) KERNEL=linux BOARD=linux run/log_hello_world
make JOBS=$(nproc) KERNEL=linux BOARD=linux run/configuration
make JOBS=$(nproc) KERNEL=linux BOARD=linux run/timer_clock
make JOBS=$(nproc) KERNEL=linux BOARD=linux run/block_client
make JOBS=$(nproc) KERNEL=linux BOARD=linux run/block_server
make JOBS=$(nproc) KERNEL=linux BOARD=linux run/block_proxy
