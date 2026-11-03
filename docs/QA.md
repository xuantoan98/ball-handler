# QA và bằng chứng Flutter

## M6 tiếp tục — Redmi profile và Android Chrome (03/11/2026)

Thiết bị thật: Redmi K30 5G `9d9af905`, Android 10/API 29, 1080×2400. Lần này kiểm bản profile native và bản web trong **Chrome Beta trên chính điện thoại**, không gọi viewport desktop là máy thật. Save native gốc 271 byte đã sao lưu trước thử; sau cùng cài lại APK debug, force-stop và khôi phục đúng file, SHA-256 trước/sau `5a177d4f8ff3fcbe015039c468a7684c947f4179d96ea325359e22bdae126ce6`. Không xóa app data, không công bố bản build.

| Hạng mục | Lệnh / kết quả thực tế |
| --- | --- |
| Build và rules | `flutter test --reporter compact` → **84/84 pass**; `flutter analyze` → No issues found; `dart run tool/export_levels.dart` → 20 validated levels; `flutter build web --no-wasm-dry-run` → pass (còn cảnh báo font CupertinoIcons); `flutter build apk --profile --no-pub` → pass. APK profile SHA-256 `7acd19f45e0caa25c038c81b215005e3b5efeec0ecf6e978054587f1290c6719`. |
| Lỗi chặn bản profile | Lần `flutter run --profile` đầu crash ở `MobileAdsInitProvider`: merged manifest có provider nhưng không có `com.google.android.gms.ads.APPLICATION_ID`. `aapt dump xmltree ... app-profile.apk AndroidManifest.xml | rg -q` test ID trả exit 1 trước sửa. Đã thêm **Google sample app ID chỉ vào `src/profile/AndroidManifest.xml`** như debug; build lại, `aapt` thấy ID và app profile mở trên máy. Release vẫn cần app ID thật và kiểm riêng trong M7. |
| Frame time native | Flutter VM timeline (`clearVMTimeline`/`getVMTimeline`, sự kiện `Animator::BeginFrame` và `Rasterizer::DoDraw`) trên APK profile: màn 01 đứng yên 2 giây: UI p99 **5,125 ms** (238 frame), raster p99 **8,952 ms** (238). Màn 20 đứng yên, 8 cửa sổ × 1,8 giây: UI p99 **7,184 ms** (1.699), raster p99 **11,173 ms** (1.575), không có thời gian xử lý UI/raster >16,67 ms trong mẫu; [số liệu](qa/m6/profile-redmi-stage20-2026-11-03.json). Màn 20 khi ADB kéo đèn 2,2 giây: UI p99 **11,450 ms** (237), raster p99 **15,463 ms** (221), cũng 0 mẫu >16,67 ms. Đây là thời gian xử lý từng luồng trong các cửa sổ ngắn, chưa phải phép chứng minh FPS ổn định suốt 20 màn hoặc chơi lâu/nóng máy. |
| 30 chu kỳ native | Trên profile, ADB lặp **30 lần Bắt đầu → Tạm dừng → Bỏ ván về preview** ở màn 01. Sau 5 và 30 chu kỳ, preview vẫn có nút Bắt đầu; process PID 568 không đổi. `dumpsys meminfo` TOTAL PSS trước 260449 KB, sau 5 lần 265640 KB, sau 30 lần 273059 KB (+12610 KB so với đầu); không crash, nhưng phép đo này chưa tách cache khỏi leak dài hạn. |
| Background native | Bắt đầu màn 01, UI báo còn 57 giây; đưa app về Home 5 giây rồi mở lại thấy popup Tạm dừng. Bấm Tiếp tục, UI báo còn 53 giây sau thêm thời gian thao tác; không thấy đồng hồ chạy suốt 5 giây nền. Đây là một lượt quan sát, không phải stress test nhiều loại kill. |
| Android Chrome Beta | `adb reverse tcp:8765 tcp:8765`, host `build/web` qua HTTP cục bộ, mở `http://127.0.0.1:8765/` trong `com.chrome.beta`. Flutter tải asset và hiện [home](qa/m6/m6-android-chrome-home-v2.png), [preview 01](qa/m6/m6-android-chrome-preview-v2.png), [chạm kéo đèn ở màn 01](qa/m6/m6-android-chrome-touch-v2.png). Touch được CDP tiêm vào Chrome **trên thiết bị thật**; bóng và đèn đổi vị trí. Trong cửa sổ 3 giây sau khi gửi touch tới vùng Pause, CDP ghi 0 `Runtime.exceptionThrown`, 0 log mức error và 0 `Network.loadingFailed`. Chưa thắng màn 01 trên Chrome Beta trong phiên này. Web save thử nằm riêng trong browser, không thay save native. |

