# Chạy và build Flutter M0–M3

Yêu cầu Flutter SDK tương thích Dart 3.13.5. Trên máy này, binary dùng được là /home/bss-group/snap/flutter/common/flutter/bin/flutter; dùng đường dẫn này thay cho từ flutter trong các lệnh bên dưới vì launcher /snap/bin/flutter bị giới hạn bởi snap.

Các lệnh: flutter pub get, flutter analyze, flutter test, flutter run -d chrome, flutter build web. M2 mở preview màn 1; chọn màn trước/sau, bắt đầu rồi kéo đĩa đèn vàng trong bàn lilac bằng chuột hoặc một ngón tay. Nút tạm dừng/đặt lại chỉ hiện khi chơi. Build release ẩn tọa độ debug; chạy debug hiển thị L và S dưới sân khấu.

build/web là artifact vòng chơi M3. Target Android đã được scaffold nhưng Android SDK chưa có trong môi trường; lệnh flutter build apk --debug từng dừng ở “No Android SDK found”. Sau khi cài SDK, chạy flutter doctor -v rồi build lại để xác minh. com.example.ball_handler, icon template và cấu hình ký hiện chỉ là placeholder. M3 chưa phải bản phát hành; chưa có deployment/rollback.

M3 điều chỉnh: bắt đầu/retry/next không trừ lượt; chỉ kết quả thua đã lưu mới trừ 1; thắng reset về 3. Tối đa 3 lượt, hồi 1 mỗi 30 phút. Nút “Xem quảng cáo +1 lượt” chạy quảng cáo mô phỏng 5 giây, không kết nối SDK thật. Web chỉ cho một tab ghi; tab khác hiện chỉ đọc. Dữ liệu lưu lỗi không tự reset, người chơi có thể chọn đặt lại có xác nhận. `shared_preferences` là lưu local thử nghiệm, không đủ bảo đảm cho thưởng có giá trị hoặc đồng bộ nhiều thiết bị.

Ba nền sân khấu nằm tại `assets/backgrounds/` và được Flutter đóng gói vào web build; nguồn/prompt xem `docs/ASSETS.md`. Ảnh chỉ là trang trí, không thay thế bounds tương tác. Chưa đo FPS hoặc tải ảnh trên điện thoại thật.

## M6 — Candidate web để review, chưa phát hành

Từ thư mục repo, chạy `flutter pub get`, `flutter analyze`, `flutter test`, `dart run tool/export_levels.dart`, rồi `flutter build web --no-wasm-dry-run`. Artifact tĩnh nằm ở `build/web/`; có thể xem cục bộ bằng `python3 -m http.server 8765 --directory build/web`. Entry editor dev nằm ở `tool/editor_main.dart`, không thuộc entry `lib/main.dart` của web build. Không có deployment riêng tư trong M6 vì chưa được yêu cầu.

Nếu một bản triển khai sau này có lỗi, phục hồi bằng artifact đã lưu của bản trước: phục vụ lại thư mục `build/web/` của phiên bản trước trên cùng môi trường, kiểm tra màn bắt đầu, lượt và lưu trước khi mở lại người chơi. Không dùng checkout nhánh làm rollback cho dữ liệu local đã ghi trên máy người chơi; cần kiểm tra schema save khi đổi phiên bản. Hiện chưa có deployment hoặc artifact phiên bản trước được lưu trong repo, nên đây là quy trình, không phải một rollback đã thực hiện.

Xem `docs/QA.md` để biết bug/blocker còn mở, thiết bị chưa thử và kết quả kiểm tra. Candidate này **không production-ready**.
