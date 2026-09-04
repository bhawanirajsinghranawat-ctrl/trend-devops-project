pipeline {
    agent any

    stages {
        stage('Build Docker Image') {
            steps {
                sh '''
                    echo "Building Trend Docker image..."
                    docker build -t trend-app:${BUILD_NUMBER} .
                    docker tag trend-app:${BUILD_NUMBER} trend-app:latest
                '''
            }
        }

        stage('Verify Docker Image') {
            steps {
                sh '''
                    echo "Docker images:"
                    docker images trend-app
                '''
            }
        }

        stage('Push to Docker Hub') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub-credentials',
                        usernameVariable: 'DOCKER_USERNAME',
                        passwordVariable: 'DOCKER_PASSWORD'
                    )
                ]) {
                    sh '''
                        echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin

                        docker tag trend-app:latest $DOCKER_USERNAME/trend-app:latest
                        docker push $DOCKER_USERNAME/trend-app:latest

                        docker logout
                    '''
                }
            }
        }
    }
}
