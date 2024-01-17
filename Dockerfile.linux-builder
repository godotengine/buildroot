FROM almalinux:8

RUN yum -y update && \
    yum -y install make ncurses-devel which unzip perl cpio rsync fileutils diffutils bc bzip2 gzip sed git python3 file patch wget perl-Thread-Queue perl-Data-Dumper perl-ExtUtils-MakeMaker perl-IPC-Cmd gcc gcc-c++ && \
    yum clean all

