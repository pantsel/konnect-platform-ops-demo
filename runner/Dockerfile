FROM catthehacker/ubuntu:act-latest

# Prevents installdependencies.sh from prompting the user and blocking the image creation
ARG DEBIAN_FRONTEND=noninteractive

RUN apt update -y && apt upgrade -y
RUN apt install -y --no-install-recommends \
    curl jq build-essential libssl-dev libffi-dev python3 python3-venv python3-dev python3-pip unzip nodejs gnupg software-properties-common apt-transport-https wget lsb-release ca-certificates netcat-openbsd bats

RUN rm -rf /var/lib/apt/lists/*

# Install Trivy
RUN wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | apt-key add -
RUN echo deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main | tee -a /etc/apt/sources.list.d/trivy.list
RUN apt-get update
RUN apt-get install trivy

# Intsall node js 20
RUN curl -sL https://deb.nodesource.com/setup_20.x | bash -
RUN apt-get install -y nodejs
RUN npm install -g @stoplight/spectral-cli

# Install yq
RUN add-apt-repository ppa:rmescandon/yq
RUN apt update
RUN apt install yq -y

# Install k6
RUN gpg -k
RUN gpg --no-default-keyring --keyring /usr/share/keyrings/k6-archive-keyring.gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C5AD17C747E3415A3642D57D77C6C491D6AC1D69
RUN echo "deb [signed-by=/usr/share/keyrings/k6-archive-keyring.gpg] https://dl.k6.io/deb stable main" | sudo tee /etc/apt/sources.list.d/k6.list
RUN apt-get update
RUN apt-get install k6


# Download MinIO client (mc), make it executable, and add to PATH
RUN mkdir -p $HOME/minio-binaries
RUN curl https://dl.min.io/client/mc/release/linux-arm64/mc \
    --create-dirs \
    -o ~/minio-binaries/mc

RUN chmod +x $HOME/minio-binaries/mc
RUN cp $HOME/minio-binaries/mc /usr/local/bin/mc

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
RUN tar -xf deck.tar.gz -C /tmp
RUN cp /tmp/deck /usr/local/bin/

# Final cleanup (if needed)
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN node -v
RUN mc --help
RUN vault --version
RUN deck version
