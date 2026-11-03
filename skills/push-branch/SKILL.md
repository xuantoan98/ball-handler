---
name: push-branch
description: Đẩy commit của dự án ball-handler lên origin/develop trên GitHub khi người dùng yêu cầu push. Không tạo Pull Request.
---
# Push lên develop

Repo này dùng GitHub, remote `origin` qua SSH và nhánh làm việc `develop`. Khi được yêu cầu push:

1. Kiểm tra `git status --short --branch`, `git branch --show-current` và `git remote get-url origin`. Chỉ tiếp tục nếu đang ở `develop` và `origin` trỏ tới repo GitHub mong đợi; nếu trạng thái khác, báo rõ để tránh đẩy sai đích.
2. Dùng `git fetch origin develop` nếu kết nối khả dụng, rồi kiểm tra quan hệ giữa `develop` và `origin/develop`. Nếu remote có commit mới, xem xét thay đổi và xử lý đồng bộ trước khi push; không ghi đè lịch sử remote.
3. Chạy `git push origin develop` khi người dùng đã yêu cầu push và nhánh đã sẵn sàng. Nếu push bị từ chối, báo nguyên nhân thực tế và xử lý theo trạng thái Git; không tự dùng `--force` hoặc `--force-with-lease`.
4. Báo commit đã đẩy và kết quả lệnh. Không tạo hoặc gợi ý Pull Request theo quy trình mặc định của dự án.

Chỉ commit khi người dùng cũng yêu cầu commit hoặc đã có chỉ dẫn rõ trong phiên. Push không bao gồm file chưa commit. Không yêu cầu người dùng đưa token, mật khẩu hoặc khóa SSH vào chat.
