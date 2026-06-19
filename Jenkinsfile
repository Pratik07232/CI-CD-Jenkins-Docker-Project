pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "pratikgadekar/my-app"
        DOCKER_TAG   = "${env.BUILD_NUMBER}"
        DOCKER_CREDS = credentials('dockerhub-credentials')
    }

    stages {
        stage('Checkout') {
            steps {
                echo '==> Checking out source code from GitHub...'
                checkout scm
            }
        }

        stage('Build') {
            steps {
                echo '==> Building Docker image...'
                sh "docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} -f app/Dockerfile app"
                sh "docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_IMAGE}:latest"
            }
        }

        stage('Test') {
            steps {
                echo '==> Running tests inside container...'
                sh "docker run --rm ${DOCKER_IMAGE}:${DOCKER_TAG} npm test || true"
            }
        }

        stage('Push to DockerHub') {
            steps {
                echo '==> Pushing image to DockerHub...'
                sh "echo ${DOCKER_CREDS_PSW} | docker login -u ${DOCKER_CREDS_USR} --password-stdin"
                sh "docker push ${DOCKER_IMAGE}:${DOCKER_TAG}"
                sh "docker push ${DOCKER_IMAGE}:latest"
            }
        }

        stage('Deploy') {
            steps {
                echo '==> Deploying container to server...'
                sh """
                    docker stop my-app || true
                    docker rm   my-app || true
                    docker pull ${DOCKER_IMAGE}:latest
                    docker run -d --name my-app -p 80:5000 ${DOCKER_IMAGE}:latest
                """
            }
        }
    }

    post {
        success {
            echo '✅ Pipeline succeeded! App is live.'
        }
        failure {
            echo '❌ Pipeline failed. Check logs above.'
        }
        always {
            sh 'docker logout'
            sh "docker rmi ${DOCKER_IMAGE}:${DOCKER_TAG} || true"
        }
    }
}
