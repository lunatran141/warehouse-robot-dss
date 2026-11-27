# Biên bản kiểm thử T07 – Metrics & Đặc tả Dashboard KPI

- **Người thực hiện:** TV5 – Phạm Đăng Khôi
- **Module:** `model/src/metrics.nls`
- **Hợp đồng tham chiếu:** `docs/dss-contract.md` (Mục 3, Mục 4.2, Mục 5.2 & Mục 6)
- **Môi trường kiểm thử:** NetLogo 7.0.4 (Headless & Command Center ở chế độ `observer>`)
- **Kết quả:** Toàn bộ **12 nhóm kiểm thử (`TC01`–`TC12`, 17 lượt chạy tự động)** đều **Đạt 100%** khớp với tính toán tay.

---

## 1. Bảng định nghĩa KPI, đơn vị, chiều tốt/xấu & Đặc tả Dashboard bàn giao cho `T10`

Để tránh xung đột chỉnh sửa XML trên `model/WarehouseRobot.nlogox` trước giai đoạn tích hợp giao diện của TV1 (`T10`), toàn bộ reporter đã sẵn sàng để gắn trực tiếp vào Monitor, Plot và BehaviorSpace theo bảng sau:

### 1.1. 5 KPI cốt lõi cấp chiến lược (đầu vào cho `decision-engine.nls` ở `T08`)

| # | Trục DSS | Reporter (`metrics.nls`) | Định nghĩa ngắn | Đơn vị | Chiều tốt | Precision gợi ý (Monitor UI) | Biên khi mẫu = 0 |
|---|---|---|---|---|---|---|---|
| 1 | **Speed** | `kpi-avg-completion-time` | Thời gian hoàn thành trung bình `(completed-tick - created-tick)` của đơn `"completed"` | `ticks/đơn` | **Thấp hơn tốt hơn (`min`)** | `2` | `sim-max-ticks` |
| 2 | **On-time** | `kpi-ontime-rate` | Tỷ lệ đơn hoàn thành đúng hạn trên tổng đơn đã xong hoặc đã quá hạn | `% (0–100)` | **Cao hơn tốt hơn (`max`)** | `1` | `100` |
| 3 | **Energy** | `kpi-energy-per-order` | Năng lượng tiêu thụ trung bình mỗi đơn hoàn thành | `đv pin/đơn` | **Thấp hơn tốt hơn (`min`)** | `2` | `9999` (nếu còn đơn tồn) / `0` |
| 4 | **Balance** | `kpi-load-balance` | Độ cân bằng tải `max(0, 1 - stdev(orders-done) / mean(orders-done))` | `0..1` | **Cao hơn tốt hơn (`max`)** | `3` | `1` |
| 5 | **Resilience** | `kpi-resilience` | `0.5 × completion-ratio + 0.5 × uptime-ratio` | `0..1` | **Cao hơn tốt hơn (`max`)** | `3` | `1` |

### 1.2. 8 Reporter phụ & Cấu hình Plot gợi ý cho Dashboard `T10`

| Nhóm Dashboard | Reporter (`metrics.nls`) | Định nghĩa | Đơn vị | Chiều tốt |
|---|---|---|---|---|
| Monitor vận hành | `kpi-completed-orders` | Tổng số đơn hoàn thành (`total-orders-completed`) | `đơn` | Cao hơn tốt hơn |
| Monitor vận hành | `kpi-pending-orders` | Số đơn chưa hoàn thành (`order-status != "completed"`) | `đơn` | Thấp hơn tốt hơn |
| Monitor vận hành | `kpi-late-rate` | Tỷ lệ đơn trễ (`100 - kpi-ontime-rate`) | `%` | Thấp hơn tốt hơn |
| Monitor năng lượng | `kpi-total-energy` | Tổng năng lượng tiêu thụ toàn đội robot | `đv pin` | Thấp hơn tốt hơn |
| Monitor năng lượng | `kpi-total-charges` | Tổng số lần sạc của toàn đội robot | `lần` | Tham khảo |
| Monitor tắc nghẽn | `kpi-avg-wait-time` | Thời gian chờ trung bình mỗi robot | `ticks/robot` | Thấp hơn tốt hơn |
| Monitor tắc nghẽn | `kpi-congestion-events` | Tổng số tick kẹt chờ (`total-wait-ticks`) | `ticks` | Thấp hơn tốt hơn |
| Monitor sự cố | `kpi-recovery-rate` | Tỷ lệ hoàn thành đơn từng bị thu hồi (`total-reassigned-completed / total-orders-reassigned × 100`) | `%` | Cao hơn tốt hơn |

