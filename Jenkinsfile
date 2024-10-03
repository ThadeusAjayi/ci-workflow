pipeline {
    agent { label 'shiftacare' }
    stages {
        stage('Build') {
            steps {
                sh '''
                    apt-get update && yes | apt install curl
                    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash
                    export NVM_DIR="$HOME/.nvm" && [ -s "$NVM_DIR/nvm.sh" ] && \\. "$NVM_DIR/nvm.sh" && nvm install 20
                    chmod +x ./startshell.sh
                    ./startshell.sh
                '''
            }
        }
    }
}
