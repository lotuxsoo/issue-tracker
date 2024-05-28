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
        ENCODED_DB_CONFIG = credentials('db-config.yml')
        ENCODED_JWT = credentials('jwt.yml')
    }

    stages {
        stage('Clone Repository') {
            steps {
                git branch: 'deploy',
                    credentialsId: 'github_token',
                    url: 'https://github.com/lotuxsoo/issue-tracker.git'
            }
        }

         stage('Read Encoded Files') {
            steps {
                script {
                    // db-config.yml 디코딩
                    def encodedDbConfig = sh(script: "echo \${ENCODED_DB_CONFIG}", returnStdout: true).trim()
                    def decodedDbConfig = sh(script: "echo \${encodedDbConfig} | base64 -d", returnStdout: true).trim()
                    writeFile file: 'db_config.yml', text: decodedDbConfig

                    // jwt.yml 디코딩
                    def encodedJwt = sh(script: "echo \${ENCODED_JWT}", returnStdout: true).trim()
                    def decodedJwt = sh(script: "echo \${encodedJwt} | base64 -d", returnStdout: true).trim()
                    writeFile file: 'jwt.yml', text: decodedJwt
                }
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
                       # Copy docker-compose.yml to the remote server's home directory
                       scp -o StrictHostKeyChecking=no docker-compose.yml ${SSH_USER}@${EC2_INSTANCE_IP}:/home/${SSH_USER}/docker-compose.yml

                       # SSH into the remote server and execute deployment commands
                       ssh -o StrictHostKeyChecking=no ${SSH_USER}@${EC2_INSTANCE_IP} << EOF
                       cd /home/${SSH_USER}
                       newColor=\$(test "$CURRENT_COLOR" == 'blue' && echo 'green' || echo 'blue')
                       echo "New Color: \$newColor"

                       # Update Docker Compose file with new image
                       sed -i 's|tndus5383/docker_repository:.*|tndus5383/docker_repository:latest|' docker-compose.yml

                       # Stop the currently running container of the new color
                       docker-compose stop \$newColor || true
                       docker-compose rm -f \$newColor || true

                       # Run the new container
                       docker-compose up -d \$newColor

                       # Update Nginx configuration
                       sudo cp /etc/nginx/sites-available/default /etc/nginx/sites-available/default.bak
                       sudo sed -i 's|proxy_pass http://.*;|proxy_pass http://\$newColor;|' /etc/nginx/sites-available/default
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