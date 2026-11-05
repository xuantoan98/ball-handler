---
name: commit
description: "Một lệnh commit cho ball-handler: viết Conventional Commit message từ diff, tạo commit đúng phạm vi, rồi push lên origin/develop."
---
# Commit và push bằng một lệnh

Áp dụng khi người dùng nhắn `commit`, gọi `skills/commit/SKILL.md` hoặc yêu cầu gộp viết message, commit và push. Trong repo này, yêu cầu đó **đã bao gồm quyền push** lên `origin/develop`; không hỏi xác nhận lại. Nếu người dùng chỉ yêu cầu viết message, tạo commit local hoặc chỉ push, làm đúng phạm vi hẹp hơn bằng skill tương ứng.

Thực hiện tuần tự, dừng khi một bước thất bại:

1. **Viết:** Theo [`write-commit`](../write-commit/SKILL.md), đọc status, staged/unstaged diff và file mới; xác định file thuộc công việc hiện tại, giữ nguyên thay đổi không liên quan. Soạn Conventional Commit message tiếng Việt phù hợp với thay đổi thực tế.
2. **Kiểm tra đích:** Xác nhận đang ở `develop`, `origin` là repo GitHub của dự án. `git fetch origin develop` và kiểm tra quan hệ giữa local/remote trước khi commit. Nếu remote đã đi trước, xử lý đồng bộ an toàn; không ghi đè lịch sử.
3. **Tạo commit:** Theo [`run-commit`](../run-commit/SKILL.md), stage đúng các file đã xác định, kiểm tra `git diff --cached --check` và danh sách staged, rồi tạo commit với message ở bước 1. Không gom file ngoài phạm vi, credential hoặc cache sinh tự động.
4. **Push:** Theo [`push-branch`](../push-branch/SKILL.md), chạy `git push origin develop` không force. Xác minh commit đã ở `origin/develop` và báo hash, message, kiểm tra đã chạy cùng phần còn lại trong working tree (nếu có).

Nếu không có thay đổi cần commit, không tạo commit rỗng; báo trạng thái. Nếu phát hiện thay đổi staged không liên quan hoặc không thể xác định an toàn phạm vi, dừng trước commit và nêu rõ file cần người dùng quyết định.
