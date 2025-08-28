pipeline {
    agent any

    environment {
        DOCKER_HUB = "deepwhoo/devops-build"       // Your DockerHub repo
        AWS_REGION = "ap-south-1"
        CLUSTER_NAME = "devops-build-cluster"
        K8S_DIR = "k8s"
    }

    stages {

        stage('Checkout Code') {
            steps {
                git branch: 'dev', url: 'https://github.com/Deepak-r-2001/devops-build.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh '''
                        set -e
                        echo "🚀 Building Docker image..."
                        docker build --no-cache -t $DOCKER_HUB:${BUILD_NUMBER} .
                        docker tag $DOCKER_HUB:${BUILD_NUMBER} $DOCKER_HUB:latest
                    '''
                }
            }
        }

        stage('Login to DockerHub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh '''
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                    '''
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                sh '''
                    set -e
                    docker push $DOCKER_HUB:${BUILD_NUMBER}
                    docker push $DOCKER_HUB:latest
                '''
            }
        }

        stage('Configure Kubeconfig') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-eks-creds']]) {
                    sh '''
                        set -e
                        echo "🔧 Updating kubeconfig for EKS..."
                        aws eks update-kubeconfig --region $AWS_REGION --name $CLUSTER_NAME
                    '''
                }
            }
        }

        stage('Deploy to EKS') {
            steps {
                script {
                    sh '''
                        set -e
                        echo "🚀 Deploying to EKS..."
                        kubectl apply -f $K8S_DIR/
                        kubectl rollout status deployment/devops-build-deployment
                        echo "✅ Deployment successful!"
                        echo "🌍 App URL: $(kubectl get svc devops-build-service -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')"
                    '''
                }
            }
        }

        stage('Clean Up Docker Images') {
            steps {
                sh '''
                    docker rmi $DOCKER_HUB:${BUILD_NUMBER} || true
                    docker rmi $DOCKER_HUB:latest || true
                '''
            }
        }
    }

    post {
        success {
            echo "✅ Build & Deployment successful!"
        }
        failure {
            echo "❌ Deployment failed. Check Jenkins logs for details."
        }
    }
}
