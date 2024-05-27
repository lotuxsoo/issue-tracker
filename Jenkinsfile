pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "tndus5383/docker_repository"
        BLUE_PORT = 8081
        GREEN_PORT = 8082
        CURRENT_COLOR = ""
    }

    stages {
        stage('Determine Deployment Color') {
            steps {
                script {
                    def response = sh(script: "curl -s -o /dev/null -w '%{http_code}' http://localhost", returnStdout: true).trim()
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
                    docker.withRegistry('https://index.docker.io/v1/', 'dockerhub-credentials-id') {
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

                    // Stop the currently running container of the new color
                    sh "docker stop ${newColor} || true"
                    sh "docker rm ${newColor} || true"

                    // Run the new container
                    sh "docker run -d --name ${newColor} -p ${newPort}:8080 ${DOCKER_IMAGE}:${commitId}"

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