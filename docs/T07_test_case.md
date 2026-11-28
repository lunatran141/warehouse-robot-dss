# Biên bản kiểm thử T07 – Metrics & Dashboard KPI

- **Người thực hiện:** TV5 – Phạm Đăng Khôi
- **Module:** `model/src/metrics.nls`
- **Môi trường:** NetLogo 7.0.4 (Headless và Command Center ở chế độ `observer>`)
- **Kết quả:** 12 nhóm kiểm thử (`TC01`–`TC12`, 17 lượt chạy) đạt kết quả mong đợi.

## 1. Bảng KPI & Gợi ý gắn Dashboard cho T10

### 5 KPI cốt lõi (đầu vào cho `decision-engine.nls` ở T08)

| # | Trục | Reporter | Định nghĩa | Đơn vị | Chiều tốt | Precision | Biên mẫu = 0 |
|---|---|---|---|---|---|---|---|
| 1 | Speed | `kpi-avg-completion-time` | Trung bình `(completed-tick - created-tick)` của đơn `"completed"` | ticks/đơn | Thấp (`min`) | 2 | `sim-max-ticks` |
| 2 | On-time | `kpi-ontime-rate` | Đơn xong đúng hạn / (đơn đã xong hoặc đã quá hạn) | % | Cao (`max`) | 1 | `100` |
| 3 | Energy | `kpi-energy-per-order` | Tổng năng lượng / số đơn hoàn thành | pin/đơn | Thấp (`min`) | 2 | `9999` (nếu còn đơn tồn) / `0` |
| 4 | Balance | `kpi-load-balance` | `max(0, 1 - stdev(orders-done) / mean(orders-done))` | 0..1 | Cao (`max`) | 3 | `1` |
| 5 | Resilience | `kpi-resilience` | `0.5 * completion-ratio + 0.5 * uptime-ratio` | 0..1 | Cao (`max`) | 3 | `1` |

### 8 Reporter phụ & 3 Plot gợi ý cho T10

| Reporter | Định nghĩa | Đơn vị | Chiều tốt |
|---|---|---|---|
| `kpi-completed-orders` | Tổng đơn hoàn thành (`total-orders-completed`) | đơn | Cao |
| `kpi-pending-orders` | Đơn chưa hoàn thành (`order-status != "completed"`) | đơn | Thấp |
| `kpi-late-rate` | Tỷ lệ đơn trễ (`100 - kpi-ontime-rate`) | % | Thấp |
| `kpi-total-energy` | Tổng năng lượng tiêu thụ toàn đội | pin | Thấp |
| `kpi-total-charges` | Tổng số lần sạc của toàn đội | lần | Tham khảo |
| `kpi-avg-wait-time` | Thời gian chờ trung bình mỗi robot | ticks/robot | Thấp |
| `kpi-congestion-events` | Tổng tick kẹt chờ (`total-wait-ticks`) | ticks | Thấp |
| `kpi-recovery-rate` | Tỷ lệ hoàn thành đơn từng bị thu hồi (`total-reassigned-completed / total-orders-reassigned * 100`) | % | Cao |

Plot gợi ý cho TV1 (T10):
- Plot 1: `plot kpi-ontime-rate` (xanh lá), `plot kpi-late-rate` (đỏ).
- Plot 2: `plot kpi-completed-orders` (xanh dương), `plot kpi-pending-orders` (cam).
- Plot 3: `plot kpi-load-balance` (tím), `plot kpi-resilience` (xanh ngọc).

Reporter bàn giao T08: `collect-current-kpi-snapshot` trả về `[active-strategy kpi-avg-completion-time kpi-ontime-rate kpi-energy-per-order kpi-load-balance kpi-resilience]`.

## 2. Cách chạy kiểm thử

1. Mở `model/WarehouseRobot.nlogox` bằng NetLogo 7.0.4 và bấm **Check** ở tab Code.
2. Vào tab Interface, mở Command Center (`observer>`) và chạy từng khối lệnh bên dưới.

---

## TC01 – Trạng thái biên khi khởi tạo (0 đơn, tick 0)

**Mục đích:** Xác nhận 13 reporter không chia cho `0` và trả đúng giá trị biên.

```netlogo
setup setup-robots reset-metrics update-metrics show (list kpi-avg-completion-time kpi-ontime-rate kpi-late-rate kpi-energy-per-order kpi-load-balance kpi-resilience kpi-completed-orders kpi-pending-orders kpi-total-energy kpi-avg-wait-time kpi-total-charges kpi-congestion-events kpi-recovery-rate)
```

