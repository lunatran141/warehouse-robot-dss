# Biên bản kiểm thử T05 – Orders và Basic Strategies

- **Người thực hiện:** TV3 – Nguyễn Khánh Vân.
- **Module:** `model/src/orders.nls`, `model/src/basic-strategies.nls`.
- **Môi trường:** NetLogo 7.0.4, Command Center ở chế độ `observer>`.
- **Cập nhật kiểm thử tích hợp:** 28/11/2026.
- **Trạng thái:** Đã triển khai, kiểm thử riêng, Docker smoke test và các lượt kiểm thử tích hợp nêu trong tài liệu.

## 1. Phạm vi kiểm thử

Các chức năng được kiểm tra:
- Sinh đơn theo xác suất và phân loại mức ưu tiên.
- Deadline high 45 tick, normal 90 tick.
- Hàng đợi theo ưu tiên, thời điểm tạo và who.
- Nearest và Least workload, bao gồm quy tắc hòa điểm.
- Phân công đơn và xử lý thiếu robot khả dụng.
- Hoàn thành, thu hồi đơn và thống kê đúng hạn/trễ.
- Chống đếm trùng khi gọi lại procedure.
- Ghi nhận đơn từng bị thu hồi và hoàn thành lại.
- Phối hợp với core, robot, routing, incidents và metrics.

Phân biệt bằng chứng kiểm thử:
- TC01–TC16: đã chạy lại đầy đủ trên core mới, tất cả kết quả thực tế khớp kết quả mong đợi.
- TC17–TC19: kết quả kiểm thử tích hợp đã chạy ngày 28/11/2026.
- Docker/headless: đã build image và chạy smoke test thành công.

Một số test riêng đặt trực tiếp vị trí robot, trạng thái đơn hoặc deadline để kiểm tra từng quy tắc. Các test này không thay thế kiểm thử giao hàng thực tế.

## 2. Cách thực hiện trên core hiện tại

1. Lưu code và mở `model/WarehouseRobot.nlogox`.
2. Vào tab Interface, mở Command Center và chọn `observer>`.
3. Dán khối lệnh của từng bài rồi nhấn Enter.
4. So sánh kết quả với giá trị mong đợi.

**Lưu ý:**
- Core mới đã gọi `setup-robots` trong `setup`.
- Không gọi thêm `setup-robots` sau `setup`, tránh tạo robot hai lần.
- `setup` xóa dữ liệu lượt trước.
- Bài có ghi “chạy tiếp” phải giữ nguyên trạng thái của bài trước.
- Các bài kiểm thử riêng dùng preset Normal để cố định số robot là 8.
- Không bấm Go trong lúc thực hiện các bài giả lập TC01–TC16.
- Các giá trị xác suất 0 hoặc 1 được đặt trực tiếp nhằm tạo dữ liệu kiểm thử chắc chắn.

## 3. Các bài kiểm thử riêng T05
Các lệnh TC01–TC16 dưới đây đã được chạy lại trên core mới.
Tất cả kết quả thực tế khớp kết quả mong đợi.

### TC01 – Sinh 10 đơn và phân công theo Nearest

**Mục đích:** 10 đơn được tạo; 8 robot nhận 8 đơn, 2 đơn tiếp tục chờ.

```netlogo
set scenario-preset "Normal" setup set active-strategy "Nearest" set order-spawn-rate 1 repeat 10 [ generate-orders ] show total-orders-created show count robots assign-unassigned-orders show count orders with [order-status = "assigned"] show count orders with [order-status = "waiting"]
```

- **Mong đợi:** `10 → 8 → 8 → 2`.
- **Kết quả chạy lại trên core mới:** `10 → 8 → 8 → 2`, đạt.

### TC02 – Sinh và phân công theo Least workload

**Mục đích:** Không phân công vượt quá số robot khả dụng.

```netlogo
set scenario-preset "Normal" setup set active-strategy "Least workload" set order-spawn-rate 1 repeat 10 [ generate-orders ] assign-unassigned-orders show count orders show count orders with [order-status = "assigned"] show count orders with [order-status = "waiting"]
```

