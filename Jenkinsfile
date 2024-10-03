pipeline {
    agent { label 'shiftacare' }
    stages {
        stage('Setup nvm') {
            steps {
                sh 'apt-get update && yes | apt install curl'
                sh 'curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash'
                sh 'export NVM_DIR="$HOME/.nvm" && [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" && nvm install 20'
            }
        }
        stage('Build') {
            steps {
                sh 'chmod +x ./startshell.sh'
                sh './startshell.sh'
            }
        }
    }
}
