# Đánh giá source và kế hoạch tối ưu code (04/11/2026)

Phạm vi: rà tĩnh `lib/`, `test/`, `tool/`, cấu hình Flutter và tài liệu sản phẩm hiện có. Đây là kế hoạch refactor cho cùng codebase Flutter Android/web, **chưa thay đổi code, luật chơi, màn, asset hoặc save**. Các số đo hiệu năng dưới đây là bằng chứng M6 đã ghi trong [QA](QA.md), không phải phép đo mới của lượt rà này.

## Đánh giá hiện trạng

| Khu vực | Đánh giá dựa trên source | Hướng xử lý |
| --- | --- | --- |
| Luật chơi và dữ liệu màn | `core/geometry.dart`, `rules.dart`, `level.dart` độc lập Flutter; `level_validator.dart` replay bằng đúng engine. 20 màn thủ công giữ trong `level_catalog.dart`. Đây là ranh giới tốt, không cần viết lại engine. | Giữ logic thuần Dart. Chỉ tối ưu thuật toán sau khi có profile hoặc test chứng minh điểm nghẽn; bảo toàn thứ tự va chạm và lời giải 20 màn. |
| Phiên chơi và UI | `main.dart` 1.363 dòng; `_GamePageState` giữ gameplay, pointer, ticker, ảnh decode, save, quảng cáo, audio, lifecycle, home và toàn bộ overlay. `build` dựng lại cây trang chơi khi `_onFrame` gọi `setState` mỗi frame; `_refreshLives` cũng gọi `setState` mỗi giây dù record không đổi. Đây là nơi ưu tiên tách trách nhiệm. | Tách điều phối phiên, lớp giao diện board và các panel. Thu hẹp phạm vi cập nhật UI theo trạng thái thực đổi. |
| Vẽ sân khấu | `game_painter.dart` 1.064 dòng, một `CustomPainter` vẽ hậu cảnh, vật cản, bóng, hiệu ứng, bàn đèn, HUD. `shouldRepaint` luôn `true`; painter nghe animation và tạo `TextPainter` trong hàm vẽ. Hậu cảnh có 16 dải pha ảnh mỗi lần vẽ. Đây là **ứng viên** tối ưu raster, chưa được chứng minh là nghẽn. | Tách hàm vẽ theo lớp trước; đo lại rồi mới tách `CustomPaint`/`RepaintBoundary` hoặc cache ảnh tĩnh nếu có lợi. Không đổi bounds va chạm. |
| Lưu, lượt, quảng cáo | `LivesService` là nơi duy nhất thay đổi lượt/tiến độ, commit record sau khi ghi thành công; `SaveRecord` hỗ trợ schema v1–v5; reward có interface/coordinator/session và test. `main.dart` còn giữ hàng đợi lưu đồng hồ và nhiều cờ `busy`. | Giữ service hiện có; tách hàng đợi lưu thời gian và điều phối trạng thái ra khỏi widget, kiểm tra thứ tự start/finish/reward và lỗi ghi. Không đổi schema chỉ để refactor. |
| Âm thanh và ngôn ngữ | `GameAudio`/backend đã tách. Dịch chữ hiện tra bằng nguyên văn tiếng Việt, hai regex và một mẫu tiền tố; thông báo gameplay còn là `String`, `main.dart` nhận biết âm báo bằng `startsWith`. Đổi câu chữ có thể làm thiếu bản dịch hoặc đổi cue âm thanh. | Dùng key/kiểu sự kiện rõ nghĩa cho thông báo và cue; chuyển từng nhóm có test VI/EN. Không thay đổi câu chữ hay âm lượng trong bước tách cấu trúc. |
| UI Kit và editor | `theatre_components.dart` đã có nút/panel tái dùng. `HomeScreen` 434 dòng chứa intro và settings popup; `EditorApp` 407 dòng đi qua entrypoint dev riêng, không nằm trong `main.dart`. | Tách popup/intro thành widget nội bộ có props rõ ràng; giữ `TheatreButton`/`TheatrePanel` và token màu. Editor là ưu tiên thấp nếu chưa phát sinh thay đổi tính năng. |
| Asset và nền tảng | Asset game khoảng 23 MB trên đĩa; stage decode thủ công mỗi lần chọn màn và giải phóng ảnh cũ. Android ad adapter hiện là spike test; web dùng mock. | Đo decoded image memory và thời gian đổi màn trước khi thêm cache. Giữ adapter quảng cáo test, không gộp vào refactor UI hay bật ad live. |
| Kiểm thử | Test đang bao phủ rules, validator, save/reward/audio, widget flow, art/layout; lượt rà này chạy 108/108 pass và analyze sạch. Test lớn `widget_test.dart` 695 dòng. | Khi tách, di chuyển test theo hành vi/module, bổ sung test cho controller/lifecycle và ảnh so sánh nơi có rủi ro thị giác; tránh test chỉ lặp lại implementation. |

