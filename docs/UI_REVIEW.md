# Đánh giá và chỉnh UI/UX sau M2

Ngày: 21/10/2026. Tham chiếu: `design/Midnight Shadow Theatre Game Board.png`, `docs/DESIGN_SYSTEM.md` và phản hồi của chủ sản phẩm. Phạm vi là ba màn M2, không mở M3.

| Vấn đề quan sát | Nguyên nhân | Chỉnh sửa | Xác minh |
| --- | --- | --- | --- |
| Sân khấu phẳng, thiếu chất liệu và điểm nhấn của ảnh chuẩn | Hậu cảnh M2 chỉ là vài vòng tròn và sao vector | Tạo ba nền giấy cắt riêng theo chủ đề màn; giữ vùng giữa thoáng, vẽ cửa/cảm biến/sao/chắn/bóng bằng cùng dữ liệu gameplay phía trên | Đã xem browser desktop, viewport 360 × 800 và 390 × 844; cần duyệt mỹ thuật cuối bởi chủ sản phẩm |
| Preview che gần hết sân khấu | Panel lớn nằm giữa vùng chơi | Dời preview xuống khu bàn đèn khi chưa chơi để người chơi nhìn rõ bố cục màn trước khi bắt đầu | Kiểm tra browser và widget; kết quả/pause vẫn có panel giữa sân khấu |
| Đĩa đèn quá lớn | Vòng ngoài 37px trên board 390px, gần chạm nhãn/bờ bàn | Giảm vòng ngoài xuống 26px, giữ vùng bắt đầu kéo 35px bán kính; dời reset lên dải con rối để không chặn góc điều khiển | Widget test chạm một ngón và browser mouse qua |
| Bóng không áp sát mọi biên khi đèn ở góc | Mặt phẳng đèn cũ x100..255, y135..315 chỉ cho bóng x12..322, y63..423 | Giới hạn mới `Lx=99..261`, `Ly=133.5..346.5`; tâm đèn x49..341, y694..782 | Unit + widget test bốn góc: hộp bóng x0..360, y0..480 |
| Đường giải màn 2 bị ảnh hưởng bởi vùng chiếu mới | Vị trí bóng đầu màn cao hơn trước | Bổ sung waypoint hạ bóng xuống dưới cảm biến rồi mới đi ngang | Replay cả ba màn qua cùng `GameAttempt` |
| HUD, viền ảnh và bệ rối chồng nhau ở ảnh phản hồi | Ảnh nền/viền sân khấu bắt đầu từ y58 trong khi HUD kết thúc ở y109; nhãn con rối đè lên thân | Tách HUD y13–105, tường y111–561, bệ y574–650, bàn đèn y655–835; ảnh nền khớp đúng tường gameplay | Đã xem browser 390 × 844 và 360 × 800 ở preview, playing, pause; không còn đường viền cắt chữ |
| Viền, nút và bàn đèn thiếu nhận diện chung | Các bề mặt chỉ dùng màu phẳng, ít lớp viền và điểm sáng | Thêm khung giấy kép, đinh/sao góc, bảng tên rối, nút gradient có viền và bóng, bàn đèn có khung vàng/tím | Đã xem trên browser mobile; `flutter analyze`, 22 tests và `flutter build web` qua |
| Con rối và vật thể thiếu chiều sâu | Rối là hình chữ nhật đơn giản; cửa/cảm biến không đổ bóng | Vẽ silhouette răng cưa, vương miện lệch và mắt sáng; thêm bóng mềm cho rối, cửa trăng, cảm biến, công tắc, cổng | Đã đối chiếu trực quan với ảnh phản hồi; đánh giá thẩm mỹ cuối vẫn cần chủ sản phẩm duyệt |
| Các viền chạm/chồng ở ảnh phản hồi mới, bệ rối có đường ngang lạc lõng | Khung lớn bao trùm HUD và sân khấu; ô gợi ý có đuôi chạm viền sân khấu; bảng xem trước đặt đè lên mép bàn đèn | Bỏ khung lớn và đuôi bảng gợi ý; dùng các vùng riêng có khoảng hở 8–13 px; xóa đường ngang bệ rối; đặt bảng xem trước lọt trong bàn đèn và ẩn phần điều khiển phía dưới khi đang preview | Kiểm tra hình ở 420 × 900; thêm test hình học vùng UI; cần đánh giá mỹ thuật cuối bởi chủ sản phẩm |
| Nhãn “Con rối” và chân nhân vật tĩnh | Tên thiếu cá tính; silhouette là một khối cố định | Đổi nhãn thành “Bóng Mơ”; tách bốn chân cong khỏi thân, cho lượn và nhấp nhô khi đứng yên, đổi nhịp/nghiêng ngược hướng khi bóng di chuyển rồi giảm dần về nhịp nghỉ | Unit test công thức chuyển động; cần xem trực tiếp trong browser và trên điện thoại thật |
| Cửa trăng còn là ô bo góc đơn điệu | Khung chữ nhật và hai hình tròn chưa gợi được cửa sân khấu hay trạng thái của đích | Vẽ vòm vàng hai lớp, lòng xanh sâu, trăng lưỡi liềm phát sáng, sao treo, lá chân cửa; trạng thái khóa giảm sáng và có ổ khóa; thanh giữ bóng nằm trong chân cửa. Vùng đích và luật chơi giữ nguyên | `flutter analyze`, 27 tests và `flutter build web` qua; xem trực tiếp màn 1 mở và màn 3 khóa ở viewport trình duyệt giả lập 390 × 844. Chưa kiểm tra trên thiết bị thật |

## Còn cần đánh giá

- [ ] Chủ sản phẩm duyệt ba nền và cách đặt preview mới so với ảnh chuẩn.
- [ ] Chủ sản phẩm duyệt tạo hình con rối và hệ khung/nút đã chỉnh từ phản hồi mới nhất.
- [ ] Đo tương phản chữ/nút trên thiết bị mục tiêu, kiểm tra font Nunito có đủ dấu tiếng Việt nếu tích hợp ở M5.
- [ ] Chơi thử một ngón trên điện thoại thật: bốn góc, nhả và kéo lại, kéo nhanh, pause/reset.
- [ ] Đo dung lượng tải và FPS/memory của ba ảnh 1024 × 1536 trên điện thoại thật.
- [ ] Playtest 3–5 người mới theo `docs/M2_PLAYTEST.md`; chưa có kết quả.
