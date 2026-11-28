# Biên bản kiểm thử T08 – Decision Engine & Multi-criteria

- **Người thực hiện:** TV5 – Phạm Đăng Khôi
- **Module:** `model/src/decision-engine.nls`
- **Môi trường:** NetLogo 7.0.4 (Headless và Command Center ở chế độ `observer>`)
- **Kết quả:** 13 nhóm kiểm thử (`TC01`–`TC13`, 20 lượt chạy) đạt kết quả mong đợi.

## 1. Bàn giao giao diện cho T09 (TV3) và T10 (TV1)

### Procedure / Reporter chính

| Procedure / Reporter | Loại | Vai trò |
|---|---|---|
| `select-robot-multi-criteria` | `to-report [ord]` | Chọn robot theo 5 tiêu chí Min-Max; hòa điểm chọn `who` nhỏ nhất. Gọi bởi `orders.nls`. |
| `apply-goal-weights` | `to` | Áp dụng 6 preset `management-goal` hoặc chế độ `"Custom"` (kẹp `mc-w-*` trong `[0.14, 0.44]`, tổng `= 1.0`). |
| `normalized-kpi-weights` | `to-report` | Chuẩn hóa 5 slider `w-speed..w-resilience` về tổng `1.0` (fallback đều `0.2` khi tổng `<= 0`). |
| `mc-dispatch-weights` | `to-report` | Trả danh sách `[mc-w-distance mc-w-battery mc-w-workload mc-w-priority mc-w-congestion]`. |
| `run-comparison` | `to` | Chạy 3 chiến lược trên cùng `sim-seed`, tính điểm, xếp hạng và khôi phục `active-strategy`. |
| `normalize-strategy-results` | `to` | Chuẩn hóa Min-Max `comparison-results` → `normalized-results` (`max = min → 1`). |
| `calculate-strategy-scores` | `to` | Tính `Strategy Score` và 5 đóng góp `w_k * norm_k`. |
| `rank-strategies` | `to` | Xếp hạng giảm dần, gán `recommended-strategy` và đóng gói `decision-summary-data` (9 phần tử). |
| `format-strategy-ranking` | `to-report` | Định dạng bảng xếp hạng cho Monitor UI ở T10. |
| `generate-recommendation` | `to` | Bản tạm thời để chạy trọn luồng; TV3 thay phần thân hàm ở T09. |

### Cấu trúc `decision-summary-data` (9 phần tử cho TV3 – T09)

- `item 0`: Tên chiến lược hạng 1 (`best-name`)
- `item 1`: Điểm hạng 1 (làm tròn 3 chữ số)
- `item 2`: Tên chiến lược hạng 2 (`second-name`)
- `item 3`: Điểm hạng 2 (làm tròn 3 chữ số)
- `item 4`: Hiệu điểm `score-gap` (`< 0.05` kích hoạt cảnh báo sát điểm)
- `item 5`: Tiêu chí đóng góp lớn nhất của hạng 1 (`"Speed"`, `"On-time"`, `"Energy"`, `"Balance"` hoặc `"Resilience"`)
- `item 6`: Tiêu chí đóng góp lớn thứ 2 của hạng 1
- `item 7`: Chuỗi so sánh KPI thô giữa hạng 1 và hạng 2 trên 2 tiêu chí mạnh nhất
- `item 8`: Danh sách đánh đổi `[ [kpi-name better-strategy delta] ... ]` (`[]` nếu hạng 1 không thua KPI nào)

### Gợi ý gắn UI cho TV1 (T10)

- Nút **Run Comparison** gọi `run-comparison` (`core.nls:setup` và `setup-for-strategy` đã gọi sẵn `apply-goal-weights`).
- Monitor: `recommended-strategy`, `format-strategy-ranking`, `recommendation-reason`, `trade-off-warning`.

## 2. Cách chạy kiểm thử

1. Mở `model/WarehouseRobot.nlogox` bằng NetLogo 7.0.4 và bấm **Check** ở tab Code.
2. Vào tab Interface, mở Command Center (`observer>`) và chạy các khối lệnh bên dưới (hoặc chạy tự động qua `netlogo-headless`).

---

## TC01 – Biên dịch & BehaviorSpace (`smoke-test`, `decision-engine-smoke`)

**Mục đích:** Xác nhận 12 file `.nls` biên dịch sạch và chạy được cả `smoke-test` lẫn `decision-engine-smoke` trong `experiments/experiments.xml`.

**Kết quả thực tế:**
- `smoke-test`: `ticks = 10`, `model-status = "Running"`, exit code `0`.
- `decision-engine-smoke`: `comparison-results = 3`, `normalized-results = 3`, `strategy-ranking = 3`, `decision-summary-data = 9`, `recommended-strategy = "Nearest"`, `is-comparing? = false`, `model-status = "Done"`, exit code `0`.

**Kết quả:** **Đạt.**

---

## TC02 – Áp dụng 6 preset `management-goal`

