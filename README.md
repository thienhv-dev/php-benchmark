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
│   └── run-test.sh            # Script tự động benchmark (Apache Bench)
├── gatling/                   # Gatling load testing
│   ├── user-files/
│   │   └── simulations/       # Gatling simulation files
│   └── scripts/               # Gatling helper scripts
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
   Lệnh này sẽ build image và khởi động 3 services: `php-app` (chạy app PHP), `benchmark` (Apache Bench tools), và `gatling` (Gatling load testing).
3. **Truy cập ứng dụng PHP:**
   - Mở trình duyệt và vào địa chỉ [http://localhost:8080](http://localhost:8080)
4. **Chạy benchmark:**
   
   **Apache Bench (AB):**
   ```sh
   docker exec php-benchmark-tools bash /benchmark/run-test.sh
   ```
   
   **Gatling Load Testing:**
   ```sh
   # Cài đặt Demo Gatling (nhanh, cho demo)
   bash gatling/scripts/setup-gatling-simple.sh
   
   # Hoặc cài đặt Gatling đầy đủ (chậm hơn, production)
   bash gatling/scripts/setup-gatling-local.sh
   
   # Chạy test đơn lẻ
   bash gatling/scripts/run-single-test.sh SingleEndpointSimulation fast 100 60
   bash gatling/scripts/run-single-test.sh PhpBenchmarkSimulation
   
   # Tạo báo cáo HTML sau khi chạy test
   bash create-gatling-report.sh PhpBenchmarkSimulation
   bash create-gatling-report.sh SingleEndpointSimulation medium
   ```
   
   - Kết quả sẽ lưu ở thư mục `results/`

## Gatling Load Testing

### Các loại test Gatling

**1. Comprehensive Load Test (`PhpBenchmarkSimulation`)**
- Test tổng hợp tất cả endpoints với mixed workload
- Mô phỏng tình huống sử dụng thực tế
- Thời gian: ~5-8 phút

**2. Single Endpoint Test (`SingleEndpointSimulation`)**
- Test riêng lẻ từng endpoint
- Có thể tuỳ chỉnh users, duration
- Phù hợp để đánh giá hiệu năng từng API

**3. Stress Test (`StressTestSimulation`)**
- Test khả năng chịu tải cao
- Tăng dần số lượng users để tìm breaking point
- Thời gian: ~10-15 phút

### Cài đặt Gatling

**Demo Mode (Khuyến nghị cho thử nghiệm):**
- Nhanh, không cần download file lớn
- Hiển thị kết quả mô phỏng realistic
- Phù hợp cho demo và hiểu workflow

```sh
bash gatling/scripts/setup-gatling-simple.sh
```

**Production Mode (Cho testing thực tế):**
- Download Gatling đầy đủ (~74MB)
- Chạy test thực tế với PHP endpoints
- Tạo báo cáo HTML chi tiết

```sh
bash gatling/scripts/setup-gatling-local.sh
```

### Lệnh Gatling thông dụng

```sh
# Chạy comprehensive test
bash gatling/scripts/run-single-test.sh PhpBenchmarkSimulation

# Test endpoint cụ thể với 200 users trong 120 giây
bash gatling/scripts/run-single-test.sh SingleEndpointSimulation fast 200 120

# Chạy stress test
bash gatling/scripts/run-single-test.sh StressTestSimulation

# Chạy trực tiếp trong container
docker exec php-benchmark-gatling /opt/gatling/bin/gatling.sh -s PhpBenchmarkSimulation
```

### Tạo và đọc báo cáo HTML

**Tạo báo cáo:**
```sh
# Tạo báo cáo cho test vừa chạy
bash create-gatling-report.sh PhpBenchmarkSimulation

# Tạo báo cáo cho endpoint cụ thể  
bash create-gatling-report.sh SingleEndpointSimulation medium
```

**Mở báo cáo:**
```sh
# Mở báo cáo mới nhất
open results/latest-gatling-report.html

# Hoặc mở báo cáo cụ thể
open results/gatling-phpbenchmarksimulation-*.html
```

**Nội dung báo cáo:**
- **📊 Response Time Statistics**: Percentiles (50th, 95th, 99th), Min/Max
- **🎯 Endpoint Performance**: RPS, Success rate, Mean time từng endpoint
- **📈 Charts**: Biểu đồ thời gian phản hồi và load pattern
- **⚙️ Test Configuration**: Thông tin cấu hình test

### So sánh Apache Bench vs Gatling

| Feature | Apache Bench (AB) | Gatling |
|---------|-------------------|---------|
| **Đơn giản** | ✅ Rất đơn giản | ⚠️ Cần hiểu Scala |
| **Kết quả** | Text reports | 📊 Rich HTML reports |
| **Scenarios** | Single endpoint | 🎯 Complex user journeys |
| **Real-time monitoring** | ❌ Không có | ✅ Có dashboard |
| **Load patterns** | Fixed load | 🔄 Ramp up/down, spikes |
| **Assertions** | ❌ Không có | ✅ Built-in assertions |
| **CI/CD** | ✅ Dễ tích hợp | ✅ Dễ tích hợp |

**Khi nào dùng Apache Bench:**
- Test nhanh, đơn giản
- Baseline performance check
- CI/CD pipeline cơ bản

**Khi nào dùng Gatling:**
- Load testing chuyên nghiệp
- Performance regression testing
- Cần reports đẹp cho stakeholders
- Test scenarios phức tạp

## Tuỳ biến
- Sửa code trong thư mục `app/` nếu muốn thay đổi logic ứng dụng PHP.
- Sửa hoặc thêm script trong `benchmark/` nếu muốn thay đổi cách benchmark Apache Bench.
- Sửa simulation files trong `gatling/user-files/simulations/` để tuỳ chỉnh Gatling tests.

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

# Chạy Apache Bench
docker exec php-benchmark-tools bash /benchmark/run-test.sh

# Hoặc chạy Gatling Demo (nhanh)
bash gatling/scripts/setup-gatling-simple.sh
bash gatling/scripts/run-single-test.sh PhpBenchmarkSimulation

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