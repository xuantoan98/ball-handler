# Tiến độ và task board

Ngày cập nhật: 21/10/2026. Trạng thái: TODO, DOING, BLOCKED, READY FOR REVIEW, DONE.

Trạng thái nghiệm thu M1: **READY FOR REVIEW**. Mã, test mô phỏng và kiểm tra browser đã qua; yêu cầu xác nhận điều khiển ổn định bằng một ngón trên thiết bị thật còn NOT VERIFIED.

Trạng thái M2: **READY FOR REVIEW**. Ba màn và replay lời giải đã qua test; browser desktop đã chơi thắng màn 1. Playtest 3–5 người mới và cảm ứng thiết bị thật chưa thực hiện.

Đánh giá UI/UX theo phản hồi mới: đã thêm ba nền giấy cắt, thu nhỏ đèn, dời reset, mở rộng phạm vi chiếu tới bốn biên và chuyển preview xuống dưới. Bằng chứng/khoảng trống ở `docs/UI_REVIEW.md`; chưa coi phê duyệt mỹ thuật hoặc cảm ứng thật là hoàn tất.

| ID | Task | Trạng thái | Bằng chứng / việc còn lại |
| --- | --- | --- | --- |
| M0-01 | Kiểm tra repo và giữ nguồn thiết kế/kế hoạch | DONE | Giữ plan/, ảnh trong design/, design system và tài liệu audit có sẵn. |
| M0-02 | Chuyển skeleton sang Flutter | DONE | Tạo project Flutter 3.47.7 cho Android/web; gỡ toolchain Vite/Phaser. |
| M0-03 | Mock tĩnh màn 01 theo ảnh thiết kế | READY FOR REVIEW | CustomPaint render trong browser; chưa xác minh trên thiết bị Android hoặc viewport 360px. |
| M0-04 | Tài liệu, lệnh và khóa dependency | DONE | PRODUCT/PLAN/DECISIONS/QA/RELEASE, pubspec.lock. |
| M0-05 | Analyze, test, build | DONE cho web | flutter analyze, flutter test, flutter build web qua; xem QA. |
| M0-06 | Build Android | BLOCKED | flutter doctor không tìm thấy Android SDK; chưa có APK/AAB. |
| M1-01 | Hình học bóng Dart thuần và mapping viewport | DONE | Unit test công thức, biên và round-trip desktop/mobile qua. |
| M1-02 | Kéo đèn một pointer, giữ offset và giới hạn | DONE trong giả lập | Widget test chuột desktop và chạm một ngón ở 360 × 800, 390 × 844 qua; cancel, kéo ra ngoài board, resize qua. |
| M1-03 | Xem sandbox trên trình duyệt desktop và mobile viewport | DONE trong browser | Đã kéo bằng chuột ở desktop 1280 × 720 và viewport 360 × 800; render 390 × 844, resize giữ vị trí logic. Không phải cảm ứng điện thoại. |
| M1-04 | Xác minh trên điện thoại thật | TODO | Chưa có thiết bị Android/iPhone được kết nối; không ghi là đã kiểm thử cảm ứng thật. |

M1 là sandbox điều khiển và hình học, chưa có vòng chơi, service lượt, save, quảng cáo hoặc level có thể giải. M1 đạt các kiểm tra mô phỏng một ngón và thử kéo chuột trên browser; chưa thể xác nhận cổng nghiệm thu điều khiển một ngón trên thiết bị thật. Android toolchain cần cài để build APK.

## M2

| ID | Task | Trạng thái | Bằng chứng / việc còn lại |
| --- | --- | --- | --- |
| M2-01 | Rules Dart thuần, swept AABB, thứ tự tiếp xúc | DONE | Test kéo nhanh qua cảm biến, cửa chắn mỏng, công tắc sau chắn, ưu tiên thua qua. |
| M2-02 | Ba level và replay lời giải | DONE | Cả 3 replay bằng `GameAttempt` kết thúc thắng sau giữ cửa 1 giây. |
| M2-03 | Preview/start/play/win/fail/pause/retry/next | DONE trong test | Widget test và unit test qua; browser desktop thắng màn 1. |
| M2-04 | Responsive desktop/mobile viewport | DONE trong browser/giả lập | Widget test 1366 × 768, 360 × 800, 390 × 844; browser đã xem 360 × 800, 390 × 844; resize giữ tọa độ. Chưa là thiết bị thật. |
| M2-05 | Playtest 3–5 người mới, cảm ứng thiết bị thật | TODO | Checklist ở `docs/M2_PLAYTEST.md`; chưa có kết quả người chơi. |

