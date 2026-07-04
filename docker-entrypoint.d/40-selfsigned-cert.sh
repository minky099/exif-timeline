#!/bin/sh
# nginx:alpine 기본 엔트리포인트가 nginx 시작 전에 /docker-entrypoint.d/*.sh 를 실행한다.
# HTTPS(9443)용 자체서명 인증서가 없으면 생성한다. (일괄 저장=공유시트는 보안 컨텍스트 필요)
set -e

CERT_DIR=/etc/nginx/certs
CRT="$CERT_DIR/cert.pem"
KEY="$CERT_DIR/key.pem"
mkdir -p "$CERT_DIR"

if [ -f "$CRT" ] && [ -f "$KEY" ]; then
  echo "[cert] 기존 인증서 사용: $CRT"
  exit 0
fi

# SAN 구성: localhost/127.0.0.1 기본 + TLS_HOST(단일 IP/호스트) + TLS_SANS(원시 목록)
SAN="DNS:localhost,IP:127.0.0.1"
if [ -n "$TLS_HOST" ]; then
  if echo "$TLS_HOST" | grep -Eq '^[0-9]+(\.[0-9]+){3}$'; then
    SAN="$SAN,IP:$TLS_HOST"
  else
    SAN="$SAN,DNS:$TLS_HOST"
  fi
fi
if [ -n "$TLS_SANS" ]; then
  SAN="$SAN,$TLS_SANS"
fi

# iOS는 유효기간 825일 초과 TLS 인증서를 신뢰 설정해도 거부한다 → 800일로 발급
echo "[cert] 자체서명 인증서 생성 (SAN=$SAN)"
openssl req -x509 -newkey rsa:2048 -nodes \
  -keyout "$KEY" -out "$CRT" -days 800 \
  -subj "/CN=exif-timeline" \
  -addext "subjectAltName=$SAN" \
  -addext "extendedKeyUsage=serverAuth" \
  -addext "basicConstraints=CA:TRUE" >/dev/null 2>&1

chmod 600 "$KEY"
echo "[cert] 생성 완료: $CRT"
