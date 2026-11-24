# Biên bản kiểm thử T05 – Orders và Basic Strategies

- **Người thực hiện:** TV3 – Nguyễn Khánh Vân
- **Module:** `model/src/orders.nls`, `model/src/basic-strategies.nls`
- **Môi trường:** NetLogo 7.0.4, Command Center ở chế độ `observer>`
- **Kết quả:** 16 bài kiểm thử dưới đây đạt kết quả mong đợi.

## 1. Phạm vi kiểm thử

Kiểm tra:
- Sinh đơn hàng và phân công đơn cho robot.
- Chiến lược Nearest và Least workload, bao gồm quy tắc hòa điểm.
- Sắp xếp hàng đợi theo ưu tiên và thời điểm tạo.
- Hạn giao: `high` là 45 tick, `normal` là 90 tick.
- Hoàn thành đơn, thu hồi đơn và cập nhật bộ đếm.
- Không đếm trùng khi gọi lại procedure.
- Giữ đơn trong hàng chờ khi không có robot khả dụng.

Các bài test được chạy trực tiếp bằng Command Center.
Một số bài chủ động đặt vị trí robot, trạng thái đơn hoặc deadline để kiểm tra từng quy tắc.

**Chưa kiểm thử tích hợp:** robot di chuyển và giao hàng thực tế thông qua T06 và vòng `Go`.

## 2. Cách thực hiện

1. Lưu hai file T05 và mở `model/WarehouseRobot.nlogox`.
2. Vào tab Interface, mở Command Center, chọn `observer>`.
3. Dán khối lệnh của từng bài test và nhấn Enter.
4. So sánh kết quả `show` với kết quả mong đợi.

`setup` xóa dữ liệu của bài test trước.
Các bài test có ghi “chạy tiếp” phải giữ nguyên trạng thái của bài trước.

---

## TC01 – Sinh 10 đơn và phân công theo Nearest

**Mục đích:** Xác nhận 10 đơn được tạo; 8 robot nhận 8 đơn, 2 đơn còn lại chờ.

```netlogo
setup setup-robots set active-strategy "Nearest" set order-spawn-rate 1 repeat 10 [ generate-orders ] show total-orders-created show count robots assign-unassigned-orders show count orders with [order-status = "assigned"] show count orders with [order-status = "waiting"]
```

**Mong đợi và thực tế:** `10 → 8 → 8 → 2`.

**Kết quả:** Đạt.

> Preset Normal và Peak đều có 8 robot. Khi thử lại, chọn một trong hai preset trước khi chạy.

---

## TC02 – Sinh và phân công theo Least workload

**Mục đích:** Xác nhận phân công không vượt quá số robot khả dụng.

```netlogo
setup setup-robots set active-strategy "Least workload" set order-spawn-rate 1 repeat 10 [ generate-orders ] assign-unassigned-orders show count orders show count orders with [order-status = "assigned"] show count orders with [order-status = "waiting"]
```

**Mong đợi và thực tế:** `10 → 8 → 2`.

**Kết quả:** Đạt.

> Bài này dùng preset có 8 robot như TC01.

---

## TC03 – Least workload ưu tiên robot ít tải

**Mục đích:** Robot đã hoàn thành 5 đơn không được chọn khi còn robot có tải bằng 0.

```netlogo
setup setup-robots set active-strategy "Least workload" set order-spawn-rate 1 ask min-one-of robots [who] [ set orders-done 5 ] generate-orders assign-unassigned-orders show [robot-state] of min-one-of robots [who]
```

**Mong đợi và thực tế:** `"idle"`.

**Kết quả:** Đạt.

---

## TC04 – Nearest chọn robot gần điểm lấy hàng nhất

**Mục đích:** Kiểm tra lựa chọn theo khoảng cách đến `pickup-patch`.

Tất cả robot đứng tại `(0, -10)`, riêng robot có `who` nhỏ nhất đứng tại `(0, 13)`. Điểm lấy hàng đặt tại `(0, 14)`.

```netlogo
setup setup-robots set active-strategy "Nearest" set order-spawn-rate 1 generate-orders ask orders [ set pickup-patch patch 0 14 ] ask robots [ setxy 0 -10 ] ask min-one-of robots [who] [ setxy 0 13 ] assign-unassigned-orders show (([assigned-robot] of one-of orders) = (min-one-of robots [who]))
```

