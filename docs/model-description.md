# Mô tả Mô hình Warehouse Robot DSS

Tài liệu này giới thiệu tổng quan mô hình mô phỏng đa tác tử kết hợp hỗ trợ ra quyết định (Agent-based DSS) cho bài toán điều phối robot trong kho hàng thông minh trên nền tảng **NetLogo 7.0.4** (`model/WarehouseRobot.nlogox`).

> **Nguồn đặc tả kỹ thuật chuẩn (Single Source of Truth):** Toàn bộ Data Dictionary (biến Interface, `globals`, `breeds`, `*-own`), công thức chi tiết 5 KPI, 3 chiến lược và Procedure Contract của 12 module `.nls` được quy định thống nhất tại [**`docs/dss-contract.md`**](./dss-contract.md). Các thành viên không tự ý thay đổi tên biến hoặc chữ ký hàm ngoài hợp đồng đã duyệt.

---

## 1. Bối cảnh bài toán & Cân bằng 50/50

- **Bài toán**: Trong kho hàng thông minh, nhiều robot tự chủ cùng tiếp nhận và xử lý các đơn hàng (thường và ưu tiên) trong điều kiện có giới hạn pin, tắc nghẽn lối đi và rủi ro sự cố.
- **Triết lý 50% Mô phỏng ABM – 50% Hỗ trợ ra quyết định (DSS)**:
  - **50% Mô phỏng Agent-based**: Mô hình hóa chân thực robot, đơn hàng và môi trường kho để tạo dữ liệu vận hành đáng tin cậy trên cùng điều kiện công bằng.
  - **50% Hỗ trợ ra quyết định**: Thu thập 5 KPI, chuẩn hóa về cùng thang đo, tính `Strategy Score` theo mục tiêu của người quản lý, xếp hạng 3 chiến lược và cung cấp khuyến nghị tham khảo kèm giải thích và cảnh báo đánh đổi. **Người quản lý là người đưa ra quyết định cuối cùng.**

---

## 2. Ba tầng kiến trúc của mô hình

1. **Tầng Mô phỏng (`core`, `environment`, `scenarios`, `robot`, `battery`, `orders`, `basic-strategies`, `routing`, `congestion`, `incidents`)**:
   - **Môi trường kho (`patches`)**: Gồm lối đi (`"aisle"`), kệ hàng (`"shelf"`), điểm lấy hàng (`"pickup"`), khu đóng gói (`"packing"`), trạm sạc (`"charger"`) và vùng chờ (`"waiting-zone"`).
   - **Tác tử Robot (`robots`)**: Vận hành theo máy trạng thái 7 trạng thái (`"idle"`, `"assigned"`, `"to-pickup"`, `"carrying"`, `"waiting"`, `"charging"`, `"broken"`), có tiêu hao/sạc pin và xử lý sự cố.
   - **Tác tử Đơn hàng (`orders`)**: Có thời điểm phát sinh, mức ưu tiên (`"normal"` / `"high"`), hạn giao (`deadline-tick`) và hỗ trợ trả đơn về hàng chờ (`release-order`) khi robot gặp sự cố.
2. **Tầng Đo lường (`metrics.nls` & BehaviorSpace)**:
   - Theo dõi **5 KPI cốt lõi**: `Speed` (thời gian hoàn thành trung bình), `On-time` (tỷ lệ đơn đúng hạn), `Energy` (năng lượng tiêu thụ/đơn), `Balance` (mức cân bằng tải) và `Resilience` (khả năng phục hồi).
   - Chạy thực nghiệm lặp tối thiểu 10 lần với cùng tập `sim-seed` trên 4 kịch bản (`Normal`, `Peak`, `Congestion`, `Incidents`).
3. **Tầng Hỗ trợ ra quyết định (`decision-engine.nls` & UI Decision Support)**:
   - Chuẩn hóa Min-Max kết quả của **3 chiến lược** (`Nearest`, `Least workload`, `Multi-criteria`), nhân trọng số theo mục tiêu quản lý (`management-goal` hoặc 5 slider `w-*`), xếp hạng và xuất `Suggested Strategy`, `Explanation` và `Trade-off Warning`.

---

## 3. Phân chia 12 Module mã nguồn (`model/src/`)

| Nhóm tầng | Module `.nls` | Phụ trách | Vai trò chính |
|---|---|---|---|
| Nền mô hình | `core.nls`, `environment.nls`, `scenarios.nls` | TV1 | Điều phối vòng đời `setup`/`go`/`setup-for-strategy`, bản đồ kho và preset kịch bản |
| Tác tử Robot & Pin | `robot.nls`, `battery.nls` | TV2 | Máy trạng thái 7 trạng thái, tiêu hao năng lượng, phát hiện pin thấp và sạc |
| Đơn hàng & Cơ sở | `orders.nls`, `basic-strategies.nls` | TV3 | Sinh/quản lý vòng đời đơn hàng và chiến lược `Nearest`, `Least workload` |
| Điều kiện động | `routing.nls`, `congestion.nls`, `incidents.nls` | TV4 | Tìm đường tránh vật cản/lối khóa, đo tắc nghẽn và tạo/phục hồi sự cố |
| Đo lường & DSS | `metrics.nls`, `decision-engine.nls` | TV5 (+ TV3 `T09`) | Tính 5 KPI, chiến lược `Multi-criteria`, chuẩn hóa, chấm điểm, xếp hạng và giải thích |

---

## 4. Hướng dẫn đóng góp phần Mô hình khái niệm (TV2 & TV4)

Khi hoàn thiện báo cáo và tài liệu ở các bước tiếp theo, TV2 và TV4 có thể bổ sung sơ đồ trạng thái robot, giả định mô hình và phân tích giới hạn chi tiết vào tài liệu này hoặc `docs/algorithms.md`, đồng thời giữ nguyên mọi tên biến và chữ ký procedure đã thống nhất trong [`docs/dss-contract.md`](./dss-contract.md).
