pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "deepwhoo/devops-build"
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
                    sh """
                        docker build -t $DOCKER_IMAGE:latest .
                    """
                }
            }
        }

        stage('Push to DockerHub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh """
                        echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
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
                        kubectl set image deployment/devops-app devops-app=$DOCKER_IMAGE:latest -n default || kubectl apply -f k8s/deployment.yaml
                        kubectl rollout status deployment/devops-app -n default
                    """
                }
            }
        }
    }

    post {
        success {
            echo '✅ Deployment Successful!'
        }
        failure {
            echo '❌ Deployment Failed'
        }
    }
}