- **Mong đợi:** `10 → 8 → 2`.
- **Kết quả chạy lại trên core mới:** `10 → 8 → 2`, đạt.

### TC03 – Least workload ưu tiên robot ít tải

**Mục đích:** Robot đã hoàn thành 5 đơn không được chọn khi còn robot có tải bằng 0.

```netlogo
set scenario-preset "Normal" setup set active-strategy "Least workload" set order-spawn-rate 1 ask min-one-of robots [who] [ set orders-done 5 ] generate-orders assign-unassigned-orders show [robot-state] of min-one-of robots [who]
```

- **Mong đợi:** `"idle"`.
- **Kết quả chạy lại trên core mới:** `"idle"`, đạt.

### TC04 – Nearest chọn robot gần nhất

**Mục đích:** Robot gần pickup-patch nhất được chọn.

Tất cả robot đứng tại `(0, -10)`.
Riêng robot có who nhỏ nhất đứng tại `(0, 13)`.
Điểm lấy hàng đặt tại `(0, 14)`.

```netlogo
set scenario-preset "Normal" setup set active-strategy "Nearest" set order-spawn-rate 1 generate-orders ask orders [ set pickup-patch patch 0 14 ] ask robots [ setxy 0 -10 ] ask min-one-of robots [who] [ setxy 0 13 ] assign-unassigned-orders show (([assigned-robot] of one-of orders) = (min-one-of robots [who]))
```

- **Mong đợi:** `true`.
- **Kết quả chạy lại trên core mới:** `true`, đạt.

### TC05 – Nearest xử lý hòa khoảng cách

**Mục đích:** Khi cùng khoảng cách, chọn robot có who nhỏ nhất.

```netlogo
set scenario-preset "Normal" setup set active-strategy "Nearest" set order-spawn-rate 1 ask robots [ setxy 0 0 ] generate-orders assign-unassigned-orders show (([assigned-robot] of one-of orders) = (min-one-of robots [who]))
```

- **Mong đợi:** `true`.
- **Kết quả chạy lại trên core mới:** `true`, đạt.

### TC06 – Least workload hòa tải và khoảng cách

**Mục đích:** Khi cùng tải và khoảng cách, chọn who nhỏ nhất.

```netlogo
set scenario-preset "Normal" setup set active-strategy "Least workload" set order-spawn-rate 1 ask robots [ setxy 0 0 ] generate-orders assign-unassigned-orders show (([assigned-robot] of one-of orders) = (min-one-of robots [who]))
```

- **Mong đợi:** `true`.
- **Kết quả chạy lại trên core mới:** `true`, đạt.

### TC07 – Hoàn thành đúng hạn và chống đếm trùng

**Mục đích:** complete-order cập nhật trạng thái và bộ đếm đúng.

Giả lập đơn đã lấy bằng trạng thái `"picked"`:

```netlogo
set scenario-preset "Normal" setup set active-strategy "Nearest" set order-spawn-rate 1 generate-orders assign-unassigned-orders ask orders [ set order-status "picked" ] complete-order one-of orders show [order-status] of one-of orders show total-orders-completed show total-orders-ontime show total-orders-late
```

- **Mong đợi:** `"completed" → 1 → 1 → 0`.
- **Kết quả chạy lại trên core mới:** đúng như mong đợi.

Chạy tiếp, không setup lại:

```netlogo
complete-order one-of orders show total-orders-completed show total-orders-ontime
```

- **Mong đợi:** `1 → 1`.
- **Kết quả chạy lại trên core mới:** `1 → 1`, đạt.

### TC08 – Thu hồi đơn và chống đếm trùng

**Mục đích:** release-order trả đơn về hàng chờ và ghi nhận thu hồi.

```netlogo
set scenario-preset "Normal" setup set active-strategy "Nearest" set order-spawn-rate 1 generate-orders assign-unassigned-orders release-order one-of orders show [order-status] of one-of orders show [assigned-robot] of one-of orders show [was-reassigned?] of one-of orders show total-orders-reassigned
```

- **Mong đợi:** `"waiting" → nobody → true → 1`.
- **Kết quả chạy lại trên core mới:** đúng như mong đợi.

