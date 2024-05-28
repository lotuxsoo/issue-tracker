pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = 'docker_token'
        DOCKER_IMAGE = "tndus5383/docker_repository"
        BLUE_PORT = 8081
        GREEN_PORT = 8082
        CURRENT_COLOR = ""
        DOCKER_HOST = "unix:///var/run/docker.sock"
        SSH_USER = "ubuntu" // SSH로 인스턴스에 접속할 사용자명
        SSH_KEY_ID = "my-keypair" // Jenkins 자격 증명에 등록된 SSH 키의 ID
        EC2_INSTANCE_IP = "3.36.70.238" // EC2 인스턴스의 IP 주소
    }

    stages {
        stage('Clone Repository') {
            steps {
                git branch: 'deploy',
                    credentialsId: 'github_token',
                    url: 'https://github.com/lotuxsoo/issue-tracker.git'
            }
        }

        stage('Determine Deployment Color') {
            steps {
                script {
                    def response = sh(script: "curl -s -o /dev/null -w '%{http_code}' http://localhost:8080", returnStdout: true).trim()
                    if (response == '200') {
                        CURRENT_COLOR = 'blue'
                    } else {
                        CURRENT_COLOR = 'green'
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

        stage('Build Docker Image') {
            steps {
                script {
                    sh 'docker --version'
                    sh "docker build -t ${DOCKER_IMAGE}:latest ."
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    withDockerRegistry([url: 'https://index.docker.io/v1/', credentialsId: DOCKERHUB_CREDENTIALS]) {
                        def dockerImage = docker.image("${DOCKER_IMAGE}:latest")
                        dockerImage.push()
                    }
                }
            }
        }

       stage('Deploy to New Color') {
           steps {
               script {
                   // SSH 키를 사용하여 인스턴스에 접속
                   sshagent(credentials: ['my-keypair']) {
                       sh '''
                       ssh -o StrictHostKeyChecking=no ubuntu@3.36.70.238 << 'EOF'
                       # 현재 디렉토리에서 작업 수행
                       newColor=$(test "$CURRENT_COLOR" == 'blue' && echo 'green' || echo 'blue')
                       echo "New Color: $newColor"
                       commitId=$(git rev-parse --short HEAD)
                       echo "Commit ID: $commitId"

                       # Docker Compose 명령어 실행
                       sed -i "s|tndus5383/docker_repository:latest|tndus5383/docker_repository:${commitId}|" docker-compose.yml

                       docker-compose stop $newColor || true
                       docker-compose rm -f $newColor || true

                       docker-compose up -d $newColor

                       # Nginx 설정 업데이트
                       sudo cp /etc/nginx/sites-available/default /etc/nginx/sites-available/default.bak
                       sudo sed -i "s|proxy_pass http://.*;|proxy_pass http://$newColor;|" /etc/nginx/sites-available/default
                       sudo nginx -t && sudo systemctl reload nginx

                       exit
                       EOF
                       '''
                   }
               }
           }
       }
    }

    post {
        always {
            script {
                sh "docker system prune -f"
            }
        }
    }
}