# Little Shadow Theatre

Game giải đố 2D về ánh sáng và bóng, xây dựng bằng **Flutter + Dart** cho Android và web từ cùng một codebase. Người chơi kéo đèn để di chuyển Bóng Mơ trên tường theo hướng ngược lại, bật các công tắc theo thứ tự và đưa bóng vào cửa trăng. Trò chơi có 20 màn thiết kế thủ công, mỗi lượt chơi tối đa 60 giây.

> “Rạp bóng nhỏ” là tên tiếng Việt và hướng mỹ thuật của game. Tên hiển thị của ứng dụng là **Little Shadow Theatre**.

## Chạy dự án

Yêu cầu Flutter SDK và Dart tương thích với [`pubspec.yaml`](pubspec.yaml). Dự án đã được kiểm tra với Flutter 3.47.7 và Dart 3.13.5. Để chạy hoặc build Android, cần cài Android SDK; để chạy bản web, cần trình duyệt được Flutter hỗ trợ.

```bash
flutter pub get
flutter devices
flutter run -d chrome          # Bản web để xem thử
flutter run -d DEVICE_ID       # Thay DEVICE_ID bằng ID Android từ flutter devices
```

Chạy kiểm tra và tạo artifact:

```bash
flutter analyze
flutter test
flutter build web
flutter build apk --debug
```

Web build nằm ở `build/web/`; APK debug nằm ở `build/app/outputs/flutter-apk/app-debug.apk`. Các thư mục build được Git bỏ qua. Xem [`docs/QA.md`](docs/QA.md) để biết kết quả và giới hạn kiểm thử thực tế.

## Cách chơi và tiến độ

- Kéo đèn để điều khiển bóng; bóng di chuyển ngược hướng đèn. Tránh cảm biến đỏ và chướng ngại vật di chuyển.
- Bật sao đúng thứ tự để mở cửa chắn; giữ toàn bộ bóng trong cửa trăng liên tục một giây để qua màn.
- Bắt đầu màn không trừ lượt; thua mới trừ một lượt. Tối đa ba lượt, hồi một lượt mỗi 30 phút. Tiến độ màn, ván đang chơi, thời gian còn lại, âm thanh và ngôn ngữ được lưu trên thiết bị.
- Có thể xem trước 20 màn, nhưng chỉ chơi màn đã mở khóa. Cài đặt cho phép chuyển Tiếng Việt/English trong toàn bộ game.

Luật chính xác và các trường hợp biên nằm trong [`docs/PRODUCT.md`](docs/PRODUCT.md).

## Cấu trúc chính

| Đường dẫn | Nội dung |
| --- | --- |
| `lib/core/` | Hình học, luật chơi, dữ liệu và kiểm tra màn |
| `lib/game/` | Màn hình, điều khiển, lớp vẽ và thành phần UI |
| `lib/services/` | Save, lượt, âm thanh và adapter quảng cáo |
| `test/` | Unit test và widget test |
| `assets/`, `design/` | Tài nguyên game và ảnh thiết kế chuẩn |
| `tool/` | Công cụ tạo icon, export màn/graphic và mô phỏng QA |
| `docs/` | Đặc tả, quyết định, tiến độ, thiết kế và bằng chứng QA |

## Trạng thái phát hành

Android qua Google Play là nền tảng phát hành được chọn; web hiện dùng để xem thử. Tích hợp quảng cáo Android mới ở mức **spike debug với Google sample ID**. Bản release chưa có AdMob ID của sản phẩm, application ID chính thức, khóa ký và các bước nghiệm thu phát hành; chưa có quảng cáo live hoặc bản phát hành công khai. Xem [`docs/M7_READINESS.md`](docs/M7_READINESS.md) và [`docs/SECURITY_REVIEW.md`](docs/SECURITY_REVIEW.md) trước khi chuẩn bị release.

## Tài liệu

- [`docs/PLAN.md`](docs/PLAN.md): lộ trình và trạng thái milestone.
- [`docs/DECISIONS.md`](docs/DECISIONS.md): các quyết định sản phẩm và kỹ thuật.
- [`docs/DESIGN_SYSTEM.md`](docs/DESIGN_SYSTEM.md): hệ thống hình ảnh “Rạp bóng nhỏ”.
- [`docs/PROGRESS.md`](docs/PROGRESS.md): công việc đã thực hiện và kết quả lệnh.
- [`plan/SHADOW_CONTROLLER_PLAN.md`](plan/SHADOW_CONTROLLER_PLAN.md): kế hoạch gốc; các giả định web-first trong đó đã được thay bằng quyết định Flutter.
