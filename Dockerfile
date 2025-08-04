FROM amazon/aws-cli:latest

ENV TERRAFORM_VERSION=1.12.2

RUN apt-get update && apt-get install -y wget unzip git && \
    wget --version \

    # terraform
    wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    echo $PATH && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/local/bin/ && \
    ls -l /usr/local/bin/ && \
    terraform -version && \
    rm -rf terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \

    # tfsec
    curl -L "$(curl -s https://api.github.com/repos/tfsec/tfsec/releases/latest | grep -o -E "https://.+tfsec-linux-amd64")" -o tfsec && \
    chmod +x tfsec && \
    mv tfsec /usr/local/bin && \
    tfsec --version && \
    
    # Clean up
    apt-get clean && rm -rf /var/lib/apt/lists/*

CMD ["/bin/bash"]    