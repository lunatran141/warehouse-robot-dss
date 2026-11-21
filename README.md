# Warehouse Robot Decision Support System

Đồ án cuối kỳ môn Hệ thống hỗ trợ ra quyết định, sử dụng NetLogo để xây dựng mô hình mô phỏng đa tác tử cho hoạt động phân phối hàng hóa bằng robot trong kho.

Hệ thống cho phép người quản lý thiết lập tình huống vận hành, chạy thử nhiều chiến lược phân phối, quan sát kết quả, so sánh các chỉ số và nhận khuyến nghị trước khi lựa chọn phương án cuối cùng.

## 1. Bài toán

Trong kho hàng có nhiều robot cùng thực hiện đơn hàng. Mỗi robot phải di chuyển đến vị trí lấy hàng, giao hàng và quay về khu vực chờ hoặc trạm sạc.

Quá trình vận hành có thể gặp các vấn đề:

- Nhiều robot cùng lựa chọn một tuyến đường gây tắc nghẽn.
- Robot nhận đơn hàng không phù hợp với vị trí hiện tại.
- Robot có mức pin thấp nhưng vẫn nhận nhiệm vụ xa.
- Một số khu vực hoặc tuyến đường có thể bị chặn.
- Đơn hàng có mức độ ưu tiên khác nhau.
- Chiến lược đạt tốc độ cao có thể tiêu thụ nhiều năng lượng.
- Chiến lược tiết kiệm năng lượng có thể làm tăng thời gian chờ.
- Chiến lược phù hợp trong điều kiện bình thường có thể không phù hợp khi kho quá tải.

Vì vậy, người quản lý cần một công cụ để thử nghiệm các chiến lược trong nhiều tình huống trước khi áp dụng vào thực tế.

## 2. Mục tiêu của hệ thống

Hệ thống hướng đến các mục tiêu:

1. Mô phỏng hoạt động của nhiều robot trong môi trường kho.
2. Mô phỏng quá trình phát sinh và xử lý đơn hàng.
3. Cho phép thay đổi điều kiện vận hành của kho.
4. Thử nghiệm nhiều chiến lược phân phối đơn hàng.
5. Thu thập các chỉ số đánh giá của từng chiến lược.
6. So sánh ưu điểm, nhược điểm và sự đánh đổi giữa các chiến lược.
7. Xếp hạng và đề xuất chiến lược phù hợp với mục tiêu quản lý.
8. Cung cấp thông tin để người quản lý đưa ra quyết định cuối cùng.

## 3. Yếu tố hỗ trợ ra quyết định

Đây không chỉ là mô hình điều khiển robot hoặc tìm đường ngắn nhất.

Phần hỗ trợ ra quyết định nằm ở việc hệ thống:

- Nhận mục tiêu và tình huống do người quản lý thiết lập.
- Chạy cùng một tình huống với nhiều chiến lược khác nhau.
- Đo lường kết quả của từng chiến lược.
- Chuẩn hóa và tổng hợp các chỉ số đánh giá.
- Xếp hạng các phương án.
- Đề xuất chiến lược phù hợp.
- Giải thích lý do đề xuất.
- Cảnh báo các điểm đánh đổi.
- Cho phép người quản lý xem xét và lựa chọn phương án cuối cùng.

Hệ thống không tự động thay người quản lý quyết định. Khuyến nghị của hệ thống chỉ là cơ sở hỗ trợ cho quyết định cuối cùng.

## 4. Luồng hỗ trợ ra quyết định

```text
Người quản lý thiết lập kịch bản và mục tiêu
                        ↓
Hệ thống tạo môi trường kho, robot và đơn hàng
                        ↓
NetLogo chạy mô phỏng với từng chiến lược
                        ↓
Hệ thống thu thập các chỉ số của mỗi chiến lược
                        ↓
Decision Engine chuẩn hóa, so sánh và xếp hạng
                        ↓
Hệ thống đề xuất chiến lược phù hợp
                        ↓
Hiển thị lý do đề xuất và cảnh báo đánh đổi
                        ↓
Người quản lý xem xét và đưa ra quyết định cuối cùng
```

## 5. Các tác tử trong mô hình

### Robot

Mỗi robot có thể có các thuộc tính:

- Vị trí hiện tại.
- Trạng thái hoạt động.
- Mức pin.
- Đơn hàng đang thực hiện.
- Quãng đường đã di chuyển.
- Năng lượng đã tiêu thụ.
- Thời gian chờ.
- Số đơn hàng đã hoàn thành.

Robot có thể thực hiện các hành vi:

- Chờ nhận nhiệm vụ.
- Di chuyển đến vị trí lấy hàng.
- Di chuyển đến vị trí giao hàng.
- Tránh vật cản và khu vực tắc nghẽn.
- Đi đến trạm sạc.
- Hoàn thành và bàn giao đơn hàng.