**Chưa đạt cổng nghiệm thu M6:** chưa có 3–5 người mới tự chơi 01–20, chưa kiểm Safari iPhone (không có thiết bị), và chưa đo frame time khi chơi dài hoặc mọi màn trên profile. [Phiếu playtest 20 màn](M6_PLAYTEST_V2.md) đã chuẩn bị nhưng chưa có dữ liệu; không điền PASS thay người chơi. M5 còn phần chưa nghiệm thu. Không gọi candidate này là production-ready hoặc tự triển khai công khai.

## Thiết kế lại 20 màn v2 (02/11/2026)

| Kiểm tra | Kết quả / giới hạn |
| --- | --- |
| Catalog/schema/luật | PASS tự động: 20 layout có ID giữ nguyên, validator và replay có thời gian qua trong 60 giây. Test riêng kiểm đạo cụ chắn, chớp chạm bóng đứng yên, pause/reset, cửa có thời hạn và export JSON. Replay không chứng minh người mới hiểu hay giải được bằng ngón tay. |
| Art và bố cục | 20 WebP riêng được nạp từ asset bundle, tổng 11.76 MB. Đã xem từng nền qua contact sheet và render từ `GamePainter` bảy màn 01/04/08/10/13/17/20 ở 390×844. Flutter test dùng font thay thế, nên bản render chỉ dùng rà vị trí/độ tương phản vật thể, không phải ảnh app thật. |
| Lệnh xác minh | `dart format lib test`: 40 files, 0 changed; `dart run tool/export_levels.dart`: 20 validated levels; `flutter test`: **84/84 pass**; `flutter analyze`: No issues found; `flutter build web`: pass; `flutter build apk --debug`: pass. APK debug 177 MiB, SHA-256 `e61798339eae84420674476f21221ab16327aa722dd159a7fc6444f3a73fc4ad`. Web build có cảnh báo CupertinoIcons template nhưng vẫn thành công. |
| Android thật bản v2 | **Đã kiểm một phần trên Redmi K30 5G ngày 03/11**: cài APK debug, xem home và sáu preview, kéo đèn bằng ADB touch để thắng màn 08, quan sát cửa màn 13 mở rồi khóa sau hạn. Chi tiết và giới hạn ở mục ngay dưới. |
| Web tương tác bản v2 | **NOT VERIFIED**: `flutter build web` qua, nhưng inventory của công cụ browser không có trình duyệt/tab để mở bản cuối. Ảnh render Flutter test ở trên chỉ là kiểm tra bố cục. |
| Playtest độ khó 20 màn | **NOT VERIFIED**: chưa có người chơi mới thử từng màn; cần đo thời gian giải, số lần chết, nhận biết coral/vật chắn và khoảng hở với ngón tay. |

Bản v2 đã có smoke trên Android thật nhưng chưa có playtest người mới hoặc số liệu frame time Flutter đáng tin cậy để nghiệm thu chất lượng trải nghiệm. Không xuất bản công khai.

### Smoke Android thật bản 20 màn v2 (03/11/2026)

Thiết bị `9d9af905`: Redmi K30 5G, Android 10/API 29, 1080×2400, density 440. `adb devices -l` báo `device`; `adb install -r build/app/outputs/flutter-apk/app-debug.apk` → `Success`; `adb shell am start -n com.example.ball_handler/.MainActivity` mở app. APK debug cuối sau sửa bóng có SHA-256 `dbb3fb7ef9a3e3788f586bcc6c4fbdbda9cea52f850ccab1f97c111ed17c4233`. Trước cài đã sao lưu DataStore gốc 271 byte; cuối phiên force-stop và chép lại, SHA-256 trước/sau cùng `5a177d4f8ff3fcbe015039c468a7684c947f4179d96ea325359e22bdae126ce6`. Không xóa app data.

