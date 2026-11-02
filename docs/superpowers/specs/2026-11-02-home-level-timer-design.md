# Trang chủ, khóa màn và đồng hồ 60 giây — thiết kế

Ngày 02/11/2026. Đầu vào: phản hồi sau thử trên Redmi K30 5G, `docs/PRODUCT.md`, `docs/DESIGN_SYSTEM.md`, hai ảnh chuẩn trong `design/` và quyết định trả lời trong cuộc trao đổi này. **Preview v2:** [xem PNG](home-preview-v2.png) · [nguồn SVG](home-preview-v2.svg). Đây là bản duyệt UI, chưa phải mã màn hình. Bản v1 [home-preview.svg](home-preview.svg) bị chủ sản phẩm nhận xét quá đơn giản; v2 bám sát `design/Whimsical Shadow Theatre UI Kit.png`.

## Ý định và phạm vi

Người chơi thấy một trang chủ theo nhận diện “Rạp bóng nhỏ” mỗi lần mở app, nhận hướng dẫn đúng một lần khi cài mới, rồi duyệt được mọi màn bằng hai nút Màn trước/Màn sau. Một màn chỉ chơi được sau khi đã qua màn trước. Ván có tối đa 60 giây để qua cửa trăng; thời gian còn lại đọc được ngay cạnh nút tạm dừng, viền sáng nhịp mỗi giây trong 10 giây cuối. Hết giờ là thua theo cùng giao dịch lượt hiện có.

Không thêm quảng cáo banner, cơ chế gameplay mới, backend hay tính năng phát hành. Giữ Flutter/Dart chung cho Android và web; giữ quy tắc cảm biến đỏ thắng ưu tiên khi chạm đích đồng thời, và thưởng/quảng cáo M7 hiện có. Mọi thay đổi ảnh hưởng code M7 chưa commit phải được giữ nguyên.

## Cách triển khai đã xét

| Cách | Ưu điểm | Giới hạn | Chọn |
| --- | --- | --- | --- |
| Trang chủ trong cùng `GamePage`, dùng state và save hiện có | Không dựng phiên `LivesService` thứ hai; quay từ trang chủ vào màn đã chọn không mất dữ liệu | `GamePage` cần tách widget trang chủ để tránh phình thêm | **Có** — người dùng chọn trang chủ mỗi lần mở app |
| Trang chủ route Flutter riêng, tự nạp save rồi chuyển route | Mỗi trang độc lập | Dễ tạo hai luồng nạp save/ownership và chuyển trạng thái active attempt | Không |
| Banner chỉ xuất hiện lần đầu | Ít thao tác hơn | Không đáp ứng yêu cầu có màn giới thiệu mỗi lần mở | Không |

Đồng hồ thuộc `GameAttempt` Dart thuần. `LivesService` lưu thời gian còn lại cùng phiên hiện hành. Khi Đặt lại, chỉ đặt lại vị trí đèn, công tắc và đồng hồ cửa; đồng hồ ván giữ nguyên. Khi app pause/background, dừng đồng hồ và lưu thời gian còn lại; khi mở lại app, hồi phục từ giá trị đã lưu. Sau thất bại, Retry tạo ván mới 60 giây. Cập nhật thời gian lưu theo nhịp phù hợp thay vì ghi mỗi frame. Nếu ghi lỗi lúc pause, hiển thị lỗi và không báo đã lưu thành công.

## Màn hình và trạng thái

### Trang chủ

Khung mobile dọc 390 × 844. Nền sân khấu giấy xanh đêm/tím nhiều lớp, viền hoa văn vàng, rèm nhung mở hé, đèn treo và lâu đài xa như UI Kit; không vẽ vật cản gameplay. Đỉnh có bảng tên khung vàng “RẠP BÓNG NHỎ” và câu “Một ngọn đèn. Cả thế giới chuyển động.” Trung tâm có Bóng Mơ đội vương miện ở tiền cảnh, cửa trăng mint và ánh đèn mặt trời vàng như ba dấu nhận diện. Dải dưới có hai nút vé xem kịch: **Chơi ngay** vàng và **Xem màn** lilac, kế đến bảng lượt `x/3` và thời gian hồi nếu có. “Chơi ngay” mở màn cao nhất đã mở; nếu ván còn hoạt động thì vào ván được khôi phục. “Xem màn” mở preview màn 1 để duyệt. Dùng Nunito, token `StageColors` và `TheatreButton`/`TheatrePanel`. Tại 360 px vẫn giữ vùng chạm ≥44 px. Không hiển thị tên level giả hoặc tiến độ không có trong save.

### Popup lần đầu

Trên trang chủ khi save mới có `introSeen=false`: panel giấy mực xanh tím có viền hoa văn vàng, huy hiệu trăng và backdrop tối như hàng popup của UI Kit. Tiêu đề “Cách chơi”, ba ý ngắn: “Kéo đèn để dẫn bóng về cửa trăng”; “Tránh vùng đỏ, bật sao theo thứ tự”; “Mỗi lượt có 60 giây. Tạm dừng sẽ dừng giờ.” Nút vé vàng “Đã hiểu” ghi `introSeen=true` rồi đóng. Nếu ghi thất bại, báo lỗi, vẫn cho thử lại; không âm thầm đánh dấu đã xem. Save cũ thiếu trường này được xem là đã xem để tránh popup bất ngờ sau cập nhật. Tab web chỉ đọc không ghi cờ và không bật popup.

