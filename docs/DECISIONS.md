# Quyết định M0

Ngày: 21/10/2026. Chỉ đạo mới nhất của chủ sản phẩm thay giả định web-first trong kế hoạch gốc.

| ID | Quyết định | Lý do / giới hạn |
| --- | --- | --- |
| D01 | **Flutter + Dart** là codebase sản phẩm | Chủ sản phẩm chọn Flutter. Vite, Phaser và TypeScript của bản M0 trước đã được gỡ khỏi repo. |
| D02 | Tạo target Android và web từ cùng project Flutter | Android là đích ứng dụng dự kiến; web là bản xem và build khả dụng ở M0. Chưa quyết định phân phối Google Play. |
| D03 | Dùng Flutter 3.47.7 stable, Dart 3.13.5 | Phiên bản SDK cài sẵn đã được xác nhận; package được khóa trong pubspec.lock. |
| D04 | Mock M0 là CustomPaint tĩnh trong khung 390 × 844 | Giữ bố cục sân khấu của ảnh thiết kế mà chưa triển khai input, collision hay luật chơi. Màu được gom tại lib/design_tokens.dart. |
| D05 | Ảnh design/Midnight Shadow Theatre Game Board.png và docs/DESIGN_SYSTEM.md là chuẩn nhận diện xuyên suốt | Ba màn trong ảnh là tham chiếu giao diện, không phải dữ liệu gameplay hay sprite sheet. |
| D06 | Mô hình bóng S = 3P − 2L, 3 lượt và hồi 30 phút vẫn là quy tắc v1 | Đây là quyết định sản phẩm từ kế hoạch; chưa triển khai ở M0. |
| D07 | com.example.ball_handler và icon template chỉ là placeholder kỹ thuật | Chưa chốt application ID, ký app, icon phát hành hoặc store listing. |

## API được xác minh với tài liệu chính thức