| Kiểm tra | Kết quả và bằng chứng |
| --- | --- |
| Home và 20 màn có thể duyệt | **PASS smoke**: [home](qa/twenty-stages/home-redmi-v2.png) và preview [01](qa/twenty-stages/preview-01-redmi-v2.png), [04](qa/twenty-stages/preview-04-redmi-v2.png), [08](qa/twenty-stages/preview-08-redmi-v2.png), [13](qa/twenty-stages/preview-13-redmi-v2.png), [17](qa/twenty-stages/preview-17-redmi-v2.png), [20](qa/twenty-stages/preview-20-redmi-v2.png) là ảnh từ máy thật. Art theo chapter, điều khiển và nhân vật đọc được ở các mẫu này; chưa xem riêng toàn bộ 20 màn đang chơi trên máy. |
| Kéo đèn, màn chớp và thắng | **PASS một đường màn 08**: ADB `input swipe` phát sự kiện chạm một ngón qua bàn đèn, tránh màn chớp di chuyển và giữ cửa để thắng; [đang chơi](qa/twenty-stages/playing-08-redmi-v2.png), [thắng](qa/twenty-stages/win-08-redmi-v2.png). Đây là touch được ADB tiêm vào điện thoại thật, chưa chứng minh sự thoải mái của ngón tay người chơi. Pause hiển thị đúng [ảnh](qa/twenty-stages/paused-08-redmi-v2.png); thời gian còn 18.601 giây không đổi giữa hai lần đọc save khi pause. |
| Cửa có thời hạn màn 13 | **PASS một chu kỳ**: ADB swipe chạm sao; UI semantics báo “Cửa trăng đang mở”, và [ảnh](qa/twenty-stages/gate-open-13-redmi-v2.png) có vòng đếm. Sau 12 giây, UI semantics báo “Cửa trăng đang khóa” trong cùng lượt. Không suy từ ảnh nền ra hitbox. |
| Bộ nhớ và khung hình | `adb shell dumpsys meminfo com.example.ball_handler` khi app debug đang chơi: TOTAL PSS 383017 KB, trong đó Graphics 94800 KB. `dumpsys gfxinfo` chỉ ghi 12 Android View frames, 3 janky; mẫu này không đo đầy đủ Flutter raster/UI frames và không đủ để kết luận 60 FPS. Cần profile build + Flutter DevTools trên thiết bị để nghiệm thu hiệu năng. |
| Lệnh kiểm code sau sửa glow bóng | `flutter test` → **84/84 pass**; `flutter analyze` → No issues found; `flutter build web` và `flutter build apk --debug` → pass. Đổi glow hình chữ nhật thành oval blur, còn silhouette vẫn clip trong hitbox. |

ADB đã mất kết nối một lần giữa phép thử màn 13; sau khi cắm lại, `adb devices -l` nhận máy, app được mở lại để kiểm rồi khôi phục save gốc. Ảnh có thông báo/overlay cá nhân đã loại khỏi bộ bằng chứng. Chưa có playtest người mới 01–20, kiểm va chạm chớp bằng ngón tay người hoặc đo frame time bằng profile build.

Review code độc lập phát hiện và đã sửa: cửa đọc `requires` riêng, va chạm khi bóng/chớp cùng đi qua nhau, ảnh nền bị kéo giãn, và phần nhân vật động vượt mép hitbox. Validator chặn gate có thời hạn chỉ tham chiếu một phần chuỗi sao vì đồng hồ của schema v2 bắt đầu ở sao cuối. Ba test mới tương ứng đã chạy đỏ trước sửa và xanh sau sửa; toàn bộ suite cuối 84/84.

## Trang chủ v2, duyệt màn và đồng hồ 60 giây (02/11/2026)

