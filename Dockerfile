FROM ||UbuntuImage||

ARG python_version=||Python_Runtime||

ENV DEBIAN_FRONTEND=noninteractive \
    CONDA_DIR=/opt/conda \
	SHELL=/bin/bash \
	PATH=/opt/conda/bin:$PATH
	
COPY fix-permissions.sh /usr/local/bin/fix-permissions.sh
RUN chmod a+rx /usr/local/bin/fix-permissions.sh

ARG MINIMAL_APTS="build-essential \
    bzip2 \
	emacs \
	netcat \
	p..." \
	
#Conda Base Packages
ARG BASE_PKGS="awscli \
    ----
	
ARG SCIPY_PKGS="hdfs \
    pandas \
	... \

# Update: System Packages
RUN apt-get update -y && \
    apt-get dist-upgrade -yq && \
    apt-get install -y openssl && \
	
    #apt install -y ansible apt-transport-https build-essential ca-certificates chromium-browser ffmpeg gnupg-agent htop iputils-ping libffi-dev libssl-dev python3 python3-dev python3-pip ranger software-properties-common sshpass systemd tree unzip vim wget youtube-dl

# Code-Server: Install
RUN mkdir ~/code-server && \
    cd ~/code-server && \
    wget https://github.com/cdr/code-server/releases/download/3.2.0/code-server-3.2.0-linux-x86_64.tar.gz && \
    tar -xzvf code-server-3.2.0-linux-x86_64.tar.gz && \
    cp -r code-server-3.2.0-linux-x86_64 /usr/lib/code-server && \
	ln -s /usr/lib/code-server/code-server /usr/bin/code-server && \
	mkdir /var/lib/code-server


# Setup Code-Server as a Systemd Service
COPY code-server.service /lib/systemd/system/ 

# Restart the Service
RUN systemctl daemon-reload && \
    apt install -y nginx && \
    systemctl start nginx && \
	systemctl start code-server && \
    systemctl enable code-server 

# Install SSL Letsencrypt
RUN apt install certbot -y
ADD  certificatefiles /etc/letsencrypt/live/domainname/     


ADD code-server.conf /etc/nginx/sites-available/
RUN ln -s /etc/nginx/sites-available/code-server.conf /etc/nginx/sites-enabled/ && \
    systemctl restart nginx && \
    systemctl enable nginx  && \