**Mục đích:** Kiểm tra `apply-goal-weights` với 6 preset khớp bảng Mục 3.3 trong `docs/dss-contract.md`, mọi `mc-w-* ∈ [0.10, 0.45]`, tổng `= 1.0`.

```netlogo
setup foreach ["Balanced" "Fast Delivery" "Minimize Late Orders" "Save Energy" "Load Balance" "Incident Resilience"] [g -> set management-goal g apply-goal-weights show (list g w-speed w-ontime w-energy w-balance w-resilience mc-dispatch-weights sum mc-dispatch-weights)]
```

**Kết quả thực tế:** Cả 6 preset khớp bảng hợp đồng, tổng `mc-dispatch-weights = 1`. **Đạt.**

---

## TC03 – Chế độ `"Custom"` & kẹp trọng số `[0.14, 0.44]`

**Mục đích:** Kiểm tra trường hợp kéo cực đoan 1 slider lên `100` và trường hợp 5 slider cùng bằng `0`.

```netlogo
setup set management-goal "Custom" set w-speed 100 set w-ontime 0 set w-energy 0 set w-balance 0 set w-resilience 0 apply-goal-weights show (list normalized-kpi-weights mc-dispatch-weights sum mc-dispatch-weights)
```

- **TC03a** (`100/0/0/0/0`): `mc-dispatch-weights = [0.35 0.14 0.14 0.14 0.23]`, tổng `1`.
- **TC03b** (`0/0/0/100/0`): `mc-dispatch-weights = [0.14 0.14 0.44 0.14 0.14]`, tổng `1`.
- **TC03c** (`0/0/0/0/0`): `normalized-kpi-weights = [0.2 0.2 0.2 0.2 0.2]`, `mc-dispatch-weights = [0.2 0.2 0.2 0.2 0.2]`, tổng `1`.

**Kết quả:** **Đạt.**

---

## TC04 – Chọn robot ở `select-robot-multi-criteria` & hòa điểm theo `who`

**Mục đích:** Kiểm tra 4 trường hợp: không có robot rảnh (`nobody`), tự khởi tạo `mc-w-*` khi đang bằng `0`, đổi mục tiêu (`Fast Delivery` vs `Load Balance`) đổi robot được chọn, và hòa điểm chọn `who` nhỏ hơn.

**Kết quả thực tế:** `[true true true true 1]`. **Đạt.**

---

## TC05 – Tính `priority_score` theo `slack(r, o)`

**Mục đích:** Dưới `"Minimize Late Orders"`, đơn `"high"` (`deadline = 45`) và đơn `"normal"` sắp quá hạn (`deadline = 20`, còn `<= 30` tick) ưu tiên robot gần có `slack` lớn hơn; đơn `"normal"` còn nhiều hạn (`deadline = 90`) dùng giá trị trung tính `0.5`.

**Kết quả thực tế:** `[true true true]`. **Đạt.**

---

## TC06 – Chuẩn hóa Min-Max & biên `max = min`

```netlogo
setup set comparison-results (list (list "Nearest" 20 80 50 0.5 0.6) (list "Least workload" 40 60 50 1.0 0.8) (list "Multi-criteria" 30 100 50 0.75 1.0)) normalize-strategy-results show normalized-results
```

**Mong đợi và thực tế:**
- `Nearest`: `[1 0.5 1 0 0]`
- `Least workload`: `[0 0 1 1 0.5]`
- `Multi-criteria`: `[0.5 1 1 0.5 1]` *(cột Energy bằng nhau cả 3 cùng ra `1`)*

**Kết quả:** **Đạt.**

---

## TC07 – Đổi mục tiêu trên bảng KPI đánh đổi 3 phía

**Mục đích:** Với dữ liệu `Nearest [20 70 30 0.30 0.50]`, `Least workload [60 60 70 1.00 0.60]`, `Multi-criteria [45 95 55 0.50 0.95]`, kiểm tra đổi qua 6 `management-goal`.

**Thực tế:**
- `Fast Delivery` → `Nearest` (`0.621`)
- `Save Energy` → `Nearest` (`0.643`)
- `Load Balance` → `Least workload` (`0.522`)
- `Minimize Late Orders` → `Multi-criteria` (`0.737`)
- `Incident Resilience` → `Multi-criteria` (`0.768`)
- `Balanced` → `Multi-criteria` (`0.643`)

**Kết quả:** **Đạt.**

---

## TC08 – Gói dữ liệu 9 phần tử `decision-summary-data`

- **TC08a (Có đánh đổi):** `length = 9`, `best = "Multi-criteria" (0.825)`, `second = "Nearest" (0.525)`, `gap = 0.3`, `top1 = "On-time"`, `top2 = "Resilience"`, `item 8 = [[Speed Nearest 5] [Energy Nearest 5] [Balance Least workload 0.25]]`.
- **TC08b (Thống trị cả 5 KPI):** `best = "Multi-criteria" (1)`, `item 8 = []`.
- **TC08c (Sát điểm `< 0.05`):** `gap = 0.045` → `trade-off-warning` có `"Canh bao sat diem (chenh lech 0.045 < 0.05)"` và câu nhắc người quản lý quyết định cuối.

