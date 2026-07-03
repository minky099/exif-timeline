# 단일 HTML 웹앱을 nginx로 정적 서빙 (빌드 단계 없음)
FROM nginx:1.27-alpine

# HTTPS 자체서명 인증서 생성을 위한 openssl
RUN apk add --no-cache openssl

# 9003(HTTP) + 9443(HTTPS) 리스닝 설정으로 기본 default.conf 대체
COPY nginx.conf /etc/nginx/conf.d/default.conf

# 시작 전 인증서 생성 스크립트 (nginx:alpine 기본 엔트리포인트가 실행)
COPY docker-entrypoint.d/40-selfsigned-cert.sh /docker-entrypoint.d/40-selfsigned-cert.sh
RUN chmod +x /docker-entrypoint.d/40-selfsigned-cert.sh

# 앱 파일 배치
COPY index.html exif-test.html video-test.html /usr/share/nginx/html/

EXPOSE 9003 9443

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget -qO- http://127.0.0.1:9003/healthz || exit 1