M2 chưa triển khai lượt, save, quảng cáo hoặc nội dung sau màn 3. Android SDK vẫn thiếu; chưa build/test trên Android thật.

Đường giải tham chiếu theo góc trên trái của bóng trên tường 360 × 480: màn 1 `(285, 85)`; màn 2 `(134, 380) → (285, 380) → (285, 85)` để hạ bóng xuống dưới cảm biến trước khi đi ngang; màn 3 `(75, 210) → (285, 85)` để bật sao rồi qua chắn. `controlForShadow` đổi các điểm này thành tọa độ đèn, test replay chạy qua `GameAttempt` thực tế.

## M3 — Lượt, lưu và quảng cáo mô phỏng (22/10/2026)

| ID | Task | Trạng thái | Bằng chứng / việc còn lại |
| --- | --- | --- | --- |
| M3-01 | Lượt 3 tối đa, hồi 30 phút, giao dịch kết quả thua | DONE trong test | `LivesService` + Clock giả: start giữ 3; thua 3→2 đặt mốc, thắng reset 3; 30/60/90 phút, cap 3, giờ lùi, double-click và save fail. Gameplay chỉ mở sau khi lưu phiên. |
| M3-02 | Lưu phiên/tiến độ/settings và reload | DONE trong test/browser | SaveRecord version 2 lưu nguyên khối, migration v1 hoàn lượt cho active attempt; widget test reload trả ván về spawn không trừ tiếp; terminal lưu xong mới cho retry/next. Dữ liệu lỗi không tự reset. |
| M3-03 | Mock ad và reward ID | DONE trong test | Mock 5 giây, cancel/error +0, duplicate ID +1 tổng cộng kể cả reload; UI có nút xem quảng cáo và countdown hồi lượt. Chưa có SDK thật. |
| M3-04 | Chặn ghi đồng thời hai tab web | DONE trong browser | Exclusive Web Lock; tab phụ hiển thị chỉ đọc khi tab đầu đang chơi. Chưa kiểm tra trên mọi trình duyệt mục tiêu. |
| M3-05 | Android/thiết bị thật | NOT VERIFIED | Android SDK và điện thoại thật chưa có bằng chứng; không báo build APK. |

`flutter pub add shared_preferences:^2.5.6 web:^1.1.1` resolve thành công. `flutter analyze` sạch; `flutter test` và `flutter build web` đã qua sau triển khai ban đầu; kết quả chạy cuối và số test ở `docs/QA.md`. Browser localhost ở bản M3 ban đầu xác nhận start 3→2; luật này đã được thay thế sau kiểm thử của chủ sản phẩm. Browser thao tác bằng chuột, không phải thiết bị thật. M3 không mở các milestone sau.

## Điều chỉnh lượt sau kiểm thử của chủ sản phẩm (22/10/2026)

- Chỉ thua đã lưu mới trừ 1; bắt đầu/retry không trừ; thắng reset 3. Save schema v2 chuyển bản v1 đang chơi bằng cách hoàn 1 lượt một lần; nếu ghi migration lỗi, không mở phiên. HUD dùng 3 đèn vàng theo ảnh chuẩn, cân lại nhãn màn, đèn và nút pause.
- `/home/bss-group/snap/flutter/common/flutter/bin/flutter test`: **42/42 pass** (Clock giả, ID giả, duplicate, save fail, migration, widget). `flutter analyze`: **No issues found**. `flutter build web`: **pass**, artifact `build/web`; cảnh báo font CupertinoIcons template còn xuất hiện.
- Browser localhost viewport giả lập **390×844**: đã xem preview và màn đang chơi; 3 đèn, số 3/3, nhãn màn và pause không chồng nhau. Kiểm tra bằng chuột/browser, **chưa kiểm tra thiết bị thật**. Android SDK/artifact vẫn chưa được xác minh.