Chủ sản phẩm duyệt [preview v2](superpowers/specs/home-preview-v2.png) theo UI Kit và chốt: trang chủ mỗi lần mở app, hướng dẫn chỉ lần đầu; màn 1–20 duyệt bằng Màn trước/Màn sau nhưng Play khóa nếu chưa qua màn trước; 60 giây mỗi lượt, hết giờ thua; Đặt lại/mở lại app giữ giờ còn lại. Save schema v3 migrate v1/v2; save cũ không hiện lại popup.

| Kiểm tra | Kết quả và giới hạn |
| --- | --- |
| Flutter test/analyze | `dart format lib test` → 37 file, 0 đổi; `flutter analyze` → No issues found; `flutter test` → **69/69 pass**. Test mới bao gồm timeout đúng ngưỡng, tie với cửa, reset/pause/retry, save v2→v3, khóa trực tiếp tại service, home/popup và lỗi lưu popup có thể thử lại, duyệt màn, reload timer, timeout trừ một lượt và nhịp sáng từng giây cuối. |
| Artifact | `flutter build web` → exit 0, `build/web`; cảnh báo CupertinoIcons như trước. `flutter build apk --debug` → exit 0, `build/app/outputs/flutter-apk/app-debug.apk`, SHA-256 `457f597e4d75f10562f03b917553ac2909da89284b7e34fdc77361e78b48d62a`; APK cuối đã `adb install -r` thành công. Không có AAB release hay upload. |
| Redmi K30 5G, Android 10 | `adb install -r ...` → `Performing Streamed Install / Success`; `adb shell am start -n com.example.ball_handler/.MainActivity` mở app. Trang chủ v2 nhìn được trên máy ([ảnh](qa/home-timer/home-redmi.png)); nút “Xem màn” vào preview màn 1 có hint đúng sau sửa notice ([ảnh](qa/home-timer/preview-redmi.png)); vào chơi thấy viền Pause và `57/60s` nằm trong HUD, không đè thẻ gợi ý ([ảnh](qa/home-timer/timer-redmi.png)). APK cuối đã cài đè thành công và chạy lại với save tạm mới. ADB có ngắt kết nối ngắn lúc đầu, lần cài sau thành công. |
| Save tạm mới trên Redmi | Sau khi sao lưu file DataStore gốc, thử trạng thái fresh save trên APK cuối: popup hướng dẫn hiện ở lần mở đầu ([ảnh](qa/home-timer/first-run-redmi.png)); đóng popup, vào “Xem màn”, bấm “Màn sau” tới màn 02 thấy “Qua màn 01 để mở” và Play “Chưa mở” ([ảnh](qa/home-timer/locked-redmi.png)); bấm vùng nút khóa vẫn ở preview ([ảnh](qa/home-timer/locked-tapped-redmi.png)). Trở lại màn 01 và chơi tới hết giờ: kết quả “Hết 60 giây”, lượt giảm 3/3 → 2/3 ([ảnh](qa/home-timer/timeout-redmi.png)). Đây là một lượt quan sát cho mỗi nhánh, không phải playtest nhiều người. |
| Dữ liệu máy sau smoke | Đã force-stop và khôi phục file DataStore gốc từ backup sau thử save tạm; `adb exec-out run-as ... cat ... | sha256sum` → `8294037ec0b849591143e87facb6f98acbea847ccbe36afe5c1d28912676052b`, khớp backup. Không xóa toàn bộ app data; app được để ở trạng thái force-stop sau khi khôi phục. |
| Cần xác minh thêm trên máy | Nhịp sáng viền Pause trong 10 giây cuối **PASS test thời điểm, chưa xác minh hiệu ứng nhìn thấy trên thiết bị**; ảnh gần hết giờ chỉ ghi được nhãn `1/60s`. Chưa đo FPS, tương phản bằng số hoặc playtest người mới. |

Đồng hồ lưu theo lần đổi giây và ngay khi app pause; nếu tiến trình bị kill đột ngột trước khi callback pause/ghi hoàn tất, lần khôi phục có thể cao hơn tối đa gần một giây. `shared_preferences` cũng không hứa ghi bền vững sau mất điện, nên chưa coi đây là cơ chế chống gian lận hay lưu tài sản có giá trị.


