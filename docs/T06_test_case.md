# Biên bản kiểm thử T06 – Routing, Congestion và Incidents

- **Người thực hiện:** TV4 – Nguyễn Đức Tiến
- **Module:** `model/src/routing.nls`, `model/src/congestion.nls`, `model/src/incidents.nls`
- **Môi trường:** NetLogo 7.0.4, Command Center ở chế độ `observer>`
- **Kết quả:** Toàn bộ 10 bài kiểm thử dưới đây đạt kết quả mong đợi.

---

## 1. Phạm vi kiểm thử

Kiểm tra:
- Thuật toán tìm đường từng bước (`next-step-toward`, `move-robot-step`): không đi xuyên kệ, né ô bị khóa.
- Tránh va chạm và điều hướng vòng khi gặp tắc nghẽn (`wait-streak` và `re-routing`).
- Ước lượng chi phí thời gian hoàn thành đơn (`estimated-trip-ticks`).
- Cập nhật chỉ số tắc nghẽn tức thời trên ô (`update-congestion`, `congestion-score`).
- Ước lượng mật độ tắc nghẽn dọc hành lang (`path-congestion`).
- Kích hoạt sự cố làm hỏng robot (`break-robot`), giải phóng đơn hàng về hàng đợi (`release-order`, `was-reassigned? = true`).
- Robot tự phục hồi sau khi hết thời hạn hỏng (`broken-until`).
- Khóa cụm lối đi (`block-aisle-segment`) và tự động giải phóng khi hết hạn (`update-incidents`).
- Kích hoạt sự cố thủ công cho mục đích demo tương tác (`trigger-manual-incident`).
- Tích hợp vòng đời di chuyển: Robot nhận đơn -> di chuyển lấy hàng -> giao hàng thành công.

---

## 2. Cách thực hiện

1. Mở file `model/WarehouseRobot.nlogox` trong **NetLogo 7.0.4**.
2. Vào tab **Interface**, mở khung **Command Center** ở phía dưới, chọn chế độ `observer>`.
3. Dán từng khối lệnh kiểm thử vào Command Center và nhấn **Enter**.
4. So sánh kết quả hiển thị trên Command Center / màn hình với kết quả mong đợi.

---

## TC01 – Robot tìm đường không đi xuyên kệ hàng

**Mục đích:** Xác nhận robot khi di chuyển từ khu chờ (-14, 0) sang khu lấy hàng (0, 14) chỉ đi trên các ô lối đi, tuyệt đối không bước vào kệ hàng (`patch-type != "shelf"`).

```netlogo
setup setup-robots ask robots [ setxy -14 0 set target-patch patch 0 14 ] repeat 30 [ ask robots [ travel-one-step ] ] show any? robots with [ [patch-type] of patch-here = "shelf" ]
```

**Mong đợi:** `false` (không có bất kỳ robot nào đứng trên kệ hàng).  
**Kết quả:** Đạt.

---

## TC02 – Robot tự động đi đường vòng né ô lối đi bị sự cố khóa

**Mục đích:** Đặt một ô bị khóa (`is-blocked? = true`) ngay trên đường đi thẳng của robot, xác nhận robot tự phát hiện và rẽ sang ô lối đi hợp lệ khác.

```netlogo
setup setup-robots let r one-of robots ask r [ setxy 0 0 set target-patch patch 0 5 ] ask patch 0 1 [ set is-blocked? true set pcolor red ] ask r [ travel-one-step ] show [pxcor] of r show [pycor] of r show ([patch-type] of [patch-here] of r != "shelf" and not [is-blocked?] of [patch-here] of r)
```

**Mong đợi:** Robot rẽ sang ô bên cạnh (ví dụ `(1, 0)` hoặc `(-1, 0)`) thay vì đi thẳng vào ô `(0, 1)` đang bị khóa màu đỏ. Biểu thức cuối cùng trả về `true`.  
**Kết quả:** Đạt.

---

## TC03 – Tính toán tắc nghẽn tức thời trên ô (congestion-score)

**Mục đích:** Xác nhận khi có nhiều robot tập trung, ô đó và các ô lân cận tăng điểm `congestion-score` tương ứng.

```netlogo
setup setup-robots ask robots [ setxy 0 0 ] update-congestion show [congestion-score] of patch 0 0 show [congestion-score] of patch 0 1 show [congestion-score] of patch 10 10
```

**Mong đợi:** `patch 0 0` có điểm tắc nghẽn cao nhất (nơi tập trung robot), `patch 0 1` lân cận có điểm trung bình, `patch 10 10` không có robot điểm bằng `0`.  
**Kết quả:** Đạt.

---

## TC04 – Ước lượng tắc nghẽn hành lang (path-congestion)

