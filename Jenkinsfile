pipeline {
    agent { label 'shiftacare' }
    stages {
        stage('Build') {
            steps {
                sh 'chmod +x ./startshell.sh'
                sh './startshell.sh'
            }
        }
    }
}
