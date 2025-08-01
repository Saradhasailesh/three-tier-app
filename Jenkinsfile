pipeline {
    agent any

    environment {
        IMAGE_TAG = "v${BUILD_ID}"
        AWS_REGION = credentials('AWS_REGION')
        AWS_ACCOUNT_ID = credentials('AWS_ACCOUNT_ID')
        IMAGE_NAME = "three-tier-app"
        ECR_REGISTRY_URI = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
        FULL_IMAGE_URI = "${ECR_REGISTRY_URI}/demo/${IMAGE_NAME}:${IMAGE_TAG}"
    }

    stages {
        stage ('Install AWS CLI') {
            steps{
                // Update and install curl, unzip
                sh '''
                        apt-get update
                        apt-get install -y curl unzip
                    
                    '''
                // Install AWS CLI v2    
                sh '''
                    if command -v aws &> /dev/null; then
                       echo "AWS CLI already installed."   
                    else
                        echo "AWS CLI not found. Installing..."
                        curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
                        unzip -o awscliv2.zip
                        ./aws/install
                    fi  
                    '''
                // Install Docker CE (official method)    
                sh  ''' 
                    if command -v docker &> /dev/null; then
                        echo "Dcoker is already installed."
                        
                    else 
                        echo "Installing docker..."
                        apt-get install ca-certificates curl
                        install -m 0755 -d /etc/apt/keyrings
                        curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
                        chmod a+r /etc/apt/keyrings/docker.asc

                        # Add the repository to Apt sources:
                        echo \
                        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
                        $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
                        tee /etc/apt/sources.list.d/docker.list > /dev/null
                        apt-get update
                        apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin 
                    fi       
                    '''    
            }
        }   
       
        stage ('build-image') {
            steps {
                script {
                    sh "docker build -t '${IMAGE_NAME}:${IMAGE_TAG}' ."
                }
            }
        }

        stage ('ecr login') {
            steps {
                withAWS(credentials: 'aws-demo-credentials', region: "${AWS_REGION}") {
                sh "aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS password-stdin ${ECR_REGISTRY_URI}"
                }
            }
        }
        stage ('Tag and push to ecr') {
            steps {
                script {
                     // Tag the image with the ECR URI
                    sh "docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${FULL_IMAGE_URI}"
                    // Push the image to ECR
                    sh "docker push ${FULL_IMAGE_URI}"
                }
            }
        }
    }
}