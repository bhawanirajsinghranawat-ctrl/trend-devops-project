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
    }
}