Chạy tiếp, không setup lại:

```netlogo
release-order one-of orders show total-orders-reassigned
```

- **Mong đợi:** `1`.
- **Kết quả chạy lại trên core mới:** `1`, đạt.

Bài này kiểm tra phía đơn hàng. Module xử lý sự cố chịu trách nhiệm giải phóng nhiệm vụ và cập nhật trạng thái robot.

### TC09 – Đơn quá hạn còn tồn và hoàn thành trễ

**Mục đích:** Đơn quá hạn được ghi nhận khi còn tồn; khi hoàn thành trễ không bị đếm hai lần.

Đặt deadline tick 1 và hoàn thành tại tick 2:

```netlogo
set scenario-preset "Normal" setup set active-strategy "Nearest" set order-spawn-rate 1 generate-orders assign-unassigned-orders ask orders [ set deadline-tick 1 set order-status "picked" ] tick tick update-orders show total-orders-late complete-order one-of orders update-orders show total-orders-completed show total-orders-ontime show total-orders-late
```

- **Mong đợi:** `1 → 1 → 0 → 1`.
- **Kết quả chạy lại trên core mới:** `1 → 1 → 0 → 1`, đạt.

### TC10 – Đơn thu hồi được hoàn thành lại

**Mục đích:** Ghi nhận dữ liệu phục hồi.

Giả lập thu hồi, giải phóng robot, phân công lại và hoàn thành:

```netlogo
set scenario-preset "Normal" setup set active-strategy "Nearest" set order-spawn-rate 1 generate-orders assign-unassigned-orders ask robots with [current-order != nobody] [ release-order current-order set current-order nobody set target-patch nobody set robot-state "idle" ] assign-unassigned-orders ask orders [ set order-status "picked" ] complete-order one-of orders show total-orders-reassigned show total-reassigned-completed show total-orders-completed
```

- **Mong đợi:** `1 → 1 → 1`.
- **Kết quả chạy lại trên core mới:** `1 → 1 → 1`, đạt.

### TC11 – High đứng trước normal

**Mục đích:** Đơn high được xếp trước dù tạo sau.

```netlogo
set scenario-preset "Normal" setup set order-spawn-rate 1 set priority-order-ratio 0 generate-orders tick set priority-order-ratio 1 generate-orders show map [ord -> [priority] of ord] unassigned-orders
```

- **Mong đợi:** `["high" "normal"]`.
- **Kết quả chạy lại trên core mới:** `["high" "normal"]`, đạt.

### TC12 – Deadline high và normal

**Mục đích:** Xác nhận thời hạn nhóm đã chốt.

Chạy tiếp TC11, không setup lại:

```netlogo
show map [ord -> (list ([priority] of ord) (([deadline-tick] of ord) - ([created-tick] of ord)))] unassigned-orders
```

- **Mong đợi:** `[["high" 45] ["normal" 90]]`.
- **Kết quả chạy lại trên core mới:** đúng như mong đợi, đạt.

### TC13 – FIFO khi cùng mức ưu tiên

**Mục đích:** Đơn tạo trước được xếp trước khi cùng ưu tiên.

```netlogo
set scenario-preset "Normal" setup set order-spawn-rate 1 set priority-order-ratio 0 generate-orders tick generate-orders show map [ord -> [created-tick] of ord] unassigned-orders
```

- **Mong đợi:** `[0 1]`.
- **Kết quả chạy lại trên core mới:** `[0 1]`, đạt.

### TC14 – Không có robot khả dụng

**Mục đích:** Robot pin yếu không nhận đơn; đơn tiếp tục chờ.

```netlogo
set scenario-preset "Normal" setup set active-strategy "Nearest" set order-spawn-rate 1 ask robots [ set battery 10 ] generate-orders assign-unassigned-orders show count available-robots show count orders with [order-status = "assigned"] show count orders with [order-status = "waiting"]
```

- **Mong đợi:** `0 → 0 → 1`.
- **Kết quả chạy lại trên core mới:** `0 → 0 → 1`, đạt.

### TC15 – Least workload xét khoảng cách trước who

**Mục đích:** Khi cùng tải, chọn robot gần hơn thay vì robot có who nhỏ hơn nhưng đứng xa.