## Thứ tự thực hiện đề xuất

### 0. Chốt baseline trước khi sửa

- Ghi commit/hash làm mốc sau khi các thay đổi đang dở được xử lý theo chỉ đạo của chủ sản phẩm; không trộn refactor với M7 hoặc thay đổi icon/UI hiện có.
- Giữ `flutter analyze`, `flutter test`, `dart run tool/export_levels.dart` làm cổng chức năng. Chụp home, preview, playing, pause, result, settings VI/EN ở kích thước đang dùng; lưu save v1–v5 fixture và case lỗi lưu.
- Đo profile Android thật ở màn 01/20: idle, kéo đèn, đổi màn, 30 chu kỳ vào/ra; ghi UI/raster p95/p99, số frame vượt budget, PSS và thời gian decode. Đo web riêng. Số M6 trước đó chỉ là baseline tham khảo: màn 20 đứng UI/raster p99 7,184/11,173 ms; kéo 11,450/15,463 ms trong mẫu ngắn. Chưa kết luận có jank dài hạn.

### 1. Tách màn và component trình bày — ưu tiên cao

1. Giữ `ShadowTheatreApp`/composition root gọn trong `main.dart`. Chuyển phần `GamePage` sang `lib/game/game_page.dart` mà không đổi hành vi.
2. Tách `BoardScene` (canvas, pointer và các nút gắn tọa độ), `ResultPanel`, `AdOverlay`, `StatusOverlay` từ các đoạn `build`, `_panel`, `_adOverlay`, `_statusOverlay`. Truyền dữ liệu và callback cụ thể; `LivesService` không được widget con sửa trực tiếp. Dùng `BoardUiLayout`/`ViewportMapper` hiện có để giữ vị trí và vùng chạm.
3. Tách `SettingsPopup` và `IntroOverlay` từ `HomeScreen`; tái dùng `TheatreButton`/`TheatrePanel`. Giữ chuẩn “Rạp bóng nhỏ”, Bóng Mơ đội vương miện, cửa mint, đèn vàng; không lấy ảnh mock làm hitbox.

**Xong khi:** ảnh trước/sau không có thay đổi ngoài sai số render cho phép, nhãn/semantics và thao tác VI/EN đúng, 108 test hiện tại vẫn qua. Đây là bước giảm độ phức tạp file, chưa hứa tăng FPS.

### 2. Tách điều phối phiên khỏi `State` — ưu tiên cao

1. Tạo controller phiên (`GameSessionController` hoặc tên tương đương) sở hữu `GameAttempt`, chuyển màn, pause/resume/reset, ticker/lifecycle và trạng thái terminal. Widget chỉ chuyển input và dựng view state. Giữ `GameAttempt` thuần Dart.
2. Đưa logic `_queueTimerSave`/`_drainTimerSaves` vào một thành phần lưu thời gian nhỏ, có test thứ tự save đang chờ → finish/abandon, lỗi ghi và dispose. Không thay đổi chính sách lưu một lần mỗi giây.
3. Thay các cờ chồng nhau như `_operationBusy`, `_terminalPending`, `_adOpen`, `_terminalSaveFailed` bằng trạng thái/transition có tên rõ khi đã có test bảo vệ. Đừng chuyển toàn bộ sang package state management mới chỉ vì file lớn.
4. Thay việc phân nhánh âm thanh theo tiền tố `feedback` bằng sự kiện gameplay có kiểu; lớp hiển thị dịch sự kiện sang VI/EN. Chuyển từng loại sự kiện, giữ thứ tự ưu tiên va chạm/thắng/thua.

**Xong khi:** start, reload, pause/background, timeout, thắng/thua, ad reward/cancel/error/duplicate và lỗi save giữ đúng kết quả; v1–v5 đọc được; chỉ một nơi sở hữu mỗi transition.

### 3. Tối ưu render theo số đo — ưu tiên vừa, có điều kiện

1. Tách `GamePainter` thành các module vẽ hậu cảnh/đạo cụ, bóng và vật tương tác, bàn/HUD, hiệu ứng. Bước đầu giữ một canvas và cùng thứ tự vẽ để giảm rủi ro hình ảnh.
2. Nếu timeline cho thấy raster bị tốn ở lớp tĩnh, thử layer tĩnh riêng với `RepaintBoundary` và `shouldRepaint` so sánh input bất biến. Lưu ý animation hiện được truyền qua `super(repaint: animation)`; chỉ đổi predicate không tự chặn các lần repaint do animation.
3. Nếu profile chỉ ra 16 dải pha ảnh hoặc layout chữ nóng, thử tiền xử lý ảnh nền theo kích thước cần dùng/cache text phù hợp; đo memory cùng frame time. Giữ quyền sở hữu/`dispose` ảnh rõ ràng và hủy kết quả decode cũ khi đổi màn nhanh.
4. Chỉ giữ thay đổi nếu UI/raster p95/p99 và memory không xấu đi; nếu không, giữ bản tách module đơn giản. Không tối ưu vi mô `rules.dart` chỉ vì thấy cấp phát tạm.