## M7 — Android AdMob test spike (02/11/2026)

Thiết bị thật: Redmi K30 5G, Android 10/API 29, USB `9d9af905`. Flutter 3.47.7/Dart 3.13.5; `google_mobile_ads` 9.2.0; Google sample app ID `ca-app-pub-3940256099942544~3347511713` chỉ ở `src/debug/AndroidManifest.xml`, sample rewarded unit `ca-app-pub-3940256099942544/5224354917` chỉ chạy khi `kDebugMode`. Đây là **quảng cáo test SDK thật**, không phải quảng cáo live. APK dùng cho ảnh spike có SHA-256 `e6f26df4bda068e2999ee92ef96d572de7ecde84964c67f2a654c8357b547494`; APK build cuối sau chỉnh nhãn UI có SHA-256 `3b8719d5b67f8f446af31e7098cb40f909dc4d68c322a7d3ef0d0f960d7b349a` tại `build/app/outputs/flutter-apk/app-debug.apk`, đã cài lại và xác nhận process chạy trên máy.

Lệnh và kết quả: `flutter test` → 57 test pass; `flutter analyze` → sạch; `flutter build web` → exit 0; `flutter build apk --debug` → exit 0; `adb install -r build/app/outputs/flutter-apk/app-debug.apk` → Success; `adb shell am start -n com.example.ball_handler/.MainActivity` → app hiển thị trên máy. `aapt dump badging` của APK ghi minSdk 24, target/compile SDK 36, application ID placeholder `com.example.ball_handler`; manifest đã merge có `INTERNET`, `ACCESS_NETWORK_STATE`, `AD_ID`, `ACCESS_ADSERVICES_AD_ID`, `ACCESS_ADSERVICES_ATTRIBUTION`, `ACCESS_ADSERVICES_TOPICS` cùng các quyền kỹ thuật khác. Mọi quyền và dữ liệu SDK phải được đối chiếu Data safety/consent trước bản phát hành.

| Kịch bản | Kết quả và bằng chứng |
| --- | --- |
| Reward sau xem đủ | **PASS trên Redmi cho 1 lượt quan sát:** thua màn 20 làm 3/3 → 2/3; sample ad Google hiển thị; sau nhãn “Đã cấp phần thưởng” và đóng ad, UI hiện 3/3, “Đã nhận +1 lượt”. Ảnh: [trước](qa/m7/before-test-ad.png), [ad test](qa/m7/google-test-ad.png), [sau](qa/m7/earned.png). File save sau restart chứa `lives:3` và 1 `processedRewardIds`. |
| Cancel trước reward | **PASS unit, CHƯA XÁC MINH trên SDK thiết bị:** `RewardedAdSession` dismiss trước earned → cancelled; sample creative trên máy chưa cho đóng trước lúc cấp thưởng; phím Back không đóng ad. Không suy diễn từ test đơn vị sang ad network. |
| Load/show error | **PASS unit; PASS một đường lỗi trên máy:** session fail → error, +0. Bấm xem ad rồi về Home ngay khi tải, sau 9 giây mở lại thấy “Quảng cáo hoặc lưu thưởng bị lỗi; không cộng lượt”, vẫn 2/3 và `processedRewardIds` rỗng ([ảnh](qa/m7/resume-error.png)). Chưa phân biệt được callback load fail hay show fail từ log; lỗi mạng riêng chưa kiểm. |
| Callback earned trùng | **PASS unit/service, CHƯA XÁC MINH callback trùng từ SDK:** session gọi earn hai lần chỉ lưu một lần; `LivesService` chặn reward ID trùng kể cả reload theo `test/services/m3_services_test.dart`. |
| Lifecycle | **PASS hai nhánh trên máy:** force-stop 1 giây sau bấm ad khi đang tải, save vẫn 2/3 và `processedRewardIds` rỗng; Home khi tải rồi resume cũng +0 và hiện lỗi. Reward đã hoàn thành tồn tại qua force-stop/restart. Home/lock/rotate trong lúc ad đang hiện và kill đúng lúc save đang ghi vẫn CHƯA XÁC MINH. |

