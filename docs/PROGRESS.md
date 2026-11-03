# Tiến độ và task board

## M5 — triển khai bàn đèn, âm thanh và hiệu ứng (03/11/2026)

Âm thanh: chủ sản phẩm nghe được nhạc sau sửa audio focus nhưng còn nhỏ; đã tăng volume nhạc lên 1,0, được phản hồi mức âm ổn. Theo yêu cầu tiếp theo, Android hiện bắt đầu nhạc ngay ở home khi save bật âm, web vẫn chờ gesture. Chủ sản phẩm xác nhận nhạc phát ở home. Phản hồi tiếp: bấm loa làm hai nút home nháy vì trạng thái save tạm vô hiệu hóa chúng; test tái hiện đỏ và sửa để nút giữ visual ổn định. Test 96/96, analyze, build web/APK đều qua; đang chờ xem lại trên Redmi. M5 vẫn DOING vì QA hiệu ứng/performance còn mở.

Phản hồi nghe thật: nhạc nền không nghe được dù SFX sao có tiếng. Đã xác minh file nhạc không im lặng, tăng âm lượng nhưng vẫn không nghe; tìm thấy SFX mặc định giành audio focus khiến nhạc bị tạm dừng. APK mới cấu hình SFX không giành focus, build/test qua và track nhạc vẫn active sau tiếng nút trên Redmi; **đang chờ chủ sản phẩm nghe xác nhận**, chưa đánh dấu âm thanh đạt. Xem [QA](QA.md).

Sau khi Redmi được mở khóa, đã xem home/preview 20/chơi 01/pause, kiểm nút loa lưu qua restart, thắng màn 01 và thua do cảm biến ở màn 02 bằng touch ADB. Ảnh thiết bị và kết quả ở [QA](QA.md). Save gốc đã khôi phục nguyên byte, hash khớp, app mở lại ở home 3/3 lượt. Chưa chấm chất lượng âm bằng tai, chưa đo frame time M5 hoặc xác nhận trực quan hạt giấy/rung; M5 tiếp tục **DOING / chờ QA cảm nhận**.

Tiếp tục M5: đã sửa lỗi biên dịch popup hướng dẫn do thiếu `BuildContext` trong `HomeScreen._stage`, và hai cảnh báo analyze trong audio/test. Kiểm tra cuối: `flutter analyze --no-pub` sạch, `flutter test --reporter compact --no-pub` **94/94 pass**, `flutter build web --no-wasm-dry-run --no-pub` và `flutter build apk --debug --no-pub` đều thành công. APK debug mới đã cài trên Redmi, lệnh mở được nhận và process chạy; máy đang khóa nên chưa xác nhận hình UI bản cuối. Chưa đo frame time hoặc kiểm âm thanh/hiệu ứng bằng cảm nhận trên máy. Chi tiết và hash artifact ở [QA](QA.md). Không push/phát hành.

Theo yêu cầu tiếp tục, đã đưa nền bàn v3 trống mặt trời vào `GamePainter`; đèn và hitbox kéo vẫn do Flutter/rules điều khiển. Đã thêm nhạc/hiệu ứng CC0 cục bộ, nút âm thanh trên home/pause lưu qua `LivesService`, điều khiển phát một loop sau tương tác đầu tiên, dừng khi pause/background/ad. Thêm hiệu ứng giấy vàng/lilac khi thắng, viền coral khi bóng chạm nguy hiểm, rung Android một lần sau khi lưu kết quả va chạm, và nhịp vào nhẹ cho tiêu đề/nút/panel; chế độ giảm chuyển động bỏ hạt/rung/dịch chuyển. Không thay level, lượt, save schema, đồng hồ hoặc adapter quảng cáo.

APK debug có artifact thực và đã cài trên Redmi. Ảnh máy xác nhận bàn trong ván và nút loa home; đã bật/tắt nút, rồi trả về bật, save cuối cho thấy `soundEnabled:true`, `activeAttempt:null`, 1/3 lượt. **Chưa nghe thẩm định chất lượng/mức âm bằng tai, chưa xác nhận cue/haptic thắng-thua trên máy, chưa đo frame time sau hiệu ứng, chưa smoke tương tác web vì browser inventory rỗng, chưa có Safari/playtest người mới.** M5 vẫn **DOING / chờ QA cảm nhận**; không phát hành/push. Lệnh và kết quả ở [QA](QA.md).


## M5 — thiết kế bàn đèn, âm thanh, chuyển động v3 (03/11/2026)

