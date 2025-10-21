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

        stage('OWASP Dependency Check') {
            steps {
                dependencyCheck additionalArguments: '--scan . --format HTML', odcInstallation: 'Default'
            }
            post {
                always {
                    dependencyCheckPublisher pattern: '**/dependency-check-report.html'
                }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                script {
                    def scannerHome = tool 'sonarqube'
                    withSonarQubeEnv('sonarqube') {
                        sh """
                            ${scannerHome}/bin/sonar-scanner \
                            -Dsonar.projectKey=shop-app \
                            -Dsonar.projectName=\"shop-app\" \
                            -Dsonar.sources=. \
                            -Dsonar.java.binaries=target
                        """
                    }
                }
            }
        }

        stage('Dockerized the app') {
            steps {
                echo "this is dockerize stage"
                sh 'docker build -t java-shop -f Dockerfile .'
            }
        }

        stage('Scan Image with Trivy') {
            steps {
                echo "Scanning image for vulnerabilities..."
                sh '''
                    # Generate JSON report (for archiving)
                    trivy image --timeout 15m --scanners vuln \
                        --format json -o trivy-report.json \
                        --severity HIGH,CRITICAL \
                        java-shop

                    # Generate HTML report (for easy viewing) using template
                    trivy image --timeout 15m --scanners vuln \
                        --format template \
                        --template "@/usr/local/share/trivy/templates/html.tpl" \
                        -o trivy-report.html \
                        --severity HIGH,CRITICAL \
                        java-shop

                    # Also generate a full report (all severities) for reference
                    trivy image --timeout 15m --scanners vuln \
                        --format template \
                        --template "@/usr/local/share/trivy/templates/html.tpl" \
                        -o trivy-report-full.html \
                        java-shop
                '''
            }
            post {
                always {
                    echo "Archiving Trivy scan reports..."
                    archiveArtifacts artifacts: 'trivy-report.json', fingerprint: true
                    publishHTML([
                        allowMissing: false,
                        alwaysLinkToLastBuild: true,
                        keepAll: true,
                        reportDir: '.',
                        reportFiles: 'trivy-report.html',
                        reportName: 'Trivy Security Report (HIGH/CRITICAL)',
                        reportTitles: 'Trivy Security Scan'
                    ])
                    publishHTML([
                        allowMissing: false,
                        alwaysLinkToLastBuild: true,
                        keepAll: true,
                        reportDir: '.',
                        reportFiles: 'trivy-report-full.html',
                        reportName: 'Trivy Full Report (All Severities)',
                        reportTitles: 'Trivy Full Scan'
                    ])
                }
            }
        }

        stage('login and push') {
            steps {
                echo "this is login and push stage"
                withCredentials([usernamePassword(credentialsId: 'docker-hup', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                    sh '''
                        echo "$PASS" | docker login -u "$USER" --password-stdin
                        docker tag java-shop "$USER/java-shop"
                        docker push "$USER/java-shop"
                    '''
                }
            }
        }

        stage('deploy to k8s') {
            steps {
                echo "Deploying app to Kubernetes cluster..."
                withCredentials([file(credentialsId: 'k8s', variable: 'kube')]) {
                    sh '''
                        export PATH=$PATH:/home/jenkins/bin
                        kubectl config view --kubeconfig=./k8s/config
                        kubectl apply -f ./k8s/deploy.yml --context sallam --kubeconfig k8s/config
                        echo "all good"
                    '''
                }
            }
        }
    }
    post {
        success {
            slackSend (
                channel: '#jenkins-ci',
                message: "Build Success - ${env.JOB_NAME} ${env.BUILD_NUMBER} (<${env.BUILD_URL}|Open>)",
                teamDomain: 'jenkinstest-xxj7763',
                tokenCredentialId: 'slack-notificate'
            )
        }
        failure {
            slackSend (
                channel: '#jenkins-ci',
                message: "Build Failed - ${env.JOB_NAME} ${env.BUILD_NUMBER} (<${env.BUILD_URL}|Open>)",
                teamDomain: 'jenkinstest-xxj7763',
                tokenCredentialId: 'slack-notificate'
            )
        }
    }
}