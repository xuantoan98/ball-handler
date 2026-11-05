# QA và bằng chứng Flutter

## Refactor source và kiểm hồi quy (04/11/2026)

`flutter analyze --no-pub` → No issues found. `flutter test --reporter compact --no-pub` → 110/110 pass sau tách `BoardCanvas`, gồm hai test mới kiểm hàng đợi lưu thời gian khi ghi chậm/lỗi. `dart run tool/export_levels.dart` → `Exported 20 validated levels`; file `data/m4_levels.json` sinh ra được trả về trạng thái trước lượt này để không trộn thay đổi dữ liệu màn vào refactor. `flutter build web --no-wasm-dry-run --no-pub` → `Built build/web`; `flutter build apk --debug --no-pub` → `Built build/app/outputs/flutter-apk/app-debug.apk`, SHA-256 artifact cuối `ccea1d60be10d2d10c501e90ac709d57d2feb31ec1920779a4e031f8276858de`. `git diff --check` → không có lỗi khoảng trắng.

`adb devices -l` nhận Redmi K30 5G `9d9af905`; `adb install -r` → Success; `am start` chạy app, `pidof` có PID. Ảnh máy cho thấy home tiếng Anh, popup Settings, [preview màn 01](qa/code-opt-2026-11-04/preview-redmi.png), playing với đồng hồ 58 giây và panel pause; APK cuối sau tách `BoardCanvas` được cài lại và xác nhận preview → playing → [pause](qa/code-opt-2026-11-04/pause-redmi.png). `adb logcat -d -t 700 | rg 'FATAL EXCEPTION|E/flutter|AudioPlayerException'` không có dòng khớp tại thời điểm kiểm. Trước thử đã sao lưu `files/datastore/FlutterSharedPreferences.preferences_pb` (328 byte); sau `am force-stop` khôi phục bằng `adb shell -T run-as ... tee ...` và `adb exec-out run-as ... cat ... | sha256sum` khớp backup `126805e3ead151b656fbe4deb4948a8267dc05d31e137670693b062e44bb2869`.

Chrome headless mở web build qua `python3 -m http.server` ở 390×844, chụp được [popup Cách chơi](qa/code-opt-2026-11-04/web-intro-390.png). Đây là smoke tải/render, chưa thử tương tác web. Redmi chưa kiểm lại đủ 20 màn, ad SDK, âm lượng bằng tai, độ khó hay frame time profile cho refactor này; không coi các mục đó là pass.

## Nút Âm thanh đồng bộ với Cài đặt (04/11/2026)

- `SoundButton` dùng `TheatreButtonTone.outline` như nút Cài đặt. `flutter analyze --no-pub` → sạch; `flutter test test/widget_test.dart --reporter compact --no-pub` → **27/27 pass**, bao gồm bật/tắt lưu bền và test hai nút Play không chuyển sang trạng thái vô hiệu khi save âm thanh; `flutter build apk --debug --no-pub` → pass, SHA-256 `ce319b7736085ee31d2db50350930167666f14710f6c88b8a9306a61d28e5586`; `flutter build web --no-wasm-dry-run --no-pub` → pass (cảnh báo CupertinoIcons cũ).
- Redmi K30 5G: `adb install -r` → Success. [Ảnh hai nút khi âm bật](qa/sound-button/home-on-redmi.png) và [khi âm tắt](qa/sound-button/home-off-redmi.png) cho thấy cùng viền/nền và chỉ icon loa đổi; các nút Chơi ngay/Xem màn vẫn giữ màu trong ảnh sau thao tác. DataStore ghi `soundEnabled:false` sau tap; tap lần nữa trở về true và SHA-256 save khớp trước thử `126805e3ead151b656fbe4deb4948a8267dc05d31e137670693b062e44bb2869`. Đây là kiểm một chu kỳ trên máy, không phải phép đo pixel cho animation trung gian.

## Tên và icon ứng dụng trên Redmi (04/11/2026)

