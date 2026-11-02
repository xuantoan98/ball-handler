# Người điều khiển bóng — Đặc tả sản phẩm v1

Trạng thái: đặc tả v1; M3 đã triển khai lượt, lưu game và quảng cáo mô phỏng cho ba màn, chưa có SDK quảng cáo thật. Nguồn chi tiết: [kế hoạch gốc](../plan/SHADOW_CONTROLLER_PLAN.md). Chuẩn mỹ thuật xuyên suốt: [Rạp bóng nhỏ](DESIGN_SYSTEM.md) và [ảnh thiết kế](../design/Midnight%20Shadow%20Theatre%20Game%20Board.png).

## Nền tảng và vòng chơi

Flutter là nền tảng triển khai, ưu tiên trải nghiệm điện thoại màn dọc; target web dùng để xem thử và build cùng codebase. Game giải đố 2D, một người chơi: kéo một nguồn sáng để di chuyển bóng ngược chiều trên tường, bật công tắc đúng thứ tự, mở cửa chắn, đưa toàn bộ bóng vào cửa thoát liên tục 1 giây. Bóng chạm cảm biến đỏ trong khi chơi thì thua; nếu chạm đích và cảm biến đồng thời, thua được xử trước. **Mỗi lượt có tối đa 60 giây; hết giờ tính thua.** Ở cùng tick, hết giờ được xử trước khi hoàn tất giữ cửa.

Mô hình logic có ba mặt phẳng: đèn `L` tại `z=0`, vật tạo bóng `P` tại `z=1`, tường tại `z=3`. Mỗi điểm bóng `S = 3P - 2L`, cho cả x và y. Vật ban đầu là hình chữ nhật; vùng va chạm phải nhìn thấy và khớp hình vẽ. Tọa độ logic tách khỏi CSS pixel, vùng tường tham chiếu `360 × 480`; màn hình scale và letterbox. Mọi chuyển động nhanh phải kiểm tra cả đường đi để không xuyên vật cản hoặc bật công tắc sau cửa đóng.

## Phiên chơi và lượt

- Xem preview và bắt đầu không mất lượt. “Bắt đầu” kiểm tra còn lượt và lưu phiên trước khi mở điều khiển.
- Trang chủ mở ở mỗi lần khởi động app; popup “Cách chơi” chỉ hiện ở save mới lần đầu. “Chơi ngay” mở màn cao nhất đã mở hoặc tiếp tục ván được khôi phục. Duyệt 1–20 bằng “Màn trước”/“Màn sau”; Play vô hiệu ở màn chưa qua màn trước. Save cũ không bị ép xem lại popup.
- Công tắc đúng thứ tự giữ trạng thái trong lần thử; chạm công tắc sai thứ tự chỉ nhận phản hồi. Cửa chắn đóng chặn bóng và đèn dừng ở vị trí hợp lệ.
- Màn 04–20 lần lượt giới thiệu đạo cụ tối viền đồng (chặn bóng, không gây thua), màn chớp sọc coral di chuyển (chạm là thua kể cả bóng đứng yên), và chuỗi sao mở cửa có thời hạn (hết hạn reset chuỗi, cửa khép sau khi bóng rời hitbox). Các cơ chế chỉ dùng trong màn đã author; trạng thái động dừng khi pause/background. Chi tiết và giới hạn ở [thiết kế 20 màn](superpowers/specs/2026-11-02-twenty-stage-redesign-design.md).
- Thắng hoặc thua khóa điều khiển và hiện kết quả một lần. Chỉ thua mới trừ 1 lượt khi lưu kết quả; thắng reset về 3 lượt cho màn tiếp theo. Retry, next, pause, resume và reset không trừ lượt. Pause hoặc mất focus dừng mô phỏng, bộ đếm cửa và đồng hồ ván.
- Đặt lại trong ván đưa đèn/công tắc/bộ đếm cửa về đầu màn nhưng **giữ thời gian ván còn lại**. Reload khi ván đang chơi khôi phục ở điểm đầu màn, giữ thời gian còn lại, không trừ tiếp. Ván đã kết thúc không được khôi phục như ván đang chơi. Retry sau thua tạo ván mới 60 giây.
- Tối đa 3 lượt. Sau mỗi lần thua, hồi 1 mỗi 30 phút tới tối đa 3. Đây là cấu hình thử nghiệm. Trạng thái lưu có version, giao dịch lượt thuộc một service duy nhất.
- Bản web thử nghiệm chỉ có quảng cáo mô phỏng tự nguyện: hoàn tất mới +1 lượt khi chưa đầy; thưởng theo reward ID chỉ xử một lần. Không có SDK quảng cáo thật ở M0.

## Phạm vi v1 và ngoài phạm vi

Dự kiến 20 màn thủ công, chỉ mở rộng sau khi ba màn đầu chứng minh điều khiển dễ hiểu và thú vị. Có hướng dẫn, chọn màn, tạm dừng, kết quả, hết lượt, cài đặt, ghi nguồn asset và lưu tiến độ/lượt/âm thanh. Không tài khoản, bảng xếp hạng, mua vật phẩm, 3D, vật lý đi bộ, bóng mềm vật lý, nhiều đèn, multiplayer hoặc màn sinh ngẫu nhiên. Google Play và quảng cáo thật là nhánh sau khi gameplay đạt yêu cầu.

Tên “Rạp bóng nhỏ” là tên làm việc theo hướng mỹ thuật đã được chấp nhận; tên thương mại và mức độ khác biệt với game tương tự chưa được khảo sát/chốt.