Dữ liệu save của thiết bị trước spike đã sao lưu; sau spike đã khôi phục, SHA-256 trước/sau cùng `8294037ec0b849591143e87facb6f98acbea847ccbe36afe5c1d28912676052b`. Chưa có AAB release ký, Play test track, Data safety đã duyệt, consent theo khu vực/độ tuổi, ad live hoặc công bố công khai. M7 **chưa đủ điều kiện DONE/phát hành**.

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

## M4 — kiểm tra tự động (30/10/2026)

| Kiểm tra | Trạng thái | Bằng chứng |
| --- | --- | --- |
| Catalog và validator | PASS | `dart run tool/export_levels.dart` in “Exported 20 validated levels”; JSON có 20 màn. Test validator kiểm tra lỗi ID, biên, ref, spawn, thiếu/sai replay. |
| Replay màn 01–20 | PASS tự động | `flutter test`: 49/49 pass; `validateCatalog` replay qua `GameAttempt` và `tick(1)`. |
| Editor dev | PASS widget test | Kéo hazard đổi tọa độ trong JSON export; đổi thứ tự công tắc màn 09 làm replay báo lỗi. Chưa chạy thử editor bằng browser hoặc thiết bị thật. |
| Build phát hành web | PASS | `flutter build web` tạo `build/web`; `rg 'Editor dev|Import JSON|Export JSON' build/web/main.dart.js` không có kết quả. |
| Playtest người thật 01–20 | NOT VERIFIED | Không có người mới chơi thử từng màn. |
| Android build/cảm ứng thật | NOT VERIFIED | Chưa có Android SDK hoặc artifact APK/AAB được xác nhận. |
| Duyệt mỹ thuật chapter | NOT VERIFIED | 04–20 dùng lại ba nền hiện có; bốn key visual draft đã tạo nhưng chưa được chủ sản phẩm duyệt hoặc tích hợp. |

## M6 — QA candidate web trên bản hiện tại (30/10/2026)

Môi trường: Ubuntu 24.04, Flutter 3.47.7, Dart 3.13.5, Chrome headless trên máy phát triển. `flutter devices` chỉ liệt kê Linux và Chrome; `flutter doctor -v` báo thiếu Android SDK và Linux toolchain. Không có điện thoại Android, iPhone hay giả lập Android được kết nối. Ảnh dưới `docs/qa/m6/` là screenshot Chrome headless ở kích thước viewport chỉ định, không phải ảnh thiết bị thật.

| Ma trận | Kết quả | Bằng chứng / giới hạn |
| --- | --- | --- |
| Desktop 1366 × 768 | PASS render | [Ảnh](qa/m6/m6-desktop.png); không có Runtime/Log/console error trong lần mở. Không đo FPS. |
| Mobile viewport 360 × 800 | PASS render giả lập | [Ảnh](qa/m6/m6-mobile360.png); không phải cảm ứng thật. |
| Mobile viewport 390 × 844 | PASS render + thắng màn 01 bằng chuột | [Ảnh preview](qa/m6/m6-mobile390.png), [ảnh thắng](qa/m6/m6-mobile390-win.png); 3/3 lượt sau thắng; không có console error. |
| Ngang 844 × 390 | PASS sau sửa | [Ảnh](qa/m6/m6-landscape.png): hiện hướng dẫn xoay dọc; widget test xác nhận ván tự pause và còn pause khi xoay lại. |
| Android Chrome thiết bị thật | CHƯA THỰC HIỆN — blocker nghiệm thu | Thiếu thiết bị và Android SDK; chưa có APK/AAB hay đo cảm ứng/FPS trên model cụ thể. |
| Safari iPhone | CHƯA THỰC HIỆN | Không có iPhone hoặc dịch vụ kiểm thử Safari. |