Chủ sản phẩm chọn tên **Little Shadow Theatre**. Icon cuối được xem ở 48/72/96 px trên nền sáng/tối và trong mô phỏng mask adaptive; các nét nhận diện lớn vẫn đọc được. `python3 tool/generate_app_icons.py` → xuất Android legacy 5 mật độ (48/72/96/144/192 px), foreground adaptive 5 mật độ (108/162/216/324/432 px), web 192/512 và favicon 64 từ ảnh gốc 1254×1254. Đây là kiểm tra raster và kích thước, không thay playtest thị giác của nhiều người.

Lệnh/kết quả: `flutter analyze --no-pub` → No issues found; `flutter build apk --debug --no-pub` → pass, APK SHA-256 `59d3b798ff5334e3175c0f647a710470bb687415b1fecca366497ede964619ac`; `flutter build web --no-wasm-dry-run --no-pub` → pass (cảnh báo font CupertinoIcons cũ). `aapt dump badging` xác nhận `application-label:'Little Shadow Theatre'`, minSdk 24, targetSdk 36. `adb install -r` → Success trên Redmi K30 5G; [ảnh cắt từ launcher thật](qa/app-icon/launcher-redmi.png) cho thấy icon mới sắc nét, tên xuống hai dòng do độ dài; app mở, PID 20097, `mResumedActivity` là `com.example.ball_handler/.MainActivity`. Save trước/sau cài APK cùng SHA-256 `126805e3ead151b656fbe4deb4948a8267dc05d31e137670693b062e44bb2869`. Chưa kiểm store listing hoặc release AAB.

## M7 — kiểm lại quảng cáo test trên Redmi (04/11/2026)

- Cổng: D27 đã chốt Flutter Android/Google Play. Redmi K30 5G `9d9af905`, Android 10/API 29; Flutter 3.47.7, `google_mobile_ads` 9.2.0, Android SDK/target API 36, minSdk 24, `com.example.ball_handler`. Debug dùng sample app ID `ca-app-pub-3940256099942544~3347511713` và rewarded unit `ca-app-pub-3940256099942544/5224354917`; không có quảng cáo live. Trước sửa UMP, APK có SHA-256 `60961b983e4043cc218ca2ab99a64ce41e1f43ddae469ca7f3366c4294764756`; sau sửa, `flutter build apk --debug` → pass, APK `build/app/outputs/flutter-apk/app-debug.apk` SHA-256 `55be05080ea83816db23082e815f8ad5aba079f5ef96e3bc794d819003d61352`, `adb install -r` → Success và test creative vẫn hiện trên máy ([ảnh](qa/m7-2026-11-04/rebuilt-ad.png)). `flutter analyze` → No issues found; `flutter test --reporter compact` → **108/108 pass**; `git diff --check` → pass. Bản sửa gọi UMP consent update lúc khởi động và chờ cùng future trước ad load; sample ID không có message theo cấu hình AdMob của sản phẩm nên chưa xác minh UI consent/Privacy options.
- Reward: dùng save tạm 2/3, mở preview màn 01 và bấm Watch test ad. [Creative Google test](qa/m7-2026-11-04/test-ad.png) hiện; sau 8 giây có nhãn [đã cấp thưởng](qa/m7-2026-11-04/reward-ready.png). Đóng X → [3/3](qa/m7-2026-11-04/earned.png); DataStore chứa `lives:3` và thêm đúng một reward ID. **PASS trên SDK thiết bị** trước sửa UMP và kiểm lại trên APK mới: creative hiện, xem đủ, đóng X → [3/3](qa/m7-2026-11-04/rebuilt-earned.png), save từ 2/3 lên 3/3 với đúng một ID mới.
- Cancel trước reward: **CHƯA XÁC MINH trên SDK thật**. Sample creative chỉ cho X sau khi đã cấp thưởng; Back trước mốc thưởng không đóng quảng cáo trong spike cũ. `RewardedAdSession.dismiss()` trước `earn()` và mock cancel đã pass unit/widget test, không thay thế nhánh native này.
- Error: tắt Wi-Fi và mobile data, bấm ad, quan sát sau khoảng 20 giây: vẫn 2/3, reward ID không tăng; không bắt được callback/log phân biệt UMP, load fail hay show fail. Vì vậy **PASS điều kiện không cộng thưởng khi offline trong một lần thử; nguyên nhân lỗi chưa xác định**. `RewardedAdSession.fail()` pass unit test; show fail SDK chưa được kích hoạt riêng.
- Duplicate: save 2/3→3/3 chỉ có một ID trong một lần hiển thị; unit/service test gọi earned trùng và grant cùng ID sau reload chỉ cộng một lần. **Không quan sát được SDK gửi callback earned trùng**, nên nhánh duplicate SDK còn chưa xác minh.
- Lifecycle: khi creative đang đếm ngược 7 giây, bấm Home rồi mở lại app: [home 2/3](qa/m7-2026-11-04/resume-home.png), DataStore không thêm ID. **PASS một nhánh Home/resume +0**. Force-stop lúc load và thưởng đã lưu sau restart đã có bằng chứng ở spike 02/11; lock/rotate, kill trong lúc ghi save và cancel native trước reward vẫn chưa xác minh.
- Dữ liệu máy: trước thử `adb exec-out run-as ... cat files/datastore/FlutterSharedPreferences.preferences_pb` đã sao lưu SHA-256 `126805e3ead151b656fbe4deb4948a8267dc05d31e137670693b062e44bb2869`. Chỉ thay DataStore bằng save tạm 2/3 sau `am force-stop`; sau thử force-stop và chép lại backup, SHA-256 trên máy khớp chính xác. Wi-Fi ban đầu `1`, mobile data `0`; sau thử cũng là `1`/`0`. Không xóa dữ liệu app. Không có AAB release ký, Play track hay xuất bản.

