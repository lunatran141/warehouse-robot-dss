# T05 – Đơn hàng và hai chiến lược điều phối cơ sở

- Người thực hiện: TV3 – Nguyễn Khánh Vân.
- Module: `model/src/orders.nls`, `model/src/basic-strategies.nls`.
- Trạng thái: Đã triển khai và kiểm thử riêng T05; chờ kiểm thử tích hợp.

## 1. Mục đích

Tạo nhu cầu vận hành kho và hai phương án điều phối cơ sở:
- Nearest: chọn robot gần điểm lấy hàng nhất.
- Least workload: chọn robot có số đơn đã hoàn thành ít nhất.

Các module lưu dữ liệu đơn hàng để TV5 tính KPI và so sánh chiến lược.

## 2. Sinh đơn hàng

Procedure: `generate-orders`.

Mỗi lần được gọi:
1. Thử sinh tối đa một đơn với xác suất `order-spawn-rate`.
2. Lấy điểm nhận hàng từ `random-pickup-patch` và điểm giao từ `random-packing-patch`.
3. Nếu thiếu điểm nhận hoặc giao hợp lệ, không tạo đơn.
4. Chọn mức ưu tiên theo xác suất `priority-order-ratio`.
5. Khởi tạo trạng thái và thời gian:
   - `order-status = "waiting"`.
   - `created-tick = ticks`.
   - `completed-tick = -1`.
   - `assigned-robot = nobody`.
   - `was-reassigned? = false`.
6. Đặt deadline:
   - `high`: `created-tick + 45`.
   - `normal`: `created-tick + 90`.
7. Tăng `total-orders-created`.

Trong mô phỏng tích hợp, core phải gọi procedure đúng một lần mỗi tick.

## 3. Hàng đợi

Reporter: `unassigned-orders`.

Chỉ lấy các đơn có trạng thái `"waiting"` và trả về một danh sách sắp theo:
1. `high` trước `normal`.
2. Cùng mức ưu tiên: `created-tick` nhỏ hơn đứng trước.
3. Cùng thời điểm tạo: `who` nhỏ hơn đứng trước.

Quy tắc cuối giúp tránh lựa chọn ngẫu nhiên khi hòa.

## 4. Phân công đơn

Procedure: `assign-unassigned-orders`.

Giả mã:

    Với mỗi đơn trong hàng đợi đã sắp:
        Chọn robot theo active-strategy.
        Nếu tìm được robot:
            Gọi assign-task của robot đó.
        Nếu không có robot:
            Giữ đơn ở trạng thái waiting.

`assign-task` thuộc module T04 và chịu trách nhiệm cập nhật quan hệ giữa robot và đơn.
T05 không đổi đơn sang `"assigned"` trước khi gọi procedure này.

Hai chiến lược cơ sở chỉ xét robot từ `available-robots` do T04 cung cấp.

## 5. Nearest

Reporter: `select-robot-nearest [ord]`.

Thứ tự lựa chọn:
1. Khoảng cách từ robot đến `pickup-patch` nhỏ nhất.
2. Nếu hòa khoảng cách, chọn `who` nhỏ nhất.

Trả về `nobody` nếu không có robot khả dụng hoặc thiếu đơn/điểm lấy hợp lệ.

Ví dụ:
- Robot A cách điểm lấy 3 đơn vị.
- Robot B cách điểm lấy 8 đơn vị.
- Nếu cả hai khả dụng, chọn A.

Khoảng cách dùng primitive `distance` của NetLogo; không phải độ dài tuyến tránh vật cản do T06 tìm.

## 6. Least workload

Reporter: `select-robot-least-workload [ord]`.

Thứ tự lựa chọn:
1. `orders-done` nhỏ nhất.
2. Nếu cùng tải, chọn khoảng cách đến `pickup-patch` nhỏ nhất.
3. Nếu vẫn hòa, chọn `who` nhỏ nhất.

Trả về `nobody` nếu không có robot khả dụng hoặc thiếu đơn/điểm lấy hợp lệ.

