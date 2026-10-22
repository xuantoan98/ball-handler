# Lộ trình

Nguồn đầy đủ và tiêu chí từng mốc: [SHADOW_CONTROLLER_PLAN.md](../plan/SHADOW_CONTROLLER_PLAN.md). Chỉ thực hiện milestone được giao; trạng thái thực tế ở [PROGRESS.md](PROGRESS.md).

**Thay đổi nền tảng ngày 21/10/2026:** chủ sản phẩm chọn Flutter. Các đoạn trong kế hoạch gốc đề xuất TypeScript/Vite/Phaser hoặc gọi web-first là giả định đã được thay thế. Mốc M0 hiện là project Flutter cho Android và web, mock tĩnh bằng Flutter. Các mốc sau cần thiết kế bằng Dart/Flutter, không mở lại hai codebase song song.

| Mốc | Kết quả chính | Trạng thái |
| --- | --- | --- |
| M0 | Chốt tài liệu, repo Flutter, mock tĩnh, build web; Android scaffold | Đang nghiệm thu |
| M1 | Hình chiếu và kéo đèn trong sandbox | Đã kiểm thử bằng viewport/touch giả lập; thiết bị thật chưa xác minh |
| M2 | Vòng chơi ba màn, rules và chống xuyên | Đã triển khai/test tự động; chờ playtest người thật và cảm ứng thiết bị |
| M3 | Lượt, save và ad mô phỏng | Đã triển khai/test tự động; chờ kiểm tra thiết bị thật |
| M4 | Validator/editor và tối đa 20 màn có lời giải | TODO |
| M5 | UI, âm thanh, hướng dẫn và art | TODO |
| M6 | QA Flutter trên các target được chọn và bản candidate | TODO |
| M7 | Quảng cáo thật và phát hành Android nếu quyết định phát hành | Chưa quyết định |

M2 tạm thời chưa tính lượt để tập trung kiểm chứng gameplay. Lượt, lưu game và quảng cáo mô phỏng thuộc M3.

**Điều chỉnh M3 sau kiểm thử 22/10/2026:** bắt đầu không trừ lượt; thua trừ 1 sau khi lưu; thắng reset 3. Quy tắc này thay các dòng M3 cũ của kế hoạch gốc.