## Chuyển ngôn ngữ toàn game (03/11/2026)

- `flutter test --reporter compact --no-pub` → **108/108 pass**. Test mới xác nhận save v4 lên v5 mặc định Tiếng Việt, English lưu qua restart, lỗi ghi không đổi save, đủ bản dịch tên/gợi ý 20 màn, phản hồi số sao/màn, popup chuyển ngay home/preview/pause rồi đổi lại Tiếng Việt. `flutter analyze --no-pub` → No issues found. `flutter build apk --debug --no-pub` → pass, SHA-256 artifact cuối `60961b983e4043cc218ca2ab99a64ce41e1f43ddae469ca7f3366c4294764756`; `flutter build web --no-wasm-dry-run --no-pub` → pass (cảnh báo font CupertinoIcons cũ).
- Redmi K30 5G `9d9af905`: `adb install -r` → Success. [Popup Tiếng Việt](qa/language/settings-vi-redmi.png), [popup English](qa/language/settings-en-redmi.png), [preview 01 tiếng Anh](qa/language/stage01-en-redmi.png) là ảnh máy thật. UI semantics đổi `Cài đặt`→`Settings`, `Tắt âm thanh`→`Mute sound`, `Chơi ngay`→`Play now`, nút preview `Bắt đầu`→`Start`. Save sau chọn English có `schemaVersion=5`, `language=en`, `highestUnlocked=0`, `currentLevel=0`. Đây là QA đọc hình và thao tác ADB; chưa đánh giá ngôn ngữ bởi người bản ngữ hoặc kiểm mọi câu dịch trên thiết bị.
- Save trước thử được sao lưu `/tmp/ball-handler-before-language-qa.pb`, SHA-256 `d80cff94d77820878d5694bfcbe76f01050f7cbddc6723eb6d30ac673ba8479a`, schema v4, màn 1, 3 lượt, âm bật. Sau QA đã force-stop, chép lại đúng hash rồi mở app; migration tạo schema v5 với `language=vi`, `highestUnlocked=0`, `currentLevel=0`, home hiện `Chơi ngay`. Save gốc không bị giữ ở English sau phép thử.

## Màn 15/19, hiệu ứng thắng và khóa màn (03/11/2026)

