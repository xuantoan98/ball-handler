# M4 — key visual chapter để duyệt

Bốn ảnh dưới đây là **preview ý tưởng**, tạo ngày 30/10/2026 bằng built-in `image_gen` (không dùng CLI/API key). Ảnh chuẩn `design/Midnight Shadow Theatre Game Board.png` đã được xem để đối chiếu; công cụ imagegen không đọc được file tham chiếu trực tiếp trong lần gọi do lỗi sandbox, nên các prompt mô tả nhận diện bằng chữ. Không ảnh nào được đưa vào build. Tọa độ và collision chỉ lấy từ `lib/core/level_catalog.dart`.

| Nhóm màn | Key visual | Điểm cần duyệt/chỉnh |
| --- | --- | --- |
| 04–07 Vườn trăng | `design/chapters/moon-garden-preview-v1.png` | Giữ cây/hoa ở mép, cảm biến dọc; cần duyệt mức chi tiết và khoảng thoáng. |
| 08–12 Xưởng sao | `design/chapters/star-workshop-preview-v1.png` | Motif bánh răng; hình sao trong ảnh giống vật trang trí hơn đĩa sao chuẩn, phải sửa nếu dùng làm asset. |
| 13–16 Thư viện đêm | `design/chapters/night-library-preview-v1.png` | Sách và quỹ đạo giấy ở viền; cảm biến trong ảnh nằm ngang, không khớp dữ liệu màn cụ thể. |
| 17–20 Sân khấu thiên hà | `design/chapters/cosmic-stage-preview-v1.png` | Giữ rèm tím và sao xa; cảm biến trong ảnh dọc hết thấp, không phải đường đi đã replay. |

Prompt set của bốn ảnh: "Portrait flat-on game board in layered paper-cut midnight theatre; navy/purple curtains, gold edge stars; narrow three-light HUD, large open wall, small black rectangular crowned shadow with two cream eyes, mint crescent exit in rectangular goal, lilac lower control desk with one yellow sun lamp; [Vườn trăng: lá/hoa và hazard coral dọc; Xưởng sao: bánh răng, 2 sao mint và gate; Thư viện đêm: sách, quỹ đạo giấy, sao/gate/hazard; Sân khấu thiên hà: nhiều lớp rèm tím, 3 sao/gate/hazard]; no text, extra character, extra mechanism; concept art only, geometry separate." Prompt đầu Vườn trăng đã được tạo lại một lần để giữ HUD, đèn và dải ngăn; file lưu là bản thứ hai.

Chưa có duyệt chủ sản phẩm cho bốn preview. Trước khi thay nền hoặc component trong game, cần duyệt từng key visual theo `docs/DESIGN_SYSTEM.md` rồi tách hậu cảnh khỏi vật thể gameplay. Các preview hiện tại không đủ chính xác để làm background production.
