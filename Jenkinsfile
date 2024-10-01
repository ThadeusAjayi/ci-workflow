pipeline {
    agent { label 'api-node' }
    stages {
        stage('Build') {
            steps {
                sh 'npm install'
                sh 'node index.js'
            }
        }
    }
}
