pipeline {
    agent { label 'Jenkins-api' }
    stages {
        stage('Build') {
            steps {
                sh 'npm install'
                sh 'node index.js'
            }
        }
    }
}