**Xong khi:** so ảnh 20 màn và các trạng thái hiệu ứng, kiểm hitbox bằng validator/replay, profile Android/web trên cùng cảnh và thao tác; không suy diễn FPS từ một mẫu ngắn.

### 4. Bảo trì dài hạn — ưu tiên sau các bước trên

- Đổi `GameLanguage.text(String)` sang key và tham số cho các chuỗi động theo từng nhóm; có kiểm tra đủ key VI/EN và test màn/tình huống dài. Giữ mặc định VI cho save cũ.
- Chỉ chia `level_catalog.dart` theo nhóm màn khi việc author/review trở nên khó; không sinh dữ liệu màn tự động và không đổi lời giải/hitbox trong refactor.
- Sắp test theo module sau khi ranh giới mới ổn định; giữ vài integration test xuyên luồng thay cho một file widget ngày càng dài.

## Quy tắc nghiệm thu từng bước

- Mỗi bước là một thay đổi nhỏ, không sửa đồng thời engine, art, save schema và ad adapter. `flutter analyze`, `flutter test`, `dart run tool/export_levels.dart` phải qua; Android/web build khi đụng đến UI, asset hoặc nền tảng.
- So sánh trên Redmi thật khi thay đổi painter/input/lifecycle; kiểm ít nhất màn 01, 08, 15, 19, 20 và home/settings VI/EN. Giữ bản sao save QA, đối chiếu trước/sau.
- Chỉ gọi là **tối ưu hiệu năng** nếu có phép đo trước/sau cùng build mode, máy và kịch bản, không tăng frame vượt budget hoặc PSS quá mức nhiễu đo. Việc tách file đơn thuần được ghi là cải thiện bảo trì.
- M7 còn đang spike; không bật ad live, ký hoặc phát hành trong kế hoạch tối ưu code này.

## Lệnh đã chạy trong lượt rà

- `flutter analyze --no-pub` → `No issues found`.
- `flutter test --reporter compact --no-pub` → `All tests passed`, 108 test. Flutter snap in thông báo thiếu công cụ build Linux; lệnh test vẫn exit 0.
- `find lib test tool -type f \( -name '*.dart' -o -name '*.py' \) | sort`, `rg -n 'setState\(|shouldRepaint|TextPainter\(|drawImageRect\(|instantiateImageCodec|TODO|FIXME|debugPrint\(|print\(' lib tool`, `du -ch assets/backgrounds/* assets/controls/* assets/audio/*`, `git status --short` → kiểm kê source, điểm repaint/state và asset; working tree đã có nhiều thay đổi từ công việc trước, không được động tới trong lượt rà.

Chưa chạy profile, build mới, kiểm thiết bị hoặc playtest trong lượt phân tích này.

## Tiến độ triển khai (04/11/2026)

- **Đã làm:** `main.dart` chỉ giữ entrypoint/composition root; `GamePage` chuyển sang `game/game_page.dart`. Intro/settings, `BoardCanvas`, result panel, ad/status overlay và nút board có widget riêng. `GameSession` giữ attempt, drag và các chuyển trạng thái puzzle; `AttemptTimerSaveQueue` giữ thứ tự lưu đồng hồ trước khi kết thúc/bỏ ván. Phần pha ảnh hậu cảnh chuyển sang `StageBackdropRenderer` nhưng vẫn dùng cùng thuật toán/canvas.
- **Đã làm:** thông báo luật chơi có `AttemptFeedbackKind`; chọn cue âm thanh và hiệu ứng va chạm không còn dựa vào tiền tố của câu tiếng Việt. `_refreshLives` chỉ yêu cầu dựng lại UI khi số lượt đổi hoặc đang hiện đếm hồi lượt.
- **Đã kiểm:** analyze sạch, 110 test pass, 20 màn qua validator; web và APK debug build thành công. Redmi mở được home/settings/preview/playing/pause; save gốc khôi phục đúng hash. Chi tiết lệnh và giới hạn ở [QA](QA.md).
- **Còn theo kế hoạch:** chưa chuyển toàn bộ ticker/lifecycle/ad state khỏi `GamePage`, chưa đổi toàn bộ bản dịch sang key, chưa tách static/dynamic `CustomPaint`, chưa đo profile trước/sau trên cùng bản nguồn. Vì vậy chưa tuyên bố tăng FPS hoặc giảm bộ nhớ. Các bước render chỉ tiếp tục khi có baseline đủ tin cậy để đánh giá lợi ích.