**Plot gợi ý cho TV1 ở `T10`:**
- **Plot 1 – Hiệu suất giao hàng theo tick**: Pen 1 `plot kpi-ontime-rate` (màu xanh lá), Pen 2 `plot kpi-late-rate` (màu đỏ).
- **Plot 2 – Năng lượng & Tải theo tick**: Pen 1 `plot kpi-completed-orders` (xanh dương), Pen 2 `plot kpi-pending-orders` (cam).
- **Plot 3 – Cân bằng tải & Phục hồi**: Pen 1 `plot kpi-load-balance` (tím), Pen 2 `plot kpi-resilience` (xanh ngọc).

**Reporter bàn giao cho `T08` (`decision-engine.nls`):**
- `collect-current-kpi-snapshot` → trả về list 6 phần tử chuẩn: `[ active-strategy kpi-avg-completion-time kpi-ontime-rate kpi-energy-per-order kpi-load-balance kpi-resilience ]`.

---

## 2. Cách chạy kiểm thử trên NetLogo 7.0.4

1. Mở `model/WarehouseRobot.nlogox` bằng **NetLogo 7.0.4**.
2. Vào tab **Code**, bấm **Check** để xác nhận biên dịch sạch cả 12 file `.nls`.
3. Vào tab **Interface**, mở **Command Center** (`observer>`) và chạy từng khối lệnh bên dưới (hoặc chạy tự động qua `netlogo-headless`).

*(Lưu ý: Do `core.nls` hiện ở bản khung `T03` chưa nối vòng `go` 8 bước cho đến `T10`, các bài kiểm thử gọi tường minh các procedure theo đúng hợp đồng, đồng bộ với `T05_test_case.md` và `T06_test_case.md`.)*

---

## 3. Chi tiết 12 Kịch bản Kiểm thử (`TC01`–`TC12`)

### TC01 – Trạng thái biên ngay sau `setup`, `setup-robots`, `reset-metrics` (0 đơn, tick 0)

**Mục đích:** Xác nhận toàn bộ 13 reporter không phát sinh lỗi chia cho `0` khi chưa có đơn hàng nào và trả đúng giá trị biên theo hợp đồng.

```netlogo
setup setup-robots reset-metrics update-metrics show (list kpi-avg-completion-time kpi-ontime-rate kpi-late-rate kpi-energy-per-order kpi-load-balance kpi-resilience kpi-completed-orders kpi-pending-orders kpi-total-energy kpi-avg-wait-time kpi-total-charges kpi-congestion-events kpi-recovery-rate)
```

- **Mong đợi & Thực tế (NetLogo 7.0.4):** `[300 100 0 0 1 1 0 0 0 0 0 0 100]`
- **Kết quả:** **Đạt.**

---

### TC02 – KPI Speed (`kpi-avg-completion-time`)

**Mục đích:** Tạo 3 đơn tại tick 0 và hoàn thành lần lượt tại tick 10, 20, 30 → trung bình phải bằng `(10 + 20 + 30) / 3 = 20`.

```netlogo
setup setup-robots reset-metrics set order-spawn-rate 1 repeat 3 [ generate-orders ] let ords sort orders ask orders [ set created-tick 0 set order-status "picked" ] repeat 10 [ tick ] complete-order item 0 ords repeat 10 [ tick ] complete-order item 1 ords repeat 10 [ tick ] complete-order item 2 ords update-metrics show kpi-avg-completion-time show kpi-completed-orders
```

