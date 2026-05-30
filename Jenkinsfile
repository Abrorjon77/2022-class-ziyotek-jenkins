pipeline {
    agent any

    stages {
        stage('Prep') {
            steps {
                echo 'Preparing...'
                sh 'aws --version'
                sh 'terraform --version'
            }
        }
        stage('Build') {
            steps {
                sh '''
                    cd terraform
                    terraform init
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
