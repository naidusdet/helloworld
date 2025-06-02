pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "maheshboyalla/helloworld:latest"
        KUBECONFIG = "$HOME/.kube/config"
    }

    options {
        skipDefaultCheckout(true) // Jenkins already checks out source
    }

    stages {
        stage('Check Branch') {
            when {
                not {
                    branch 'master'
                }
            }
            steps {
                echo "⛔ Skipping build — this pipeline runs only on 'master' branch."
                script {
                    currentBuild.result = 'NOT_BUILT'
                    error("Build aborted: not on 'master' branch.")
                }
            }
        }

        stage('Build') {
            when {
                branch 'master'
            }
            steps {
                sh 'ls -la'
                sh './gradlew clean build'
            }
        }

        stage('Docker Compose Build & Push') {
            when {
                branch 'master'
            }
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-credentials',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh '''
                        echo "🔧 Logging in to Docker..."
                        mkdir -p ~/.docker-no-creds
                        echo '{ "credsStore": "" }' > ~/.docker-no-creds/config.json

                        export DOCKER_CONFIG=~/.docker-no-creds
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin

                        echo "🧹 Cleaning up old containers..."
                        docker-compose down || true

                        echo "🐳 Building image with docker-compose..."
                        export DOCKER_IMAGE=$DOCKER_IMAGE
                        docker-compose up --build -d

                        echo "📦 Pushing image to Docker Hub..."
                        docker push $DOCKER_IMAGE

                        echo "🧹 Shutting down containers..."
                        docker-compose down

                        docker logout
                    '''
                }
            }
        }

        stage('Deploy to Kubernetes') {
            when {
                branch 'master'
            }
            steps {
                sh '''
                    echo "🚀 Deploying to Kubernetes..."
                    kubectl apply -f helloworld-config.yaml
                    kubectl apply -f helloworld-deployment.yaml
                    kubectl apply -f services.yaml
                    kubectl apply -f helloworld-ingress.yaml
                    kubectl rollout restart deployment helloworld-deployment
                '''
            }
        }
    }

    post {
        success {
            mail to: 'emailmenaidu@gmail.com',
                 subject: "✅ Build Success: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                 body: "Build on master succeeded. View at ${env.BUILD_URL}"
        }
        failure {
            mail to: 'emailmenaidu@gmail.com',
                 subject: "❌ Build Failed: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                 body: "Build on master failed. Check logs at ${env.BUILD_URL}"
        }
    }
}
