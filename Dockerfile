# 단일 HTML 웹앱을 nginx로 정적 서빙 (빌드 단계 없음)
FROM nginx:1.27-alpine

# 기본 80 포트 설정을 9003 리스닝 설정으로 대체
COPY nginx.conf /etc/nginx/conf.d/default.conf

# 앱 파일 배치
COPY index.html exif-test.html /usr/share/nginx/html/

EXPOSE 9003

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget -qO- http://127.0.0.1:9003/healthz || exit 1
