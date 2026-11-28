# Biên bản kiểm thử T09 – Explanation và Trade-off Warning

- Thành viên: TV3 – Nguyễn Khánh Vân.
- Nhánh: `feature/T09-recommendation-explanation`.
- Ngày kiểm thử: 28/11/2026.
- Code: `generate-recommendation` trong `model/src/decision-engine.nls`.
- Môi trường: NetLogo 7.0.4 headless, Java 17 trên Windows.
- Phương pháp: gọi HeadlessWorkspace, chạy lệnh và kiểm tra các biểu thức xác nhận; lỗi hoặc kết quả false làm lượt kiểm thử thất bại.
- Kết quả: 18 lượt kiểm thử riêng thuộc TC01–TC16 và 4 lượt run-comparison thực tế đạt.
- Đã chạy bổ sung decision-engine-smoke bằng Docker: exit code 0, đủ dữ liệu ba phương án và gói giải thích 9 phần tử. CI GitHub của T09 chưa được xác nhận.

## 1. Phạm vi và nguyên tắc

Chỉ thay phần giải thích tạm ở cuối decision-engine.nls bằng T09.
Không thêm globals, không sửa chữ ký procedure, không sửa thuật toán chọn robot, chuẩn hóa, tính điểm hay xếp hạng của T08.
Không sửa core, file mô hình, các module T04–T07 hoặc tài liệu T05 đang được người dùng cập nhật.

Đầu vào: decision-summary-data, đọc đúng schema 9 phần tử do T08 bàn giao:
0. Tên hạng 1.
1. Điểm hạng 1.
2. Tên hạng 2.
3. Điểm hạng 2.
4. Chênh lệch điểm.
5. KPI đóng góp lớn nhất.
6. KPI đóng góp lớn thứ hai.
7. Chuỗi so sánh định lượng hai KPI do T08 cung cấp.
8. Danh sách [tên KPI, phương án tốt hơn, mức chênh lệch bất lợi].

Đầu ra:
- recommendation-reason: bối cảnh, mục tiêu, hạng 1, điểm hạng 1/hạng 2, hai tiêu chí và chuỗi định lượng của T08.
- trade-off-warning: các bất lợi có trong item 8; nếu rỗng, nêu đánh đổi vận hành định tính và không bịa số liệu. Cảnh báo khi gap < 0.05, diễn giải riêng trường hợp gap = 0 và nhắc người quản lý quyết định cuối.

T09 không tự tính lại KPI hoặc hiệu điểm. Chỉ dùng gói dữ liệu T08 để định dạng văn bản.
Với thiếu/sai dữ liệu hoặc chỉ một phương án, thông báo chưa đủ cơ sở so sánh thay vì bịa hai lý do hoặc đánh đổi đo được.
Speed/Energy cao hơn là bất lợi; On-time/Balance/Resilience thấp hơn là bất lợi.
Chênh lệch On-time được diễn giải bằng điểm phần trăm, không phải phần trăm thay đổi tương đối.

## 2. Kiểm thử riêng

Các case dưới dùng dữ liệu giả lập để kiểm tra cách diễn giải. Số liệu không phải kết quả thực nghiệm kho.
Chạy từng khối tại Command Center observer>. Các biểu thức show cuối mỗi khối phải trả true.
Case có local variables cần dán toàn bộ khối cùng một lần để giữ phạm vi biến.
TC09 có 3 lượt, nên TC01–TC16 tương ứng 18 lượt kiểm thử.

### TC01_missing – Thiếu dữ liệu và xóa nội dung giải thích cũ

```netlogo
set scenario-preset "Normal" set management-goal "Balanced" setup set recommendation-reason "OLD" set trade-off-warning "OLD" set decision-summary-data [] generate-recommendation show (member? "Chưa có dữ liệu" recommendation-reason) show (not member? "OLD" trade-off-warning) show (member? "người quản lý" trade-off-warning)
```

Kết quả headless: tất cả biểu thức xác nhận đúng; đạt.

### TC02_invalid_schema – Sai kiểu dữ liệu đầu vào

```netlogo
set scenario-preset "Normal" set management-goal "Balanced" setup set decision-summary-data 0 generate-recommendation show (member? "Chưa có dữ liệu" recommendation-reason) show (member? "người quản lý" trade-off-warning)
```

