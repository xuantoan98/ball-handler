# QA và bằng chứng Flutter M0–M1

Ngày: 21/10/2026. Máy: Ubuntu 24.04, Flutter 3.47.7 stable, Dart 3.13.5.

| Kiểm tra | Trạng thái | Bằng chứng |
| --- | --- | --- |
| flutter doctor -v | PASS Flutter/web; Android thiếu | Flutter và Chrome được nhận; Android SDK không được tìm thấy. |
| flutter pub get | PASS | Resolve thành công, pubspec.lock hiện có. |
| flutter analyze | PASS | “No issues found”. |
| flutter test | PASS | 1 widget smoke test qua; chỉ xác nhận mock mở và có nhãn “Chưa thể chơi”. |
| flutter build web | PASS | Artifact tại build/web. Build báo dry run Wasm thành công và cảnh báo font CupertinoIcons từ template; chưa cần icon đó cho mock. |
| Browser desktop | PASS cho render mock | Mở lại artifact web cuối trên localhost, kiểm tra cả nửa trên/dưới: lớp vẽ đã nằm trong khung; biểu tượng vector hiển thị, không còn glyph lỗi. Đây chưa phải test gameplay. |
| Build Android | BLOCKED / NOT VERIFIED | Đã chạy flutter build apk --debug, dừng với “[!] No Android SDK found”; chưa có APK/AAB. |
| Viewport mobile/thiết bị thật | NOT VERIFIED | Chưa kiểm tra 360 × 800, 390 × 844 trên thiết bị. |
| Gameplay, FPS, tương phản, font/asset cuối | NOT VERIFIED | M0 chỉ là mock tĩnh. |

Ảnh chuẩn là tham chiếu thị giác do chủ sản phẩm cung cấp. Mock không chứng minh công thức bóng, collision, lượt, quảng cáo hoặc màn có thể giải.

## M1 — Hình học và điều khiển

| Kiểm tra | Trạng thái | Bằng chứng |
| --- | --- | --- |
| Công thức S = 3P − 2L | PASS | Unit test điểm biết trước, chuyển động ngược hệ số 2, hình chữ nhật phóng 3 lần. |
| Biên đèn/bóng | PASS | Unit test các góc cực trị: bóng nằm toàn bộ trong tường 360 × 480; đèn clamp vào vùng bàn. |
| Pointer mapping và resize | PASS trong giả lập | Round-trip tại 1366 × 768, 360 × 800, 390 × 844; widget test resize giữ nguyên tọa độ logic. |
| Một pointer, không nhảy vị trí | PASS trong giả lập | Widget test chuột desktop và touch một ngón tại hai kích thước mobile; giữ offset khi bắt đầu kéo. |
| Pointercancel, kéo ra ngoài board, multi-touch | PASS trong giả lập | Widget test cancel/kéo ngoài board; unit test pointer thứ hai không chiếm quyền. |
| Không cuộn trong vùng điều khiển | PASS theo cấu trúc/test | Màn sandbox không có Scrollable; Listener nhận raw pointer trên toàn viewport. Chưa thử trên trình duyệt điện thoại thật. |
| Browser desktop | PASS với chuột | Build web đã mở trong Codex in-app browser; kéo đèn trái/xuống, bóng dịch phải/lên. |
| Mobile viewport | PASS trong trình duyệt và Flutter widget test giả lập | Browser web đã render ở 360 × 800 và 390 × 844; kéo bằng chuột ở 360 × 800 và resize lên 390 × 844 vẫn giữ vị trí logic. Widget test dùng PointerDeviceKind.touch ở cả hai cỡ. Không phải thiết bị thật. |
| Cảm ứng trên thiết bị thật | NOT VERIFIED | flutter devices chỉ có Linux và Chrome; không có Android SDK/điện thoại kết nối. |

Tọa độ L/S chỉ vẽ khi kDebugMode. M1 chưa có collision, công tắc, cửa chắn, cảm biến, thắng/thua hoặc lượt.

Chạy lại sau thay đổi cuối: `flutter analyze` — No issues found; `flutter test` — 12/12 qua; `flutter build web` — thành công. Build có cảnh báo font CupertinoIcons từ template, không chặn. Bản build cuối được tải lại trong trình duyệt desktop 1280 × 720; kéo đèn bằng chuột từ gần (660, 610) sang (602, 630), đèn đi trái/xuống và bóng đi phải/lên. Tại viewport browser 360 × 800, kéo đèn sang phải cũng làm bóng sang trái; đổi sang 390 × 844 giữ vị trí logic. Browser không phát cảm ứng trong lần kiểm tra này; bài test touch chỉ là mô phỏng Flutter, chưa phải cảm ứng trên điện thoại.

## M2 — Ba màn và vòng chơi

| Kiểm tra | Trạng thái | Bằng chứng |
| --- | --- | --- |
| Replay lời giải 1–3 | PASS tự động | Waypoint trong `lib/core/level.dart` đi qua cùng `GameAttempt` như gameplay; cả 3 thắng sau giữ cửa 1 giây. |
| Kéo nhanh và tiếp xúc theo đường đi | PASS tự động | Kéo chéo màn 2 thua dù đích cuối an toàn; gate mỏng chặn trước switch phía sau; thua ưu tiên hơn đích. |
| Gate/công tắc | PASS tự động | Màn 3 không thể qua gate đóng, chạm sao mở gate rồi mới vào đích. |
| Thắng/thua/pause/reset/resize | PASS tự động | Unit và widget test kiểm tra đồng hồ cửa, rời đích reset, retry, chuyển màn, resize. |
| Browser desktop | PASS hạn chế | Bản web M2 đã mở tại localhost, kéo bằng chuột từ màn 1 vào cửa; thấy panel thắng sau 1 giây. Không có log mức error trong tab sau lần chơi thử; chưa đo FPS. |
| Viewport mobile 360 × 800, 390 × 844 | PASS browser viewport + giả lập widget | Đã xem bản web cuối ở cả hai cỡ, màn 2/3 có cảm biến, sao, chắn và cửa đọc được; widget test kéo một pointer `PointerDeviceKind.touch` không nhảy, không có Scrollable. Browser vẫn dùng chuột, chưa là cảm ứng thật. |
| Người thật chơi thử | NOT VERIFIED | Chưa có 3–5 người thử; dùng checklist `docs/M2_PLAYTEST.md`. |
| Android build, điện thoại thật | NOT VERIFIED | Android SDK chưa có; không có thiết bị thử được kết nối. |