- `flutter test --reporter compact --no-pub` → **102/102 pass**: replay 20 màn; test mới kiểm vật chắn 15/19 không giao nhau, đường ziczac, 36 hạt và thời gian hiệu ứng 1.200 ms; widget test duyệt 01→20 từ save mới, màn khóa đều không tạo ván. `flutter analyze --no-pub` → No issues found; `flutter build web --no-wasm-dry-run --no-pub` → pass; `flutter build apk --debug --no-pub` → pass, SHA-256 `344e281d5c6c160b6c49fb04e32b83bc73bd6f004829ef3e3fe92b21aeb69fd0`; `adb install -r` trên Redmi `9d9af905` → Success.
- [Màn 15](qa/stage-zigzag/stage15-redmi.png) và [màn 19](qa/stage-zigzag/stage19-redmi.png) là ảnh APK mới trên Redmi: hai vách không còn chồng nhau, vùng coral màn 19 riêng biệt. Đây là kiểm hình, chưa có người thật giải hai màn bằng ngón tay. Lượt kéo ADB đầu để chụp hiệu ứng thắng màn 1 đã hết 60 giây trước thao tác; lượt thứ hai thắng màn 1, chụp được [vòng sáng, tia và nhãn hoàn thành](qa/stage-zigzag/win-effect-redmi.png), rồi panel `Qua cửa trăng!` hiện. Đây là QA touch ADB, chưa phải đánh giá cảm nhận của người chơi.
- Save thiết bị trước thử SHA-256 `95db3883c194161cf3f457b1ead9d93bb095b822e0345298f731e4867923c060`, sao lưu tại `/tmp/ball-handler-redmi-before-lock-fix.pb`: `highestUnlocked=19`, `currentLevel=9`, `activeAttempt=9`, 3 lượt, âm bật. Đây là tiến độ được mở trong các phiên QA cũ, giải thích vì sao người dùng có thể chơi màn sau khi duyệt. Sau QA hình và hiệu ứng, đã đặt `highestUnlocked=0`, `currentLevel=0`, `activeAttempt=null`, giữ 3 lượt và âm bật; hash save mới `d80cff94d77820878d5694bfcbe76f01050f7cbddc6723eb6d30ac673ba8479a`. Mở app lại ở home, duyệt màn 2: nút `Chưa mở` disabled trong [ảnh](qa/stage-zigzag/stage02-locked-redmi.png). Chạm nút rồi force-stop, save vẫn `highestUnlocked=0`, `currentLevel=0`, `activeAttempt=null`. Sau lượt thử hiệu ứng, đã trả lại save màn 1 đúng hash và mở app lại ở home. Không trả lại save QA đã mở khóa để thiết bị bắt đầu từ màn 1 như yêu cầu.

## Điều chỉnh 20 màn, HUD, nút và nhạc (03/11/2026)

- `gst-launch-1.0` giải mã `music.ogg`, `audioamplify amplification=2.0`, mã hóa Vorbis lại; `gst-discoverer-1.0` xác nhận thời lượng 33,652 giây, stereo 44,1 kHz. PCM sau giải mã có peak 0,508 và RMS 0,0972; file SHA-256 `6daaae17102a053812cd1f5c1508ca3e50982a1dcbbf35b41dbf23df548d152c`. Chưa có xác nhận bằng tai về mức mới.
- `flutter test --reporter compact --no-pub` → **100/100 pass**, gồm validator và replay 20 màn; test mới kiểm chớp dọc chạm gần hai mép, có chớp ngang và ít nhất bốn vị trí cửa. `flutter analyze --no-pub` → No issues found. `flutter build apk --debug --no-pub` → APK SHA-256 `233f07366fd00388a31901e21dbd76beb38f0b67dd4a897f3eb0da98c01ce662`; `flutter build web --no-wasm-dry-run --no-pub` → tạo `build/web`.
- Redmi `9d9af905`: `adb install -r` → Success. Xem [ảnh HUD màn 20](qa/m5/hud-stage20-redmi-v2.png): tên/số màn trái, thời gian 41s và pause giữa, lượt 3/3 phải; chữ không đè nhau ở khung 1080×2400. Nút home và preview có hoa văn góc mới. Trong quá trình kiểm ảnh, ván đang chạy trên máy hết giờ; đã force-stop và khôi phục save sao lưu trước thử. Hash save trước/sau khớp `ce83e29bfdba2f23a1ddf7cc20aa26d8e7f0ee67fd70f03b6ed810cdc0c1c33c`, gồm 3/3 lượt, `activeAttempt=19`, `attemptRemainingMs=53275`. App mở lại ở home và thông báo ván được khôi phục. Đây là kiểm hình và trạng thái save, chưa phải bằng chứng người thật giải được các màn đã chỉnh hoặc mức nhạc dễ chịu.