Đã đối chiếu ảnh Game Board, UI Kit, ảnh bàn đèn chủ sản phẩm chỉ định và screenshot Redmi đang chơi màn 08. Chủ sản phẩm chọn nhạc nền nhẹ cùng hiệu ứng ngắn, và nền bàn trang trí từ ảnh với đèn Flutter di động; [preview v3](superpowers/specs/m5-control-preview-v3.png) đã được xác nhận đúng hướng. [Thiết kế M5](superpowers/specs/2026-11-03-m5-control-audio-motion-design.md) ghi nguồn CC0, nút âm thanh, chuyển cảnh, confetti và rung có điều kiện; **đang chờ duyệt tài liệu trước khi sửa code/asset production**. Kiểm tra độc lập tài liệu: không còn câu hỏi quan trọng để lập kế hoạch. Chưa tích hợp âm thanh hay hiệu ứng, chưa kiểm trên máy cho bản M5 này.

Lệnh đã chạy: `file docs/superpowers/specs/m5-control-preview-v3.png` → PNG 1859×846; `git diff --check` → không có lỗi khoảng trắng. Đã xem `pubspec.yaml` và `lib/` để xác nhận `soundEnabled` đã lưu nhưng chưa có phát audio/nút điều khiển.

## M6 — mô phỏng sai số đầu vào khi chưa có người thử (03/11/2026)

Đã chạy `dart run tool/m6_simulate_inputs.dart` với 5 cấu hình × 20 màn × 25 seed qua cùng `GameAttempt`: đường chuẩn và lệch ±2 px mốc đèn thắng 500/500; lệch ±5 px thắng 218/500 (6 thua, 276 chưa vào đích); chậm 1,25× với ±2 px thắng 500/500; chậm 1,35× với ±8 px thắng 113/500 (10 thua, 377 chưa vào đích). Phần lớn lượt chưa xong hụt điều kiện **toàn bộ bóng trong cửa** ở mốc cuối. Đây là phép thử độ nhạy với sai số trên đường lời giải có sẵn, **không phải 5 người chơi giả lập** và không thể xác nhận họ hiểu điều khiển hay thấy độ khó hợp lý. Chi tiết giả định và dữ liệu từng màn ở [QA](QA.md). M6 vẫn chờ playtest người mới khi có thể tổ chức; hiện chủ sản phẩm chưa thu xếp được người tham gia.

## M6 tiếp tục trên Redmi và Android Chrome (03/11/2026)

Trên Redmi K30 5G đã đo Flutter VM timeline bằng APK profile ở màn 01/20. Phát hiện profile crash trước khi vào Flutter do thiếu AdMob application ID trong merged manifest; đã thêm Google sample ID **chỉ cho biến thể profile**, build lại và xác nhận app chạy. Màn 20 đứng yên qua 8 mẫu ×1,8 giây có UI p99 7,184 ms, raster p99 11,173 ms; mẫu kéo đèn 2,2 giây có UI p99 11,450 ms, raster p99 15,463 ms. Chưa đủ dữ liệu để khẳng định FPS ổn định khi chơi dài. ADB hoàn tất 30 chu kỳ Bắt đầu/Tạm dừng/Bỏ ván về preview, PID giữ nguyên; PSS tăng 260449→273059 KB. Background 5 giây hiện pause khi trở lại. Chrome Beta trên máy mở bản web, popup/home/preview/play và kéo đèn bằng CDP touch; chưa thắng màn web trong phiên này. Chi tiết lệnh, ảnh và giới hạn ở [QA](QA.md).

Lệnh sau sửa: `flutter test --reporter compact` → **84/84 pass**; `flutter analyze` → No issues found; `dart run tool/export_levels.dart` → 20 validated levels; `flutter build web --no-wasm-dry-run` → pass; `flutter build apk --profile --no-pub` → pass. Đã cài lại APK debug cuối và khôi phục save native gốc; SHA-256 trước/sau cùng `5a177d4f8ff3fcbe015039c468a7684c947f4179d96ea325359e22bdae126ce6`. Không push hay xuất bản.

M6 vẫn **DOING**: cần 3–5 người mới chơi thử 01–20 theo [phiếu](M6_PLAYTEST_V2.md), ghi màn khó hiểu/thời gian/lượt thua thực, rồi sửa các điểm lặp lại và đo lại. Chưa có iPhone/Safari để kiểm. Không đánh dấu M6 hoặc bản phát hành DONE khi thiếu dữ liệu người chơi.