### Đơn hàng

Mỗi đơn hàng có thể có:

- Vị trí lấy hàng.
- Vị trí giao hàng.
- Mức độ ưu tiên.
- Thời điểm phát sinh.
- Thời hạn hoàn thành.
- Trạng thái xử lý.
- Robot được phân công.

### Môi trường kho

Môi trường kho bao gồm:

- Lối đi.
- Kệ hàng.
- Điểm lấy hàng.
- Điểm giao hàng.
- Trạm sạc.
- Khu vực bị chặn.
- Khu vực tắc nghẽn.
- Khu vực chờ của robot.

## 6. Các chiến lược phân phối

Hệ thống triển khai và so sánh ba chiến lược phân phối đơn hàng chính thức.

### 6.1. Nearest — Robot gần nhất

Phân công đơn hàng cho robot có khoảng cách đến điểm lấy hàng ngắn nhất.

Ưu điểm:

- Đơn giản, dễ xây dựng và dễ giải thích.
- Có thể giảm thời gian robot đến điểm lấy hàng.

Hạn chế:

- Chưa xem xét đầy đủ mức pin và tải công việc.
- Có thể dồn nhiều robot vào cùng một khu vực.
- Không bảo đảm cân bằng tải.

### 6.2. Least workload — Robot có tải thấp nhất

Phân công đơn hàng cho robot có khối lượng công việc hiện tại thấp nhất.

Ưu điểm:

- Hạn chế tình trạng một robot xử lý quá nhiều nhiệm vụ.
- Phân phối công việc đồng đều hơn giữa các robot.

Hạn chế:

- Robot được chọn có thể không phải robot gần nhất.
- Cần theo dõi trạng thái công việc của toàn bộ đội robot.

### 6.3. Multi-criteria — Chiến lược đa tiêu chí

Chấm điểm các robot dựa trên nhiều tiêu chí:

- Khoảng cách đến điểm lấy hàng.
- Mức pin hiện tại.
- Khối lượng công việc.
- Độ ưu tiên của đơn hàng.
- Mức độ tắc nghẽn trên tuyến đường.

Robot có điểm phù hợp nhất sẽ được đề xuất nhận nhiệm vụ.

Công thức tổng quát:

```text
score =
  w_distance × distance_score
+ w_battery × battery_score
+ w_workload × workload_score
+ w_priority × priority_score
+ w_congestion × congestion_score
```

Trong đó, các trọng số được điều chỉnh theo mục tiêu của người quản lý.

Ưu điểm:

- Xem xét đồng thời nhiều yếu tố vận hành.
- Có thể thích nghi với các mục tiêu quản lý khác nhau.
- Phù hợp với vai trò hỗ trợ ra quyết định.

Hạn chế:

- Cần lựa chọn và giải thích trọng số hợp lý.
- Kết quả phụ thuộc vào cách chuẩn hóa các tiêu chí.

Mức pin và mức độ tắc nghẽn là tiêu chí đầu vào của chiến lược `Multi-criteria`, không được triển khai thành hai chiến lược phân phối độc lập.

## 7. Các kịch bản thử nghiệm dự kiến

Hệ thống dự kiến cung cấp các kịch bản:

### Kịch bản vận hành bình thường

- Số lượng robot và đơn hàng ở mức trung bình.
- Không có sự cố nghiêm trọng.
- Dùng để đánh giá hiệu quả cơ bản của các chiến lược.

### Kịch bản giờ cao điểm

- Đơn hàng phát sinh với tần suất cao.
- Nhiều robot hoạt động đồng thời.
- Dùng để kiểm tra thông lượng và mức độ tắc nghẽn.

### Kịch bản thiếu năng lượng

- Nhiều robot bắt đầu với mức pin thấp.
- Dùng để kiểm tra khả năng phân công nhiệm vụ và quản lý pin.

### Kịch bản có sự cố

- Một số lối đi hoặc khu vực bị chặn.
- Robot phải thay đổi tuyến đường.
- Dùng để đánh giá khả năng thích nghi của chiến lược.

### Kịch bản có đơn hàng ưu tiên

- Một số đơn hàng cần được hoàn thành sớm.
- Dùng để đánh giá khả năng đáp ứng mục tiêu dịch vụ.

## 8. Các chỉ số đánh giá

Hệ thống dự kiến thu thập:

- Số đơn hàng hoàn thành.
- Tỷ lệ đơn hàng hoàn thành đúng hạn.
- Thời gian hoàn thành trung bình.
- Thời gian chờ trung bình.
- Tổng quãng đường di chuyển.
- Tổng năng lượng tiêu thụ.
- Số lần robot phải sạc.
- Số lần xảy ra xung đột hoặc tắc nghẽn.
- Mức độ sử dụng của từng robot.
- Mức độ cân bằng tải giữa các robot.
- Thông lượng của hệ thống.
- Số đơn hàng còn tồn.

