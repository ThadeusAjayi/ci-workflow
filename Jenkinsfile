pipeline {
    agent { label 'api-node' }
    stages {
        stage('Build') {
            steps {
                sh 'chmod +x ./startshell.sh'
                sh './startshell.sh'
            }
        }
    }
}
