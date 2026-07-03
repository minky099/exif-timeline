#!/usr/bin/env bash
# exif-timeline 업데이트: 최신 코드 받기 → 재빌드 & 재기동 → 안 쓰는 이미지 정리
set -euo pipefail

# 스크립트 위치로 이동 (어디서 실행해도 동작)
cd "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# docker compose(v2) / docker-compose(v1) 자동 감지
if docker compose version >/dev/null 2>&1; then
  DC="docker compose"
elif command -v docker-compose >/dev/null 2>&1; then
  DC="docker-compose"
else
  echo "✗ docker compose 를 찾을 수 없습니다. Docker를 설치/실행하세요." >&2
  exit 1
fi

echo "▶ 1/4  최신 코드 받기 (git pull)"
if [ -d .git ]; then
  BRANCH="$(git rev-parse --abbrev-ref HEAD)"
  git pull --ff-only origin "$BRANCH"
else
  echo "  (git 저장소가 아니라 pull 생략)"
fi

echo "▶ 2/4  이미지 빌드"
$DC build

echo "▶ 3/4  재기동 (up -d)"
$DC up -d

echo "▶ 4/4  안 쓰는(dangling) 이미지 정리"
# 재빌드로 태그가 벗겨진 옛 이미지를 삭제. 다른 프로젝트 이미지는 건드리지 않음.
# (전체 미사용 이미지까지 지우려면 아래를 'docker image prune -af' 로. 단, 다른 컨테이너용 이미지도 지워질 수 있음)
docker image prune -f

echo
echo "✓ 완료"
$DC ps