## Màn khởi động và lưu màn tiếp tục (03/11/2026)

- `dart format` → 5 file kiểm tra, 2 file đổi; `flutter test --reporter compact --no-pub` → **99/99 pass**; `flutter analyze --no-pub` → No issues found; `flutter build web --no-wasm-dry-run --no-pub` → tạo `build/web`; `flutter build apk --debug --no-pub` → tạo APK SHA-256 `f640ee975c9a5d4345e9b58416a7f72c35039c133bca8a5e86037d83cae518ac`.
- Redmi `9d9af905`: save v3 trước cài có `highestUnlocked=19`, `activeAttempt=null`, SHA-256 `50d442494f30c70375bcee72425e9cf2891c1c6adbaa6c882ba6af8491e2cc0f`; `adb install -r` → Success. Mở app chuyển sang schema v4 với `highestUnlocked=19`, `currentLevel=0`, giữ lives/âm thanh/reward; chạm `Chơi ngay` thấy preview “Đánh thức ánh sáng” (màn 1), `Màn trước` disabled.
- Duyệt đến “Ròng rọc giấy” (màn 10), chạm `Bắt đầu`: save có `activeAttempt=9`, `currentLevel=9`, `attemptRemainingMs=58989`. Force-stop/mở lại: home thông báo khôi phục; chạm `Chơi ngay` vào ván đang chơi, đồng hồ còn 55 giây. Sau thử nghiệm, đã trả save về trạng thái v4 trước thử nghiệm (`activeAttempt=null`, `currentLevel=0`), hash trước/sau cùng `28bff0f12d40ea3e9fae20b266fefa50153d84659c6e094d918e7f648b7066ee`.

## M5 bàn đèn/âm thanh/chuyển động (03/11/2026)

