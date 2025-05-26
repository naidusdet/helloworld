pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "maheshboyalla/helloworld:latest"
        KUBECONFIG = "$HOME/.kube/config"
    }

    when {
        branch 'master'
    }

    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/naidusdet/helloworld.git'
            }
        }

        stage('Build & Docker Push') {
            parallel {
                stage('Build') {
                    steps {
                        sh 'ls -la'
                        sh './gradlew clean build'
                        archiveArtifacts artifacts: 'build/libs/**/*.jar', fingerprint: true
                    }
                }

                stage('Docker Build & Push') {
                    steps {
                        withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                            sh '''
                                echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                                docker build -t $DOCKER_IMAGE .
                                docker push $DOCKER_IMAGE
                                docker logout
                                docker image prune -f
                            '''
                        }
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    retry(2) {
                        sh '''
                            kubectl apply -f helloworld-config.yaml
                            kubectl apply -f helloworld-deployment.yaml
                            kubectl apply -f services.yaml
                            kubectl apply -f helloworld-ingress.yaml
                            kubectl rollout restart deployment helloworld-deployment
                        '''
                    }
                }
            }
        }
    }

    post {
        success {
            mail to: 'emailmenaidu@gmail.com',
                 subject: "✅ Build Success: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                 body: "Build succeeded. View it at ${env.BUILD_URL}"
        }
        failure {
            mail to: 'emailmenaidu@gmail.com',
                 subject: "❌ Build Failed: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                 body: "Build failed. Check logs at ${env.BUILD_URL}"
        }
    }
}
