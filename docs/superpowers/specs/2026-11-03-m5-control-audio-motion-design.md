# M5 · Bàn đèn, âm thanh và chuyển động v3

Trạng thái: **chờ chủ sản phẩm duyệt thiết kế** · 03/11/2026. Chỉ áp dụng cho M5 của Flutter Android và web; không thay luật 20 màn, hình học va chạm, lượt, đồng hồ 60 giây hoặc quảng cáo.

## Mục đích và chuẩn tham chiếu

Người chơi thấy bàn đèn xứng với mức hoàn thiện của màn home, nghe phản hồi rõ nhưng dịu khi giải đố, và nhận biết thắng/thua ngay từ cảnh trước khi panel kết quả xuất hiện. Hình chuẩn là `design/Midnight Shadow Theatre Game Board.png`, UI Kit và ảnh chủ sản phẩm chỉ định `exec-43fafa83-bc34-45f3-b54b-9869df9f9eb0.png`. [Preview bàn v3](m5-control-preview-v3.png) chỉ chốt chất liệu/họa tiết; mặt trời trong preview là ví dụ vị trí đèn, **không được đóng vào nền production**.

Hiện tại `GamePainter._desk` vẽ một oval lilac, trục chữ thập đậm và đĩa đèn tròn bằng Canvas. Bàn di chuyển thật là x49..341/y694..782 và vùng chạm theo `LampDrag`; screenshot Redmi cho thấy bàn phẳng hơn ảnh chuẩn. `SaveRecord.soundEnabled` đã tồn tại nhưng chưa có phát audio hoặc nút bật/tắt. `GamePage` đã có ticker, animation controller, lifecycle pause, các phase và panel thắng/thua. Mở rộng các điểm đó; không tạo engine chuyển động thứ hai cho vật va chạm.

## Cách làm đã chọn

1. **Ảnh bàn tĩnh + đèn Flutter di động — chọn.** Tạo nền riêng từ preview với mặt lilac **trống** (không đèn, chữ, trục đậm hay icon có nghĩa gameplay). Cắt/căn cho khung 390×844, giữ ít nhất toàn bộ vùng kéo x49..341/y694..782 sạch; viền lá vàng, trăng, đèn lồng và sao ở mép. `GamePainter` vẽ mặt trời vàng nhỏ nhiều lớp ở `attempt.lamp`, halo và phản hồi nhấn bên trên ảnh. Nút Đặt lại giữ vùng chức năng riêng, không bị tranh che. Họa tiết không tạo waypoint hay gợi ý trục bị khóa.
2. **Vẽ toàn bộ bằng Canvas — không chọn.** Nhẹ hơn về asset, nhưng phải tự dựng nhiều lớp giấy/lá chạm để đạt độ chi tiết của ảnh, tốn công và dễ kém đồng nhất với home.

Ảnh bàn được ghi prompt, nguồn ảnh tham chiếu và kích thước cuối vào `docs/ASSETS.md`. Tối ưu thành WebP nhỏ, giải mã một lần; nếu khung trang trí làm vùng kéo khó đọc trên Redmi, giảm chi tiết ở mặt trong thay vì giảm vùng chạm hoặc sửa luật.

## Âm thanh

Chủ sản phẩm chọn **nhạc nền nhẹ + hiệu ứng ngắn**. Một nút loa có nhãn tiếp cận “Bật âm thanh”/“Tắt âm thanh” ở trang home và panel tạm dừng; cùng một trạng thái lưu `soundEnabled`. Bật/tắt có hiệu lực tức thì, nhạc không tiếp tục chạy khi app vào nền, pause ván hoặc mở quảng cáo; khi quay lại chỉ phát theo trạng thái hiện tại và sau tương tác đầu tiên nếu trình duyệt chặn autoplay. Không tự bật âm thanh lại sau khi người chơi đã tắt.

Âm thanh đề xuất:

| Sự kiện | Âm sắc/giới hạn |
| --- | --- |
| Home/đang chơi | Vòng nhạc ambient mơ màng rất nhỏ, không có beat gấp; chơi liên tục, âm lượng thấp hơn SFX. |
| Nút/menu | Click giấy/chuông ngắn, không chồng nhiều tiếng khi chạm nhanh. |
| Sao đúng thứ tự/cửa mở | Chuông kính cao vừa, hai sự kiện phân biệt được; sao sai thứ tự là tiếng gõ trầm mềm. |
| Bóng chạm cảm biến | Tiếng giấy cắt cụt, không giật mình; chỉ một lần cho kết quả thua. |
| Thắng | Cụm 2–3 nốt ấm và hạt giấy bay, không đè panel. |