- [Flutter tạo project](https://docs.flutter.dev/reference/create-new-app): Flutter CLI dựng skeleton Android và web.
- [CustomPainter](https://api.flutter.dev/flutter/rendering/CustomPainter-class.html) định nghĩa paint và shouldRepaint; [Canvas](https://api.flutter.dev/flutter/dart-ui/Canvas-class.html) hỗ trợ scale, clipRect và các hàm vẽ; [AspectRatio](https://api.flutter.dev/flutter/widgets/AspectRatio-class.html) giữ tỉ lệ board.
- [Flutter web build](https://docs.flutter.dev/deployment/web): flutter build web tạo artifact tại build/web. [Thiết lập Android](https://docs.flutter.dev/platform-integration/android/setup) yêu cầu Android SDK; flutter doctor hiện báo thiếu SDK.

API mock đã được kiểm tra thêm bằng analyze, test, build web và render trong browser. Chưa xác minh build Android, cảm ứng trên thiết bị thật, FPS, font Nunito/texture cuối hoặc đường giải.

## Quyết định M1

| ID | Quyết định | Lý do / giới hạn |
| --- | --- | --- |
| D08 | Tách `Point2`, `Rect2`, phép chiếu và mapping vào `lib/core/geometry.dart` | Hàm Dart thuần, không phụ thuộc Flutter renderer; cùng kết quả dùng cho hình vẽ và kiểm thử. |
| D09 | Board logic 390 × 844 fit đều vào viewport, có letterbox; tường logic 360 × 480 | Không lấy CSS pixel làm tọa độ. Resize giữ nguyên vị trí đèn logic. |
| D10 | Bàn đèn M1 giới hạn tâm trong x=55..335, y=705..790; mặt phẳng đèn x=100..255, y=135..315 | Cấu hình sandbox lịch sử, đã được thay bằng D19 sau phản hồi về bốn góc. |
| D11 | Chỉ pointer đầu bắt đúng tay cầm được kéo; giữ offset và pointer ID đến up/cancel | Ngăn nhảy đèn, hai ngón điều khiển lẫn nhau và mất giới hạn khi kéo ra ngoài board. Không có ScrollView trên màn chơi. |

[Listener](https://api.flutter.dev/flutter/widgets/Listener-class.html) hỗ trợ down/move/up/cancel và [PointerEvent.localPosition](https://api.flutter.dev/flutter/gestures/PointerEvent/localPosition.html) là tọa độ local của widget; [LayoutBuilder](https://api.flutter.dev/flutter/widgets/LayoutBuilder-class.html) cung cấp kích thước viewport. M1 đã đối chiếu các API này với tài liệu Flutter chính thức.

## Quyết định M2

| ID | Quyết định | Lý do / giới hạn |
| --- | --- | --- |
| D12 | `GameAttempt` và `Level` là Dart thuần; painter chỉ vẽ bounds từ rules | Replay lời giải, va chạm và UI dùng cùng hình học; không phụ thuộc Flutter để kiểm thử logic. |
| D13 | Dùng swept AABB cho từng đoạn kéo và xử lý tiếp xúc theo thời gian | Kéo nhanh không vượt cảm biến/cửa chắn mỏng; công tắc sau cửa đóng không thể bật xuyên qua. |
| D14 | M2 có 3 màn: học hướng, vòng cảm biến, bật sao rồi qua cửa chắn | Chỉ thêm cơ chế nằm trong kế hoạch. Chưa có lượt, lưu game, quảng cáo. |
| D15 | Preview/start/play/win/fail/pause/retry/next trong một màn Flutter | M2 là vòng chơi thử nghiệm. Retry và next không trừ lượt; M3 mới thêm service lượt. |
| D16 | Đích yêu cầu toàn bộ hộp bóng nằm trong cửa liên tục 1 giây; rời cửa reset đồng hồ | Cảm biến được xử lý trước khi xét thắng; pause và app mất focus dừng đồng hồ. |

API hiện hành đã đối chiếu: [Ticker](https://api.flutter.dev/flutter/scheduler/Ticker-class.html) có start/stop và callback từng frame; [WidgetsBindingObserver.didChangeAppLifecycleState](https://api.flutter.dev/flutter/widgets/WidgetsBindingObserver/didChangeAppLifecycleState.html) báo app nền/foreground; [Listener](https://api.flutter.dev/flutter/widgets/Listener-class.html) nhận down/move/up/cancel. Build và widget test xác minh phần dùng API này trong code hiện tại.

## Đánh giá lại UI/UX sau M2

| ID | Quyết định | Lý do / giới hạn |
| --- | --- | --- |
| D17 | Ba nền sân khấu giấy cắt riêng được đóng gói trong Flutter assets | Gần nhận diện ảnh chuẩn hơn; nền chỉ là trang trí, gameplay bounds vẫn độc lập. Nguồn/prompt ở `docs/ASSETS.md`. |
| D18 | Thu nhỏ đĩa đèn 37 → 26 đơn vị, vùng chạm 44 → 35 bán kính và dời reset khỏi bàn kéo | Tay cầm bớt che bàn nhưng vẫn có vùng chạm đường kính 70 đơn vị; bốn góc không bị nút reset phủ. |
| D19 | Mặt phẳng đèn x99..261, y133.5..346.5; tâm điều khiển x49..341, y694..782 | Bóng hình chữ nhật 36 × 54 chạm được chính xác bốn cạnh của tường 360 × 480. |
| D20 | Preview chuyển xuống bàn điều khiển, sân khấu hiển thị nguyên vẹn trước khi bắt đầu | Giúp đọc bố cục và các vật thể trước khi chơi; pause/kết quả vẫn dùng panel riêng. |

Xem `docs/UI_REVIEW.md` để biết các điểm đã đối chiếu và phần chưa được người thật hoặc thiết bị thật xác minh.

Việc nạp PNG asset đã đối chiếu API Flutter chính thức: [instantiateImageCodec](https://api.flutter.dev/flutter/dart-ui/instantiateImageCodec.html) giải mã PNG, [Canvas.drawImageRect](https://api.flutter.dev/flutter/dart-ui/Canvas-class.html) vẽ ảnh vào vùng sân khấu và [`ui.Image.dispose`](https://api.flutter.dev/flutter/dart-ui/Image-class.html) giải phóng handle khi đổi màn/đóng widget. Test/build web và xem browser xác nhận đường tải hiện tại.

## Quyết định M3

| ID | Quyết định | Lý do / giới hạn |
| --- | --- | --- |
| D21 | Một `SaveRecord` version 1 lưu nguyên khối qua `SaveService`; `LivesService` sở hữu mọi thay đổi lượt, phiên, thưởng và tiến độ | UI chỉ mở gameplay sau khi `startAttempt` ghi xong. Lỗi đọc/ghi hiện thông báo; dữ liệu lỗi chỉ được đặt lại bằng thao tác xác nhận của người chơi. M2 chưa có bản ghi nên không có dữ liệu cũ để migrate; version không hỗ trợ sẽ bị chặn thay vì xóa ngầm. |
| D22 | `GameClock` được inject, lấy mốc hồi 30 phút từ lần 3→2 và giữ mốc khi tiêu/thưởng lúc chưa đầy | Test nhảy thời gian 30/60/90 phút và chỉnh giờ lùi mà không chờ thật. Đồng hồ thiết bị không chống gian lận. |
| D23 | Reward ID được lưu cùng bản ghi; chỉ tín hiệu earned sau 5 giây của mock mới gọi cộng lượt | Callback trùng cùng ID được chặn trong phiên và sau reload; cancel/error/mất focus +0. Không có SDK quảng cáo production. |

### Điều chỉnh luật sau kiểm thử của chủ sản phẩm (22/10/2026)

| ID | Quyết định | Hệ quả |
|---|---|---|
| D26 | Mỗi màn tối đa 3 lượt; bắt đầu không trừ; chỉ thua trừ 1 sau khi lưu; thắng reset 3 | Thay thế D06 và luật tiêu lượt lúc start trong D21/D22 và kế hoạch gốc. Save schema v2 hoàn 1 lượt cho v1 active attempt đã bị tính phí, chỉ một lần khi migration lưu thành công. |
| D24 | Web giữ exclusive Web Lock suốt vòng đời tab; tab thứ hai đọc nhưng không ghi | Dùng `ifAvailable` để chuyển tab thứ hai sang chỉ đọc ngay. Nếu Web Locks không khả dụng, fail closed thành chỉ đọc; không dùng localStorage lease dễ race. Android chạy một app instance. |
| D25 | `SharedPreferencesAsync` cho Android/web ở bản thử nghiệm | API đọc mới không dùng cache cục bộ, nhưng [package chính thức](https://pub.dev/packages/shared_preferences) cảnh báo không bảo đảm ghi bền vững cho dữ liệu quan trọng. Trước sản phẩm có giá trị/đồng bộ nhiều máy cần backend xác minh thời gian và thưởng. |

API M3 đã đối chiếu tài liệu hiện hành: [SharedPreferencesAsync](https://pub.dev/documentation/shared_preferences/latest/shared_preferences/SharedPreferencesAsync-class.html), [Web Locks API](https://developer.mozilla.org/en-US/docs/Web/API/Web_Locks_API), [`LockManager.request`](https://developer.mozilla.org/en-US/docs/Web/API/LockManager/request) và [`package:web`](https://pub.dev/packages/web). Bản web đã xác minh hai tab cùng origin: tab đầu ghi, tab thứ hai chỉ đọc.
