pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Verify Source') {
            steps {
                sh '''
                    echo "Repository checkout successful"
                    echo "Current directory:"
                    pwd

                    echo "Files:"
                    ls -la
                '''
            }
        }
    }
}
