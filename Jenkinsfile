pipeline {
    agent any

    environment {
        // BUILD_TIMESTAMP = "${new Date().format('yyyyMMdd-HHmmss')}"
        // IMAGE_TAG = "${BUILD_TIMESTAMP}"
        // AWS_REGION = credentials('AWS_REGION')
        // AWS_ACCOUNT_ID = credentials('AWS_ACCOUNT_ID')
        // IMAGE_NAME = "three-tier-app"
        // ECR_REGISTRY_URI = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
        // FULL_IMAGE_URI = "${ECR_REGISTRY_URI}/demo/${IMAGE_NAME}:${IMAGE_TAG}"
        TERRAFORM_VERSION = '1.12.0'
        TERRAFORM_DIR = 'terraform'
        ACTION = "${params.TF_ACTION}" //'plan', 'apply', or 'destroy'
    }

    parameters {
        choice (name: 'TF_ACTION', choices: ['plan', 'apply', 'destroy'], description: 'Select Terraform action')
    }

    stages {
        // stage ('build-image') {
        //     steps {
        //         script {
        //             sh "docker build --no-cache -t '${IMAGE_NAME}:${IMAGE_TAG}' ."
        //         }
        //     }
        // }

        // stage ('ecr login') {
        //     steps {
        //         withAWS(credentials:'AWS_credentials', region: "${AWS_REGION}"){
        //         sh "aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REGISTRY_URI}"
        //         }
        //     }
        // }
        // stage ('Tag and push to ecr') {
        //     steps {
        //         script {
        //              // Tag the image with the ECR URI
        //             sh "docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${FULL_IMAGE_URI}"
        //             // Push the image to ECR
        //             sh "docker push ${FULL_IMAGE_URI}"
        //         }
        //     }
        // }

        stage ('Install dependencies') {
            steps{
                sh """
                    apt-get update && 
                    apt-get install -y wget unzip git python3 python3-pip python3-venv docker.io &&
                    wget --version &&
                    docker --version &&

                    # aws-cli
                    python3 -m venv /opt/awscli-venv &&
                    . /opt/awscli-venv/bin/activate &&
                    pip install --upgrade pip && 
                    pip install awscli && 

                    # terraform
                    wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip &&
                    echo $PATH && 
                    unzip -o -q terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/local/bin/ &&
                    ls -l /usr/local/bin/ && 
                    terraform -version && 
                    rm -rf terraform_${TERRAFORM_VERSION}_linux_amd64.zip &&

                    # trivy
                    wget https://github.com/aquasecurity/trivy/releases/latest/download/trivy_0.65.0_Linux-64bit.deb &&
                    dpkg -i trivy_0.65.0_Linux-64bit.deb &&
                    
                    # Clean up
                    apt-get clean && rm -rf /var/lib/apt/lists/* 
                 """
            }
        }
        stage ('Terraform Plan') {
            when {
                expression {params.TF_ACTION == 'plan'}
            }
            steps{
              dir("${TERRAFORM_DIR}") {
                withCredentials([file(credentialsId: 'TF_FILE', variable: 'TF_FILE')]) {  
                  sh """      
                    pwd
                    ls -l

                    # init
                    terraform init

                    # format
                    terraform fmt

                    # validate
                    terraform validate

                    trivy config ./ > trivy-report.txt || true

                    # plan

                    terraform plan -var-file=${TF_FILE} -out=tfplan.out
                    """
                    }

                    // Archive 
                    archiveArtifacts artifacts: 'trivy-report.txt',  fingerprint: true
                    archiveArtifacts artifacts: 'tfplan.out', fingerprint: true
                    
                }
            }
        }
        stage ('Terraform Apply with Approval') {
            when {
                expression { params.TF_ACTION == 'apply'}
            }
            steps {
                dir("${TERRAFORM_DIR}") {
                    withCredentials([file(credentialsId: 'TF_FILE', variable: 'TF_FILE')]) { 
                        sh """
                            terraform init
                            terraform fmt
                            terraform validate
                            terraform plan -var-file=${TF_FILE} -out=tfplan.out
                            terraform show tfplan.out
                        """
                        // Manual approval
                        script {
                            def userInput = input(
                                id:'ApproveApply', message:'Do you want to APPLY these Terraform changes?',
                                parameters: [
                                    choice(choices: ['Apply', 'Cancel'], description: 'Choose what to do', name:'action')
                                ]
                            )
                            if(userInput == 'Apply'){
                                sh 'terraform apply --auto-approve tfplan.out'
                            } else {
                                sh 'echo "Terraform apply cancelled by user."'
                            }

                        }
                    }    
                     
                }
            
            }
        }
        stage ('Destroy Infrastructure') {
            when {
                expression { params.TF_ACTION == 'destroy'}
            }
            steps{
                dir("${TERRAFORM_DIR}") {
                    withCredentials([file(credentialsId: 'TF_FILE', variable: 'TF_FILE')]) { 
                        script {
                            def userInput = input(
                                id: 'Destroy Infra', message: 'Do you want to DESTROY all the resources?',
                                parameters: [
                                    choice(choices: ['Destroy', 'Cancel'], description: 'Choose what to do', name: 'action')
                                ]
                            )
                            if (userInput == 'Destroy') {
                                sh 'terraform destroy -var-file=${TF_FILE} --auto-approve'
                            } else {
                                sh 'echo "Terrafrom destroy cancelled by user."'
                            }
                        }
                    }    
                }
            }
        }
    }
}