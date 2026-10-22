# Áp dụng Whimsical Shadow Theatre UI Kit vào M2

Tham chiếu: `design/Whimsical Shadow Theatre UI Kit.png`. Ảnh là chuẩn thị giác; chữ minh họa và các control chưa có trong M2 không tạo ra chức năng gameplay mới.

| Component hiện có | Cách áp dụng |
| --- | --- |
| Nút chính: Bắt đầu, Tiếp tục, Thử lại, Màn tiếp theo | Thẻ giấy vàng cắt góc, hai lớp viền, điểm trang trí ở góc, biểu tượng play/replay, trạng thái nhấn |
| Nút phụ: Màn trước/sau, Xem màn, Đặt lại | Thẻ giấy lilac cùng hình học và viền; trạng thái vô hiệu hóa thành xanh đêm mờ |
| Nút biểu tượng: Tạm dừng, Đặt lại khi chơi | Đĩa tròn lilac hai vòng viền; giữ Tooltip và semantics |
| Popup tạm dừng/thắng/thua | Khung xanh đêm ba lớp viền vàng, họa tiết cuộn, rèm góc và sao treo; chữ tiêu đề vàng kem |
| Bảng xem trước | Cùng khung viền và họa tiết của popup ở dạng gọn, vẫn nằm trong khu điều khiển |
| HUD và gợi ý | Biển tên màn xanh đêm với nét cuộn vàng; gợi ý dạng bảng thoại giấy kem có đuôi |
| Bệ Bóng Mơ và bàn đèn | Giữ bố cục đã kiểm tra M2, dùng cùng màu vàng, lilac, xanh đêm và viền nhiều lớp; chân nhân vật lượn khi đứng yên và vẫy/nghiêng theo hướng di chuyển |
| Chữ trên bảng, nút và popup | Dùng Nunito từ Google Fonts, cùng kiểu chữ tròn đậm trong UI Kit; font được đóng gói cục bộ để tránh phụ thuộc mạng lúc chơi |

Các ô nhập, công tắc âm thanh/chuyển động, thanh âm lượng, số lượt, trạng thái tải và popup hết lượt trong UI Kit **chưa có chức năng tương ứng ở M2**. Khi triển khai các chức năng đó ở giai đoạn phù hợp, dùng lại chính bộ component này. Không diễn giải ảnh minh họa thành luật lượt hoặc phần thưởng.

Đã xem bản web ở viewport 390 × 844, 360 × 800 và 1366 × 768; kiểm tra preview màn 1/2, đang chơi và tạm dừng. Đây là trình duyệt giả lập kích thước, chưa phải điện thoại thật. Kiểm thử tự động và build được ghi trong báo cáo thực hiện.

Font: `assets/fonts/Nunito.ttf` lấy từ kho `google/fonts` chính thức; giấy phép SIL Open Font License nằm tại `assets/fonts/OFL.txt`.