- **Mong đợi & Thực tế:** `20` → `3`
- **Kết quả:** **Đạt.**

---

### TC03 – KPI On-time & Late-rate (Chống gian lận đơn tồn quá hạn)

**Mục đích:** Tạo 4 đơn tại tick 0 (`deadline-tick = 10`): hoàn thành 2 đơn đúng hạn (tick 8 và đúng biên tick 10), 1 đơn trễ (tick 15), 1 đơn vẫn `"waiting"` ở tick 15 (quá hạn còn tồn), cộng thêm 1 đơn mới tạo lúc tick 12 (`deadline-tick = 100`, chưa đến hạn). Mẫu số phải là `4`, đúng hạn `2` → `50%` đúng hạn / `50%` trễ.

```netlogo
setup setup-robots reset-metrics set order-spawn-rate 1 repeat 4 [ generate-orders ] let ords sort orders ask orders [ set created-tick 0 set deadline-tick 10 ] ask item 0 ords [ set order-status "picked" ] ask item 1 ords [ set order-status "picked" ] ask item 2 ords [ set order-status "picked" ] repeat 8 [ tick ] complete-order item 1 ords repeat 2 [ tick ] complete-order item 0 ords repeat 2 [ tick ] generate-orders ask max-one-of orders [who] [ set deadline-tick 100 ] repeat 3 [ tick ] complete-order item 2 ords update-orders update-metrics show (list kpi-ontime-rate kpi-late-rate total-orders-ontime total-orders-late kpi-pending-orders)
```

- **Mong đợi & Thực tế:** `[50 50 2 2 2]`
- **Kết quả:** **Đạt.**

---

### TC04 – KPI Energy (`kpi-energy-per-order` & biên phạt `9999`)

**Mục đích:**
- **TC04a:** Tiêu thụ `120` pin cho `4` đơn hoàn thành → `30` pin/đơn.
- **TC04b:** `0` đơn hoàn thành nhưng còn `1` đơn tồn chưa giao → trả phạt `9999`.

```netlogo
;; TC04a
setup setup-robots reset-metrics set total-energy-consumed 120 set total-orders-completed 4 show (list kpi-energy-per-order kpi-total-energy)

;; TC04b
setup setup-robots reset-metrics set order-spawn-rate 1 generate-orders show (list kpi-energy-per-order kpi-pending-orders)
```

- **Mong đợi & Thực tế:** TC04a `[30 120]`; TC04b `[9999 1]`
- **Kết quả:** **Đạt.**

---

### TC05 – KPI Balance (`kpi-load-balance` ở 4 tình huống biên)

**Mục đích:** Kiểm tra tải đều tuyệt đối (`1`), tải lệch vừa (`[2, 4, 6, 8]` → `1 - sqrt(20/3)/5 ≈ 0.4836`), tải cực lệch (`[10, 0, 0, 0]` → kẹp về `0`), và biên chỉ còn `1` robot (không nổ lỗi `standard-deviation`).

```netlogo
;; TC05a - Đều tuyệt đối
setup set num-robots 4 setup-robots reset-metrics ask robots [ set orders-done 5 ] show kpi-load-balance

;; TC05b - Lệch vừa [2 4 6 8]
setup set num-robots 4 setup-robots reset-metrics let rs sort robots ask item 0 rs [ set orders-done 2 ] ask item 1 rs [ set orders-done 4 ] ask item 2 rs [ set orders-done 6 ] ask item 3 rs [ set orders-done 8 ] show kpi-load-balance

;; TC05c - Cực lệch [10 0 0 0]
setup set num-robots 4 setup-robots reset-metrics let rs sort robots ask item 0 rs [ set orders-done 10 ] ask item 1 rs [ set orders-done 0 ] ask item 2 rs [ set orders-done 0 ] ask item 3 rs [ set orders-done 0 ] show kpi-load-balance

;; TC05d - Biên 1 robot
setup set num-robots 2 setup-robots reset-metrics ask max-one-of robots [who] [ die ] ask robots [ set orders-done 3 ] show (list count robots kpi-load-balance)
```

