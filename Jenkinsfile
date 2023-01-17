pipeline {
    agent any

    stages {
        stage('Prep') {
            steps {
                echo 'Building..'
            }
        }
        stage('Build') {
            steps {
                sh '''
                cd terraform
                terraform init
                aws --version
                '''
            }
        }
        stage('Deploy') {
            steps {
                sh '''
                echo 'Deploying terraform infrastructure'
                cd terraform
                terraform apply -auto-approve
                '''
            }
        }
    }
}