## Thiết kế lại 20 màn v2 (02/11/2026)

Chủ sản phẩm đã duyệt [thiết kế và ba concept](superpowers/specs/2026-11-02-twenty-stage-redesign-design.md). Trong cùng codebase Flutter đã thêm đạo cụ chắn không gây thua, màn chớp nguy hiểm di chuyển, sao/cửa có thời hạn; author lại 20 layout, lời giải có bước thời gian; vẽ lại Bóng Mơ và bàn đèn; thêm 20 hậu cảnh WebP riêng. Level ID 01–20, tiến độ/lượt/60 giây và adapter quảng cáo M7 giữ nguyên. Các ảnh nền chỉ trang trí, không chứa hitbox.

Lệnh cuối: `dart format lib test` → 40 files, 0 changed; `dart run tool/export_levels.dart` → `Exported 20 validated levels`; `flutter test` → **84/84 pass**; `flutter analyze` → **No issues found**; `flutter build web` → `Built build/web`; `flutter build apk --debug` → `Built build/app/outputs/flutter-apk/app-debug.apk`, 177 MiB, SHA-256 `e61798339eae84420674476f21221ab16327aa722dd159a7fc6444f3a73fc4ad`; `git diff --check` → không có lỗi. Đã render thử 7 board đại diện 01/04/08/10/13/17/20 bằng `GamePainter` trong Flutter test với asset đóng gói; đây là kiểm tra bố cục, font test không phản ánh app thật.

**Cập nhật 03/11:** Redmi K30 5G đã kết nối lại và chạy APK debug bản v2. Đã kiểm home, sáu preview đại diện, kéo đèn bằng ADB touch thắng màn 08, mở rồi hết hạn cửa màn 13, pause giữ thời gian, và đo PSS debug. Ảnh/lệnh/giới hạn ở [QA](QA.md). Sau khi ADB ngắt rồi kết nối lại, đã force-stop và khôi phục save gốc; SHA-256 trước/sau cùng `5a177d4f8ff3fcbe015039c468a7684c947f4179d96ea325359e22bdae126ce6`. Chưa có playtest người mới, xác minh va chạm bằng ngón tay người hoặc phép đo frame time Flutter đủ tin cậy. Bản này chưa phát hành và chưa push.

Đã thử mở `build/web` qua browser automation, nhưng inventory trả `browsers: []`; chưa có smoke tương tác bản web v2. Không quy kết `flutter build web` thành kiểm thử UI trên trình duyệt.

## Phản hồi sau thử máy — trang chủ v2, khóa màn, đồng hồ (02/11/2026)

Chủ sản phẩm duyệt [thiết kế v2](superpowers/specs/2026-11-02-home-level-timer-design.md) và quy tắc 60 giây/hết giờ thua/giữ giờ khi Đặt lại hoặc mở app lại. Đã thêm trang chủ art Kit + nút Flutter thật, popup lần đầu, duyệt 1–20 với Play disabled khi chưa mở, vòng thời gian và huy hiệu `còn/60s` quanh Pause, pulse vàng 10 giây cuối. Save schema v3 thêm `introSeen` và `attemptRemainingMs` với migration v1/v2; `LivesService` chặn start màn khóa. Code M7 trong worktree được giữ nguyên. Không push hoặc công bố công khai.

Lệnh cuối: `dart format lib test` → 37 file, 0 đổi; `flutter analyze` → No issues found; `flutter test` → 69/69 pass; `flutter build web` → exit 0; `flutter build apk --debug` → exit 0 (SHA-256 APK `457f597e4d75f10562f03b917553ac2909da89284b7e34fdc77361e78b48d62a`). `adb install -r` APK cuối trên Redmi K30 5G → Success. Ảnh trên máy xác nhận home v2, hint preview, vòng/huy hiệu Pause; thử với save tạm mới xác nhận popup lần đầu, Play màn 02 khóa và không phản ứng khi bấm, hết 60 giây thua và giảm một lượt. Dữ liệu save gốc đã được khôi phục, hash sau cùng trùng backup. Nhịp sáng nhìn thấy trong 10 giây cuối chưa chụp xác nhận. Xem [QA](QA.md) để phân biệt kiểm thử tự động và quan sát trên thiết bị.

## M7 — Google Play được chọn, spike AdMob test Android (02/11/2026)