- Chủ sản phẩm xác nhận nhạc phát ngay ở home và âm lượng **ổn** trên Redmi; sau đó báo bấm loa làm hai nút `Chơi ngay`/`Xem màn` nháy. Test widget giữ lệnh save âm thanh chờ bằng `writeGate`, ban đầu fail vì `onPressed` của `Chơi ngay` thành null. Nguyên nhân: `_operationBusy` tạm thời vô hiệu hóa hai nút khi chỉ đang lưu lựa chọn loa. Đã tách `_soundSaveBusy` khỏi trạng thái bận hiển thị; logic vẫn chặn thao tác đồng thời, hai nút giữ trạng thái visual và `Opacity=1` trong lúc lưu. Test mới qua; toàn suite `flutter test --reporter compact --no-pub` → **96/96 pass**, `flutter analyze --no-pub` → No issues found, build web/APK debug pass. APK SHA-256 `60d0aead5b976d426cdb7e9d8a3ac3cd938a694d6988bf7a0a9d6b167dc130c9`, `adb install -r` → Success, cold start home có loa bật và hai nút enabled; save trước/sau cài cùng hash `50d442494f30c70375bcee72425e9cf2891c1c6adbaa6c882ba6af8491e2cc0f`. Chủ sản phẩm bấm loa vài lần trên APK mới và xác nhận **không còn nháy**.
- Chủ sản phẩm xác nhận sau sửa audio focus nhạc đã nghe được nhưng quá nhỏ với volume 0,55. Tăng volume player lên 1,0 (file nguồn peak 0,253, không vượt trần PCM); `flutter analyze --no-pub` sạch, test audio 3/3 pass, build web và APK debug pass (SHA-256 `3271777ecd8b37531c29b4c8930736b69c03aca0aa55e20e078cb41cfa83d19d`). Cài APK, Android ghi track nhạc active ở mức player 0 dB. Chủ sản phẩm báo mức âm **ổn**, nhưng yêu cầu nhạc phát ngay ở màn chờ.
- Đã cho `GameAudio` tự mở khóa trên Android/native, còn web vẫn chờ gesture để tuân autoplay; `unlock()` lặp không phát thêm loop. Test mới `native music starts on the waiting screen without a gesture`; toàn bộ `flutter test --reporter compact --no-pub` → **95/95 pass**, `flutter analyze --no-pub` → No issues found, build web và APK debug pass. APK mới SHA-256 `c652faa438d34a07f95d3e62a18a4e8618694663bd1f9341dae52f7ba06f5d4f`; `adb install -r` → Success. Sau force-stop/mở app lạnh **không chạm**, semantics ở home với loa bật, `dumpsys media.audio_flinger` ghi track PID 25566 active, volume player 0 dB. Save trước/sau cùng SHA-256 `50d442494f30c70375bcee72425e9cf2891c1c6adbaa6c882ba6af8491e2cc0f`. Chủ sản phẩm xác nhận đã nghe nhạc ngay và âm lượng ổn.
- Phản hồi nghe trên Redmi: chủ sản phẩm **không nghe nhạc nền**, chỉ nghe tiếng chạm sao. Điều tra `music.ogg`: GStreamer giải mã Ogg Vorbis thành PCM; 33,65 giây có RMS toàn file −26,3 dBFS, từng giây khoảng −25 đến −28 dBFS, nên file không im lặng. Android log đã nạp `audio/music.ogg` và xin audio focus. Tăng volume player 0,12→0,55, build/cài APK SHA-256 `a395dbc41766d09aa93b3bc86bc36c5c3f2421a91304a4619cba5eb670fe15e9`; chủ sản phẩm **vẫn không nghe nhạc**. Do đó tăng volume riêng không giải quyết lỗi.
- Kiểm tiếp cho thấy các SFX dùng `AudioContextAndroid` mặc định `AndroidAudioFocus.gain`, làm nhạc mất focus khi tiếng click/sao phát; `GameAudio` vẫn giữ `_playing=true`. Đã cấu hình SFX `AndroidAudioFocus.none`, giữ nhạc ở focus dài. Lượt sửa đầu có lỗi `const AudioContext` và build thất bại; sau sửa `flutter analyze --no-pub` → No issues found, `flutter test --reporter compact --no-pub` → **94/94 pass**, `flutter build web --no-wasm-dry-run --no-pub` → pass, `flutter build apk --debug --no-pub` → pass, APK SHA-256 `eeaa52e690aa70760d1bfc047573aa65ff380324ee6e792b2a1c1036c91578a7`. Cài `adb install -r` → Success. Sau khi bấm `Xem màn`, `dumpsys media.audio_flinger` ghi track PID 21725 ở trạng thái active ở mốc đầu và hơn 12 giây sau; sau hơn 30 giây vẫn có track nhưng trạng thái `s2`, cần thẩm định tai/ngữ nghĩa loop. Save trước/sau cài và thử có cùng SHA-256 `bb300263339380bb7aecde21c16cb573da5f238115b10957a5c338ba830d079e`. Đang chờ chủ sản phẩm nghe lại APK focus mới; không đánh dấu âm thanh PASS chỉ từ trạng thái audio system.
- Redmi K30 5G mở khóa, APK debug SHA-256 `1408b1125c57153bd6a96958eeed17ef4384920f87c2bfe84b9cd4ad6f992c91`: `adb devices -l` nhận `9d9af905`; `adb shell pidof com.example.ball_handler` nhận process. Save 296 byte được sao lưu bằng `adb exec-out run-as ... cat files/datastore/FlutterSharedPreferences.preferences_pb` trước khi thử. Bấm loa ở home: semantics đổi `Tắt âm thanh` → `Bật âm thanh`; force-stop/mở lại vẫn `Bật âm thanh`; bấm bật lại. Home, preview màn 20, bàn đèn đang chơi màn 01 và panel pause đã xem trên ảnh máy. Ảnh crop bỏ status/navigation ở [home](qa/m5/home-redmi.webp), [đang chơi 01](qa/m5/playing-01-redmi.webp), [pause 01](qa/m5/paused-01-redmi.webp).
- Kéo đèn trên màn 01 bằng `adb shell input swipe` và giữ bóng trong cửa: semantics `Qua cửa trăng!`, panel [thắng](qa/m5/won-01-redmi.webp), lượt về 3/3. Màn 02 kéo qua cảm biến đỏ: semantics `Bóng chạm vùng đỏ`, panel [thua](qa/m5/collision-02-redmi.webp), lượt 2/3 → 1/3. Một lần màn 01 hết 60 giây trong khi tìm tọa độ ADB cũng hiện `Hết 60 giây` và trừ một lượt; đây là thử bằng touch ADB, không phải playtest người mới. `adb logcat -d -t 1200` không tìm thấy `FATAL EXCEPTION`, `E/flutter` hoặc `AudioPlayerException` ở cuối phép thử. Ảnh tĩnh chứng minh panel/trạng thái, chưa xác nhận hạt giấy, viền coral hay rung trong cửa sổ hiệu ứng ngắn.
- Sau thử: `adb shell am force-stop`, chép lại save gốc qua `run-as`; SHA-256 trên máy và backup đều `d87d14fe7e5267a097c74eac8d1820a0cad6ad14aff3be5c2703351bfa084398`. Mở app lại, semantics hiện `3 / 3 lượt` và `Tắt âm thanh` như trước thử. Chưa nghe thẩm định chất lượng/loop hoặc đo Flutter frame time cho bản M5; đang chờ phản hồi nghe trực tiếp của chủ sản phẩm. Không dùng log âm thanh để suy ra đã nghe được tiếng hoặc rung.
- Tiếp tục kiểm tra bản M5 ngày 03/11: `flutter test --reporter compact` ban đầu exit 1 vì `HomeScreen._stage()` dùng `context` ngoài scope. Đã truyền `BuildContext` vào `_stage`; lần test kế tiếp **94/94 pass**. `flutter analyze --no-pub` sau đó báo 2 info về dấu ngoặc `if` và thiếu `@override`; đã sửa, chạy lại → **No issues found**. `flutter test --reporter compact --no-pub` → **94/94 pass**; `flutter build web --no-wasm-dry-run --no-pub` → `Built build/web` (cảnh báo CupertinoIcons cũ); `flutter build apk --debug --no-pub` → `Built build/app/outputs/flutter-apk/app-debug.apk`, SHA-256 `1408b1125c57153bd6a96958eeed17ef4384920f87c2bfe84b9cd4ad6f992c91`; `git diff --check` → exit 0. APK cuối `adb install -r` → `Success`, `am start` được Android nhận, `pidof com.example.ball_handler` → 14104; `adb logcat -d -t 500` lọc `FATAL EXCEPTION|E/flutter|AudioPlayerException` không có dòng khớp. Ảnh chụp sau lệnh chỉ thấy màn khóa của máy, nên chưa xác nhận UI bản cuối bằng mắt. Đây là smoke tiến trình, chưa kiểm cue hoặc frame time trên máy cho bản cuối.
- TDD: `flutter test test/game/game_painter_test.dart` ban đầu fail vì thiếu `deskBackdrop`, sau triển khai 2/2 pass; test audio/widget và effect/entrance cũng được chạy đỏ trước khi thêm code. Lệnh cuối: `dart format lib test` → 46 file, 2 file format; `flutter analyze --no-pub` → No issues found; `flutter test --reporter compact --no-pub` → 93/93 pass; `git diff --check` → exit 0. `flutter build web --no-wasm-dry-run --no-pub` → `Built build/web` (cảnh báo CupertinoIcons còn); `flutter build apk --debug --no-pub` → `Built build/app/outputs/flutter-apk/app-debug.apk`, SHA-256 `8c46d4229d281073e8a58b995869377cc23207070814a0f407daf4de0f6a7bac`.
- Redmi K30 5G qua ADB: `adb install -r .../app-debug.apk` sau build cuối → `Success`; `adb shell am start -n ...` → process PID 9198. Mở app thấy home cùng nút loa, bấm đổi biểu tượng tắt, bấm lại đổi về bật; `adb logcat` không thấy `FATAL EXCEPTION`, `E/flutter` hoặc `AudioPlayerException` trong 300 dòng cuối. Datastore sau force-stop chứa `soundEnabled:true`, `activeAttempt:null`, 1/3 lượt. Ảnh màn chơi sau asset bàn xác nhận đèn vẽ trên mặt oval, nút reset và sân khấu không bị che. Không chấm âm lượng/loop bằng tai hoặc haptic thắng-thua là PASS.
- Browser UI smoke: thử inventory Computer Use → `browsers: []`; Chrome automation không khả dụng trong phiên này. Chỉ build web pass, chưa xác nhận first-gesture autoplay trên browser. Safari và định dạng Ogg trên Safari chưa kiểm chứng.
- Chưa có phép đo Flutter frame time sau asset/effect, test người mới, hoặc xác nhận trực quan hiệu ứng thắng/thua trên thiết bị; những hạng mục này vẫn mở.


