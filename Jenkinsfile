pipeline {
    agent any

    environment {
        DOCKER_HUB = "deepwhoo/devops-build"  // Replace with your DockerHub repo
        AWS_REGION = "ap-south-1"
        CLUSTER_NAME = "devops-build-cluster"
        K8S_DIR = "k8s"
    }

    stages {

        stage('Checkout Code') {
            steps {
                git branch: 'dev', url: 'https://github.com/sriram-R-krishnan/devops-build.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh """
                        echo "Building Docker image..."
                        docker build -t $DOCKER_HUB:${BUILD_NUMBER} .
                        docker tag $DOCKER_HUB:${BUILD_NUMBER} $DOCKER_HUB:latest
                    """
                }
            }
        }

        stage('Login to DockerHub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh """
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                    """
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                sh """
                    docker push $DOCKER_HUB:${BUILD_NUMBER}
                    docker push $DOCKER_HUB:latest
                """
            }
        }

        stage('Configure Kubeconfig') {
            steps {
                sh """
                    aws eks update-kubeconfig --region $AWS_REGION --name $CLUSTER_NAME
                """
            }
        }

        stage('Deploy to EKS') {
            steps {
                script {
                    sh """
                        kubectl apply -f $K8S_DIR/
                        kubectl rollout status deployment/devops-build-deployment
                    """
                }
            }
        }

        stage('Clean Up Docker Images') {
            steps {
                sh """
                    docker rmi $DOCKER_HUB:${BUILD_NUMBER} || true
                    docker rmi $DOCKER_HUB:latest || true
                """
            }
        }
    }

    post {
        success {
            echo "✅ Deployment successful! Access your app at: http://a88b13b8a168443a5862667496ea0cf4-869908835.ap-south-1.elb.amazonaws.com"
        }
        failure {
            echo "❌ Deployment failed. Check Jenkins logs for details."
        }
    }
}
