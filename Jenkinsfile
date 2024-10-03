pipeline {
    agent { label 'shiftacare' }
    stages {
        stage('Build') {
            steps {
                sh '''
                    . ~/.nvm/nvm.sh
                    chmod +x ./startshell.sh
                    ./startshell.sh
                '''
            }
        }
    }
}
