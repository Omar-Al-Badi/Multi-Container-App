pipeline {
    agent any

    stages {
        stage('Clone Repository') {
            steps {
                git(
                    url: 'https://github.com/Omar-Al-Badi/Multi-Container-App.git',
                    branch: 'main'
                )
            }
        }

        stage('Expose App to Port 3000') {
            steps {
                script {
                    sh 'docker compose up'
                }
            }
        }
    }
}