Kết quả headless: tất cả biểu thức xác nhận đúng; đạt.

### TC03_quantified_reasons – Chiến lược, bối cảnh, mục tiêu và hai lý do định lượng

```netlogo
set scenario-preset "Normal" set management-goal "Balanced" setup set decision-summary-data (list "Multi-criteria" 0.825 "Nearest" 0.525 0.3 "On-time" "Resilience" "On-time: 95% vs 70% (+25%); Resilience: 0.95 vs 0.5 (+0.45)" (list (list "Speed" "Nearest" 5) (list "Energy" "Nearest" 5) (list "Balance" "Least workload" 0.25))) generate-recommendation show (member? "Multi-criteria" recommendation-reason) show (member? "0.825" recommendation-reason) show (member? "On-time" recommendation-reason) show (member? "Resilience" recommendation-reason) show (member? (item 7 decision-summary-data) recommendation-reason) show (member? "Balanced" recommendation-reason) show (member? "Normal" recommendation-reason) show (member? "người quản lý" trade-off-warning)
```

Kết quả headless: tất cả biểu thức xác nhận đúng; đạt.

### TC04_trade_units_all – Nhiều đánh đổi; đúng chiều bất lợi và đơn vị

```netlogo
set scenario-preset "Normal" set management-goal "Balanced" setup set decision-summary-data (list "Multi-criteria" 0.825 "Nearest" 0.525 0.3 "On-time" "Resilience" "On-time: 95% vs 70% (+25%); Resilience: 0.95 vs 0.5 (+0.45)" (list (list "Speed" "Nearest" 5) (list "Energy" "Nearest" 5) (list "Balance" "Least workload" 0.25))) generate-recommendation show (member? "5 tick/đơn" trade-off-warning) show (member? "5 đơn vị pin/đơn" trade-off-warning) show (member? "0.25 điểm chỉ số" trade-off-warning) show (member? "Least workload" trade-off-warning) show (member? "người quản lý" trade-off-warning)
```

Kết quả headless: tất cả biểu thức xác nhận đúng; đạt.

### TC05_percentage_points – On-time dùng điểm phần trăm

```netlogo
set scenario-preset "Normal" set management-goal "Balanced" setup set decision-summary-data (list "Multi-criteria" 0.825 "Nearest" 0.525 0.3 "On-time" "Resilience" "On-time: 95% vs 70% (+25%); Resilience: 0.95 vs 0.5 (+0.45)" (list (list "Speed" "Nearest" 5) (list "Energy" "Nearest" 5) (list "Balance" "Least workload" 0.25))) set decision-summary-data replace-item 8 decision-summary-data (list (list "On-time" "Nearest" 1.79)) generate-recommendation show (member? "thấp hơn 1.79 điểm phần trăm" trade-off-warning) show (member? "người quản lý" trade-off-warning)
```

Kết quả headless: tất cả biểu thức xác nhận đúng; đạt.

### TC06_near_tie – Sát điểm tại 0.049

```netlogo
set scenario-preset "Normal" set management-goal "Balanced" setup set decision-summary-data (list "Multi-criteria" 0.825 "Nearest" 0.525 0.3 "On-time" "Resilience" "On-time: 95% vs 70% (+25%); Resilience: 0.95 vs 0.5 (+0.45)" (list (list "Speed" "Nearest" 5) (list "Energy" "Nearest" 5) (list "Balance" "Least workload" 0.25))) set decision-summary-data replace-item 4 decision-summary-data 0.049 generate-recommendation show (member? "Cảnh báo sát điểm" trade-off-warning) show (member? "người quản lý" trade-off-warning)
```

Kết quả headless: tất cả biểu thức xác nhận đúng; đạt.

### TC07_threshold – Đúng biên 0.05 không cảnh báo sát điểm

```netlogo
set scenario-preset "Normal" set management-goal "Balanced" setup set decision-summary-data (list "Multi-criteria" 0.825 "Nearest" 0.525 0.3 "On-time" "Resilience" "On-time: 95% vs 70% (+25%); Resilience: 0.95 vs 0.5 (+0.45)" (list (list "Speed" "Nearest" 5) (list "Energy" "Nearest" 5) (list "Balance" "Least workload" 0.25))) set decision-summary-data replace-item 4 decision-summary-data 0.05 generate-recommendation show (not member? "Cảnh báo sát điểm" trade-off-warning) show (member? "người quản lý" trade-off-warning)
```

