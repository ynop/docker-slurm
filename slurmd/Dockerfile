FROM ynop/centos_ssh

RUN yum -y install wget openssl openssl-devel pam-devel numactl numactl-devel hwloc hwloc-devel lua lua-devel readline-devel rrdtool-devel ncurses-devel man2html libibmad libibumad perl-ExtUtils-MakeMaker

#
#   CUDA
#
LABEL com.nvidia.volumes.needed="nvidia_driver"

RUN NVIDIA_GPGKEY_SUM=d1be581509378368edeec8c1eb2958702feedf3bc3d17011adbf24efacce4ab5 && \
    curl -fsSL http://developer.download.nvidia.com/compute/cuda/repos/rhel7/x86_64/7fa2af80.pub | sed '/^Version/d' > /etc/pki/rpm-gpg/RPM-GPG-KEY-NVIDIA && \
    echo "$NVIDIA_GPGKEY_SUM  /etc/pki/rpm-gpg/RPM-GPG-KEY-NVIDIA" | sha256sum -c --strict -

COPY cuda.repo /etc/yum.repos.d/cuda.repo

ENV CUDA_VERSION 8.0
LABEL com.nvidia.cuda.version="8.0"

ENV CUDA_PKG_VERSION 8-0-8.0.44-1
RUN yum install -y \
        cuda-nvrtc-$CUDA_PKG_VERSION \
        cuda-nvgraph-$CUDA_PKG_VERSION \
        cuda-cusolver-$CUDA_PKG_VERSION \
        cuda-cublas-$CUDA_PKG_VERSION \
        cuda-cufft-$CUDA_PKG_VERSION \
        cuda-curand-$CUDA_PKG_VERSION \
        cuda-cusparse-$CUDA_PKG_VERSION \
        cuda-npp-$CUDA_PKG_VERSION \
        cuda-cudart-$CUDA_PKG_VERSION && \
    ln -s cuda-$CUDA_VERSION /usr/local/cuda && \
    rm -rf /var/cache/yum/*

RUN echo "/usr/local/cuda/lib" >> /etc/ld.so.conf.d/cuda.conf && \
    echo "/usr/local/cuda/lib64" >> /etc/ld.so.conf.d/cuda.conf && \
    ldconfig

RUN echo "/usr/local/nvidia/lib" >> /etc/ld.so.conf.d/nvidia.conf && \
    echo "/usr/local/nvidia/lib64" >> /etc/ld.so.conf.d/nvidia.conf

ENV PATH /usr/local/nvidia/bin:/usr/local/cuda/bin:${PATH}
ENV LD_LIBRARY_PATH /usr/local/nvidia/lib:/usr/local/nvidia/lib64:${LD_LIBRARY_PATH}

#
#   MUNGE
#

RUN groupadd -g 991 munge
RUN useradd -c "Munge User" -d /var/lib/munge -u 991 -g munge -s /sbin/nologin munge

RUN groupadd -g 992 slurm
RUN useradd -c "Slurm User" -d /var/lib/slurm -u 992 -g slurm -s /bin/bash slurm

RUN yum -y install munge munge-libs munge-devel

ADD munge.key /etc/munge/munge.key

RUN chmod -R 0700 /etc/munge
RUN chmod -R 0711 /var/lib/munge
RUN chmod -R 0700 /var/log/munge
RUN chmod -R 0755 /var/run/munge

RUN chown munge: /etc/munge/munge.key
RUN chmod 400 /etc/munge/munge.key

#
#   SLURM
#

ENV slurm_version="16.05.6"
WORKDIR /tempinst

RUN wget http://www.schedmd.com/download/latest/slurm-$slurm_version.tar.bz2

RUN yum -y install rpm-build gcc

# build rpms to current folder
RUN rpmbuild -ta --bb --define "_rpmdir $(pwd)" slurm-$slurm_version.tar.bz2

# install them
WORKDIR /tempinst/x86_64
RUN yum -y --nogpgcheck localinstall slurm-$slurm_version-1.el7.centos.x86_64.rpm slurm-devel-$slurm_version-1.el7.centos.x86_64.rpm slurm-munge-$slurm_version-1.el7.centos.x86_64.rpm slurm-perlapi-$slurm_version-1.el7.centos.x86_64.rpm slurm-plugins-$slurm_version-1.el7.centos.x86_64.rpm slurm-sjobexit-$slurm_version-1.el7.centos.x86_64.rpm slurm-sjstat-$slurm_version-1.el7.centos.x86_64.rpm slurm-torque-$slurm_version-1.el7.centos.x86_64.rpm

# config
ADD slurm.conf /etc/slurm/slurm.conf

# files slurmctl
RUN mkdir /var/spool/slurmctld
RUN chown slurm: /var/spool/slurmctld
RUN chmod 755 /var/spool/slurmctld
RUN touch /var/log/slurmctld.log
RUN chown slurm: /var/log/slurmctld.log
RUN touch /var/log/slurm_jobacct.log /var/log/slurm_jobcomp.log
RUN chown slurm: /var/log/slurm_jobacct.log /var/log/slurm_jobcomp.log

# files slurmd
RUN mkdir /var/spool/slurmd
RUN chown slurm: /var/spool/slurmd
RUN chmod 755 /var/spool/slurmd
RUN touch /var/log/slurmd.log
RUN chown slurm: /var/log/slurmd.log

WORKDIR /

#
#   DEPENDENCIES FOR COMPUTING
#

# KALDI
RUN yum -y install which bc gcc-c++ git zlib1g-dev make gcc automake autoconf bzip2 wget libtool subversion python2.7 atlas python-pip

# SPYCH
RUN yum -y install https://centos7.iuscommunity.org/ius-release.rpm 
RUN yum -y install python35u python35u-pip

RUN ln -s /usr/bin/python3.5 /usr/bin/python3 && \
    ln -s /usr/bin/pip3.5 /usr/bin/pip3

RUN pip3 install --upgrade pip

RUN pip3 install modgrammar beautifulsoup4 requests cement httplib2 pystache

#
#   SUPERVISOR
#
ADD supervisord.conf /etc/supervisord.conf

#
#   CONTAINER
#
EXPOSE 6817 6818 57000-59999

