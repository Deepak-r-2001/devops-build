pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('docker-hub')   // Use your DockerHub credentials ID in Jenkins
        GITHUB_TOKEN = credentials('github-token')          // Use your GitHub PAT credentials ID in Jenkins
        DOCKER_IMAGE = "deepwhoo/devops-build"
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'dev', url: "https://github.com/Deepak-r-2001/devops-build.git"
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh """
                        docker build -t $DOCKER_IMAGE:latest .
                    """
                }
            }
        }

        stage('Push to DockerHub') {
            steps {
                script {
                    sh """
                        echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin
                        docker push $DOCKER_IMAGE:latest
                    """
                }
            }
        }

        stage('Deploy to EKS') {
            steps {
                script {
                    sh """
                        aws eks --region ap-south-1 update-kubeconfig --name brain-tasks-cluster
                        kubectl apply -f k8s/deployment.yaml
                        kubectl apply -f k8s/service.yaml
                    """
                }
            }
        }
    }

    post {
        success {
            echo '✅ Deployment Successful'
        }
        failure {
            echo '❌ Deployment Failed'
        }
    }
}