Chủ sản phẩm chọn lựa chọn 1: Flutter Android trên Google Play (D27). Đã thêm `google_mobile_ads` 9.2.0, adapter Android debug qua `RewardedAdSource`, Google sample app/unit ID và cổng consent UMP trước ad request. Web giữ mock. Android release chưa cấu hình ad live nên nút bị vô hiệu hóa; không dùng sample ID để phát hành. Test callback session kiểm tra cancel/error/duplicate/save. Lệnh cuối: `flutter test` 57 pass, `flutter analyze` sạch, `flutter build web` exit 0, `flutter build apk --debug` exit 0; `adb install -r` Success và process chạy trên Redmi K30 5G. APK debug cuối SHA-256 `3b8719d5b67f8f446af31e7098cb40f909dc4d68c322a7d3ef0d0f960d7b349a`. Ad test Google thực đã hiện trên APK ngay trước chỉnh nhãn UI; một lượt hoàn tất làm 2/3 → 3/3 và lưu qua restart. Kill trong khi tải +0. Chi tiết pass/chưa xác minh và ảnh ở `docs/QA.md`.

Trạng thái: **DOING / chưa đủ điều kiện phát hành**. Device cancel trước reward, lỗi mạng/show tách riêng, callback SDK trùng và một số nhánh lifecycle chưa xác minh. Home khi ad đang tải rồi resume cho error +0 trên máy. Chưa có application ID thương mại, AdMob ID của app, khóa ký, AAB release ký, hồ sơ privacy/Data safety, Play Console test track hoặc ad live. Không upload/xuất bản. Save thiết bị đã khôi phục nguyên trạng sau spike với SHA-256 đối chiếu.

## Kiểm tra lại điều kiện bắt đầu M7 (02/11/2026)

Đã đối chiếu tài liệu chính thức hiện hành của Google Mobile Ads Flutter (setup, rewarded, test ads, UMP), pub.dev `google_mobile_ads` 9.2.0 và Google Play target API. Ma trận adapter và đầu vào của chủ sản phẩm ở `docs/M7_READINESS.md` đã cập nhật theo môi trường hiện tại. `flutter devices` nhận Redmi K30 5G `9d9af905` (Android 10/API 29); `flutter doctor -v` nhận SDK 36.0.0, all Android licenses accepted; `adb devices -l` báo `device` qua USB. `ls -l build/app/outputs/flutter-apk` thấy APK debug có sẵn từ 10:18 nhưng chưa xác minh cài/chạy. Đây chỉ là kiểm tra môi trường, **không phải spike quảng cáo M7**. Kênh phát hành chưa được chốt trong PLAN/DECISIONS, nên chưa tích hợp SDK, chạy spike ad hoặc tuyên bố reward/cancel/error/lifecycle đạt.

## Tái hiện assembleDebug sau phản hồi lỗi (02/11/2026)

`flutter build apk --debug` exit 1 sau 9,8 giây. Log xác nhận `LicenceNotAcceptedException` cho `ndk;28.2.13676358`, SDK đang dùng `/home/bss-group/Android/Sdk`; `sdkmanager --sdk_root=/home/bss-group/Android/Sdk --licenses </dev/null` vẫn báo **8/8 chưa chấp nhận**. `flutter doctor -v` còn báo chưa có Android platform hợp lệ. `flutter devices` có Redmi K30 5G, nhưng chưa build/cài/chạy app trên máy này. Cần chủ sản phẩm hoàn tất lệnh license tương tác trong terminal trước khi có thể cài NDK và kiểm tra lại.

## Android SDK license/NDK blocker (02/11/2026)

`flutter run` trên Redmi K30 5G dừng ở `LicenseNotAcceptedException`: Gradle cần NDK `28.2.13676358` nhưng `/usr/lib/android-sdk` chỉ có `platform-tools`, không có `cmdline-tools`, NDK hoặc license được chấp nhận. Đây là lỗi setup SDK, chưa phải lỗi gameplay.

Đã tải Android Command-line Tools Linux `commandlinetools-linux-15859902_latest.zip` từ trang Android Developers, kiểm SHA-256 `4e4c464f145a7512b57d088ac6c278c03c9eea610886b35a5e0804e74eedf583`, giải nén vào `~/Android/Sdk/cmdline-tools/latest`, sao chép `platform-tools` có sẵn, đặt `ANDROID_HOME`/`ANDROID_SDK_ROOT` trong shell và trỏ `flutter config --android-sdk` cùng `android/local.properties` đến `~/Android/Sdk`. `sdkmanager --version` → 22.0. Flutter 3.47.7 yêu cầu compile/target SDK 36 và NDK 28.2.13676358 theo `FlutterExtension.kt` của SDK đang cài.

