pipeline {
    agent { label 'slave-1' }
    tools {
        maven 'mvn363'   
        jdk 'java8'      
    }
    stages {
        stage('build') {
            steps {
                echo "this is build stage"
                sh 'mvn clean package -DskipTests'
            }
        }
        
        stage('unit test') {
            steps {
                echo "this is test stage"
                sh 'mvn test'
            }
        }

        stage('Dockerized the app') {
            steps {
                echo "this is dockerize stage"
                sh 'docker build -t java-shop -f Dockerfile .'
            }
        }
    }
}