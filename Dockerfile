#Notes: Requires setting the tag of image to: "mcr.microsoft.com/azureiotedge-agent:1.0.0-linux-arm32v7" in /etc/iotedge/config.yaml   
#bump
FROM aarch64/ubuntu:16.04

RUN apt-get update -qq && apt-get install -qqy \
    apt-transport-https \
    ca-certificates \
    curl \
    wget \
    gnupg \
    lsb-release \
    jq \
    net-tools \
    iproute2 \
    systemd \
    build-essential \
    python \
    python-dev \
    libffi-dev \
    libssl1.0.0 \
    libssl-dev \
    iptables && \
    rm -rf /var/lib/apt/lists/*

RUN wget https://azurecliprod.blob.core.windows.net/install.py -O azure-cli-install.py && \
    chmod +x azure-cli-install.py && \
    yes "" | ./azure-cli-install.py

RUN cp /root/bin/az /usr/local/bin && \
    az extension add --name azure-iot

RUN dpkg --add-architecture armhf && \
    apt-get update -qq && apt-get install -qqy --allow-remove-essential \
    iptables:armhf \
    hostname:armhf \
    libcurl3:armhf 

RUN wget http://ftp.us.debian.org/debian/pool/main/o/openssl1.0/libssl1.0.2_1.0.2r-1~deb9u1_armhf.deb && \
    dpkg -i libssl1.0.2_1.0.2r-1~deb9u1_armhf.deb

RUN curl -L https://aka.ms/moby-engine-armhf-latest -o moby_engine.deb && dpkg -i ./moby_engine.deb && rm ./moby_engine.deb && \
    curl -L https://aka.ms/moby-cli-armhf-latest -o moby_cli.deb && dpkg -i ./moby_cli.deb && rm ./moby_cli.deb

RUN curl -L https://github.com/Azure/azure-iotedge/releases/download/1.0.0/libiothsm-std_1.0.0-1_armhf.deb -o libiothsm-std.deb && dpkg -i ./libiothsm-std.deb && rm ./libiothsm-std.deb && \
    curl -L https://github.com/Azure/azure-iotedge/releases/download/1.0.0/iotedge_1.0.0-1_armhf.deb -o iotedge.deb && dpkg -i ./iotedge.deb && rm ./iotedge.deb

COPY edge-provision.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/edge-provision.sh

VOLUME /var/lib/docker

EXPOSE 2375
EXPOSE 15580
EXPOSE 15581

ENTRYPOINT ["bash", "edge-provision.sh"]

CMD []