Lệnh `sdkmanager --sdk_root=/home/bss-group/Android/Sdk --licenses </dev/null` → **8/8 SDK package licenses not accepted**. Đã yêu cầu chủ sản phẩm đọc và tự chấp nhận license nếu đồng ý. Chưa cài platform 36, build-tools 36.0.0, NDK; `flutter doctor -v` vẫn báo không có Android platform hợp lệ. Chưa build APK hoặc chạy app trên điện thoại. Sau khi license được chấp nhận, cài đúng các package bằng SDK manager, chạy lại `flutter doctor -v`, `flutter run -d 9d9af905` và lưu artifact/log thật.

## Sửa môi trường Java cho Android (02/11/2026)

Lỗi nhận được: `JAVA_HOME is not set and no 'java' command could be found in your PATH`. Kiểm tra `command -v java`, `command -v javac` và `/usr/lib/jvm` đều không tìm được JDK; `sudo -n true` báo cần mật khẩu. Android Gradle Plugin 9.1.0 của repo và Gradle 9.3.1 cần JDK 17. Tải `openjdk-17-jdk-headless` và `openjdk-17-jre-headless` 17.0.20.1 từ Ubuntu bằng `apt-get download`, giải nén trong `~/.local/opt/java17-packages`, tạo truststore từ CA hệ thống và cấu hình `JAVA_HOME`/`PATH` trong `~/.profile`, `~/.bashrc`; chạy `flutter config --jdk-dir=...` tới JDK đó. Không sửa source/build config trong repo.

Xác minh: `bash -lc '... java -version; javac -version'` → cả hai là 17.0.20.1; `cd android && ./gradlew --version` → Gradle 9.3.1, Launcher JVM 17.0.20.1, exit 0. `flutter doctor -v` hiện nhận Android SDK tại `/usr/lib/android-sdk` và Redmi K30 5G Android 10, nhưng báo **thiếu cmdline-tools**; chưa chạy Android build, chưa có APK/AAB hoặc spike ad. Trạng thái thiết bị này mới hơn bản khảo sát M7 ngay bên dưới.

## Khảo sát cổng M7 (02/11/2026)

`docs/M7_READINESS.md` ghi adapter compatibility matrix, nguồn Google/Flutter/Play hiện hành, kịch bản spike reward/cancel/error/duplicate/lifecycle và đầu vào cần chủ sản phẩm. Đây là khảo sát, **M7 vẫn chưa bắt đầu**: `docs/PLAN.md` ghi kênh phát hành chưa quyết định; `com.example.ball_handler`/ký debug vẫn là placeholder. Chưa thêm `google_mobile_ads`, chưa chạy ad SDK hoặc phát hành.

Lệnh thực chạy: `git status --short --branch` → `## develop...origin/develop`, sạch trước khi sửa; `/home/bss-group/snap/flutter/common/flutter/bin/flutter devices` → chỉ Linux và Chrome; `/home/bss-group/snap/flutter/common/flutter/bin/flutter doctor -v` → Flutter 3.47.7/Dart 3.13.5, Android toolchain **Unable to locate Android SDK**. Vì không có điện thoại Android kết nối hoặc SDK, spike thiết bị thật, APK/AAB và test ad thật là **NOT VERIFIED**. Xem `docs/M7_READINESS.md` để mở cổng sau khi chủ sản phẩm chốt kênh phát hành và cung cấp thiết bị.

## Rà soát skill Git (22/10/2026)

Đã chỉnh `skills/push-branch`, `skills/run-commit`, `skills/write-commit` cho GitHub/`develop`: push thường, không force push hoặc tạo PR; commit chỉ lấy file đúng phạm vi, không stage toàn bộ mặc định. Cập nhật `AGENTS.md` để ghi nhận quy trình Git. Đây là thay đổi hướng dẫn, không thay đổi game hay milestone.

Kiểm tra: chạy `quick_validate.py` riêng cho cả ba skill — đều trả `Skill is valid!`; `git diff --check` — không báo lỗi. `git status --short --branch` xác nhận đang ở `develop`, ba skill mới vẫn chưa được track. Chưa commit hoặc push.

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

## M4 — Dữ liệu, validator, editor dev và 20 màn (30/10/2026)

