pipeline {
    agent { label 'agent-node' }
    stages {
        stage('Build') {
            steps {
                sh 'npm install'
                sh 'node index.js'
            }
        }
    }
}