```netlogo
set scenario-preset "Normal" setup set active-strategy "Least workload" set order-spawn-rate 1 generate-orders ask orders [ set pickup-patch patch 0 14 ] ask robots [ setxy 0 13 ] ask min-one-of robots [who] [ setxy 0 -10 ] assign-unassigned-orders show (([assigned-robot] of one-of orders) = (min-one-of robots [who]))
```

- **Mong đợi:** `false`.
- **Kết quả chạy lại trên core mới:** `false`, đạt.

### TC16 – Hoàn thành đúng tại deadline

**Mục đích:** Kiểm tra điều kiện completed-tick <= deadline-tick.

```netlogo
set scenario-preset "Normal" setup set active-strategy "Nearest" set order-spawn-rate 1 generate-orders assign-unassigned-orders ask orders [ set deadline-tick 1 set order-status "picked" ] tick complete-order one-of orders show total-orders-ontime show total-orders-late
```

- **Mong đợi:** `1 → 0`.
- **Kết quả chạy lại trên core mới:** `1 → 0`, đạt.

## 4. Kiểm thử tích hợp ngày 28/11/2026

Các lượt sau chạy mô phỏng thực tế qua core và vòng go.
Không đặt giả trạng thái picked/completed hoặc di chuyển robot bằng lệnh test.

Thứ tự KPI trong snapshot:
1. Tên chiến lược.
2. Speed: thời gian hoàn thành trung bình, tick/đơn.
3. On-time: tỷ lệ đúng hạn, %.
4. Energy: năng lượng tiêu thụ trên đơn hoàn thành.
5. Balance: chỉ số cân bằng tải.
6. Resilience: chỉ số phục hồi.

Các số liệu dưới đây là kết quả quan sát của cấu hình và phiên bản đã thử, không phải giá trị cố định cho mọi cấu hình.

### TC17 – Normal, Nearest, seed 1

**Lệnh chạy:**

```netlogo
set scenario-preset "Normal" set management-goal "Balanced" setup run-single-strategy-to-end "Nearest" 1
```

Sau khi chạy xong:

```netlogo
show ticks show model-status show total-orders-created show total-orders-completed show collect-current-kpi-snapshot
```

**Kết quả thực tế:**

```text
300
"Done"
52
16
["Nearest" 91.75 21.21212121212121 105.8125 1 0.6413461538461538]
```

**Đối chiếu dữ liệu:**

```netlogo
show (total-orders-created = count orders)
show (total-orders-completed = count orders with [order-status = "completed"])
show (total-orders-ontime = count orders with [order-status = "completed" and completed-tick <= deadline-tick])
show (total-orders-completed = sum [orders-done] of robots)
```

**Kết quả thực tế:**

```text
true
true
true
true
```

**Kết luận:** Đạt các phép đối chiếu. Bộ đếm T05 khớp dữ liệu đơn hàng và robot trong lượt chạy này.

Lượt Nearest được chạy lại cùng cấu hình và seed đã cho cùng số đơn và KPI như trên.

### TC18 – Normal, Least workload, seed 1

Giữ preset Normal và mục tiêu Balanced từ TC17.

**Lệnh chạy:**

```netlogo
run-single-strategy-to-end "Least workload" 1
```

Sau khi chạy xong:

```netlogo
show ticks show model-status show total-orders-created show total-orders-completed show collect-current-kpi-snapshot
```

**Kết quả thực tế:**

```text
300
"Done"
53
16
["Least workload" 100.5 21.62162162162162 111.125 1 0.6376100628930818]
```

**Đối chiếu dữ liệu:**

```netlogo
show (total-orders-created = count orders)
show (total-orders-completed = count orders with [order-status = "completed"])
show (total-orders-ontime = count orders with [order-status = "completed" and completed-tick <= deadline-tick])
show (total-orders-completed = sum [orders-done] of robots)
```

**Kết quả thực tế:**

```text
true
true
true
true
```

**Kết luận:** Đạt các phép đối chiếu. Bộ đếm T05 khớp dữ liệu đơn hàng và robot trong lượt chạy này.