| ID | Task | Trạng thái | Bằng chứng / việc còn lại |
| --- | --- | --- | --- |
| M4-01 | Schema v1 và JSON catalog | DONE trong code | `Level.toJson/fromJson`, 20 bản export ở `data/m4_levels.json`, `dart run tool/export_levels.dart` báo 20 validated levels. |
| M4-02 | Validator và replay | DONE trong test | `validateCatalog(m4Levels)` rỗng; cả 20 màn thắng với `GameAttempt` và giữ cửa 1 giây. Test lỗi ID trùng, ngoài biên, ref sai, spawn đỏ, thiếu/sai lời giải. |
| M4-03 | Editor dev tối thiểu | DONE trong test | Entry riêng `tool/editor_main.dart`; kéo bounds, đổi thứ tự sao, import/export JSON và thử đèn bằng rules; widget test kéo hazard/export JSON và đổi thứ tự sao làm replay báo lỗi. Chưa kiểm tra thủ công UI editor trong browser. |
| M4-04 | Nhóm màn 04–07, 08–12, 13–16, 17–20 | READY FOR REVIEW | Geometry và waypoint có replay; bốn key visual draft đã lưu ở `design/chapters/` nhưng chưa duyệt; chơi thử người thật chưa thực hiện. Build dùng lại nền hiện có. |
| M4-05 | Playtest người thật/thiết bị thật | NOT VERIFIED | Không có kết quả người chơi cho màn 01–20; Android SDK/artifact vẫn chưa có bằng chứng. |

Chi tiết schema, lệnh editor và các giới hạn ở `docs/M4_LEVEL_SCHEMA.md`. Không coi replay tự động là bằng chứng màn dễ hiểu, đủ khoảng hở cho ngón tay hay thú vị khi chơi.

## M6 — QA candidate web (30/10/2026)

- Baseline trước sửa: `flutter analyze` — pass; `flutter test --reporter compact` — **49/49 pass**; `dart run tool/export_levels.dart` — **20 validated levels**; `flutter build web --no-wasm-dry-run` — pass, còn cảnh báo font CupertinoIcons template.
- Phát hiện từ Chrome headless viewport 844 × 390: UI ngang chồng chữ/nút. Test orientation viết trước đã fail; sau khi thêm hướng dẫn xoay dọc và pause, `flutter test test/m6_qa_test.dart --reporter compact` — **2/2 pass**, gồm 30 chu kỳ start/reset/pause/menu.
- Test race hủy ad trong khi save reward viết trước đã fail (kỳ vọng earned, nhận cancelled). Sau sửa `MockRewardedAds` và UI trạng thái lưu, test service và widget liên quan đều pass. Chưa tích hợp SDK ad thật.
- Chrome headless CDP ở 1366 × 768, 360 × 800, 390 × 844, 844 × 390: render không có Runtime/Log/console error. Tại 390 × 844, start, reload, bật Network offline, kéo đèn và thắng màn 01; screenshot lưu trong `docs/qa/m6/`. Các thao tác dùng chuột CDP/viewport giả lập.
- `flutter doctor -v` và `flutter devices`: thiếu Android SDK, không có thiết bị Android/iPhone; chưa build APK/AAB, chưa đo FPS/frame time hoặc bộ nhớ trên thiết bị. M5 còn TODO và playtest người thật màn 01–20 chưa có. Xem bảng pass/fail/chưa thực hiện, bug và blocker ở `docs/QA.md`.

Smoke test cuối sau sửa: `flutter analyze` — **No issues found**; `flutter test --reporter compact` — **53/53 pass**; `dart run tool/export_levels.dart` — **20 validated levels**; `flutter build web --no-wasm-dry-run` — **pass**, artifact `build/web` (cảnh báo CupertinoIcons template còn); `git diff --check` — pass. Mở lại artifact bằng Chrome headless CDP ở cả bốn viewport — **không Runtime/Log/console error**; ở 390 × 844 start → reload → chuyển Network offline → kéo đèn → thắng màn 01, 3/3 lượt. `rg -n 'Editor dev|Import JSON|Export JSON' build/web/main.dart.js` không tìm thấy chuỗi editor (exit 1 mong đợi). Screenshot cuối ở `docs/qa/m6/`.

Trạng thái M6: **candidate web để review, chưa production-ready**. Chưa deploy và chưa push; chưa có bằng chứng nghiệm thu thiết bị thật hoặc nội dung từ người chơi.
