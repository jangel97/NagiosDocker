FROM registry.access.redhat.com/rhel
ENV NRPE_BRANCH   nrpe-3.2.1
RUN  yum install git openssh  openssl openssh-clients openssh-server make httpd php php-cli gcc unzip wget glibc glibc-common gd gd-devel net-snmp openssl-devel  -y
RUN useradd nagios && echo 'nagios' | passwd nagios --stdin && groupadd nagcmd && usermod -a -G nagcmd nagios && usermod -a -G nagcmd apache
RUN cd /tmp && wget https://assets.nagios.com/downloads/nagioscore/releases/nagios-4.4.5.tar.gz && tar xzf nagios-4.4.5.tar.gz
COPY ./start.sh /nagios
WORKDIR /tmp/nagios-4.4.5
RUN	./configure	&&\
	make all	&&\
	make install    &&\
	make install-init &&\
	make install-daemoninit &&\
	make install-config	&&\
	make install-commandmode &&\
	make install-exfoliation &&\
	make install-webconf
RUN htpasswd -cb /usr/local/nagios/etc/htpasswd.users nagiosadmin nagios
RUN cd /opt && wget  http://nagios-plugins.org/download/nagios-plugins-2.2.1.tar.gz && tar xzf  nagios-plugins-2.2.1.tar.gz 
WORKDIR /opt/nagios-plugins-2.2.1
RUN ./configure --with-nagios-user=nagios --with-nagios-group=nagios &&\
    make	&&\
    make install 

RUN cd /tmp                                                                  && \
    git clone https://github.com/NagiosEnterprises/nrpe.git -b $NRPE_BRANCH  && \
    cd nrpe                                                                  && \
    ./configure                                   \
        --with-ssl=/usr/bin/openssl               \
        --with-ssl-lib=/usr/lib/x86_64-linux-gnu  \
                                                                             && \
    make check_nrpe                                                          && \
    cp src/check_nrpe /usr/local/nagios/libexec/                                && \
    make clean                                                               && \
    cd /tmp && rm -Rf nrpe

ADD etc/ /usr/local/nagios/etc

EXPOSE 80

CMD ["/bin/bash", "/nagios/start.sh"]
