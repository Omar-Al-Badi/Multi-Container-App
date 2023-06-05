pipeline {
    agent any

    stages {
        stage('ssh-agent'){
            steps{

                sshagent(['ssh-agent']) {
                    sh 'ssh -tt -o StrictHostKeyChecking=no ubuntu@52.207.187.136 mkdir testing'
                }
                
            }
            
        }
        
    }
}