### Preview màn

Màn trước/Màn sau cho duyệt 1–20 kể cả chưa mở. Với màn `index > highestUnlocked`, nút Play bị disabled, nhãn “Chưa mở”, và lời nhắc “Qua màn NN để mở.” Các màn đã qua và màn kế tiếp đã mở được chơi lại/chơi. `LivesService.startAttempt` cũng từ chối màn khóa để ngăn gọi trực tiếp bỏ qua UI. Kết quả thắng mở đúng màn kế; nút “Màn tiếp theo” chỉ chạy khi save kết quả đã hoàn tất.

### Đồng hồ ván

Ngay trong HUD, nút Tạm dừng có viền vòng tiến trình vàng giảm theo `remaining/60`, số giây còn lại nhìn thấy cạnh/ở nút cùng nhãn ngữ nghĩa “Còn NN giây”. 10 giây cuối, viền có bóng sáng vàng nhấn **mỗi giây**; không nhấp nháy toàn màn, không dùng coral khiến nhầm với vùng đỏ. Pause, app background, loading ad và panel kết quả dừng vòng. Hết thời gian trước khi hoàn tất giữ cửa 1 giây thì thua, thông báo “Hết 60 giây” thay vì “Bóng chạm vùng đỏ”. Cảm biến đỏ vẫn ưu tiên nếu va chạm xảy ra trước tick kết thúc; tại cùng tick 60 giây, timeout được xét trước thắng cửa. Bộ đếm chỉ chạy trong `AttemptPhase.playing`.

## Dữ liệu và kiểm thử

- Save phiên thêm `introSeen` và `attemptRemainingMs`; decode bản cũ có mặc định tương thích, không xóa tiến độ/lượt/reward IDs. Kết quả terminal xóa timer phiên; ván active khi reload giữ thời gian còn lại.
- Test Dart: 60 giây đúng ngưỡng, 10 giây cuối, pause/resume, reset giữ giờ, retry mới 60 giây, timeout chỉ xử một lần, ưu tiên timeout/exit theo quy tắc trên.
- Test service: màn 1 mở sẵn; duyệt màn 20 không cho start nếu chưa mở; thắng màn trước mới mở màn kế; lưu/reload timer và cờ hướng dẫn; lỗi ghi không cập nhật trạng thái giả.
- Widget test 390×844/360×800: trang chủ, popup lần đầu, nút khóa/giải thích, vòng pause và nhãn 60→10→0; smoke test trên Redmi K30 5G và web. Không gọi đó là playtest người mới.

## Phần cần duyệt

Preview v2 cho bố cục/chữ/màu vai trò. Trang chủ dùng [concept art](home-stage-concept-v2.png) tham chiếu UI Kit; chữ, nút, bảng lượt và popup trong SVG là các lớp riêng. Khi code, tranh là background không tương tác; toàn bộ chữ và nút dùng Flutter/component hiện có để hỗ trợ trạng thái thật và accessibility. Bóng/cửa/đèn trong tranh chỉ là nhận diện trang chủ, không biểu diễn hitbox gameplay. Quy tắc timer 60 giây, hết giờ thua và giữ thời gian khi Đặt lại/mở lại app do chủ sản phẩm đã chốt. Chưa sửa UI hoặc luật trước khi duyệt thiết kế màn chức năng theo `docs/DESIGN_SYSTEM.md`.

### Thành phần, token và tự soát v2

| Thành phần | Trạng thái cần code | Token/nguồn |
| --- | --- | --- |
| Tranh sân khấu, rèm, viền, bóng/cửa/đèn trang trí | Tĩnh, không nhận input | Concept art v2 từ UI Kit; nền `bg.deep`, `bg.ink`, vàng ấm và mint chỉ cho cửa |
| Bảng tên, câu giới thiệu | Chữ Flutter thật | Nunito, `text.primary`, `text.secondary`, viền `light.edge` |
| Chơi ngay | Enabled/loading/disabled khi đang lưu | `TheatreButton` primary gold |
| Xem màn | Enabled/loading | `TheatreButton` secondary lilac |
| Lượt/hồi lượt | 0–3 và đồng hồ hồi theo save | `text.primary`, vàng `light.main`, panel `frame.base` |
| Popup Cách chơi | Chưa xem/đang lưu/lỗi lưu/đã xem | `TheatrePanel`, backdrop tối, gold primary |

- **PASS trên preview:** nhận diện ba hình chính, sân khấu giấy nhiều lớp, vàng/lilac/mint đúng vai trò, chữ nút đọc được, popup theo kiểu UI Kit.
- **NOT VERIFIED trước khi code:** tương phản đo được, vùng chạm 360 px, cỡ chữ và safe area trên Android, giảm chuyển động, tốc độ render và accessibility. Những mục này cần kiểm trên Flutter/thiết bị thật.
