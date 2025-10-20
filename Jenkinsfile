pipeline {
    agent any

    environment {
        SONARQUBE = 'SonarQubeServer'
        IMAGE_NAME = 'spring-petclinic-app'
        SLACK_TOKEN = credentials('slack-bot-token')
    }

    stages {
        stage('Pulling Code from GitHub') {
            steps {
                git branch: 'main', url: 'https://github.com/mofayad96/spring-petclinic-Ci-CD.git'
                script {
                    // Get short Git commit hash dynamically
                    env.IMAGE_TAG = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                    echo "IMAGE_TAG set to ${env.IMAGE_TAG}"
                }
            }
        }

        stage('SonarQube Static Code Analysis') {
            steps {
                withSonarQubeEnv(SONARQUBE) {
                    sh 'mvn clean install sonar:sonar -DskipTests -Dsonar.projectKey=myspring-petclinic'
                }
            }
        }

        stage('Building App Docker Image') {
            steps {
                //USING MULTISTAGE DOCKER FILE
                sh "docker build -t ${env.IMAGE_NAME}:${env.IMAGE_TAG} -f Dockerfile.multistage ."
            }
        }

        stage('Scan Image Using Trivy') {
            steps {
                //IF CRITICAL VULN FOUND -> EXIT PIPELINE  
                sh """
                    docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
                    bitnami/trivy:latest image --skip-version-check --timeout 10m \
                    --severity CRITICAL --exit-code 1 ${env.IMAGE_NAME}:${env.IMAGE_TAG}
                """
            }
        }

        stage('Push Image to Docker Hub') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'd8f48c63-aa69-4c62-b6cf-5d1ded3e1332',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASS'
                    )
                ]) {
                    sh '''
                        echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                        docker tag ${IMAGE_NAME}:${IMAGE_TAG} deaddeal96/spring-petclinic:${IMAGE_TAG}
                        docker push deaddeal96/spring-petclinic:${IMAGE_TAG}
                        docker logout
                    '''
                }
            }
        }
    }

    post {
        success {
            slackSend(
                channel: 'jenkins_messages',
                color: 'good',
                message: "Build SUCCESS: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                tokenCredentialId: 'slack-bot-token'
            )
        }
        failure {
            slackSend(
                channel: 'jenkins_messages',
                color: 'danger',
                message: "Build FAILED: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                tokenCredentialId: 'slack-bot-token'
            )
        }
        unstable {
            slackSend(
                channel: 'jenkins_messages',
                color: 'warning',
                message: "Build UNSTABLE: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                tokenCredentialId: 'slack-bot-token'
            )
        }
    }
}