Kết quả headless: tất cả biểu thức xác nhận đúng; đạt.

### TC08_equal_scores – Đồng điểm tại 0

```netlogo
set scenario-preset "Normal" set management-goal "Balanced" setup set decision-summary-data (list "Multi-criteria" 0.825 "Nearest" 0.525 0.3 "On-time" "Resilience" "On-time: 95% vs 70% (+25%); Resilience: 0.95 vs 0.5 (+0.45)" (list (list "Speed" "Nearest" 5) (list "Energy" "Nearest" 5) (list "Balance" "Least workload" 0.25))) set decision-summary-data replace-item 4 decision-summary-data 0 generate-recommendation show (member? "đồng điểm" trade-off-warning) show (member? "người quản lý" trade-off-warning)
```

Kết quả headless: tất cả biểu thức xác nhận đúng; đạt.

### TC09_no_measured_loss_Nearest – Không thua KPI: đánh đổi định tính của Nearest

```netlogo
set scenario-preset "Normal" set management-goal "Balanced" setup set decision-summary-data (list "Multi-criteria" 0.825 "Nearest" 0.525 0.3 "On-time" "Resilience" "On-time: 95% vs 70% (+25%); Resilience: 0.95 vs 0.5 (+0.45)" (list (list "Speed" "Nearest" 5) (list "Energy" "Nearest" 5) (list "Balance" "Least workload" 0.25))) set decision-summary-data replace-item 0 decision-summary-data "Nearest" set decision-summary-data replace-item 2 decision-summary-data "Least workload" set decision-summary-data replace-item 8 decision-summary-data [] generate-recommendation show (member? "Đánh đổi vận hành định tính" trade-off-warning) show (member? "Chưa ghi nhận KPI nào kém hơn" trade-off-warning) show (not member? "Đánh đổi đo được" trade-off-warning) show (member? "người quản lý" trade-off-warning)
```

Kết quả headless: tất cả biểu thức xác nhận đúng; đạt.

### TC09_no_measured_loss_Least_workload – Không thua KPI: đánh đổi định tính của Least workload

```netlogo
set scenario-preset "Normal" set management-goal "Balanced" setup set decision-summary-data (list "Multi-criteria" 0.825 "Nearest" 0.525 0.3 "On-time" "Resilience" "On-time: 95% vs 70% (+25%); Resilience: 0.95 vs 0.5 (+0.45)" (list (list "Speed" "Nearest" 5) (list "Energy" "Nearest" 5) (list "Balance" "Least workload" 0.25))) set decision-summary-data replace-item 0 decision-summary-data "Least workload" set decision-summary-data replace-item 2 decision-summary-data "Nearest" set decision-summary-data replace-item 8 decision-summary-data [] generate-recommendation show (member? "Đánh đổi vận hành định tính" trade-off-warning) show (member? "Chưa ghi nhận KPI nào kém hơn" trade-off-warning) show (not member? "Đánh đổi đo được" trade-off-warning) show (member? "người quản lý" trade-off-warning)
```

Kết quả headless: tất cả biểu thức xác nhận đúng; đạt.

### TC09_no_measured_loss_Multi-criteria – Không thua KPI: chi phí cấu hình Multi-criteria

```netlogo
set scenario-preset "Normal" set management-goal "Balanced" setup set decision-summary-data (list "Multi-criteria" 0.825 "Nearest" 0.525 0.3 "On-time" "Resilience" "On-time: 95% vs 70% (+25%); Resilience: 0.95 vs 0.5 (+0.45)" (list (list "Speed" "Nearest" 5) (list "Energy" "Nearest" 5) (list "Balance" "Least workload" 0.25))) set decision-summary-data replace-item 0 decision-summary-data "Multi-criteria" set decision-summary-data replace-item 2 decision-summary-data "Nearest" set decision-summary-data replace-item 8 decision-summary-data [] generate-recommendation show (member? "Đánh đổi vận hành định tính" trade-off-warning) show (member? "Chưa ghi nhận KPI nào kém hơn" trade-off-warning) show (not member? "Đánh đổi đo được" trade-off-warning) show (member? "người quản lý" trade-off-warning)
```

