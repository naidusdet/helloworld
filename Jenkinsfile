pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "maheshboyalla/helloworld:latest"
        KUBECONFIG = "$HOME/.kube/config"
    }

    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/naidusdet/helloworld.git'
            }
        }
        stage('Build') {
            steps {
                sh 'ls -la'
                sh './gradlew clean build'
            }
        }
       stage('Docker Compose Build & Push') {
           steps {
               withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                   sh '''
                       mkdir -p ~/.docker-no-creds
                        echo '{ "credsStore": "" }' > ~/.docker-no-creds/config.json
                         DOCKER_CONFIG=~/.docker-no-creds echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                        # Stop and remove previous containers
                        docker-compose down
                       # Build using docker-compose
                       DOCKER_IMAGE=$DOCKER_IMAGE docker-compose up --build -d

                       # Push the built image manually (docker-compose does not push images)
                       docker push $DOCKER_IMAGE

                       docker-compose down
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
