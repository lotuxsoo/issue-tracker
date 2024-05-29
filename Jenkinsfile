pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('docker_token')
        DOCKER_IMAGE = 'tndus5383/issue-tracker'
        EC2_CREDENTIALS = credentials('my-keypair')
        SSH_USER = 'ubuntu'
        EC2_INSTANCE_IP = '3.36.70.238'
        JWT_FILE = credentials('JWT-YML')
        DB_CONFIG_FILE = credentials('DBCONFIG-YML')
    }

    stages {

        stage('github-clone') {
            steps {
                git branch: 'deploy',
                    credentialsId: 'github-token',
                    url: 'https://github.com/lotuxsoo/issue-tracker.git'
            }
        }

        stage('Read Credentials') {
            steps {
                // Credentials에서 파일을 읽어오고 해당 디렉토리에 복사
                withCredentials([file(credentialsId: 'JWT-YML', variable: 'jwtFile'), file(credentialsId: 'DBCONFIG-YML', variable: 'dbConfigFile')]) {
                    script {
                        // 복사할 디렉토리 경로
                        def directory = 'be/issue_tracker/src/main/resources'

                        // 파일 복사
                        sh "cp ${jwtFile} ${directory}/jwt.yml"
                        sh "cp ${dbConfigFile} ${directory}/db-config.yml"

                        // 디렉토리 밑의 .yml 파일들 리스트 확인
                        sh "ls -l ${directory}/*.yml"

                        // 복사된 파일들의 권한 설정 (선택 사항)
                        sh "chmod 644 ${directory}/*.yml"
                    }
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
                            # 새로운 컨테이너 실행
                            docker run -d --name new_issue -p 80:8080 ${DOCKER_IMAGE}:${BUILD_ID}

                            # 기존 컨테이너 중지 및 삭제 (기존 컨테이너가 있는 경우)
                            if [ \$(docker ps -q -f name=issue) ]; then
                                docker stop issue
                                docker rm issue
                            fi

                            # 새 컨테이너를 issue_tracker로 이름 변경
                            docker rename new_issue issue
                        '''
                    }
                }
            }
        }
    }
}