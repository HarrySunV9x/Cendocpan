FROM centos:8
LABEL auther = "Harry Sun"
RUN sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
RUN sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*
COPY Centos-vault-8.5.2111.repo /etc/yum.repos.d/CentOS-Base.repo
COPY panda3d-1.10.9.tar.gz /home
RUN tar -xvf /home/panda3d-1.10.9.tar.gz
RUN yum clean all
RUN yum makecache
RUN yum -y upgrade
RUN yum -y install gcc-toolset-11 git python39 python39-devel rpm-build mesa-libGL-devel epel-release fakeroot
RUN pip3 install panda3d
RUN python3 /home/panda3d-1.10.9/makepanda/makepanda.py --everything --installer --no-egl --no-gles --no-gles2 --no-opencv

# 设置环境变量以使用 gcc-toolset-11
ENV PATH /opt/rh/gcc-toolset-11/root/usr/bin:$PATH
ENV LD_LIBRARY_PATH /opt/rh/gcc-toolset-11/root/usr/lib64:/opt/rh/gcc-toolset-11/root/usr/lib:$LD_LIBRARY_PATH
ENV MANPATH /opt/rh/gcc-toolset-11/root/usr/share/man:$MANPATH

# 检查 GCC 版本
RUN gcc --version

RUN git clone https://github.com/lettier/3d-game-shaders-for-beginners.git /homecd

g++ \
  -c src/main.cxx \
  -o 3d-game-shaders-for-beginners.o \
  -std=gnu++11 \
  -O2 \
  -I/usr/include/python39 \
  -I/home/panda3d-1.10.9/built/include

g++ \
  3d-game-shaders-for-beginners.o \
  -o 3d-game-shaders-for-beginners \
  -L/home/panda3d-1.10.9/built/lib \
  -lp3framework \
  -lpanda \
  -lpandafx \
  -lpandaexpress \
  -lpandaphysics \
  -lp3dtoolconfig \
  -lp3dtool \
  -lpthread

export LD_LIBRARY_PATH=/home/panda3d-1.10.9/built/lib:$LD_LIBRARY_PATH

./3d-game-shaders-for-beginners