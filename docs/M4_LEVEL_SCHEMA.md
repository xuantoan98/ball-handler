# M4 — dữ liệu màn và editor dev

Nguồn đang chạy là `lib/core/level_catalog.dart`; `data/m4_levels.json` là bản export để review/import. Sau mỗi thay đổi catalog, chạy `dart run tool/export_levels.dart`; lệnh sẽ dừng nếu validator hoặc replay lỗi. App Android/web cùng dùng catalog Dart trong `lib/`.

## Schema v1

Mỗi màn có `id`, `schemaVersion: 1`, `title`, `hint`, `logicalBounds: [0,0,360,480]`, `lightBounds: [49,694,292,88]`, `initialLight: [x,y]`, `caster: [174,231,12,18]`, `hazards`, `switches`, `gates`, `exit`, `solutionWaypoints` và `solutionHoldSeconds`. Rect là `[left,top,width,height]`, điểm là `[x,y]` trong đơn vị logic. `switches` gồm `id`, `order`, `bounds`; `gates` gồm `bounds`, `requires` là ID công tắc. Engine hiện tại mở mọi gate khi toàn bộ công tắc được chạm đúng thứ tự, nên mỗi gate phải tham chiếu đủ bộ công tắc của màn.

Validator kiểm tra schema/geometry đúng engine, biên, ID, tham chiếu, spawn và chạy từng waypoint với `GameAttempt.moveLamp`, sau đó `tick(solutionHoldSeconds)`. Không có waypoint được báo “chưa xác minh”; hình vẽ hoặc endpoint riêng lẻ không chứng minh đường đi an toàn. Validator chạy lại khi export và trong test. Editor báo lỗi replay sau khi kéo vật thể; JSON chỉ trở thành nguồn phát hành khi thay lại catalog và chạy toàn bộ test.

## Editor

Chạy riêng: `flutter run -d chrome -t tool/editor_main.dart` hoặc target Flutter dev khác. Chọn màn; chọn loại vật thể; kéo hình chữ nhật trên bảng; thêm vùng đỏ/sao/cửa chắn; đổi thứ tự sao; import/export một màn JSON; dùng hai slider đèn và nút giữ cửa để thử bằng rules thật. Để lưu lời giải mới, chỉnh `solutionWaypoints` trong JSON rồi import và kiểm tra replay. `tool/editor_main.dart` từ chối release mode; entrypoint phát hành `lib/main.dart` không import editor.

## Nội dung và trạng thái

- 01–03: tutorial M2, giữ nguyên geometry và lời giải.
- 04–07: đường vòng và khoảng trống cho toàn bộ bóng.
- 08–12: trình tự sao.
- 13–16: sao, cửa chắn và đường vòng.
- 17–20: kết hợp ba yếu tố trên.

Màn 04–20 dùng lại nền và component sân khấu hiện tại; đã có key visual draft tại `docs/M4_KEY_VISUALS.md` nhưng chưa được duyệt hoặc tích hợp. Replay tự động không thay thế playtest. **Chưa có bằng chứng người thật chơi thử màn 01–20.** Chỉ màn 01 có lượt thắng bằng chuột trong browser ở giai đoạn M2; không phải playtest người mới hay thiết bị thật.
