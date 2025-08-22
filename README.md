# Dự án Benchmark PHP

>Dự án này cung cấp môi trường benchmark cho ứng dụng PHP sử dụng Docker. Bạn có thể dễ dàng kiểm tra hiệu năng các endpoint của ứng dụng PHP qua các kịch bản tự động.

## Cấu trúc thư mục

```
php-benchmark/
├── docker-compose.yml         
├── Dockerfile                 
├── app/                       
│   ├── index.php              # Router chính
│   ├── api.php                # Các endpoint API
│   └── config.php             # Cấu hình PHP
├── benchmark/
│   └── run-test.sh            # Script tự động benchmark
├── results/                   # Kết quả benchmark (tự sinh ra)
└── README.md
```

## Hướng dẫn cài đặt & sử dụng

### Yêu cầu
- Đã cài [Docker](https://www.docker.com/products/docker-desktop)
- Đã cài [Docker Compose](https://docs.docker.com/compose/)

### Các bước khởi động môi trường
1. **Clone source về máy:**
   ```sh
   git clone <your-repo-url>
   cd php-benchmark
   ```
2. **Build và chạy các container:**
   ```sh
   docker-compose up --build -d
   ```
   Lệnh này sẽ build image và khởi động 2 service: `php-app` (chạy app PHP) và `benchmark` (chạy script benchmark).
3. **Truy cập ứng dụng PHP:**
   - Mở trình duyệt và vào địa chỉ [http://localhost:8080](http://localhost:8080)
4. **Chạy benchmark:**
   - Thực thi script benchmark trong container:
     ```sh
     docker exec php-benchmark-tools bash /benchmark/run-test.sh
     ```
   - Kết quả sẽ lưu ở thư mục `results/`

## Tuỳ biến
- Sửa code trong thư mục `app/` nếu muốn thay đổi logic ứng dụng PHP.
- Sửa hoặc thêm script trong `benchmark/` nếu muốn thay đổi cách benchmark.

## Kết quả benchmark
- Kết quả sẽ được lưu ở thư mục `results/` dưới dạng file `.csv`, `.html`, `.txt`, `.dat`.

## Hướng dẫn nhanh: Khởi động & chạy benchmark
```sh
# Build và start containers
docker-compose up -d

# Chờ các service khởi động (30-60 giây)
sleep 30

# Kiểm tra health endpoint
curl http://localhost:8080/health

# Chạy benchmark
docker exec php-benchmark-tools bash /benchmark/run-test.sh

# Xem kết quả
ls results/
cat results/summary_*.csv
```

### Giải thích kết quả benchmark
**Các chỉ số chính:**
- RPS: Số request xử lý mỗi giây (Requests per second)
- Mean Time: Thời gian phản hồi trung bình (ms)
- Failed: Số lượng request thất bại

**Expected Performance:**

- Fast endpoint: 500-1000 RPS
- Medium endpoint: 50-200 RPS
- Slow endpoint: 5-20 RPS

### Một số lệnh test mẫu
```sh
# Test nhanh 1 endpoint
docker exec php-benchmark-tools ab -n 1000 -c 50 http://php-app/api/fast

# Test custom
docker exec php-benchmark-tools ab -n 5000 -c 100 -t 60 http://php-app/api/medium
```

### Dừng môi trường
Để dừng và xóa container, chạy:
```sh
docker-compose down
```

## Xử lý sự cố
- Đảm bảo port 8080 chưa bị chiếm dụng.
- Xem log container bằng lệnh: `docker-compose logs`