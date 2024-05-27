pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('docker_token')
        DOCKER_IMAGE = "tndus5383/docker_repository"
        BLUE_PORT = 8081
        GREEN_PORT = 8082
        CURRENT_COLOR = ""
    }

    stages {
        stage('GitHub Clone') {
            steps {
                git branch: 'deploy', credentialsId: 'github_token', url: 'https://github.com/lotuxsoo/issue-tracker'
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

        stage('Build Docker Image') {
            steps {
                script {
                    def commitId = sh(returnStdout: true, script: 'git rev-parse --short HEAD').trim()
                    docker.build("${DOCKER_IMAGE}:${commitId}")
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    def commitId = sh(returnStdout: true, script: 'git rev-parse --short HEAD').trim()
                    docker.withRegistry('https://index.docker.io/v1/', DOCKERHUB_CREDENTIALS) {
                        docker.image("${DOCKER_IMAGE}:${commitId}").push()
                    }
                }
            }
        }

        stage('Deploy to New Color') {
            steps {
                script {
                    def newColor = CURRENT_COLOR == 'blue' ? 'green' : 'blue'
                    def newPort = newColor == 'blue' ? BLUE_PORT : GREEN_PORT
                    def commitId = sh(returnStdout: true, script: 'git rev-parse --short HEAD').trim()

                    sh """
                    sed -i 's|tndus5383/docker_repository:latest|tndus5383/docker_repository:${commitId}|' docker-compose.yml
                    """

                    sh "docker-compose stop ${newColor} || true"
                    sh "docker-compose rm -f ${newColor} || true"

                    // Run the new container
                    sh "docker-compose up -d ${newColor}"

                    // Update Nginx configuration
                    sh "sudo cp /etc/nginx/sites-available/default /etc/nginx/sites-available/default.bak"
                    sh """
                        sudo sed -i 's|proxy_pass http://.*;|proxy_pass http://${newColor};|' /etc/nginx/sites-available/default
                    """
                    sh "sudo nginx -t && sudo systemctl reload nginx"
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