**Mong đợi và thực tế:** `[300 100 0 0 1 1 0 0 0 0 0 0 100]`. **Đạt.**

---

## TC02 – KPI Speed (`kpi-avg-completion-time`)

**Mục đích:** 3 đơn tạo ở tick 0, hoàn thành tại tick 10, 20, 30 → trung bình `20`.

```netlogo
setup setup-robots reset-metrics set order-spawn-rate 1 repeat 3 [ generate-orders ] let ords sort orders ask orders [ set created-tick 0 set order-status "picked" ] repeat 10 [ tick ] complete-order item 0 ords repeat 10 [ tick ] complete-order item 1 ords repeat 10 [ tick ] complete-order item 2 ords update-metrics show kpi-avg-completion-time show kpi-completed-orders
```

**Mong đợi và thực tế:** `20` → `3`. **Đạt.**

---

## TC03 – KPI On-time & Late-rate (tính cả đơn tồn quá hạn)

**Mục đích:** 4 đơn `deadline = 10` (2 xong đúng hạn ở tick 8 và 10, 1 xong trễ ở tick 15, 1 còn `"waiting"` quá hạn ở tick 15) + 1 đơn mới tạo lúc tick 12 (`deadline = 100`). Mẫu số `= 4`, đúng hạn `= 2` → `50%` / `50%`.

```netlogo
setup setup-robots reset-metrics set order-spawn-rate 1 repeat 4 [ generate-orders ] let ords sort orders ask orders [ set created-tick 0 set deadline-tick 10 ] ask item 0 ords [ set order-status "picked" ] ask item 1 ords [ set order-status "picked" ] ask item 2 ords [ set order-status "picked" ] repeat 8 [ tick ] complete-order item 1 ords repeat 2 [ tick ] complete-order item 0 ords repeat 2 [ tick ] generate-orders ask max-one-of orders [who] [ set deadline-tick 100 ] repeat 3 [ tick ] complete-order item 2 ords update-orders update-metrics show (list kpi-ontime-rate kpi-late-rate total-orders-ontime total-orders-late kpi-pending-orders)
```

**Mong đợi và thực tế:** `[50 50 2 2 2]`. **Đạt.**

---

## TC04 – KPI Energy (`kpi-energy-per-order`)

```netlogo
;; TC04a: 120 pin / 4 don -> 30
setup setup-robots reset-metrics set total-energy-consumed 120 set total-orders-completed 4 show (list kpi-energy-per-order kpi-total-energy)

;; TC04b: 0 don xong, con 1 don ton -> 9999
setup setup-robots reset-metrics set order-spawn-rate 1 generate-orders show (list kpi-energy-per-order kpi-pending-orders)
```

**Mong đợi và thực tế:** TC04a `[30 120]`; TC04b `[9999 1]`. **Đạt.**

---

## TC05 – KPI Balance (`kpi-load-balance`)

```netlogo
;; TC05a - Deu [5 5 5 5]
setup set num-robots 4 setup-robots reset-metrics ask robots [ set orders-done 5 ] show kpi-load-balance

;; TC05b - Lech vua [2 4 6 8]
setup set num-robots 4 setup-robots reset-metrics let rs sort robots ask item 0 rs [ set orders-done 2 ] ask item 1 rs [ set orders-done 4 ] ask item 2 rs [ set orders-done 6 ] ask item 3 rs [ set orders-done 8 ] show kpi-load-balance

;; TC05c - Cuc lech [10 0 0 0]
setup set num-robots 4 setup-robots reset-metrics let rs sort robots ask item 0 rs [ set orders-done 10 ] ask item 1 rs [ set orders-done 0 ] ask item 2 rs [ set orders-done 0 ] ask item 3 rs [ set orders-done 0 ] show kpi-load-balance

;; TC05d - Bien 1 robot
setup set num-robots 2 setup-robots reset-metrics ask max-one-of robots [who] [ die ] ask robots [ set orders-done 3 ] show (list count robots kpi-load-balance)
```

**Mong đợi và thực tế:** TC05a `1`; TC05b `0.4836022205056778`; TC05c `0`; TC05d `[1 1]`. **Đạt.**

---

## TC06 – KPI Resilience (`kpi-resilience`)

**Mục đích:** 4 robot, `ticks = 10` (`budget = 40`), `8/10` đơn xong (`0.8`), `6` wait + `4` broken (`uptime = 0.75`) → `0.5 * 0.8 + 0.5 * 0.75 = 0.775`.

