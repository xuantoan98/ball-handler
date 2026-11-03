---
name: write-commit
description: Đọc diff của dự án ball-handler và đề xuất Conventional Commit message khi người dùng yêu cầu viết message hoặc chuẩn bị commit.
---
# Viết commit message

1. Đọc `git status --short` cùng diff của các file thuộc yêu cầu. Xem cả staged và unstaged; với file mới, đọc nội dung liên quan vì `git diff` không hiển thị file untracked. Không stage file chỉ để soạn message.
2. Xác định phạm vi commit từ yêu cầu hiện tại và thay đổi thực tế. Giữ ngoài mọi sửa đổi không liên quan của người dùng.
3. Đề xuất subject theo Conventional Commits: `feat`, `fix`, `docs`, `test`, `refactor`, `chore`, `build` hoặc loại phù hợp khác. Dùng tiếng Việt ngắn gọn, mô tả điều thực sự thay đổi; thêm body khi cần giải thích lý do hoặc giới hạn kiểm thử.
4. Nếu chỉ được yêu cầu viết message, trả message để người dùng dùng. Nếu được yêu cầu commit, chuyển nội dung và phạm vi file sang `run-commit` hoặc thực hiện commit theo cùng nguyên tắc; không thêm bước xác nhận trùng lặp.

Skill này không tự kích hoạt cho mọi yêu cầu review code. Dự án dùng Flutter/Dart, GitHub và nhánh `develop`; không đưa ví dụ công nghệ khác vào message khi code hiện tại không dùng chúng.