**Mong đợi và thực tế:** `true`.

**Kết quả:** Đạt.

---

## TC05 – Nearest xử lý hòa khoảng cách

**Mục đích:** Khi robot cùng khoảng cách, chọn robot có `who` nhỏ nhất.

```netlogo
setup setup-robots set active-strategy "Nearest" set order-spawn-rate 1 ask robots [ setxy 0 0 ] generate-orders assign-unassigned-orders show (([assigned-robot] of one-of orders) = (min-one-of robots [who]))
```

**Mong đợi và thực tế:** `true`.

**Kết quả:** Đạt.

---

## TC06 – Least workload xử lý hòa tải và khoảng cách

**Mục đích:** Khi robot cùng `orders-done` và khoảng cách, chọn robot có `who` nhỏ nhất.

```netlogo
setup setup-robots set active-strategy "Least workload" set order-spawn-rate 1 ask robots [ setxy 0 0 ] generate-orders assign-unassigned-orders show (([assigned-robot] of one-of orders) = (min-one-of robots [who]))
```

**Mong đợi và thực tế:** `true`.

**Kết quả:** Đạt.

---

## TC07 – Ghi nhận đơn hoàn thành đúng hạn và không đếm trùng

**Mục đích:** Kiểm tra `complete-order` cập nhật trạng thái và bộ đếm đúng hạn.

Giả lập đơn đã được lấy bằng trạng thái `"picked"`:

```netlogo
setup setup-robots set active-strategy "Nearest" set order-spawn-rate 1 generate-orders assign-unassigned-orders ask orders [ set order-status "picked" ] complete-order one-of orders show [order-status] of one-of orders show total-orders-completed show total-orders-ontime show total-orders-late
```

**Mong đợi và thực tế:** `"completed" → 1 → 1 → 0`.

Chạy tiếp, không gọi lại `setup`:

```netlogo
complete-order one-of orders show total-orders-completed show total-orders-ontime
```

**Mong đợi và thực tế:** `1 → 1`.

**Kết quả:** Đạt. Gọi lại trên đơn đã hoàn thành không làm tăng bộ đếm.

---

## TC08 – Thu hồi đơn và không đếm trùng

**Mục đích:** Kiểm tra `release-order` trả đơn về hàng chờ và ghi nhận thu hồi.

```netlogo
setup setup-robots set active-strategy "Nearest" set order-spawn-rate 1 generate-orders assign-unassigned-orders release-order one-of orders show [order-status] of one-of orders show [assigned-robot] of one-of orders show [was-reassigned?] of one-of orders show total-orders-reassigned
```

**Mong đợi và thực tế:** `"waiting" → nobody → true → 1`.

Chạy tiếp, không gọi lại `setup`:

```netlogo
release-order one-of orders show total-orders-reassigned
```

**Mong đợi và thực tế:** `1`.

**Kết quả:** Đạt.

> Bài này chỉ kiểm tra phía đơn hàng. Khi tích hợp, phía xử lý sự cố phải giải phóng `current-order` và cập nhật trạng thái robot.

---

## TC09 – Đơn quá hạn còn tồn và hoàn thành trễ

**Mục đích:** Đơn quá hạn được ghi nhận ngay khi còn tồn; khi hoàn thành trễ vẫn chỉ tính một lần.

Đặt deadline bằng tick 1, hoàn thành tại tick 2:

```netlogo
setup setup-robots set active-strategy "Nearest" set order-spawn-rate 1 generate-orders assign-unassigned-orders ask orders [ set deadline-tick 1 set order-status "picked" ] tick tick update-orders show total-orders-late complete-order one-of orders update-orders show total-orders-completed show total-orders-ontime show total-orders-late
```

**Mong đợi và thực tế:** `1 → 1 → 0 → 1`.

**Kết quả:** Đạt.

---

## TC10 – Đơn từng thu hồi được hoàn thành lại

**Mục đích:** Kiểm tra dữ liệu phục vụ đánh giá khả năng phục hồi.

Giả lập thu hồi, giải phóng robot, phân công lại và hoàn thành đơn:

```netlogo
setup setup-robots set active-strategy "Nearest" set order-spawn-rate 1 generate-orders assign-unassigned-orders ask robots with [current-order != nobody] [ release-order current-order set current-order nobody set target-patch nobody set robot-state "idle" ] assign-unassigned-orders ask orders [ set order-status "picked" ] complete-order one-of orders show total-orders-reassigned show total-reassigned-completed show total-orders-completed
```

