#!/bin/bash

# 현재 실행 중인 포트 확인
CURRENT_PORT=$(curl -s http://localhost/api/health | jq -r '.port')
TARGET_PORT=8081

if [ "$CURRENT_PORT" == "8081" ]; then
  TARGET_PORT=8082
fi

# 새로운 애플리케이션 빌드 및 배포
echo "Deploying application to port $TARGET_PORT"

# 기존 포트를 종료
fuser -k $TARGET_PORT/tcp

# 새로운 포트로 애플리케이션 실행
java -jar -Dspring.profiles.active=$(if [ $TARGET_PORT == 8081 ]; then echo "blue"; else echo "green"; fi) /path/to/your/application.jar &

# Nginx 리버스 프록시 설정 변경
sed -i "s/proxy_pass http:\/\/blue;/proxy_pass http:\/\/$(if [ $TARGET_PORT == 8081 ]; then echo "blue"; else echo "green"; fi);/" /etc/nginx/nginx.conf

# Nginx 재시작
sudo systemctl reload nginx

echo "Deployment to port $TARGET_PORT complete"