## M6 mô phỏng sai số thao tác — không thay playtest (03/11/2026)

Theo yêu cầu khi chưa thu xếp được người thử thật, `dart run tool/m6_simulate_inputs.dart` đã phát sinh **5 cấu hình đầu vào tổng hợp × 20 màn × 25 seed = 2.500 lượt** qua `GameAttempt` của game. Mỗi cấu hình đi theo `solutionSteps` đã author, chỉ thay tọa độ mốc đèn trong vùng điều khiển và tốc độ/chờ; không nhìn ảnh, tự tìm đường hay sửa sau khi hụt cửa. Seed cố định `20261103`; [dữ liệu từng màn](qa/m6/simulated-inputs-2026-11-03.json) có số thắng/thua/chưa hoàn thành và lý do. `px` ở đây là đơn vị logic của bàn điều khiển 390×844, không phải sai số đo từ ngón tay người.

| Cấu hình tổng hợp | Sai số mốc | Tốc độ / chờ thêm | Thắng | Thua | Chưa hoàn thành |
| --- | --- | --- | ---: | ---: | ---: |
| Đường tham chiếu | 0 px | 1× / 0 s | 500 | 0 | 0 |
| Lệch nhỏ | ±2 px mỗi trục | 1× / 0 s | 500 | 0 | 0 |
| Lệch vừa | ±5 px mỗi trục | 1× / 0 s | 218 | 6 | 276 |
| Chậm và dừng nghĩ | ±2 px mỗi trục | 1,25× / 0,5 s trước mỗi bước kéo | 500 | 0 | 0 |
| Chậm, lệch lớn | ±8 px mỗi trục | 1,35× / 0,8 s trước mỗi bước kéo | 113 | 10 | 377 |

Trong cấu hình ±5 px, 272/276 lượt chưa hoàn thành có cửa mở nhưng bóng chưa nằm trọn trong đích sau mốc cuối; ở ±8 px là 351/377. Hình học hiện tại cho bóng cao 54, cửa cao 76 trên tường; một đơn vị dọc bàn đèn dịch bóng khoảng 4,84 đơn vị tường, nên dải dọc để bóng **nằm trọn** cửa chỉ khoảng 4,54 px logic. Đây là **dấu hiệu cần quan sát khả năng chỉnh vị trí cuối bằng ngón tay**, không phải tỷ lệ thất bại dự đoán của người chơi: mô phỏng cố ý không nhìn phản hồi để sửa đường. Năm cấu hình không tương đương năm người; M6 vẫn chờ playtest người mới theo [phiếu](M6_PLAYTEST_V2.md).

Sau khi thêm công cụ mô phỏng: `flutter analyze` → No issues found; `flutter test --reporter compact` → **84/84 pass**; kiểm JSON → 100 hàng màn×cấu hình, mỗi hàng 25 lượt; `git diff --check` → không lỗi.

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
