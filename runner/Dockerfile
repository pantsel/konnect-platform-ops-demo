FROM ubuntu:20.04

ARG RUNNER_VERSION="2.294.0"

# Prevents installdependencies.sh from prompting the user and blocking the image creation
ARG DEBIAN_FRONTEND=noninteractive

RUN apt update -y && apt upgrade -y && useradd -m docker
RUN apt install -y --no-install-recommends \
    curl jq build-essential libssl-dev libffi-dev python3 python3-venv python3-dev python3-pip unzip nodejs gnupg software-properties-common wget lsb-release

# Intsall node js 20
RUN curl -sL https://deb.nodesource.com/setup_20.x | bash -
RUN apt-get install -y nodejs
RUN npm install -g @stoplight/spectral-cli

# Install yq
RUN add-apt-repository ppa:rmescandon/yq
RUN apt update
RUN apt install yq -y

# Download MinIO client (mc), make it executable, and add to PATH
RUN mkdir -p $HOME/minio-binaries
RUN curl https://dl.min.io/client/mc/release/linux-arm64/mc \
    --create-dirs \
    -o ~/minio-binaries/mc

RUN chmod +x $HOME/minio-binaries/mc
RUN cp $HOME/minio-binaries/mc /usr/local/bin/mc
RUN chown docker:docker /usr/local/bin/mc

# Install HashiCorp Vault
RUN wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

# Verify the key's fingerprint.
RUN gpg --no-default-keyring --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg --fingerprint

# Add the official HashiCorp repository.
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list

# Update package lists and install Vault
RUN apt-get update && apt-get install -y vault

RUN setcap -r /usr/bin/vault

# Install Kong deck
RUN curl -sL https://github.com/kong/deck/releases/download/v1.38.1/deck_1.38.1_linux_amd64.tar.gz -o deck.tar.gz
RUN tar -xf deck.tar.gz -C /usr/local/bin/


# Install Inso
RUN curl -LO https://github.com/Kong/insomnia/releases/download/core%409.3.2/inso-linux-9.3.2.tar.xz
RUN tar -xf inso-linux-9.3.2.tar.xz -C /usr/local/bin/

# Download and extract the GitHub Actions runner
RUN cd /home/docker && mkdir actions-runner && cd actions-runner \
    && curl -O -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

RUN chown -R docker ~docker && /home/docker/actions-runner/bin/installdependencies.sh

COPY start.sh start.sh

# make the script executable
RUN chmod +x start.sh

# Final cleanup (if needed)
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir -p /opt/hostedtoolcache
RUN chown -R docker:docker /opt/hostedtoolcache

# since the config and run script for actions are not allowed to be run by root,
# set the user to "docker" so all subsequent commands are run as the docker user
USER docker

RUN node -v
RUN mc --help
RUN vault --version
RUN deck version

ENTRYPOINT ["./start.sh"]