Kết quả headless: tất cả biểu thức xác nhận đúng; đạt.

### TC10_single_strategy – Chỉ có một phương án

```netlogo
set scenario-preset "Normal" set management-goal "Balanced" setup set decision-summary-data (list "Multi-criteria" 0.825 "Nearest" 0.525 0.3 "On-time" "Resilience" "On-time: 95% vs 70% (+25%); Resilience: 0.95 vs 0.5 (+0.45)" (list (list "Speed" "Nearest" 5) (list "Energy" "Nearest" 5) (list "Balance" "Least workload" 0.25))) set decision-summary-data replace-item 2 decision-summary-data "" set decision-summary-data replace-item 8 decision-summary-data [] generate-recommendation show (member? "Chỉ có dữ liệu" recommendation-reason) show (member? "Chưa đủ dữ liệu" trade-off-warning) show (not member? "Cảnh báo sát điểm" trade-off-warning) show (member? "người quản lý" trade-off-warning)
```

Kết quả headless: tất cả biểu thức xác nhận đúng; đạt.

### TC11_malformed_trade – Danh sách đánh đổi sai schema

```netlogo
set scenario-preset "Normal" set management-goal "Balanced" setup set decision-summary-data (list "Multi-criteria" 0.825 "Nearest" 0.525 0.3 "On-time" "Resilience" "On-time: 95% vs 70% (+25%); Resilience: 0.95 vs 0.5 (+0.45)" (list (list "Speed" "Nearest" 5) (list "Energy" "Nearest" 5) (list "Balance" "Least workload" 0.25))) set decision-summary-data replace-item 8 decision-summary-data (list (list "Speed" "Nearest")) generate-recommendation show (member? "Chưa có dữ liệu" recommendation-reason) show (member? "người quản lý" trade-off-warning)
```

Kết quả headless: tất cả biểu thức xác nhận đúng; đạt.

### TC12_bad_kpi – Tên KPI không thuộc contract

```netlogo
set scenario-preset "Normal" set management-goal "Balanced" setup set decision-summary-data (list "Multi-criteria" 0.825 "Nearest" 0.525 0.3 "On-time" "Resilience" "On-time: 95% vs 70% (+25%); Resilience: 0.95 vs 0.5 (+0.45)" (list (list "Speed" "Nearest" 5) (list "Energy" "Nearest" 5) (list "Balance" "Least workload" 0.25))) set decision-summary-data replace-item 5 decision-summary-data "UNKNOWN" generate-recommendation show (member? "Chưa có dữ liệu" recommendation-reason) show (member? "người quản lý" trade-off-warning)
```

Kết quả headless: tất cả biểu thức xác nhận đúng; đạt.

### TC13_small_delta – Giữ đánh đổi nhỏ 0.001

```netlogo
set scenario-preset "Normal" set management-goal "Balanced" setup set decision-summary-data (list "Multi-criteria" 0.825 "Nearest" 0.525 0.3 "On-time" "Resilience" "On-time: 95% vs 70% (+25%); Resilience: 0.95 vs 0.5 (+0.45)" (list (list "Speed" "Nearest" 5) (list "Energy" "Nearest" 5) (list "Balance" "Least workload" 0.25))) set decision-summary-data replace-item 8 decision-summary-data (list (list "Resilience" "Nearest" 0.001)) generate-recommendation show (member? "0.001 điểm chỉ số" trade-off-warning) show (member? "người quản lý" trade-off-warning)
```

Kết quả headless: tất cả biểu thức xác nhận đúng; đạt.

### TC14_no_mutation_or_rng – Không thay đổi dữ liệu nguồn, KPI, ranking, trọng số và PRNG