| Kiểm tra chức năng | Kết quả | Bằng chứng / giới hạn |
| --- | --- | --- |
| 20 replay lời giải bằng engine rules | PASS tự động | `dart run tool/export_levels.dart` xuất 20 validated levels; `flutter test` chạy validator cùng `GameAttempt` và giữ cửa. Không chứng minh người mới giải được. |
| Luật lượt, hồi sau 30 phút, reward ID trùng, ad error/cancel, lỗi lưu | PASS tự động | `test/services/m3_services_test.dart` dùng fake clock, ID và write gate; không có SDK ad thật. Race hủy trong lúc lưu thưởng được sửa và test riêng. |
| 30 chu kỳ start/reset/pause/menu | PASS chức năng; bộ nhớ CHƯA ĐO | `test/m6_qa_test.dart`: 30 lần, mỗi lần về preview, active session null, lượt 3/3, đúng 61 lần ghi, không exception. Chưa có profile heap/listener trên thiết bị thật. |
| Refresh ván và mất mạng sau tải | PASS browser hạn chế | [Ảnh sau reload](qa/m6/m6-mobile390-reload.png) cho thấy ván trở lại spawn, 3/3. Bật Chrome Network offline sau reload, kéo đèn vào cửa và thắng màn 01; không có console error. Chưa kiểm tra khởi động offline từ cold cache. |
| Pause, resize, orientation | PASS tự động/browser viewport | Widget test kiểm tra pause khi xoay ngang và khôi phục portrait; Chrome render bốn kích thước. Chưa kiểm tra app nền trên điện thoại. |
| Console error | PASS trong các phiên đã chạy | CDP theo dõi `Runtime.exceptionThrown`, `Log.entryAdded` mức error và `Runtime.consoleAPICalled` mức error; đều rỗng ở bốn viewport và luồng reload/offline. |
| 60 FPS / frame time | CHƯA THỰC HIỆN — blocker nghiệm thu | Không có model thiết bị thật để đo frame time; screenshot headless không thay thế phép đo. |
| Playtest người thật màn 01–20 | CHƯA THỰC HIỆN — blocker nghiệm thu | 20 replay tự động pass; chưa có kết quả người thật chơi từng màn. |

### Bug M6

| ID | Mức | Trạng thái | Kết quả |
| --- | --- | --- | --- |
| M6-01 | Cao | ĐÃ SỬA, PASS tập trung | Viewport ngang điện thoại trước đó ép cả board vào vùng 390px cao, chữ/nút chồng nhau. Nay hiện nhắc xoay dọc và pause ván; test resize + screenshot pass. |
| M6-02 | Cao, sai báo thưởng | ĐÃ SỬA, PASS tập trung | Hủy ad đúng lúc callback lưu reward từng báo “đã hủy” dù lượt được cộng. Nay trạng thái lưu khóa nút hủy và chờ kết quả ghi; test service và widget pass. |
| M6-03 | Blocker phát hành | CHƯA XÁC MINH | Chưa có thiết bị Android thật, đo FPS/frame time, cảm ứng và lifecycle. |
| M6-04 | Blocker nội dung | CHƯA XÁC MINH | Màn 01–20 chưa được người thật chơi thử; replay chỉ chứng minh có một đường giải theo rules. |
| M6-05 | Blocker phạm vi sản phẩm | CHƯA TRIỂN KHAI | M5 vẫn TODO: âm thanh/cài đặt/hướng dẫn/chọn màn và hoàn thiện art chưa được nghiệm thu. Không coi M6 là hoàn thành M5. |

Candidate web chỉ để review. **Không production-ready** khi M6-03/04/05 còn mở. Không triển khai bản riêng tư vì chưa được yêu cầu.

Smoke cuối sau sửa: `flutter analyze` **PASS** (No issues found); `flutter test --reporter compact` **PASS 53/53**; `dart run tool/export_levels.dart` **PASS 20 validated levels**; `flutter build web --no-wasm-dry-run` **PASS**, artifact `build/web`; `git diff --check` **PASS**. Chrome headless CDP mở lại artifact cuối ở bốn viewport, console error rỗng; riêng 390 × 844 thử start → reload → offline → giải thắng màn 01, lượt 3/3. Build còn cảnh báo font CupertinoIcons template. Editor dev không có chuỗi `Editor dev`, `Import JSON`, `Export JSON` trong `build/web/main.dart.js` (`rg` exit 1 là kết quả mong đợi).