- **Mong đợi & Thực tế:**
  - TC05a: `1`
  - TC05b: `0.4836022205056778` (khớp công thức tay `1 - sqrt(20/3)/5`)
  - TC05c: `0`
  - TC05d: `[1 1]` (không phát sinh lỗi runtime)
- **Kết quả:** **Đạt.**

---

### TC06 – KPI Resilience (`kpi-resilience`)

**Mục đích:** `4` robot, `ticks = 10` (`budget = 40`), `8/10` đơn hoàn thành (`completion-ratio = 0.8`), `total-wait-ticks = 6`, `total-broken-ticks = 4` (`uptime-ratio = 1 - 10/40 = 0.75`) → `0.5 × 0.8 + 0.5 × 0.75 = 0.775`.

```netlogo
setup set num-robots 4 setup-robots reset-metrics repeat 10 [ tick ] set total-orders-created 10 set total-orders-completed 8 set total-wait-ticks 6 set total-broken-ticks 4 update-metrics show kpi-resilience
```

- **Mong đợi & Thực tế:** `0.775`
- **Kết quả:** **Đạt.**

---

### TC07 – Tỷ lệ cứu đơn sau sự cố (`kpi-recovery-rate`)

**Mục đích:** Tạo `2` đơn, phân công cho robot, làm hỏng robot (`break-robot`) để thu hồi cả `2` đơn (`total-orders-reassigned = 2`), sau đó phân công lại và hoàn thành `1` đơn → `kpi-recovery-rate = 50%`.

```netlogo
setup setup-robots reset-metrics set active-strategy "Nearest" set order-spawn-rate 1 repeat 2 [ generate-orders ] assign-unassigned-orders ask robots with [current-order != nobody] [ break-robot self 20 ] assign-unassigned-orders let ord one-of orders with [order-status = "assigned"] ask ord [ set order-status "picked" ] complete-order ord show (list total-orders-reassigned total-reassigned-completed kpi-recovery-rate)
```

- **Mong đợi & Thực tế:** `[2 1 50]`
- **Kết quả:** **Đạt.**

---

### TC08 – Các reporter phụ cho Dashboard

**Mục đích:** Kiểm tra `kpi-completed-orders`, `kpi-pending-orders`, `kpi-avg-wait-time`, `kpi-total-charges` và `kpi-congestion-events`.

```netlogo
setup set num-robots 4 setup-robots reset-metrics let rs sort robots ask item 0 rs [ set charge-count 1 ] ask item 1 rs [ set charge-count 2 ] ask item 2 rs [ set charge-count 0 ] ask item 3 rs [ set charge-count 1 ] set total-wait-ticks 12 set order-spawn-rate 1 repeat 3 [ generate-orders ] let ord one-of orders ask ord [ set order-status "picked" ] complete-order ord show (list kpi-completed-orders kpi-pending-orders kpi-avg-wait-time kpi-total-charges kpi-congestion-events)
```

- **Mong đợi & Thực tế:** `[1 2 3 4 12]`
- **Kết quả:** **Đạt.**

---

### TC09 – `reset-metrics` xóa sạch 10 bộ đếm lượt chạy nhưng bảo toàn dữ liệu DSS

**Mục đích:** Đảm bảo `reset-metrics` chỉ đưa 10 biến `total-*` về `0`, không làm mất `comparison-results` và `recommended-strategy` khi `run-comparison` chạy giữa 3 chiến lược.

```netlogo
setup setup-robots set comparison-results (list (list "Nearest" 20 95 10 0.8 0.9)) set recommended-strategy "Nearest" set total-orders-created 15 set total-orders-completed 12 set total-energy-consumed 99 set total-wait-ticks 7 set total-broken-ticks 3 set total-incidents-triggered 2 set total-orders-reassigned 1 set total-reassigned-completed 1 reset-metrics show (list total-orders-created total-orders-completed total-energy-consumed total-wait-ticks total-broken-ticks total-incidents-triggered total-orders-reassigned total-reassigned-completed (length comparison-results) recommended-strategy)
```

