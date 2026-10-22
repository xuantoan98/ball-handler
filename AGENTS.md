# Hướng dẫn repository

Đọc `docs/PRODUCT.md`, `docs/PLAN.md`, `docs/DECISIONS.md` và `docs/PROGRESS.md` trước khi làm task. Kế hoạch gốc nằm ở `plan/SHADOW_CONTROLLER_PLAN.md`.

Trước khi sửa UI, màn chơi hoặc asset, đọc `docs/DESIGN_SYSTEM.md` và xem ảnh chuẩn `design/Midnight Shadow Theatre Game Board.png`. Hướng “Rạp bóng nhỏ” trong ảnh là nhận diện xuyên suốt dự án; giữ bố cục chức năng, màu theo vai trò, bóng đội vương miện, cửa trăng mint và đèn mặt trời vàng. Gameplay phải theo PRODUCT/PLAN; ảnh mock không quyết định va chạm.

Chủ sản phẩm đã chọn Flutter + Dart thay giả định web-first trong kế hoạch. Sửa cùng một codebase Flutter; target Android và web cùng dùng mã trong `lib/`. Không tái tạo skeleton Vite/Phaser. Trước khi báo đã build Android, cần có Android SDK và artifact thực tế.

Chỉ làm milestone được giao. Ghi lệnh và kết quả thật vào `docs/PROGRESS.md` hoặc `docs/QA.md`. Không đánh dấu thiết bị thật, playtest, ad thật hoặc màn giải được là đạt khi thiếu bằng chứng. Giữ nguyên thay đổi không liên quan của người dùng.

Git remote của dự án ở GitHub. Làm việc và push trực tiếp lên `develop` khi được yêu cầu; không giả định có `main` hoặc `master`, và không tạo Pull Request theo quy trình mặc định. Không force push.