Các chỉ số được sử dụng để so sánh và xếp hạng chiến lược.

## 9. Cơ chế đề xuất chiến lược

Decision Engine dự kiến thực hiện các bước:

1. Nhận kết quả mô phỏng của từng chiến lược.
2. Chuẩn hóa các chỉ số về cùng một thang đánh giá.
3. Áp dụng trọng số theo mục tiêu của người quản lý.
4. Tính điểm tổng hợp cho từng chiến lược.
5. Xếp hạng các chiến lược.
6. Chọn chiến lược có điểm phù hợp nhất.
7. Tạo nội dung giải thích và cảnh báo đánh đổi.

Ví dụ:

- Nếu mục tiêu là tốc độ, hệ thống tăng trọng số cho thời gian hoàn thành và thông lượng.
- Nếu mục tiêu là tiết kiệm năng lượng, hệ thống tăng trọng số cho mức tiêu thụ pin.
- Nếu mục tiêu là ổn định, hệ thống ưu tiên tỷ lệ hoàn thành đúng hạn và giảm tắc nghẽn.
- Nếu mục tiêu là cân bằng, hệ thống phân bổ trọng số cho nhiều tiêu chí.

## 10. Kết quả đầu ra dự kiến

Sau mỗi lần mô phỏng, hệ thống hiển thị:

- Bảng kết quả của từng chiến lược.
- Điểm tổng hợp.
- Thứ hạng chiến lược.
- Chiến lược được khuyến nghị.
- Lý do khuyến nghị.
- Ưu điểm của chiến lược.
- Hạn chế của chiến lược.
- Cảnh báo về sự đánh đổi.
- Biểu đồ so sánh các chỉ số.
- Quyết định cuối cùng do người quản lý lựa chọn.

## 11. Phạm vi của đồ án

Đồ án tập trung vào:

- Mô phỏng đa tác tử bằng NetLogo.
- So sánh chiến lược trong cùng điều kiện.
- Hỗ trợ người quản lý lựa chọn phương án.
- Trình bày trực quan kết quả mô phỏng.
- Thực nghiệm bằng BehaviorSpace.
- Quản lý mã nguồn bằng GitHub.
- Chuẩn hóa môi trường chạy bằng Docker.
- Kiểm tra tự động bằng GitHub Actions.

Đồ án không tập trung vào:

- Điều khiển robot vật lý.
- Kết nối trực tiếp với cảm biến thật.
- Xây dựng bản đồ kho có độ chính xác công nghiệp.
- Thay thế hoàn toàn quyết định của người quản lý.
- Triển khai hệ thống sản xuất thực tế.

## 12. Công nghệ sử dụng

- NetLogo: xây dựng và hiển thị mô hình đa tác tử.
- BehaviorSpace: chạy nhiều thí nghiệm và thu thập kết quả.
- Visual Studio Code: quản lý mã nguồn và tài liệu.
- Git: quản lý phiên bản.
- GitHub: cộng tác và lưu trữ mã nguồn.
- GitHub Actions: thực hiện kiểm tra tự động.
- Docker: chuẩn hóa môi trường chạy mô hình.
- PowerShell và Shell Script: tự động hóa thí nghiệm.

## 13. Cấu trúc dự án

```text
warehouse-robot-dss/
├── .github/
│   └── workflows/
│       └── ci.yml
├── model/
│   ├── WarehouseRobot.nlogo
│   └── src/
│       ├── core.nls
│       ├── environment.nls
│       ├── scenarios.nls
│       ├── robot.nls
│       ├── battery.nls
│       ├── orders.nls
│       ├── basic-strategies.nls
│       ├── routing.nls
│       ├── congestion.nls
│       ├── incidents.nls
│       ├── decision-engine.nls
│       └── metrics.nls
├── experiments/
│   ├── experiments.xml
│   └── results/
├── scripts/
│   ├── run-experiments.sh
│   └── run-experiments.ps1
├── docker/
│   └── Dockerfile
├── docs/
│   ├── model-description.md
│   ├── algorithms.md
│   ├── experiments.md
│   └── demo-script.md
├── docker-compose.yml
├── CONTRIBUTING.md
├── .gitignore
└── README.md
```

## 14. Chức năng của các thành phần chính

### WarehouseRobot.nlogo

File mô hình chính của NetLogo, chứa giao diện demo, các nút điều khiển, thanh tham số, biểu đồ và phần khai báo liên kết đến các file mã nguồn.

### core.nls

Điều phối vòng đời của mô hình, bao gồm khởi tạo và thực hiện từng bước mô phỏng.

### environment.nls

Khởi tạo bản đồ kho, lối đi, kệ hàng, điểm lấy hàng, điểm giao hàng và trạm sạc.

### scenarios.nls

