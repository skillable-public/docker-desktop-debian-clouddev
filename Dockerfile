FROM ghcr.io/skillable-public/docker-desktop-debian:latest

ARG HOME=/home/user
ARG DEBIAN_FRONTEND="noninteractive"

# azure-cli
RUN \
  apt-get update && \
  apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release && \
  echo "**** cleanup ****" && \
  apt-get autoclean && \
  rm -rf \
    /config/.cache \
    /var/lib/apt/lists/* \
    /var/tmp/* \
    /tmp/*  

RUN \
  mkdir -p /etc/apt/keyrings && \
  curl -sLS https://packages.microsoft.com/keys/microsoft.asc | \
  gpg --dearmor | sudo tee /etc/apt/keyrings/microsoft.gpg > /dev/null && \
  chmod go+r /etc/apt/keyrings/microsoft.gpg

RUN \
  AZ_DIST=$(lsb_release -cs) && \
  echo "Types: deb" >> /etc/apt/sources.list.d/azure-cli.sources && \
  echo "URIs: https://packages.microsoft.com/repos/azure-cli/" >> /etc/apt/sources.list.d/azure-cli.sources && \
  echo "Suites: ${AZ_DIST}" >> /etc/apt/sources.list.d/azure-cli.sources && \
  echo "Components: main" >> /etc/apt/sources.list.d/azure-cli.sources && \
  echo "Architectures: $(dpkg --print-architecture)" >> /etc/apt/sources.list.d/azure-cli.sources && \
  echo "Signed-by: /etc/apt/keyrings/microsoft.gpg" >> /etc/apt/sources.list.d/azure-cli.sources && \
  apt-get update && \
  apt-get install azure-cli && \
  echo "**** cleanup ****" && \
  apt-get autoclean && \
  rm -rf \
    /config/.cache \
    /var/lib/apt/lists/* \
    /var/tmp/* \
    /tmp/*  

# aws-cli
RUN \
  apt update && \
  apt install -y unzip && \
  runuser -l user -c \
  'cd /home/user && \
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
  unzip awscliv2.zip ' && \
  ./home/user/aws/install && \
  rm /home/user/awscliv2.zip && \
  echo "**** cleanup ****" && \
  apt-get autoclean && \
  rm -rf \
    /config/.cache \
    /var/lib/apt/lists/* \
    /var/tmp/* \
    /tmp/*  

# gcp-cli
RUN \
  touch /home/user/.bashrc && \
  cd /home/user && \
  curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-linux-x86_64.tar.gz && \
  tar -xf google-cloud-cli-linux-x86_64.tar.gz && \
  chown -R user:user /home/user && \
  runuser -l user -c \
  '/home/user/google-cloud-sdk/install.sh --rc-path /home/user/.bashrc --quiet' && \
  rm /home/user/google-cloud-cli-linux-x86_64.tar.gz

RUN \
  ARCH=$(arch | sed 's/aarch64/arm64/g' | sed 's/x86_64/x64/g') && \
  wget -q https://update.code.visualstudio.com/latest/linux-deb-${ARCH}/stable -O vs_code.deb && \
  apt-get update && \
  apt-get install -y ./vs_code.deb && \
  echo "**** cleanup ****" && \
  apt-get autoclean && \
  rm -rf \
    /config/.cache \
    /var/lib/apt/lists/* \
    /var/tmp/* \
    /tmp/*  

RUN \
  sed -i 's#/usr/share/code/code#/usr/share/code/code --no-sandbox##' /usr/share/applications/code.desktop && \
  mkdir /$HOME/Desktop && \
  cp /usr/share/applications/code.desktop $HOME/Desktop && \
  chmod +x $HOME/Desktop/code.desktop && \
  chown 1000:1000 $HOME/Desktop/code.desktop && \
  rm vs_code.deb