```netlogo
set scenario-preset "Normal" set management-goal "Balanced" setup set decision-summary-data (list "Multi-criteria" 0.825 "Nearest" 0.525 0.3 "On-time" "Resilience" "On-time: 95% vs 70% (+25%); Resilience: 0.95 vs 0.5 (+0.45)" (list (list "Speed" "Nearest" 5) (list "Energy" "Nearest" 5) (list "Balance" "Least workload" 0.25))) let before-data (list decision-summary-data comparison-results normalized-results strategy-ranking recommended-strategy (collect-current-kpi-snapshot) (mc-dispatch-weights) (normalized-kpi-weights) ticks) random-seed 77 let expected-random random-float 1 random-seed 77 generate-recommendation let actual-random random-float 1 let after-data (list decision-summary-data comparison-results normalized-results strategy-ranking recommended-strategy (collect-current-kpi-snapshot) (mc-dispatch-weights) (normalized-kpi-weights) ticks) show (before-data = after-data) show (actual-random = expected-random) show (member? "người quản lý" trade-off-warning)
```

Kết quả headless: tất cả biểu thức xác nhận đúng; đạt.

### TC15_repeat – Gọi lại không cộng dồn văn bản

```netlogo
set scenario-preset "Normal" set management-goal "Balanced" setup set decision-summary-data (list "Multi-criteria" 0.825 "Nearest" 0.525 0.3 "On-time" "Resilience" "On-time: 95% vs 70% (+25%); Resilience: 0.95 vs 0.5 (+0.45)" (list (list "Speed" "Nearest" 5) (list "Energy" "Nearest" 5) (list "Balance" "Least workload" 0.25))) generate-recommendation let reason-first recommendation-reason let warning-first trade-off-warning generate-recommendation show (recommendation-reason = reason-first) show (trade-off-warning = warning-first) show (member? "người quản lý" trade-off-warning)
```

Kết quả headless: tất cả biểu thức xác nhận đúng; đạt.

### TC16_zero_weight_tie – Tích hợp chuẩn hóa với trọng số bằng 0 và KPI bằng nhau

```netlogo
set scenario-preset "Normal" set management-goal "Balanced" setup set management-goal "Custom" set w-speed 0 set w-ontime 0 set w-energy 0 set w-balance 0 set w-resilience 0 set comparison-results [["Nearest" 20 80 50 0.5 0.6] ["Least workload" 20 80 50 0.5 0.6] ["Multi-criteria" 20 80 50 0.5 0.6]] normalize-strategy-results calculate-strategy-scores rank-strategies generate-recommendation show (member? "đồng điểm" trade-off-warning) show (member? "Đánh đổi vận hành định tính" trade-off-warning) show (member? "người quản lý" trade-off-warning)
```

Kết quả headless: tất cả biểu thức xác nhận đúng; đạt.

## 3. Kiểm thử tích hợp với run-comparison

Chạy cả ba chiến lược, mỗi chiến lược 300 tick, seed 1, mục tiêu Balanced trên từng preset.
Các kết quả dưới xác nhận gói T08 được T09 diễn giải đúng; không dùng để kết luận một chiến lược tối ưu cho mọi bối cảnh.

### Normal

```netlogo
set scenario-preset "Normal" set management-goal "Balanced" set sim-seed 1 run-comparison show recommendation-reason show trade-off-warning
```

Kết quả ghi nhận: Nearest đứng đầu 0.853; Multi-criteria hạng 2 có điểm 0.541, gap 0.312.
Lý do: On-time và Speed, giữ chuỗi số liệu T08.
Cảnh báo: On-time thấp hơn Least workload 0.41 điểm phần trăm; Resilience thấp hơn Multi-criteria 0.005. Không cảnh báo sát điểm.

### Peak

```netlogo
set scenario-preset "Peak" set management-goal "Balanced" set sim-seed 1 run-comparison show recommendation-reason show trade-off-warning
```

Kết quả ghi nhận: Nearest 0.750, Multi-criteria 0.726, gap 0.024.
Lý do: Speed 112.81 so với 114.06 tick; Energy 113.75 so với 113.81 pin/đơn.
Cảnh báo: On-time thấp hơn Multi-criteria 1.79 điểm phần trăm; có cảnh báo sát điểm 0.024 < 0.05.

### Congestion

```netlogo
set scenario-preset "Congestion" set management-goal "Balanced" set sim-seed 1 run-comparison show recommendation-reason show trade-off-warning
```

Kết quả ghi nhận: Least workload 0.998, Multi-criteria 0.536, gap 0.462.
Lý do: On-time và Speed.
Cảnh báo: Energy cao hơn Multi-criteria 0.13 đơn vị pin/đơn. Không cảnh báo sát điểm.

### Incidents

