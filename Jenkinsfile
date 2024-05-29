pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('docker_token')
        DOCKER_IMAGE = 'tndus5383/issue-tracker'
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

        stage('build-docker-image') {
            steps {
                script {
                    dir('be/issue_tracker') {
                        // Bash 사용하여 Docker 이미지 빌드
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
                    sh 'docker push ${DOCKER_IMAGE}:${env.BUILD_ID}'
                }
            }
        }
    }

    post {
        always {
            // Clean up Docker images after the build
            sh 'docker rmi ${DOCKER_IMAGE}:${env.BUILD_ID}'
        }
    }
}