**Mong đợi và thực tế:** `1 → 1 → 1`.

**Kết quả:** Đạt.

---

## TC11 – Ưu tiên đơn high trước normal

**Mục đích:** Đơn `high` được xếp trước dù tạo sau đơn `normal`.

```netlogo
setup set order-spawn-rate 1 set priority-order-ratio 0 generate-orders tick set priority-order-ratio 1 generate-orders show map [ord -> [priority] of ord] unassigned-orders
```

**Mong đợi và thực tế:**

```text
["high" "normal"]
```

**Kết quả:** Đạt.

> Tỷ lệ 0 và 1 được đặt trực tiếp để tạo chắc chắn từng loại đơn trong bài test.

---

## TC12 – Hạn giao của high và normal

**Mục đích:** Xác nhận thời hạn đã được nhóm thống nhất.

Chạy tiếp TC11, không gọi lại `setup`:

```netlogo
show map [ord -> (list ([priority] of ord) (([deadline-tick] of ord) - ([created-tick] of ord)))] unassigned-orders
```

**Mong đợi và thực tế:**

```text
[["high" 45] ["normal" 90]]
```

**Kết quả:** Đạt.

---

## TC13 – Cùng ưu tiên thì đơn cũ đứng trước

**Mục đích:** Kiểm tra hàng đợi sắp xếp theo `created-tick` tăng dần khi cùng mức ưu tiên.

```netlogo
setup set order-spawn-rate 1 set priority-order-ratio 0 generate-orders tick generate-orders show map [ord -> [created-tick] of ord] unassigned-orders
```

**Mong đợi và thực tế:**

```text
[0 1]
```

**Kết quả:** Đạt.

---

## TC14 – Không có robot khả dụng

**Mục đích:** Robot pin yếu không nhận đơn; đơn tiếp tục chờ.

```netlogo
setup setup-robots set active-strategy "Nearest" set order-spawn-rate 1 ask robots [ set battery 10 ] generate-orders assign-unassigned-orders show count available-robots show count orders with [order-status = "assigned"] show count orders with [order-status = "waiting"]
```

**Mong đợi và thực tế:** `0 → 0 → 1`.

**Kết quả:** Đạt.

---

## TC15 – Least workload ưu tiên khoảng cách trước who

**Mục đích:** Khi cùng tải, robot gần hơn phải được chọn trước robot có `who` nhỏ hơn nhưng đứng xa.

```netlogo
setup setup-robots set active-strategy "Least workload" set order-spawn-rate 1 generate-orders ask orders [ set pickup-patch patch 0 14 ] ask robots [ setxy 0 13 ] ask min-one-of robots [who] [ setxy 0 -10 ] assign-unassigned-orders show (([assigned-robot] of one-of orders) = (min-one-of robots [who]))
```

**Mong đợi và thực tế:** `false`.

**Kết quả:** Đạt.

---

## TC16 – Hoàn thành đúng tại deadline

**Mục đích:** Kiểm tra điều kiện biên `completed-tick <= deadline-tick`.

Đặt deadline bằng tick 1 và hoàn thành tại tick 1:

```netlogo
setup setup-robots set active-strategy "Nearest" set order-spawn-rate 1 generate-orders assign-unassigned-orders ask orders [ set deadline-tick 1 set order-status "picked" ] tick complete-order one-of orders show total-orders-ontime show total-orders-late
```

**Mong đợi và thực tế:** `1 → 0`.

**Kết quả:** Đạt.

## 3. Trạng thái bàn giao

Các phép thử riêng cho T05 nêu trên đã đạt theo kết quả chạy trực tiếp trong Command Center.

Chưa xác nhận luồng tích hợp đầy đủ:
- Tạo đơn qua vòng `Go`.
- Robot di chuyển, lấy hàng và giao hàng bằng routing T06.
- Thu hồi đơn khi phát sinh sự cố thực tế.
- Đối chiếu kết quả với module metrics.

Sau khi T06 và vòng `Go` được tích hợp, cần chạy kiểm thử đầu cuối để xác nhận các module phối hợp đúng.

Chạy `setup` sau khi hoàn tất kiểm thử để xóa dữ liệu giả lập.