Ưu tiên nguồn **CC0**, không nhầm “royalty-free” với public domain. Ứng viên nhạc là [Heavenly Loop của isaiah658](https://opengameart.org/content/heavenly-loop), trang tác giả ghi CC0, loop liền, dùng khoảng 1–2 phút; sẽ nghe và kiểm file/license tải về trước khi đưa vào game. Ứng viên hiệu ứng là [Kenney UI Audio](https://kenney.nl/assets/ui-audio), [Interface Sounds](https://kenney.nl/assets/interface-sounds), [Impact Sounds](https://kenney.nl/assets/impact-sounds) và [Music Jingles](https://kenney.nl/assets/music-jingles), đều được trang asset ghi CC0; [Kenney xác nhận](https://kenney.nl/support) dùng thương mại và không bắt buộc ghi nguồn. Chỉ đóng gói file đã chọn, ghi URL, tác giả, license, file gốc, phép chỉnh âm/format và checksum trong `docs/ASSETS.md`; kèm giấy phép trong repo. Nếu nhạc ứng viên không hợp khi nghe, chọn một track CC0 khác và ghi lý do, không dùng nhạc chỉ ghi “free”.

`audioplayers` hiện hỗ trợ Android và web theo [pub.dev](https://pub.dev/packages/audioplayers); dùng asset cục bộ và controller trung tâm để không tạo player theo mỗi frame. Preview/menu và gameplay không phát nhiều loop trùng. Kiểm mute, resume, ad, restart app và web first interaction.

## Hiệu ứng và nhịp chuyển cảnh

| Thời điểm | Đề xuất thị giác | Giới hạn |
| --- | --- | --- |
| Home mới mở | Rèm/nền đã có hiện ngay; title và hai nút xuất hiện so le bằng fade + trượt lên 6–10px trong 450–650ms; đèn/cửa ambient chỉ pulse chậm, yếu. | Không che nút hoặc trì hoãn thao tác. Popup lần đầu xuất hiện sau nhịp vào, và không chạy lại khi hot resume. |
| Vào preview/màn chơi | Khung sân khấu sáng dần và panel trượt rất nhẹ trong 250–350ms; đối tượng gameplay, cảm biến và hitbox xuất hiện cùng lúc. | Không animate vị trí bóng/đèn bằng easing; không để frame đầu cho thấy va chạm sai. |
| Sao/cửa | Một nhịp hào quang đúng lúc state đổi; cửa rút theo chuyển động đã có trong painter nhưng biên va chạm vẫn theo `GameAttempt`. | Không báo mở trước khi engine mở. |
| Thắng | Cửa trăng lóe mint nhỏ, 12–20 mảnh giấy vàng/lilac bay từ cửa trong 500–700ms, rồi panel thắng hiện; vẫn khóa điều khiển và lưu kết quả đúng một lần. | “Pháo hoa giấy” nằm trong sân khấu; không chớp cả màn, không che nút. |
| Chạm vật gây thua | Một nhịp viền coral ngắn 150–250ms và **một** `HapticFeedback.mediumImpact` trên Android sau khi lưu kết quả thành công. | Không rung khi hết giờ, sai thứ tự sao, chạm vật chỉ chặn, hoặc callback kết quả lặp. Web không hứa có rung. |

Chế độ hệ thống **giảm chuyển động** bỏ hạt giấy, rung, dịch chuyển/parallax và pulse ambient; vẫn cho biết trạng thái bằng panel/chữ và thay đổi màu tĩnh. Flutter có tín hiệu [`disableAnimations`](https://api.flutter.dev/flutter/widgets/MediaQueryData/disableAnimations.html), nhưng animation custom phải tự tôn trọng tín hiệu này. Haptic dùng API Flutter chính thức [`HapticFeedback.mediumImpact`](https://api.flutter.dev/flutter/services/HapticFeedback/mediumImpact.html). Không để ticker trang trí chạy lúc app nền, pause hoặc âm thanh/hiệu ứng không cần thiết. Tách các lớp repaint nhỏ và đo lại trên Redmi vì đo M6 trước đây đã gần 16,67ms raster lúc kéo; theo [Flutter performance guidance](https://docs.flutter.dev/perf/best-practices), tránh opacity toàn màn và nhiều lớp blur/saveLayer.

## Kiểm chứng để nghiệm thu M5

- UI: so sánh screenshot Android thật 360px và 390px với preview; đèn vẫn kéo tới bốn góc như hiện tại, vùng chạm không đổi, tranh không gây hiểu nhầm vật cản.
- Logic: test âm thanh bật/tắt và save/restart, phát một lần cho thắng/thua, không rung cho timeout/sao sai/vật chặn; pause/background/ad dừng nhạc; reduced motion bỏ hiệu ứng trang trí.
- Build: `flutter analyze`, `flutter test`, `flutter build web`, `flutter build apk --debug` với artifact thật; nghe và xem trực tiếp trên Redmi nếu ADB còn kết nối. Ghi lệnh/kết quả vào `docs/PROGRESS.md` hoặc `docs/QA.md`.
- Performance: đo frame time trên Redmi lúc kéo ở màn 20, lúc thắng và chuyển cảnh; nếu vượt ngân sách 16,67ms ổn định, hạ số hạt/blur hoặc cache nền, không thay hitbox.

## Phần giao người thực hiện sau duyệt

Chọn clip cuối sau khi nghe bằng tai; chỉnh mức âm bằng máy thật; xuất nền bàn không có đèn từ preview, kiểm alpha/crop và kích thước gói; ấn định curve/từng thời lượng trong khoảng trên dựa trên Redmi. Không thêm nút hay cơ chế gameplay ngoài phạm vi M5. Không phát hành công khai.