Lần chạy M2 ban đầu: `flutter analyze` sạch; `flutter test` 21/21 qua; `flutter build web` thành công. Lượt, lưu game và quảng cáo chưa thuộc M2. Build web có cảnh báo font CupertinoIcons template nhưng thành công.

## Rà UI/UX theo phản hồi sau M2

| Kiểm tra | Trạng thái | Bằng chứng |
| --- | --- | --- |
| Bốn góc điều khiển/bốn biên tường | PASS tự động | Geometry + widget touch test kéo từng góc: bóng chạm trái/phải/trên/dưới đúng biên; 3 replay lời giải được kiểm lại sau đổi mapping. |
| Kích thước đèn và vùng kéo | PASS cấu trúc | Đĩa vẽ bán kính 26 thay 37; bắt đầu kéo trong bán kính 35; reset được dời lên dải con rối. |
| Nền và tương phản vật thể | PASS kiểm tra thị giác sơ bộ | Browser desktop và viewport 360 × 800 đã xem ba nền; bóng, cảm biến coral, sao mint và cửa chắn còn phân biệt được. Chưa đo tương phản bằng công cụ/thiết bị thật. |
| Mức độ giống ảnh chuẩn | READY FOR REVIEW | Xem `docs/UI_REVIEW.md` và `docs/ASSETS.md`; cần chủ sản phẩm duyệt. |

Sau khi dời preview xuống bàn và sửa tràn bố cục: `flutter analyze` sạch; `flutter test` **22/22 qua** ở 1366 × 768, 360 × 800, 390 × 844 và các test logic; `flutter build web` thành công. Đã mở lại bản build trong browser desktop và viewport 360 × 800, 390 × 844. Preview cho thấy toàn sân khấu; nhãn dưới bàn không còn cắt vào oval; không có log mức error trong tab. Đây là kiểm tra browser bằng chuột và viewport giả lập, chưa là kiểm thử cảm ứng/hiệu năng điện thoại thật.

## M3 — Lượt, lưu, mock ad (22/10/2026)

| Kiểm tra | Trạng thái | Bằng chứng |
| --- | --- | --- |
| Cài mới 3, start không trừ, double-click | PASS tự động/browser | Clock giả và write gate chứng minh chỉ một start ghi; UI chờ save. Browser vẫn 3/3 sau click ở bản điều chỉnh. |
| Hồi lượt 30/60/90 phút, cap 3, giờ lùi | PASS tự động | FakeClock dịch thời gian tức thì; không chờ 30 phút thật. |
| Reload đang chơi | PASS tự động/browser | Widget test và browser kéo đèn rồi reload: đèn/bóng về spawn, vẫn 3/3; không trừ. |
| Terminal, retry/next, pause | PASS tự động | Kết thúc lưu activeAttempt=null; thua trừ 1 sau lưu, thắng reset 3; next/retry/pause/resume không trừ. |
| Reward ID trùng, cancel/error, lỗi lưu thưởng | PASS tự động | Fake ID và fake ad callback lặp; ID xử một lần kể cả reload. Cancel/error và write fail +0. Widget test đóng mock trước 5 giây +0. |
| Dữ liệu hỏng và lỗi lưu start | PASS tự động | Save hỏng chặn khởi động; thao tác reset cần xác nhận. Ghi start thất bại để preview và 3 lượt, không mở điều khiển. |
| Hết 0 lượt | PASS widget | Nút bắt đầu vô hiệu hóa; countdown và nút xem quảng cáo vẫn hiện. |
| Hai tab web | PASS trong browser dùng chuột | Tab đầu giữ Web Lock; tab thứ hai thấy “Tab chỉ đọc”, không có nút ghi. Chưa xác minh Safari/Firefox hoặc thiết bị thật. |
| SDK quảng cáo thật, backend chống gian lận | NOT IMPLEMENTED | Ngoài M3; mock 5 giây và local save chỉ phục vụ bản thử nghiệm. |
| Build Android/thiết bị thật | NOT VERIFIED | Chưa có Android SDK/artifact hoặc cảm ứng thiết bị. |
| Migration save v1→v2 | PASS tự động, giới hạn dữ liệu cũ | Ván v1 đang chơi được hoàn 1 lượt khi migration ghi thành công, không hoàn lặp sau reload; lỗi ghi chặn mở phiên. Bản v1 đã kết thúc không đủ dữ liệu để suy ra lượt nào bị trừ bởi start nên không tự hoàn. |

Lệnh cuối sau điều chỉnh: `flutter analyze` — **No issues found**; `flutter test` — **42/42 pass**; `flutter build web` — **pass**, artifact `build/web`. Build vẫn có cảnh báo font CupertinoIcons template; không chặn. `shared_preferences` không bảo đảm dữ liệu quan trọng đã bền trên đĩa sau Future thành công, nên kết quả M3 chỉ là demo local, không tuyên bố dùng được cho thưởng có giá trị.