**Kết quả:** **Đạt.**

---

## TC09 – Chạy `run-comparison` thực tế trên `Peak` (`sim-seed = 1`, 300 ticks)

```netlogo
set scenario-preset "Peak" set active-strategy "Nearest" set sim-seed 1 set management-goal "Balanced" run-comparison show format-strategy-ranking show decision-summary-data
```

| Chiến lược | Speed (ticks ↓) | On-time (% ↑) | Energy (pin/đơn ↓) | Balance (0..1 ↑) | Resilience (0..1 ↑) | Điểm | Hạng |
|---|---:|---:|---:|---:|---:|---:|---:|
| `Nearest` | 112.81 | 2.63% | 113.75 | 1.000 | 0.538 | 0.750 | #1 |
| `Multi-criteria` | 114.06 | 4.42% | 113.81 | 1.000 | 0.536 | 0.726 | #2 |
| `Least workload` | 116.75 | 4.31% | 114.94 | 1.000 | 0.537 | 0.456 | #3 |

- Sau khi chạy: `active-strategy` giữ nguyên `"Nearest"`, `is-comparing? = false`, `model-status = "Done"`, `score-gap = 0.024 < 0.05`, `item 8 = [[On-time Multi-criteria 1.79]]`.

**Kết quả:** **Đạt.**

---

## TC10 – Chạy `run-comparison` trên `Normal`, `Congestion`, `Incidents` (`sim-seed = 1`, 300 ticks)

| Kịch bản & Mục tiêu | Bảng xếp hạng | Đánh đổi (`item 8`) |
|---|---|---|
| `Normal` (`Balanced`) | `#1 Nearest (0.853) \| #2 Multi-criteria (0.541) \| #3 Least workload (0.4)` | `[[On-time Least workload 0.41] [Resilience Multi-criteria 0.005]]` |
| `Congestion` (`Incident Resilience`) | `#1 Least workload (0.985) \| #2 Multi-criteria (0.888) \| #3 Nearest (0.062)` | `[[Resilience Multi-criteria 0.001]]` |
| `Incidents` (`Incident Resilience`) | `#1 Least workload (0.945) \| #2 Nearest (0.546) \| #3 Multi-criteria (0.091)` | `[[Balance Nearest 0.181]]` |

**Kết quả:** **Đạt.**

---

## TC11 – Đổi `management-goal` trên chạy thật `Peak` (`sim-seed = 1`)

| `management-goal` | Khuyến nghị tham khảo | Bảng xếp hạng |
|---|---|---|
| `Balanced` | `Nearest` | `#1 Nearest (0.75) \| #2 Multi-criteria (0.726) \| #3 Least workload (0.456)` |
| `Fast Delivery` | `Nearest` | `#1 Nearest (0.75) \| #2 Least workload (0.406) \| #3 Multi-criteria (0.374)` |
| `Minimize Late Orders` | `Least workload` | `#1 Least workload (0.679) \| #2 Nearest (0.55) \| #3 Multi-criteria (0.517)` |
| `Save Energy` | `Nearest` | `#1 Nearest (0.85) \| #2 Least workload (0.376) \| #3 Multi-criteria (0.279)` |
| `Load Balance` | `Multi-criteria` | `#1 Multi-criteria (0.86) \| #2 Nearest (0.85) \| #3 Least workload (0.676)` |
| `Incident Resilience` | `Least workload` | `#1 Least workload (0.866) \| #2 Nearest (0.8) \| #3 Multi-criteria (0.056)` |

**Kết quả:** Đổi mục tiêu làm khuyến nghị chuyển qua đủ 3 chiến lược. **Đạt.**

---

## TC12 – Tính lặp lại theo `sim-seed` & chuẩn xuống dòng `LF`

- Chạy `run-comparison` 2 lần liên tiếp (`Peak`, `sim-seed = 7`, `Minimize Late Orders`): `snap1 = snap2` là `true`, `rank1 = rank2` là `true`.
- `model/src/decision-engine.nls` dùng chuẩn `LF` (`0` `CRLF`).

**Kết quả:** **Đạt.**

---

## TC13 – Chạy `"Custom"` trong `run-comparison` & kiểm tra làm tròn biên

- Đặt `management-goal = "Custom"` với `[60 10 10 10 10]` rồi chạy `run-comparison` trên `Peak` (`sim-seed = 1`): 5 slider được giữ nguyên, tổng `mc-dispatch-weights = 1`, xếp hạng `#1 Nearest (0.9) | #2 Multi-criteria (0.296) | #3 Least workload (0.256)`.
- Chênh lệch `0.0002` ticks làm tròn về `0` không tạo đánh đổi `delta = 0` trong `item 8` và không hiện `"+0"` trong `item 7`.

**Kết quả:** `[true 1.0 true true]`. **Đạt.**
