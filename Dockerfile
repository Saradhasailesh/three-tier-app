FROM amazon/aws-cli:latest

ENV TERRAFORM_VERSION=1.6.6

RUN yum update && yum install -y wget unzip git && \
    wget --version && \

    # terraform
    wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    echo $PATH && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/local/bin/ && \
    ls -l /usr/local/bin/ && \
    terraform -version && \
    rm -rf terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \

    # tfsec
    curl -s https://raw.githubusercontent.com/aquasecurity/tfsec/master/scripts/install_linux.sh | bash && \
    tfsec --version && \
    
    # Clean up
    yum clean && rm -rf /var/lib/apt/lists/*

CMD ["/bin/bash"]    