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
        stage ('build-image') {
            steps {
                script {
                    sh "docker build --no-cache -t '${IMAGE_NAME}:${IMAGE_TAG}' ."
                }
            }
        }

        stage ('ecr login') {
            steps {
                withAWS(region: "${AWS_REGION}", credentials: 'AWS_credentials')
                sh "aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REGISTRY_URI}"
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