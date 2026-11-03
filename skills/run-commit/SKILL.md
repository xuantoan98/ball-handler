---
name: run-commit
description: Tạo Git commit trong dự án ball-handler khi người dùng yêu cầu commit và đã có nội dung cùng phạm vi file cần ghi nhận.
---
# Thực hiện commit

1. Kiểm tra `git status --short --branch`, `git diff --cached` và các thay đổi liên quan chưa stage. Chỉ commit trên `develop` theo quy trình hiện tại của repo; nếu nhánh khác, xác minh đích với người dùng.
2. Chỉ stage các file thuộc yêu cầu đã được xác định. Giữ nguyên mọi thay đổi không liên quan của người dùng; không dùng `git add -A` theo mặc định. Nếu index đã chứa thay đổi ngoài phạm vi, không đưa chúng vào commit này.
3. Dùng commit message đã được người dùng chốt, hoặc message được chuẩn bị cho yêu cầu commit hiện tại. Nếu người dùng đã yêu cầu commit, không hỏi xác nhận lặp lại chỉ vì skill này được gọi.
4. Chạy `git commit` và báo hash, message, các file đã ghi nhận. Chỉ push nếu người dùng yêu cầu push; khi đó áp dụng `push-branch`.

Nếu phạm vi file hoặc message chưa thể suy ra an toàn, trình bày lựa chọn cụ thể để người dùng quyết định. Không ghi credential vào commit hoặc output.
