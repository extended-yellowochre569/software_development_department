# ☁️ Cloud Run Deployment Checklist

> **Owner:** `devops-engineer`
> **Source:** Lessons from Crawler Webgame project (2026-04-03)

Sử dụng checklist này **MỖI LẦN** deploy service lên Google Cloud Run để tránh lặp lại các lỗi đã gặp.

---

## 1. Dockerfile & Container

- [ ] `WORKDIR` được đặt rõ ràng (ví dụ: `/app`)
- [ ] **Secret mount path nằm NGOÀI WORKDIR** (ví dụ: `/secrets/xxx.json`, KHÔNG dùng `/app/xxx.json`)
  > ⚠️ Mount secret vào WORKDIR sẽ che (shadow) toàn bộ thư mục code → container chỉ còn file secret, server không start được.
- [ ] ENV cho secret path được khai báo **trong Dockerfile** (không truyền qua `--set-env-vars` trên Git Bash Windows)
  > ⚠️ Git Bash tự convert path Unix `/secrets/...` → `C:/Program Files/Git/secrets/...`
- [ ] `.dockerignore` đã loại bỏ: `node_modules/`, `.git/`, `*.log`, `.env`
- [ ] Multi-stage build (nếu cần) để giảm image size

## 2. Headless Browser (Puppeteer/Playwright)

- [ ] **Bắt buộc dùng `--execution-environment gen2`** trong lệnh deploy
  > ⚠️ gen1 dùng gVisor sandbox → chặn syscall cần thiết cho Chrome → Puppeteer không launch được
- [ ] Chrome system dependencies đã cài đầy đủ trong Dockerfile:
  ```dockerfile
  RUN apt-get update && apt-get install -y \
      ca-certificates fonts-liberation libasound2 libatk-bridge2.0-0 \
      libatk1.0-0 libcairo2 libcups2 libdbus-1-3 libdrm2 libgbm1 \
      libglib2.0-0 libgtk-3-0 libnspr4 libnss3 libpango-1.0-0 \
      libx11-xcb1 libxcb1 libxcomposite1 libxcursor1 libxdamage1 \
      libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 \
      libxtst6 xdg-utils --no-install-recommends
  ```
- [ ] Puppeteer launch args tối ưu cho serverless:
  ```javascript
  { timeout: 60000, args: ['--no-sandbox', '--disable-setuid-sandbox',
    '--disable-dev-shm-usage', '--single-process', '--no-zygote', '--disable-gpu'] }
  ```
- [ ] Request interception đã bật để chặn image/css/font (giảm 60-80% bandwidth)

## 3. Deploy Command

- [ ] Lệnh deploy đầy đủ flags:
  ```bash
  gcloud run deploy SERVICE_NAME \
    --source . \
    --region asia-southeast1 \
    --execution-environment gen2 \
    --memory 1Gi \
    --cpu 1 \
    --timeout 300 \
    --set-secrets "/secrets/creds.json=SECRET_NAME:latest" \
    --allow-unauthenticated
  ```
- [ ] Nếu cần gỡ env cũ bị conflict: `--remove-env-vars VAR_NAME`

## 4. Post-Deploy Verification

- [ ] Truy cập URL `.run.app` → thấy giao diện hoặc health check trả `200`
- [ ] Test chức năng core (gửi request thật qua API)
- [ ] Kiểm tra logs: `gcloud run services logs read SERVICE_NAME --region REGION`
- [ ] Xác nhận secret được mount đúng: log không hiển thị lỗi `ENOENT` hoặc `permission denied`

---
*Checklist này được tạo từ 11 bài học thực chiến khi deploy Crawler Webgame lên Cloud Run.*