**Mục đích:** Xác nhận hàm `path-congestion from-p to-p` trả về giá trị trung bình mức tắc nghẽn của các ô lối đi giữa 2 điểm.

```netlogo
setup setup-robots ask n-of 4 robots [ setxy 0 pycor ] update-congestion show path-congestion (patch 0 -5) (patch 0 5) show path-congestion (patch 12 -5) (patch 12 5)
```

**Mong đợi:** Tuyến đi qua cột `x = 0` (đang có robot) có điểm lớn hơn tuyến thông thoáng ở cột `x = 12`.  
**Kết quả:** Đạt.

---

## TC05 – Sự cố robot hỏng và thu hồi đơn hàng (break-robot)

**Mục đích:** Khi robot gặp sự cố hỏng, trạng thái chuyển sang `"broken"`, đơn hàng đang giữ được giải phóng về hàng chờ (`order-status = "waiting"`), đánh dấu `was-reassigned? = true`.

```netlogo
setup setup-robots set active-strategy "Nearest" repeat 3 [ generate-orders ] assign-unassigned-orders let busy-r one-of robots with [current-order != nobody] let ord [current-order] of busy-r break-robot busy-r 20 show [robot-state] of busy-r show [order-status] of ord show [was-reassigned?] of ord show total-orders-reassigned
```

**Mong đợi:** Robot chuyển thành `"broken"`, đơn hàng chuyển thành `"waiting"`, `was-reassigned?` là `true`, `total-orders-reassigned >= 1`.  
**Kết quả:** Đạt.

---

## TC06 – Robot tự phục hồi sau khi hết thời hạn sự cố

**Mục đích:** Khi thời gian mô phỏng vượt qua `broken-until`, robot tự động chuyển từ trạng thái `"broken"` về `"idle"` để tiếp tục nhận việc.

```netlogo
setup setup-robots let r one-of robots break-robot r 10 show [robot-state] of r repeat 11 [ tick ask robots [ update-one-robot ] ] show [robot-state] of r
```

**Mong đợi:** Ban đầu `show [robot-state] of r` in ra `"broken"`; sau 11 tick in ra `"idle"`.  
**Kết quả:** Đạt.

---

## TC07 – Tự động phục hồi các ô lối đi bị khóa khi hết hạn

**Mục đích:** `block-aisle-segment` khóa ô trong 15 tick; sau 15 tick hàm `update-incidents` tự động mở khóa và trả về màu lối đi bình thường.

```netlogo
setup block-aisle-segment 15 let blocked count patches with [is-blocked?] show (blocked > 0) repeat 16 [ tick update-incidents ] show count patches with [is-blocked?]
```

**Mong đợi:** Ban đầu `blocked > 0` in ra `true`; sau 16 tick số ô bị khóa trở về `0`.  
**Kết quả:** Đạt.

---

## TC08 – Kích hoạt sự cố ngẫu nhiên bằng trigger-manual-incident

**Mục đích:** Nút demo trên giao diện kích hoạt thành công ít nhất 1 sự cố (hỏng robot hoặc khóa đoạn đường) và tăng biến đếm `total-incidents-triggered`.

```netlogo
setup setup-robots show total-incidents-triggered trigger-manual-incident show total-incidents-triggered
```

**Mong đợi:** `total-incidents-triggered` tăng từ `0` lên `1`.  
**Kết quả:** Đạt.

---

## TC09 – Ước lượng thời gian chuyến đi (estimated-trip-ticks)

**Mục đích:** Hàm `estimated-trip-ticks r ord` tính đúng khoảng cách Manhattan robot -> lấy hàng -> giao hàng.

```netlogo
setup setup-robots let r one-of robots ask r [ setxy 0 0 ] let o nobody create-orders 1 [ set pickup-patch patch 0 10 set delivery-patch patch 10 10 set o self ] show estimated-trip-ticks r o
```

**Mong đợi:** Khoảng cách `(0,0) -> (0,10)` là 10, `(0,10) -> (10,10)` là 10, tổng cộng in ra `20`.  
**Kết quả:** Đạt.

---

## TC10 – Kiểm thử tích hợp di chuyển hoàn chỉnh đơn hàng

**Mục đích:** Robot nhận đơn, tự động di chuyển đến ô lấy hàng, nhận hàng (`picked`), di chuyển đến ô đóng gói, và hoàn thành đơn (`completed`).

```netlogo
setup setup-robots set active-strategy "Nearest" repeat 1 [ generate-orders ] assign-unassigned-orders let ord one-of orders repeat 100 [ tick ask robots [ update-one-robot ] update-orders if [order-status] of ord = "completed" [ stop ] ] show [order-status] of ord show total-orders-completed
```

**Mong đợi:** `order-status` của đơn in ra `"completed"`, `total-orders-completed` in ra `1`.  
**Kết quả:** Đạt.
