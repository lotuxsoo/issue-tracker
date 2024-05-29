pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('docker_token')
        DOCKER_IMAGE = 'tndus5383/issue-tracker'
        EC2_CREDENTIALS = credentials('my-keypair')
        SSH_USER = 'ubuntu'
        EC2_INSTANCE_IP = '3.36.70.238'
        ENCODED_DB_CONFIG = credentials('DBCONFIG-YML')
        ENCODED_JWT = credentials('JWT-YML')
    }

    stages {

        stage('github-clone') {
            steps {
                git branch: 'deploy',
                    credentialsId: 'github-token',
                    url: 'https://github.com/lotuxsoo/issue-tracker.git'
            }
        }

        stage('Read Encoded Files') {
            steps {
                script {
                    def encodedDbConfig = sh(script: "echo \${ENCODED_DB_CONFIG}", returnStdout: true).trim()
                    def decodedDbConfig = sh(script: "echo \${encodedDbConfig} | base64 -d", returnStdout: true).trim()
                    writeFile file: 'db_config.yml', text: decodedDbConfig

                    def encodedJwt = sh(script: "echo \${ENCODED_JWT}", returnStdout: true).trim()
                    def decodedJwt = sh(script: "echo \${encodedJwt} | base64 -d", returnStdout: true).trim()
                    writeFile file: 'jwt.yml', text: decodedJwt
                }
            }
        }

        stage('Build Backend') {
            steps {
                script {
                    dir('be/issue_tracker') {
                        sh 'chmod +x ./gradlew'
                        sh './gradlew assemble --exclude-task test'
                    }
                }
            }
        }

        stage('build-docker-image') {
            steps {
                script {
                    dir('be/issue_tracker') {
                        // Dockerfile 읽음
                        sh 'docker build -t ${DOCKER_IMAGE}:${BUILD_ID} . '
                    }
                }
            }
        }

        stage('docker-login') {
            steps {
                script {
                    // Docker Hub 로그인
                    sh "echo ${DOCKERHUB_CREDENTIALS_PSW} | docker login -u ${DOCKERHUB_CREDENTIALS_USR} --password-stdin"
                }
            }
        }

        stage('push-docker-image') {
            steps {
                script {
                    // Docker 이미지 푸시
                    sh 'docker push ${DOCKER_IMAGE}:${BUILD_ID}'
                }
            }
        }

        stage('SSH to EC2 and Docker run') {
            steps {
                script {
                    sshagent(credentials: ['my-keypair']) {
                        sh '''
                            ssh -o StrictHostKeyChecking=no ${SSH_USER}@${EC2_INSTANCE_IP}
                            docker run -d -p 80:8080 ${DOCKER_IMAGE}:${BUILD_ID}
                        '''
                    }
                }
            }
        }
    }

    post {
        always {
            // Clean up Docker images after the build
            sh 'docker rmi ${DOCKER_IMAGE}:${BUILD_ID}'
        }
    }
}