Tạo và quản lý các kịch bản vận hành dùng trong demo và thực nghiệm.

### robot.nls

Quản lý trạng thái, hành vi, nhiệm vụ và quá trình di chuyển của robot.

### battery.nls

Mô phỏng tiêu thụ năng lượng, cảnh báo pin thấp và quá trình sạc.

### orders.nls

Tạo đơn hàng, quản lý hàng đợi và cập nhật trạng thái xử lý.

### basic-strategies.nls

Cài đặt các chiến lược phân phối cơ sở để làm phương án so sánh.

### routing.nls

Tìm và cập nhật tuyến đường di chuyển cho robot.

### congestion.nls

Phát hiện, đo lường và xử lý tình trạng tắc nghẽn.

### incidents.nls

Tạo các sự cố như chặn đường, robot gặp lỗi hoặc thay đổi điều kiện vận hành.

### decision-engine.nls

Chuẩn hóa chỉ số, tính điểm, xếp hạng và khuyến nghị chiến lược.

### metrics.nls

Thu thập các chỉ số, cập nhật biểu đồ và xuất kết quả thực nghiệm.

## 15. Thành viên nhóm

| Mã thành viên | Họ và tên | Vai trò chính |
|---|---|---|
| TV1 | Trần Võ Thanh Ngân | Nhóm trưởng, thiết lập GitHub, Docker, CI, core, giao diện và tích hợp |
| TV2 | Trần Quốc Tuấn | Robot, battery và kiểm thử tích hợp |
| TV3 | Nguyễn Khánh Vân | Orders, chiến lược cơ sở, giải thích khuyến nghị và hỗ trợ demo |
| TV4 | Nguyễn Đức Tiến | Routing, congestion, incidents và phân tích kết quả |
| TV5 | Phạm Đăng Khôi | Metrics, decision engine và thí nghiệm BehaviorSpace |

Tất cả thành viên đều tham gia viết code, kiểm thử, review Pull Request và chuẩn bị phần trình bày.

## 16. Quy trình phát triển

```text
Nhận task
    ↓
Tạo nhánh riêng
    ↓
Viết code và kiểm tra trên máy
    ↓
Commit và push lên GitHub
    ↓
Tạo Pull Request
    ↓
GitHub Actions chạy CI
    ↓
Một thành viên khác review
    ↓
Nhóm trưởng thực hiện squash merge
```

Không thành viên nào làm việc trực tiếp trên nhánh main sau khi hệ thống bảo vệ nhánh được kích hoạt.

## 17. Quy tắc đặt tên nhánh

Tên nhánh sử dụng mã nhiệm vụ trong bảng kế hoạch, không sử dụng mã thành viên.

Cấu trúc:

```text
<loai>/<ma-task>-<mo-ta-ngan>
```

Các loại nhánh thường dùng:

```text
feature/T01-ten-task
fix/T02-ten-loi
docs/T03-ten-tai-lieu
chore/T04-ten-cong-viec
```

Ví dụ:

```text
hore/T01-bootstrap-vscode-docker
docs/T02-dss-flow-contract
feature/T03-core-environment
feature/T04-robot-battery
feature/T05-orders-basic-strategies
feature/T06-routing-incidents
feature/T07-metrics
feature/T08-decision-engine
```

Quy tắc:

- Mã nhiệm vụ viết thường khi đặt tên nhánh: `T01`, `T02`, `T03`.
- Dùng dấu gạch ngang để phân cách các từ.
- Không dùng dấu tiếng Việt, khoảng trắng hoặc tên cá nhân.
- Mỗi nhánh chỉ nên xử lý một nhiệm vụ chính.
-Tên nhánh phải khớp với task trong kế hoạch.
- Tiêu đề Pull Request phải ghi mã nhiệm vụ, ví dụ: `T03: Implement core environment.`.

## 18. Kịch bản demo dự kiến

Phần demo tập trung vào giá trị hỗ trợ ra quyết định:

1. Giới thiệu nhanh môi trường kho.
2. Chọn một kịch bản vận hành.
3. Chọn mục tiêu của người quản lý.
4. Chạy nhiều chiến lược trên cùng kịch bản.
5. Quan sát robot và đơn hàng trong NetLogo.
6. Hiển thị các chỉ số của từng chiến lược.
7. Hiển thị bảng xếp hạng.
8. Trình bày chiến lược được khuyến nghị.
9. Giải thích lý do và cảnh báo đánh đổi.
10. Thay đổi mục tiêu quản lý và quan sát khuyến nghị thay đổi.

## 19. Hướng dẫn chạy

Hướng dẫn cài đặt và chạy mô hình sẽ được cập nhật sau khi nhóm hoàn thành:

- Mô hình NetLogo tối thiểu.
- Dockerfile.
- Docker Compose.
- Script chạy thí nghiệm.
- Quy trình CI.