```netlogo
set scenario-preset "Incidents" set management-goal "Balanced" set sim-seed 1 run-comparison show recommendation-reason show trade-off-warning
```

Kết quả ghi nhận: Least workload 0.945, Nearest 0.551, gap 0.394.
Lý do: On-time và Speed.
Cảnh báo: Balance thấp hơn Nearest 0.181 điểm chỉ số 0–1. Không cảnh báo sát điểm.

### Điều kiện xác nhận chung

Cả 4 lượt đạt:
- comparison-results, normalized-results và strategy-ranking có đủ 3 phương án.
- decision-summary-data có đủ 9 phần tử.
- recommendation-reason có chiến lược được đề xuất, bối cảnh/mục tiêu, hai KPI và chuỗi định lượng.
- trade-off-warning có đánh đổi, đúng đơn vị và câu nhắc người quản lý quyết định cuối.
- Lượt chạy kết thúc tại sim-max-ticks, is-comparing? = false.

## 4. Kiểm tra biên dịch và regression

Đã kiểm tra lại trực tiếp bản code cuối trong repository bằng NetLogo 7.0.4 headless native:
- 18/18 lượt kiểm thử riêng: đạt, exit code 0.
- 4/4 kịch bản run-comparison (Normal, Peak, Congestion, Incidents; Balanced; seed 1): đạt, exit code 0.
- smoke-test: exit code 0; CSV tới tick 10, model-status = "Running" theo điều kiện dừng experiment.
- decision-engine-smoke: exit code 0; CSV ghi 3 comparison-results, 3 normalized-results, 3 strategy-ranking, 9 decision-summary-data, recommended-strategy = "Nearest", is-comparing? = false, model-status = "Done".
- Đã đối chiếu toàn bộ phần code T08 trước generate-recommendation giữ nguyên.
- git diff --check không phát hiện lỗi whitespace.

### Kiểm thử bổ sung bằng Docker

Đã chạy luồng so sánh có gọi generate-recommendation của T09:

```powershell
docker compose run --rm -T netlogo /opt/netlogo/netlogo-headless.sh --model /workspace/model/WarehouseRobot.nlogox --setup-file /workspace/experiments/experiments.xml --experiment decision-engine-smoke --table /workspace/experiments/results/t09-decision-smoke.csv --threads 1
```

Kết quả thực tế:
- Exit code: `0`.
- `length comparison-results = 3`.
- `length normalized-results = 3`.
- `length strategy-ranking = 3`.
- `length decision-summary-data = 9`.
- `recommended-strategy = "Nearest"`.
- `is-comparing? = false`.
- `model-status = "Done"`.
- Xếp hạng: Nearest 0.750; Multi-criteria 0.726; Least workload 0.456.
- File kết quả: `experiments/results/t09-decision-smoke.csv`.

**Kết luận:** Luồng decision-engine-smoke chạy thành công bằng Docker với code T09.

CSV này xác nhận luồng so sánh kết thúc thành công và cấu trúc dữ liệu đúng.
Nội dung Explanation/Trade-off Warning được kiểm tra trong các test riêng,
các lượt tích hợp headless và lượt Peak trên giao diện.

## 5. Bàn giao cho T10

TV1 có thể hiển thị trực tiếp recommendation-reason và trade-off-warning sau run-comparison.
T09 không thay đổi nút, chooser hoặc XML giao diện.
Các văn bản dùng tiếng Việt Unicode và giữ tên chiến lược/KPI theo contract.

## 6. Giới hạn

- Số liệu, độ chính xác và lựa chọn top KPI/đánh đổi do T08 cung cấp; T09 không sửa hay suy diễn lại dữ liệu đó.
- Item 7 đã được T08 làm tròn. T09 giữ nguyên chuỗi và giải thích đơn vị, không khôi phục độ chính xác đã mất.
- Khi item 8 rỗng, đánh đổi nêu là định tính; không phải bằng chứng một KPI đã kém hơn.
- Kết quả áp dụng cho cấu hình đã thử, không thay thế thực nghiệm nhiều seed T11 hoặc kiểm thử toàn hệ thống T12.
- Phần dữ liệu đầu vào dùng chung giữa chiến lược vẫn do nhóm theo dõi khi thực nghiệm; T09 không thay đổi quá trình sinh đơn.