```netlogo
setup set num-robots 4 setup-robots reset-metrics repeat 10 [ tick ] set total-orders-created 10 set total-orders-completed 8 set total-wait-ticks 6 set total-broken-ticks 4 update-metrics show kpi-resilience
```

**Mong đợi và thực tế:** `0.775`. **Đạt.**

---

## TC07 – Tỷ lệ cứu đơn (`kpi-recovery-rate`)

```netlogo
setup setup-robots reset-metrics set active-strategy "Nearest" set order-spawn-rate 1 repeat 2 [ generate-orders ] assign-unassigned-orders ask robots with [current-order != nobody] [ break-robot self 20 ] assign-unassigned-orders let ord one-of orders with [order-status = "assigned"] ask ord [ set order-status "picked" ] complete-order ord show (list total-orders-reassigned total-reassigned-completed kpi-recovery-rate)
```

**Mong đợi và thực tế:** `[2 1 50]`. **Đạt.**

---

## TC08 – Các reporter phụ

```netlogo
setup set num-robots 4 setup-robots reset-metrics let rs sort robots ask item 0 rs [ set charge-count 1 ] ask item 1 rs [ set charge-count 2 ] ask item 2 rs [ set charge-count 0 ] ask item 3 rs [ set charge-count 1 ] set total-wait-ticks 12 set order-spawn-rate 1 repeat 3 [ generate-orders ] let ord one-of orders ask ord [ set order-status "picked" ] complete-order ord show (list kpi-completed-orders kpi-pending-orders kpi-avg-wait-time kpi-total-charges kpi-congestion-events)
```

**Mong đợi và thực tế:** `[1 2 3 4 12]`. **Đạt.**

---

## TC09 – `reset-metrics` giữ nguyên dữ liệu DSS

```netlogo
setup setup-robots set comparison-results (list (list "Nearest" 20 95 10 0.8 0.9)) set recommended-strategy "Nearest" set total-orders-created 15 set total-orders-completed 12 set total-energy-consumed 99 set total-wait-ticks 7 set total-broken-ticks 3 set total-incidents-triggered 2 set total-orders-reassigned 1 set total-reassigned-completed 1 reset-metrics show (list total-orders-created total-orders-completed total-energy-consumed total-wait-ticks total-broken-ticks total-incidents-triggered total-orders-reassigned total-reassigned-completed (length comparison-results) recommended-strategy)
```

**Mong đợi và thực tế:** `[0 0 0 0 0 0 0 0 1 "Nearest"]`. **Đạt.**

---

## TC10 – Snapshot bàn giao T08 (`collect-current-kpi-snapshot`)

```netlogo
setup set num-robots 4 setup-robots reset-metrics set active-strategy "Least workload" set order-spawn-rate 1 repeat 2 [ generate-orders ] let ords sort orders ask orders [ set created-tick 0 set deadline-tick 50 set order-status "picked" ] repeat 10 [ tick ] complete-order item 0 ords complete-order item 1 ords set total-energy-consumed 40 ask robots [ set orders-done 1 ] show collect-current-kpi-snapshot
```

**Mong đợi và thực tế:** `["Least workload" 10 100 20 1 1]` (độ dài `6`). **Đạt.**

---

## TC11 – Chạy tích hợp 120 tick trên `Peak` (`sim-seed = 1`)

| Chỉ số tại tick 120 | `Nearest` | `Least workload` |
|---|---:|---:|
| `total-orders-created` | 60 | 64 |
| `kpi-completed-orders` / `kpi-pending-orders` | 9 / 51 | 8 / 56 |
| `kpi-avg-completion-time` (ticks ↓) | 63.78 | 61.75 |
| `kpi-ontime-rate` / `kpi-late-rate` | 30.0% / 70.0% | 22.22% / 77.78% |
| `kpi-energy-per-order` (tổng pin) | 88.89 (800) | 99.00 (792) |
| `kpi-load-balance` (0..1 ↑) | 0.686 | 1.000 |
| `kpi-resilience` (0..1 ↑) | 0.561 | 0.549 |
| `kpi-total-charges` | 5 | 6 |

**Kết quả:** **Đạt.**

---

## TC12 – Tương thích CI `smoke-test` & chuẩn dòng `LF`

- `experiments/experiments.xml` (`smoke-test`): `ticks = 10`, `model-status = "Running"`, exit code `0`.
- `model/src/metrics.nls` dùng chuẩn `LF` (`0` `CRLF`).

**Kết quả:** **Đạt.**
