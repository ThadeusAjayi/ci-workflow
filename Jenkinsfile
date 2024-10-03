pipeline {
    agent { label 'shiftacare' }
    stages {
        stage('Build') {
            steps {
                sh '''
                    export NVM_DIR="$HOME/.nvm" && [ -s "$NVM_DIR/nvm.sh" ] && \\. "$NVM_DIR/nvm.sh" && nvm install 20
                    . ~/.nvm/nvm.sh
                    npm install
                    pm2 start index.js --name express --watch
                '''
            }
        }
    }
}
