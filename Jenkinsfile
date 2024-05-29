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
                        sh 'chmod u+rw ${jwtFile}'
                        sh 'chmod u+rw ${dbConfigFile}'
                        sh 'ls -l ${jwtFile}'
                        sh 'ls -l ${dbConfigFile}'

                        // 대상 디렉토리에 대한 쓰기 권한 설정
                        sh 'chmod -R u+w be/issue_tracker/src/main/resources/'

                        sh 'cp $jwtFile be/issue_tracker/src/main/resources/jwt.yml'
                        sh 'cp $dbConfigFile be/issue_tracker/src/main/resources/db-config.yml'
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
                    ssh -o StrictHostKeyChecking=no -tt ${SSH_USER}@${EC2_INSTANCE_IP} "
                    if [ \$(docker ps -a -q -f name=new_issue) ]; then 
                        docker stop new_issue; 
                        docker rm new_issue; 
                    fi
                    if [ \$(docker ps -a -q -f name=issue) ]; then 
                        docker stop issue; 
                        docker rm issue; 
                    fi
                    docker run -d --name new_issue -p 80:8080 ${DOCKER_IMAGE}:${BUILD_ID} && docker rename new_issue issue"
                '''
                    }
                }
            }
        }
    }
}