- **Mong đợi & Thực tế:** `[0 0 0 0 0 0 0 0 1 "Nearest"]`
- **Kết quả:** **Đạt.**

---

### TC10 – Cấu trúc bàn giao `collect-current-kpi-snapshot` cho `T08`

**Mục đích:** Xác nhận trả về đúng list 6 phần tử `[active-strategy Speed On-time Energy Balance Resilience]`.

```netlogo
setup set num-robots 4 setup-robots reset-metrics set active-strategy "Least workload" set order-spawn-rate 1 repeat 2 [ generate-orders ] let ords sort orders ask orders [ set created-tick 0 set deadline-tick 50 set order-status "picked" ] repeat 10 [ tick ] complete-order item 0 ords complete-order item 1 ords set total-energy-consumed 40 ask robots [ set orders-done 1 ] show collect-current-kpi-snapshot
```

- **Mong đợi & Thực tế:** `["Least workload" 10 100 20 1 1]` (độ dài `6`)
- **Kết quả:** **Đạt.**

---

### TC11 – Kiểm thử tích hợp 120 tick cùng `T03–T06` (`Peak`, `sim-seed = 1`)

**Mục đích:** Chạy toàn bộ chuỗi 8 bước `go` trong `120` tick trên cùng kịch bản `"Peak"` và cùng `sim-seed = 1` cho hai chiến lược cơ sở `Nearest` và `Least workload` để kiểm chứng `metrics.nls` đo ổn định và thể hiện rõ đánh đổi giữa hai chiến lược.

| Chỉ số đo tại tick 120 (`Peak`, `sim-seed = 1`) | `Nearest` | `Least workload` | Nhận xét đối chiếu |
|---|---|---|---|
| `total-orders-created` | `60` | `64` | Chạy ổn định không lỗi |
| `kpi-completed-orders` / `kpi-pending-orders` | `9` / `51` | `8` / `56` | Tổng luôn bằng `total-orders-created` |
| `kpi-avg-completion-time` *(Speed ↓)* | `63.78` ticks | `61.75` ticks | `Least workload` nhanh hơn nhẹ |
| `kpi-ontime-rate` *(On-time ↑)* / `kpi-late-rate` | `30.0%` / `70.0%` | `22.22%` / `77.78%` | Tổng luôn `= 100%`; `Nearest` đúng hạn hơn |
| `kpi-energy-per-order` *(Energy ↓)* / `kpi-total-energy` | `88.89` (`800`) | `99.00` (`792`) | `Nearest` tiết kiệm pin/đơn hơn |
| `kpi-load-balance` *(Balance ↑)* | `0.686` | `1.000` | `Least workload` chia tải đều tuyệt đối |
| `kpi-resilience` *(Resilience ↑)* | `0.561` | `0.549` | Nằm chuẩn trong `[0, 1]` |
| `kpi-total-charges` | `5` lần | `6` lần | Khớp cơ chế sạc `battery.nls` |

- **Kết quả:** **Đạt.** Ghi nhận đánh đổi thực tế rõ nét giữa `Nearest` (tốt hơn về `On-time`, `Energy/order`, `Resilience`) và `Least workload` (vượt trội về `Balance`).

---

### TC12 – Tương thích CI `smoke-test` (`experiments/experiments.xml`)

**Mục đích:** Chạy lại thí nghiệm `smoke-test` mặc định trong `experiments/experiments.xml` trên NetLogo 7.0.4 Headless để đảm bảo biên dịch thêm `metrics.nls` không làm hỏng pipeline CI.

- **Thực tế:** `ticks = 10`, `model-status = "Running"`, thoát mã `0`.
- **Kiểm tra chuẩn dòng (`.gitattributes`):** `model/src/metrics.nls` dùng chuẩn `LF` (`0` ký tự `CRLF`).
- **Kết quả:** **Đạt.**
