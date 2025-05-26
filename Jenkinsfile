pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "maheshboyalla/helloworld:latest"
        KUBECONFIG = "$HOME/.kube/config"
    }

    // Run this pipeline only on master
    when {
        branch 'master'
    }

    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/naidusdet/helloworld.git'
            }
        }

        stage('Parallel Execution') {
            parallel {
                stage('Build') {
                    steps {
                        sh 'ls -la'
                        sh './gradlew clean build'
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
                            '''
                        }
                    }
                }

                stage('Deploy to Kubernetes') {
                    steps {
                        sh 'kubectl apply -f helloworld-config.yaml'
                        sh 'kubectl apply -f helloworld-deployment.yaml'
                        sh 'kubectl apply -f services.yaml'
                        sh 'kubectl apply -f helloworld-ingress.yaml'
                        sh 'kubectl rollout restart deployment helloworld-deployment'
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
