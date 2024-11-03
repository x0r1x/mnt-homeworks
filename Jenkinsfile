pipeline {
    agent {
      label 'centos'
    }
    
    stages {
        stage('Get project') {
            steps {
                sh 'rm -r ./ansible-vector'
                sh 'git clone https://github.com/x0r1x/ansible-vector.git && cd ansible-vector'
            }
        }
        stage('Test project from Molecule') {
            steps {
                sh 'cd ansible-vector/ && sudo python -m molecule test'
            }
        }
    }   
}