Lượt Least workload được chạy lại cùng cấu hình và seed đã cho cùng số đơn và KPI như trên.

### TC19 – Incidents, Nearest, seed 1

Mục tiêu quản lý giữ là Balanced.

**Lệnh chạy:**

```netlogo
set scenario-preset "Incidents" run-single-strategy-to-end "Nearest" 1
```

Sau khi chạy xong:

```netlogo
show total-incidents-triggered show total-orders-reassigned show total-reassigned-completed show total-orders-completed
```

**Kết quả thực tế:**

```text
28
16
5
14
```

Diễn giải:
- 28 sự cố được bộ đếm ghi nhận.
- 16 lần thu hồi đơn.
- 5 đơn từng bị thu hồi đã hoàn thành.
- Tổng 14 đơn hoàn thành.

Số lần thu hồi không đồng nghĩa số đơn khác nhau bị thu hồi; một đơn có thể bị thu hồi nhiều lần.

**Đối chiếu dữ liệu:**

```netlogo
show (total-reassigned-completed = count orders with [order-status = "completed" and was-reassigned?])
show (total-orders-completed = count orders with [order-status = "completed"])
show (total-orders-completed = sum [orders-done] of robots)
show count orders with [order-status = "waiting" and assigned-robot != nobody]
```

**Kết quả thực tế:**

```text
true
true
true
0
```

**Kết luận:** Đạt các phép đối chiếu:
- Bộ đếm đơn phục hồi hoàn thành khớp dữ liệu đơn.
- Tổng đơn hoàn thành khớp dữ liệu đơn và robot.
- Không có đơn waiting vẫn giữ robot phụ trách.

## 5. Docker/headless smoke test

### Lệnh đã chạy

Trong PowerShell tại thư mục gốc repository:

```powershell
docker compose build
.\scripts\run-experiments.ps1
```

### Kết quả thực tế

- Image `warehouse-robot-dss:dev` build thành công.
- NetLogo chạy headless thành công.
- Terminal hiển thị:

```text
Smoke test passed.
Result: experiments/results/smoke-test.csv
```

- CSV ghi nhận mô phỏng từ tick 0 đến tick 10.

### Phạm vi xác nhận

Smoke test xác nhận phiên bản được thử biên dịch và chạy được trong Docker.
Đây là kết quả smoke test đã chạy ở giai đoạn T05, không mặc nhiên chứng minh đã chạy lại Docker sau mọi cập nhật của repository.

Các phép kiểm thử tích hợp TC17–TC19 được thực hiện riêng qua Command Center.

## 6. Lưu ý về đầu vào so sánh

Trong preset Normal, Balanced, seed 1 và 300 tick:
- Nearest sinh 52 đơn.
- Least workload sinh 53 đơn.

Các bộ đếm đều đã đối chiếu khớp với dữ liệu thực tế.

Cùng cấu hình và seed hiện chưa bảo đảm hai chiến lược nhận cùng tập đơn, vì sinh đơn và các hoạt động mô phỏng dùng chung nguồn số ngẫu nhiên.

Vấn đề này được ghi nhận để nhóm xử lý khi thiết kế thực nghiệm T11. Không dùng các lượt trên để khẳng định so sánh trên cùng một tập đơn đầu vào.

Nếu cần so sánh trên cùng nhu cầu, tập đơn phải khớp cả:
- Thời điểm sinh.
- Mức ưu tiên.
- Điểm lấy và điểm giao.
- Deadline.

## 7. Trạng thái bàn giao T05

Đã có:
- Code quản lý đơn hàng và hai chiến lược cơ sở.
- Kết quả 16 bài kiểm thử riêng ở giai đoạn trước tích hợp.
- Kết quả ba lượt kiểm thử tích hợp TC17–TC19.
- Kết quả Docker/headless smoke test ở giai đoạn T05.
- Tài liệu thuật toán trong `docs/algorithms.md`.
- TC01–TC16 đã được chạy lại trên core mới ngày 28/11/2026.
- Tất cả kết quả thực tế khớp kết quả mong đợi.
- Các lệnh sử dụng setup để tạo robot, không gọi thêm setup-robots.