Ví dụ:
- Robot A ở gần nhưng đã hoàn thành 5 đơn.
- Robot B ở xa hơn nhưng chưa hoàn thành đơn nào.
- Nếu cả hai khả dụng, chọn B.

`orders-done` do T04 cập nhật sau khi giao hàng.
T05 không tăng biến này trong `complete-order` để tránh đếm trùng.

## 7. Hoàn thành và xác định đơn trễ

Procedure: `complete-order [ord]`.

Chỉ xử lý đơn đang ở trạng thái `"picked"`:
- Đổi trạng thái thành `"completed"`.
- Ghi `completed-tick = ticks`.
- Tăng `total-orders-completed`.
- Nếu `completed-tick <= deadline-tick`, tăng `total-orders-ontime`.
- Nếu đơn từng bị thu hồi, tăng `total-reassigned-completed`.
- Cập nhật thống kê đơn trễ.

Gọi lại trên đơn đã hoàn thành không làm tăng bộ đếm.

Procedure: `update-orders`.

Tính lại `total-orders-late` từ:
- Đơn đã hoàn thành sau deadline.
- Đơn chưa hoàn thành nhưng `ticks > deadline-tick`.

Không cộng dồn đơn quá hạn qua từng tick.
Đơn hoàn thành đúng tại deadline vẫn được tính đúng hạn.

Giữ các agent đơn đã hoàn thành để metrics có thể đọc thời gian và trạng thái lịch sử.

## 8. Thu hồi đơn

Procedure: `release-order [ord]`.

Với đơn đang được xử lý:
- Trả về trạng thái `"waiting"`.
- Đặt `assigned-robot = nobody`.
- Đặt `was-reassigned? = true`.
- Tăng `total-orders-reassigned`.

Không thu hồi lại đơn đã chờ hoặc đã hoàn thành.

Theo giả định hiện tại, robot nhận lại đơn sẽ đi tới `pickup-patch` ban đầu.
Deadline và thời điểm tạo được giữ nguyên sau thu hồi.

Module gọi `release-order` phải giải phóng `current-order` và cập nhật trạng thái robot theo contract.
T05 chỉ xử lý phần dữ liệu đơn hàng.

## 9. Dữ liệu cung cấp cho metrics

Thông tin từng đơn:
- `priority`, `order-status`.
- `created-tick`, `deadline-tick`, `completed-tick`.
- `pickup-patch`, `delivery-patch`, `assigned-robot`.
- `was-reassigned?`.

Các bộ đếm:
- `total-orders-created`.
- `total-orders-completed`.
- `total-orders-ontime`.
- `total-orders-late`.
- `total-orders-reassigned`.
- `total-reassigned-completed`.

TV5 dùng dữ liệu này để tính KPI; T05 không tự chuẩn hóa, chấm điểm hoặc xếp hạng chiến lược.

## 10. Độ phức tạp

Gọi N là số đơn hàng, W là số đơn chờ và R là số robot:
- Sinh tối đa một đơn: ngoài chi phí chọn patch và tạo agent.
- Sắp xếp hàng đợi: thông thường O(W log W).
- Mỗi lần chọn robot theo một chiến lược cơ sở: O(R).
- Phân công cả hàng đợi: O(W log W + W × R).
- `update-orders`: O(N).
- `complete-order` hiện gọi `update-orders`, nên có chi phí O(N).

## 11. Phụ thuộc tích hợp

- TV1: cung cấp môi trường và nối các procedure vào setup/go.
- TV2: cung cấp available-robots, assign-task và vòng đời robot.
- TV4: cung cấp di chuyển và xử lý sự cố.
- TV5: cung cấp select-robot-multi-criteria và metrics.

T05 chuẩn bị lời gọi `select-robot-multi-criteria ord`.
Khi TV5 chưa có thuật toán thật, reporter tạm chỉ phục vụ biên dịch và báo lỗi rõ ràng nếu được gọi.

Chi tiết kiểm thử riêng nằm trong `docs/T05_test_case.md`.