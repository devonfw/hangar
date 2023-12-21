FROM python:3.7-slim as base

RUN apt-get update && apt-get install --no-install-recommends curl unzip git wget less gettext-base default-jre -y && apt-get clean && rm -rf /var/lib/apt/lists/*


FROM base as cli_install_gcloud

WORKDIR /downloaded_assets

# Install gcloud

FROM cli_install_gcloud as cli_install_aws

# Install aws
RUN curl -L https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm awscliv2.zip && rm -rf aws

FROM cli_install_aws as cli_install_azure

# Install azure
RUN (curl -sL https://aka.ms/InstallAzureCLIDeb | bash) && rm -rf /var/lib/apt/lists/*

FROM cli_install_azure as cli_install_kubectl

# Install kubectl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.25.2/bin/linux/amd64/kubectl && \
    chmod +x kubectl && \
    mv kubectl /usr/bin/kubectl

# Alias kubectl?
# RUN echo 'alias kc=kubectl' >> ~/.bashrc

FROM cli_install_kubectl as cli_install_terraform
RUN curl -L https://releases.hashicorp.com/terraform/1.3.0/terraform_1.3.0_linux_amd64.zip -o terraform.zip && \
    unzip terraform.zip && \
    mv terraform /usr/local/bin/ && \
    rm terraform.zip

FROM cli_install_terraform as cli_install_github
RUN curl -L https://github.com/cli/cli/releases/download/v2.16.0/gh_2.16.0_linux_amd64.deb -o gh.deb && \
    dpkg -i gh.deb && \
    rm gh.deb

FROM cli_install_github as cli_install_firebase

RUN curl -Lo ./firebase_tools https://firebase.tools/bin/linux/v11.16.0 && \
    chmod +x ./firebase_tools && \
    mv firebase_tools /usr/bin/firebase

FROM cli_install_firebase as run_env

ARG KEY_ONE
ARG KEY_TWO

ENV ssh_prv_key=$KEY_ONE
ENV ssh_pub_key=$KEY_TWO

WORKDIR /scripts

ADD scripts .

CMD ["/bin/bash", "-c"]
