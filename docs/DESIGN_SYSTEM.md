# RẠP BÓNG NHỎ — Chuẩn thiết kế thống nhất

Phiên bản: 1.1 · Ngày: 21/10/2026
Áp dụng: tất cả màn chơi, màn chức năng, dialog, asset và bản triển khai của game Người điều khiển bóng.

**Ảnh chuẩn do chủ sản phẩm cung cấp:** [`design/Midnight Shadow Theatre Game Board.png`](../design/Midnight%20Shadow%20Theatre%20Game%20Board.png). Ba màn trong ảnh là tham chiếu nhận diện và bố cục cho toàn dự án. Không coi ảnh tĩnh là dữ liệu va chạm, đường giải hay sprite sheet sẵn sàng dùng trong game.

**Bộ component chuẩn mới:** [`design/Whimsical Shadow Theatre UI Kit.png`](../design/Whimsical%20Shadow%20Theatre%20UI%20Kit.png). Dùng ảnh này cho kiểu nút, chữ, trạng thái, khung popup và họa tiết điều khiển trên toàn hệ thống. Màn chơi và hình học gameplay vẫn theo ảnh Game Board cùng dữ liệu trong code. Xem `docs/UI_KIT_IMPLEMENTATION.md` để biết các component đã có trong M2.

## 1. Vai trò và mức độ chốt

Người dùng đã chấp nhận hướng mỹ thuật của bản redesign “Rạp bóng nhỏ”: sân khấu giấy huyền ảo, nền xanh tím, ánh vàng, nhân vật bóng đội vương miện và cửa trăng xanh ngọc. Tài liệu này chuyển hướng đó thành quy tắc dùng chung để AI thiết kế các màn tiếp theo.

Màu HEX, kích thước, font, thời lượng chuyển động và theme màn 4–20 dưới đây là thông số chuẩn hóa đề xuất v1, không phải thông số đo chính xác từ ảnh hay từng chi tiết đã được người dùng duyệt riêng. Áp dụng thống nhất khi dựng bản tiếp theo; thay đổi có chủ đích phải cập nhật phiên bản tài liệu.

Đây là đặc tả thiết kế, không phải yêu cầu triển khai code ngay. Các màn mới cần được duyệt design trước khi thực thi theo quy trình của chủ sản phẩm.

### Thứ tự ưu tiên khi có mâu thuẫn

1. Chỉ đạo mới nhất của chủ sản phẩm.
2. Luật gameplay đã chốt trong PRODUCT.md/PLAN.md: va chạm, lượt, công tắc, thắng/thua.
3. Tài liệu DESIGN_SYSTEM này: màu, vai trò thị giác, bố cục, component.
4. Ảnh redesign được duyệt: cảm hứng chất liệu và không khí.
5. Sáng tạo bổ sung của AI.

Không sao chép sai lệch hình học hoặc chữ lỗi trong ảnh mockup. Không thay luật chơi để vừa với tranh trang trí. Nếu cơ chế mới chưa có trong đặc tả sản phẩm, ghi là đề xuất; không tự thêm bằng cách vẽ một vật thể mới.

## 2. Ý tưởng thương hiệu

**Tên làm việc:** Rạp bóng nhỏ.
**Câu mô tả:** “Một ngọn đèn. Cả thế giới chuyển động.”
**Cảm giác:** kỳ diệu, tò mò, ấm áp, tinh nghịch; có chiều sâu nhưng dễ tiếp cận.
**Ngôn ngữ hình ảnh:** rạp múa bóng thu nhỏ, giấy cắt nhiều lớp, khung sân khấu thủ công, điểm sáng ấm trên nền tối.

Ba dấu hiệu nhận diện luôn giữ:

- Nhân vật Bóng Mơ nhỏ với hai mắt kem và vương miện giấy lệch nhẹ.
- Đèn vàng hình mặt trời là vật điều khiển chính.
- Cửa trăng xanh ngọc là đích đến.

Không biến thành kinh dị, cyberpunk, game platformer đi cảnh hoặc một UI dashboard. Không quay lại tường gạch màu be làm phong cách chủ đạo.

## 3. Hệ màu — dùng theo vai trò

Các HEX là token gốc; dùng opacity cho lớp phủ và ánh sáng. Không tự tạo một bảng màu độc lập cho mỗi màn.

| Token | HEX | Vai trò |
| --- | --- | --- |
| color.bg.deep | #10152F | Nền app, vùng ngoài sân khấu |
| color.bg.ink | #191C42 | Panel tối, dialog |
| color.stage.base | #253665 | Mặt tường nhận bóng |
| color.stage.plum | #3A2855 | Biến thể nền tím, lớp hậu cảnh |
| color.frame.base | #263052 | Khung sân khấu |
| color.frame.edge | #53628C | Cạnh giấy bắt sáng |
| color.shadow.body | #10121D | Thân bóng, silhouette |
| color.shadow.eyes | #FFF1C9 | Mắt nhân vật |
| color.light.core | #FFE7A0 | Tâm sáng đèn |
| color.light.main | #FFC65A | Đèn, năng lượng lượt, điểm nhấn chính |
| color.light.edge | #D78C32 | Mép và chiều sâu đèn |
| color.exit.main | #79F2CF | Cửa thoát, mục tiêu |
| color.exit.deep | #174F50 | Lòng cửa |
| color.switch.off | #467B86 | Công tắc chưa kích hoạt |
| color.switch.on | #79F2CF | Công tắc đã kích hoạt |
| color.danger.main | #F4777A | Vùng gây thua |
| color.danger.deep | #9C3F59 | Sọc/viền vùng nguy hiểm |
| color.control.base | #C4B5E0 | Bề mặt vùng kéo đèn |
| color.control.highlight | #E6DCF4 | Điểm bắt sáng vùng kéo |
| color.text.primary | #FFF3D8 | Chữ trên nền tối |
| color.text.secondary | #C4C8E1 | Chữ phụ trên nền tối |
| color.text.onLight | #181B36 | Chữ trên nền sáng |
| color.disabled | #72758A | Điều khiển vô hiệu hóa, đi kèm giảm sáng |

### Quy tắc phân bổ

- Xanh đêm/tím chiếm khoảng 65–75% diện tích tổng thể; vàng/lilac/mint làm điểm nhấn.
- Coral dành cho nguy hiểm hoặc cảnh báo. Hoa trang trí đỏ trong ảnh tham chiếu cần chuyển sang tím hồng trầm, giảm bão hòa để không bị hiểu là vật gây thua.
- Vàng sáng tập trung vào đèn và lượt; không đặt thêm nút tròn vàng lớn trong vùng chơi.
- Mint sáng ưu tiên cửa và công tắc hoạt động; ánh mint trang trí phải yếu hơn rõ rệt.
- Màu chữ phải được đo tương phản trên nền thực tế. Mục tiêu thiết kế: ít nhất 4.5:1 cho chữ nhỏ và 3:1 cho chữ lớn/biểu tượng thiết yếu; chưa được coi là pass khi chưa đo.
- Không dùng màu làm tín hiệu duy nhất: nguy hiểm có sọc và tam giác cảnh báo; cửa có hình trăng; công tắc có ngôi sao; cửa khóa có biểu tượng khóa.

## 4. Chất liệu, ánh sáng và chiều sâu

### Chất liệu

Giấy cắt và bìa mỏng, cạnh rõ, texture hạt mịn nhẹ. Chỉ tạo chiều sâu ở khung, lá, rèm, bánh răng và panel. Vùng chơi là mặt phẳng chiếu bóng, không phải căn phòng 3D.

### Ba lớp hình ảnh

1. Hậu cảnh: gradient xanh tím, vân giấy nhẹ, cảnh xa giảm tương phản.
2. Gameplay: bóng, cửa, cảm biến, công tắc và cửa chắn; đường bao sắc nét.
3. Tiền cảnh: khung sân khấu, rèm, con rối và vùng điều khiển; không đè vật thể gameplay.

### Ánh sáng

- Một nguồn sáng chính màu vàng ấm; điểm glow mint tại cửa và công tắc bật.
- Tránh phủ toàn bộ sân khấu bằng vùng vàng khiến bóng và vật cản khó đọc.
- Vệt sáng trong mockup là hiệu ứng mỹ thuật; nếu không biểu diễn đúng mô hình chiếu thì phải là ambient, không giả một tia sáng chính xác dẫn sai về điều khiển.
- Nhân vật là bóng phẳng, không có bóng đổ chân hay khối 3D làm người chơi tưởng nhân vật đứng trên sàn.
- Glow không lấn qua biên va chạm; biên có hiệu lực phải nhận biết được khi tắt hiệu ứng.

## 5. Bố cục dùng chung cho màn chơi

### Khung tham chiếu

Thiết kế mobile dọc trên artboard 390 × 844, chưa tính vùng an toàn hệ thống. Đây là khung UI; tọa độ mô phỏng game giữ riêng theo đặc tả gameplay, không sửa tỉ lệ vật lý theo màn hình.

| Vùng | Tỷ lệ chiều cao tham chiếu | Nội dung |
| --- | --- | --- |
| HUD | 8% | Quay lại, tên/số màn, lượt, tạm dừng |
| Sân khấu | 62% | Vùng chiếu bóng và khung |
| Dải Bóng Mơ | 6% | Vật tạo bóng cố định |
| Điều khiển | 24% | Vùng kéo đèn, nhãn, đặt lại |

Tỷ lệ có thể co giãn nhẹ khi cần đọc chữ, nhưng thứ tự và vị trí chức năng phải giữ. Safe area cộng ngoài phần nội dung; không đặt nút vào camera/notch hoặc thanh thao tác hệ thống.

### Vị trí cố định

- Quay lại: trên trái. Tạm dừng: trên phải.
- Nhãn màn: trong HUD, không đặt tên dài giữa vùng gameplay.
- Lượt: ba biểu tượng đèn và số x/3; lúc đang chơi mặc định hiển thị 2/3 sau khi bắt đầu từ 3 lượt.
- Đặt lại: góc trên phải vùng điều khiển, chỉ reset thao tác theo luật phiên hiện hành; không âm thầm tạo ván mới hay trừ thêm lượt.
- Bóng Mơ: giữa dải ngăn, không xuất hiện như một nhân vật thứ hai có thể di chuyển.
- Vùng kéo đèn: luôn phía dưới, tách khỏi vùng chiếu bóng.

### Khoảng trống và vùng chạm

- Spacing dùng thang 4, 8, 12, 16, 24, 32.
- Margin ngoài tối thiểu 12 đơn vị; khoảng cách nhóm UI tối thiểu 8.
- Vùng chạm tối thiểu 44 × 44 đơn vị; icon có thể nhỏ hơn vùng chạm.
- Bàn kéo đèn rộng ít nhất khoảng 80% nội dung. Tay cầm nhìn rõ, vùng bắt đầu kéo ít nhất 48 × 48.
- Không đặt lá, rèm hoặc bụi sáng trên hành lang điều khiển bóng.
- Ở viewport hẹp, bỏ trang trí trước khi giảm vùng chạm hoặc chữ.

### Responsive

- Desktop: giữ sân khấu dọc ở giữa, nền ngoài mở rộng; không kéo giãn ngang game.
- Mobile ngang: ưu tiên gợi ý xoay dọc, giữ trạng thái phiên và tạm dừng mô phỏng; chưa tự đổi sang bố cục ngang mới.
- Tỷ lệ màn hình dài/ngắn: scale/letterbox vùng gameplay thống nhất; dành chiều cao tối thiểu cho vùng kéo. Không cắt cửa hoặc cảm biến để lấp đầy màn hình.

## 6. Typography và icon

Font đề xuất chuẩn hóa: **Nunito** cho UI và tiêu đề; fallback sans-serif có tiếng Việt. Khi triển khai, xác minh đủ glyph, quyền sử dụng và tải font thực tế. Không thêm font thứ hai theo từng chapter.

| Vai trò | Cỡ tham chiếu | Weight |
| --- | --- | --- |
| Tên game trên trang chủ | 28–32 | 800 |
| Tiêu đề dialog | 22–24 | 800 |
| Số/tên màn | 16–18 | 700 |
| Nút và nội dung | 16 | 700 / 600 |
| Chú thích | 14 | 600 |

Không viết cả câu hướng dẫn IN HOA. Copy ngắn, có dấu, động từ rõ: “Kéo đèn”, “Tiếp tục”, “Thử lại”, “Nhận +1 lượt”.

Icon dùng nét bo tròn đồng nhất, stroke khoảng 2 đơn vị ở kích thước 24. Phân biệt icon trang trí và icon chức năng. Biểu tượng mặt trời của đèn và ngôi sao của công tắc không được dùng thay cho nhau.

## 7. Thư viện thành phần bắt buộc tái sử dụng

### Nhân vật bóng

- Silhouette chữ nhật mềm, hai mắt kem, vương miện nhỏ ba chóp lệch nhẹ.
- Giữ cùng tỷ lệ thân, mắt, vương miện giữa các màn.
- Chiều rộng tham chiếu khoảng 8–10% vùng chơi; kích thước thực theo gameplay, không đổi chỉ để hợp bố cục tranh.
- Hộp va chạm phải được thống nhất với engine. Vương miện/tua giấy nằm trong hộp, hoặc chỉ là trang trí ngoài hộp có đường bao thân đủ rõ; chốt một cách cho toàn bộ game.
- Đường bao đứt nét chỉ hiện trong tutorial/gợi ý hoặc chế độ trợ giúp; không dùng đường bao ấy làm biên có hiệu lực lúc có lúc không.

### Đèn điều khiển

Đĩa vàng mặt trời, cạnh đậm, tâm sáng, phản hồi nhấn nhẹ. Vị trí di chuyển phản ánh đúng trạng thái đèn trong game. Không đổi thành cần gạt, joystick hoặc nút bấm ở chapter khác. Mũi tên hai trục chỉ là hướng dẫn, không khóa chuyển động thành một trục.

### Cửa thoát

Cửa hình trăng nằm trong vùng đích hình chữ nhật đủ chứa toàn bộ bóng. Luôn giữ outline vùng đích dễ đọc để hình trăng không làm sai kỳ vọng va chạm.

- Khóa: ánh mờ, có khóa.
- Mở: mint sáng vừa, không chớp liên tục.
- Bóng nằm đủ trong vùng: vòng tiến trình 1 giây.
- Hoàn tất: bóng tan thành hạt giấy nhỏ và chuyển sang kết quả.

### Công tắc

Đĩa nhỏ xanh ngọc, biểu tượng ngôi sao, kích thước nhỏ hơn hoặc khác rõ đèn kéo.

- OFF: tối, vòng rỗng, icon nét.
- ON: sáng, icon đặc, một nhịp sáng xác nhận.
- Nếu cần thứ tự: thêm số 1/2/3 và phản hồi chưa đúng thứ tự.
- Dây nối đi sát mép khi có thể; không cắt đường chơi và không trông như tia laser gây thua.

### Cảm biến nguy hiểm

Vùng coral có sọc chéo và icon cảnh báo. Hình học va chạm chính xác, không thêm gai phát sáng vượt ra ngoài nếu gai không gây thua. Nếu cần trang trí gai, đặt trong biên hoặc vẽ biên hiệu lực rõ.

### Cửa chắn

Tấm chớp xanh đậm có khóa; cửa đóng nhận biết được kể cả trên nền tối. Khi mở, tấm chớp rút lên và không còn cản đường. Biểu diễn phải khớp thời điểm thay đổi collision, không cho hình còn đóng nhưng bóng đi xuyên.

### Nút và panel

- Primary: vàng, chữ mực tối; chỉ một hành động chính trong một dialog.
- Secondary: lilac nhạt, chữ mực tối.
- Tertiary: nền trong/viền sáng, nhãn rõ.
- Destructive/thoát ván: nhãn rõ, không dùng cùng màu sáng ưu tiên với “Tiếp tục”.
- Dialog: nền mực tím, viền giấy lilac mảnh, backdrop tối; không dùng một bộ card trắng phẳng khác phong cách.
- Disabled: giảm bão hòa và có giải thích ngắn; không chỉ giảm opacity tới mức không đọc được.

## 8. Bộ màn chức năng cùng phong cách

| Màn/trạng thái | Thiết kế thống nhất | Nội dung thiết yếu |
| --- | --- | --- |
| Trang chủ | Sân khấu đóng rèm hé sáng, linh vật và cửa trăng | Chơi, chọn màn, lượt, cài đặt |
| Chọn màn | Vé xem kịch đánh số, chapter như một màn sân khấu | Đã mở, đang chọn, hoàn thành, bị khóa |
| Preview màn | Sân khấu tĩnh, overlay nhỏ | Mục tiêu ngắn, “Bắt đầu” |
| Tạm dừng | Panel giấy trên nền sân khấu tối | Tiếp tục, âm thanh, về chọn màn |
| Thắng | Cửa trăng sáng, confetti giấy tiết chế | Hoàn thành, màn tiếp theo, số lượt hiện tại |
| Thua | Linh vật phản ứng buồn nhẹ, tránh trừng phạt | Lý do ngắn, thử lại, về chọn màn |
| Hết lượt | Ba đèn tắt và thời gian hồi | “Nhận +1 lượt”, thời gian hồi, quay lại |
| Quảng cáo mock | Panel cùng phong cách, nhãn rõ | “Quảng cáo mô phỏng”, tiến trình, đóng |
| Đã nhận lượt | Một đèn sáng thêm, số lượt cập nhật | “Đã nhận +1 lượt” |
| Không nhận được lượt | Panel cảnh báo nhẹ | Đóng sớm/lỗi tải, thử lại khi thích hợp |
| Cài đặt | Panel tối, công tắc lilac/mint | Âm thanh, giảm chuyển động, trợ giúp |

Không vẽ nút “Xem quảng cáo” như một đồng xu mua hàng. Không vẽ thắng/thua như mặc định sẽ tự chuyển màn hoặc tự trừ lượt. Khi đầy 3 lượt, nhận thưởng bị vô hiệu hóa với nhãn “Lượt đã đầy”. Cơ chế hồi/thưởng vẫn theo đặc tả sản phẩm.

## 9. Quy tắc mở rộng màn 4–20

### Những thứ bất biến

HUD, vị trí điều khiển, nhân vật, ngôn ngữ màu chức năng, cửa trăng, đèn mặt trời, tỷ lệ UI, typography và cách phản hồi.

### Những thứ được thay đổi

Bố trí puzzle; hậu cảnh; họa tiết viền; màu nền phụ trong họ xanh tím; phụ kiện trang trí chapter; tên màn; số lượng/thứ tự vật thể đã được luật gameplay cho phép.

Không thay toàn bộ frame/đèn/HUD cho một màn mới. Mỗi màn chỉ thêm một điểm nhấn môi trường lớn; tránh vừa tăng độ khó vừa tăng nhiễu hình ảnh.

### Chapter đề xuất

| Màn | Chủ đề | Hậu cảnh/viền | Điểm nhấn được phép | Điều giữ nguyên |
| --- | --- | --- | --- | --- |
| 01 | Đánh thức ánh sáng | Rèm giấy, lâu đài xa, ngôi sao | Spotlight vàng | Toàn bộ core UI |
| 02 | Qua miền gai đỏ | Vườn lá tím ở mép | Cảm biến coral có sọc | Toàn bộ core UI |
| 03 | Chìa khóa sân khấu | Bánh răng và dây sao ở viền | Công tắc sao, cửa chắn | Toàn bộ core UI |
| 04–07 | Vườn trăng | Lá giấy, cánh hoa tím trầm, đồi xa | Một cụm hoa hoặc trăng trang trí nhỏ | Màu chức năng và bố cục |
| 08–12 | Xưởng sao | Bánh răng tĩnh, ròng rọc ở khung | Chòm sao nối điểm, đồng thau trầm | Công tắc vẫn là sao mint |
| 13–16 | Thư viện đêm | Sách giấy và trang gấp ở viền | Dải giấy hình quỹ đạo ở hậu cảnh | Cửa thoát vẫn là trăng |
| 17–20 | Sân khấu thiên hà | Nhiều lớp rèm tím, chòm sao xa | Ánh mint/vàng tiết chế | Không đổi giao diện thành sci-fi |

Đây là hướng mỹ thuật, không tự cho phép cơ chế quạt, dịch chuyển, nhiều đèn hoặc đổi trọng lực. Trước mỗi nhóm màn cần một key visual chapter để duyệt; không cần thiết kế lại toàn bộ hệ thống.

## 10. Chuyển động và phản hồi

Các giá trị sau là mục tiêu thiết kế để tinh chỉnh trên thiết bị:

| Tương tác | Thời lượng gợi ý | Cách thể hiện |
| --- | --- | --- |
| Nhấn nút | 80–120ms | Scale nhẹ 1 → 0.97 |
| Công tắc bật | 150–250ms | Icon đầy và một pulse nhỏ |
| Cửa chắn mở | 250–400ms | Rút tấm chớp, phản ánh collision đúng |
| Giữ trong cửa thoát | 1 giây theo gameplay | Vòng tiến trình rõ, rời cửa thì reset |
| Thắng | 400–700ms | Giấy sáng bay nhẹ, rồi panel |
| Thua | 150–250ms | Một nhịp coral và biểu cảm, không rung mạnh |
| Nhận lượt | 250–400ms | Đèn HUD sáng thêm, số thay đổi |

Không làm bóng trễ theo đèn bằng animation easing nếu điều đó khiến hình ảnh lệch va chạm. Khi giảm chuyển động: bỏ rung/parallax/confetti, giữ thay đổi trạng thái và tiến trình cần thiết. Không nhấp nháy nhanh, không tự chạy quảng cáo mô phỏng trong cảnh gameplay.

## 11. Tách mỹ thuật khỏi luật chơi

Mỗi vật thể trong design phải được phân loại:

| Loại | Có va chạm/tương tác? | Yêu cầu |
| --- | --- | --- |
| Gameplay object | Theo rules | Bounds và state trong dữ liệu màn |
| UI control | Có input | Vùng chạm, trạng thái, nhãn |
| Ambient decoration | Không | Ngoài hành lang, độ tương phản thấp |
| Lighting effect | Không trực tiếp | Không làm sai nhận thức vật cản |
| Tutorial overlay | Theo UI | Không chặn thao tác cần làm |

Bản artwork không quyết định collision. Cần một overlay kỹ thuật riêng khi kiểm tra, thể hiện bounds vùng bóng, cửa, vật cản và đường giải. Overlay không xuất hiện trong ảnh marketing hoặc gameplay bình thường.

Màn mới phải có đường đi đủ cho toàn bộ bóng, không chỉ điểm giữa. Ảnh đẹp chưa chứng minh màn giải được; tính khả thi do prototype kiểm chứng.

## 12. Hướng dẫn asset và bàn giao

### Khi dự án bắt đầu triển khai

Tạo token dùng chung trước, sau đó component; tránh hardcode màu rải rác trong từng scene. Các nhóm đề xuất: colors, spacing, typography, radii, motion, effects. Không bắt buộc công nghệ cụ thể trong tài liệu này.

Tên asset theo cấu trúc:

- character/shadow-idle, shadow-win, shadow-fail.
- controls/lamp-idle, lamp-pressed.
- gameplay/exit-locked, exit-open, switch-off, switch-on, gate-closed, gate-open.
- chapters/moon-garden, star-workshop, night-library, cosmic-stage.
- ui/button-primary, dialog-frame, energy-on, energy-off.

Tên file có version khi sửa nguồn; ứng dụng tham chiếu bản đã chọn, không chứa nhiều biến thể gần giống gây dùng nhầm.

### Quy cách xuất

- Tách background, khung tiền cảnh, gameplay sprite và UI. Không dùng một ảnh toàn màn làm bản triển khai tương tác.
- Asset động có alpha thật; viền không dính nền đen/trắng.
- Giữ cùng tỉ lệ và điểm neo giữa các state của một object.
- Texture hỗ trợ màn hình mật độ cao; lựa chọn kích thước xuất theo diện tích hiển thị thực và ngân sách bộ nhớ, không mặc định mọi asset đều 4K.
- Nhãn chữ là text thật trong sản phẩm để sửa, dịch và scale; chữ trong ảnh mockup chỉ dùng duyệt hình ảnh.
- Lưu nguồn, quyền sử dụng, prompt tạo và phiên bản được duyệt. Không dùng tài nguyên của game khác.

## 13. Quy trình AI thiết kế màn mới

1. Đọc tài liệu này, PRODUCT.md/PLAN.md và mẫu màn đã duyệt trong ngữ cảnh hiện có.
2. Xác định đang thiết kế màn chơi, màn chức năng hay chapter mới.
3. Ghi một brief ngắn: mục tiêu, chapter, đối tượng tương tác, vị trí chức năng cố định.
4. Lập layout gameplay trước khi thêm cảnh. Giữ đường đi, vùng đích và vùng kéo đủ rộng.
5. Dùng đúng token và component. Chỉ thay phần môi trường được phép.
6. Thiết kế ảnh preview có thể duyệt; khi công cụ hỗ trợ ảnh tham chiếu, đính kèm ảnh redesign được chấp nhận làm style reference. Không giả vờ đã nhìn thấy ảnh nếu chưa được cung cấp.
7. Tự soát bằng checklist ở mục 16, chỉ rõ phần chưa xác minh.
8. Trình người dùng duyệt. Chưa duyệt thì không triển khai code màn mới theo design ấy.
9. Sau khi duyệt, ghi phiên bản và những thay đổi vào nhật ký design.

Nếu thiếu ảnh tham chiếu, có thể dựng draft từ token nhưng phải ghi “dựa trên đặc tả chữ, chưa đối chiếu ảnh gốc”. Không tự tạo lại logo, nhân vật hay vùng điều khiển để bù thiếu reference.

## 14. Prompt giao AI — thiết kế màn chơi tiếp theo

Sao chép phần dưới, điền các trường trong ngoặc vuông:

```text
Bạn là game UI/UX designer của Rạp bóng nhỏ.

Nguồn bắt buộc:
- docs/DESIGN_SYSTEM.md là chuẩn thiết kế.
- PRODUCT.md/PLAN.md là chuẩn gameplay.
- Ảnh redesign đã duyệt được đính kèm là style reference, không phải layout bắt buộc cho mọi màn.

Nhiệm vụ: thiết kế [MÀN SỐ/TÊN] thuộc chapter [CHAPTER].
Mục tiêu gameplay: [MỤC TIÊU].
Đối tượng tương tác đã được phép: [DANH SÁCH].
Trạng thái cần thể hiện: [PREVIEW / PLAYING / WIN / FAIL].
Thiết bị: mobile dọc 390 × 844, có phương án viewport 360px.

Giữ nguyên: nhân vật bóng đội vương miện, cửa trăng mint, đèn mặt trời vàng,
HUD trên cùng, con rối ở dải ngăn, bàn kéo lilac phía dưới, kiểu giấy cắt nhiều lớp.
Dùng chính xác vai trò màu và component trong DESIGN_SYSTEM.
Được thay: bố cục puzzle và trang trí chapter ở mép.
Không thêm cơ chế, nút, tài nguyên, nhân vật hoặc màu chức năng mới.

Trước khi tạo ảnh, nêu ngắn mục tiêu thị giác, component tái sử dụng và các thay đổi.
Tạo một màn lớn dễ đọc, không mockup điện thoại nghiêng, không quảng cáo banner.
Giữ vùng gameplay thoáng; không cho trang trí che hành lang hoặc vật thể tương tác.
Phân biệt rõ vật thể gameplay và trang trí. Không coi ảnh là bằng chứng màn giải được.

Bàn giao: preview, bảng thành phần/state, danh sách token dùng,
phần khác so với màn đã duyệt và checklist PASS / FAIL / NOT VERIFIED.
Chờ người dùng duyệt design trước khi triển khai code.
```

## 15. Prompt giao AI — màn chức năng và kiểm tra tính thống nhất

### Màn chức năng

```text
Thiết kế [TRANG CHỦ / CHỌN MÀN / TẠM DỪNG / THẮNG / THUA / HẾT LƯỢT / CÀI ĐẶT]
cho Rạp bóng nhỏ theo docs/DESIGN_SYSTEM.md.
Tái sử dụng màu, font, icon, khung giấy, linh vật và component hiện có.
Nội dung/trạng thái: [DỮ LIỆU THỰC TẾ].
Hành động chính: [MỘT HÀNH ĐỘNG]. Hành động phụ: [DANH SÁCH].
Không tạo một phong cách dashboard hoặc bộ component mới.
Thể hiện loading/disabled/error cần thiết theo đúng luật lượt/quảng cáo.
Bàn giao preview mobile, component state và checklist, chờ duyệt trước khi code.
```

### Audit design

```text
Đối chiếu design đính kèm với docs/DESIGN_SYSTEM.md và reference đã duyệt.
Kiểm tra: màu theo vai trò, nhận diện nhân vật/cửa/đèn, bố cục HUD và điều khiển,
chất liệu giấy, mật độ trang trí, khả năng đọc và trạng thái gameplay.
Với mỗi lỗi: nêu vị trí, mức độ, quy tắc bị vi phạm và cách sửa cụ thể.
Phân biệt đánh giá thị giác với số đo chưa kiểm chứng như contrast, hit target,
FPS và đường giải; không tự đánh dấu PASS những phần chưa đo/test.
Chỉ đề xuất thay đổi cần để đồng bộ; không redesign toàn bộ khi không cần.
```

## 16. Checklist duyệt trước khi chốt

### Nhận diện

- [ ] Vẫn nhận ra cùng một game khi đặt cạnh ba màn đầu.
- [ ] Bóng, vương miện, mắt giữ cùng tỷ lệ và phong cách.
- [ ] Cửa trăng mint và đèn mặt trời vàng không bị thay vai trò.
- [ ] Không thêm palette/font/icon style riêng cho màn này.

### Bố cục và khả năng đọc

- [ ] HUD, con rối, điều khiển giữ vị trí chức năng.
- [ ] Sân khấu rộng, không bị trang trí lấn đường đi.
- [ ] Chữ tiếng Việt đầy đủ, không nhỏ hơn chuẩn chỉ để nhét nội dung.
- [ ] Vùng chạm và safe area được kiểm tra ở viewport mục tiêu.
- [ ] Tương phản chữ/icon được đo trên nền thực, không chỉ phán đoán.
- [ ] Nguy hiểm/cửa/công tắc phân biệt được bằng hình và trạng thái ngoài màu.

### Gameplay và state

- [ ] Số lượt phản ánh đúng preview/đang chơi/kết quả.
- [ ] Hình ảnh va chạm và vùng đích không gây hiểu nhầm.
- [ ] Tutorial không đưa đường giải hoàn chỉnh vào mọi màn.
- [ ] Có đủ state liên quan: khóa/mở, bật/tắt, nhấn/disabled, loading/error.
- [ ] Màn mới chưa tự thêm cơ chế ngoài đặc tả.
- [ ] Khả năng giải đã được prototype kiểm tra, hoặc ghi NOT VERIFIED.

### Bàn giao

- [ ] Có brief, preview và bảng state/component.
- [ ] Có token dùng và asset nguồn/version.
- [ ] Có danh sách thay đổi so với mẫu đã duyệt.
- [ ] Người dùng đã duyệt design trước khi code.

Lỗi màu chức năng, nhận diện đối tượng, bố cục điều khiển hoặc vùng tương tác bị che là lỗi chặn duyệt. Trang trí chưa tinh tế có thể chỉnh tiếp nhưng không được che các lỗi đó.

## 17. Đặt tài liệu trong dự án

Đặt file này tại `docs/DESIGN_SYSTEM.md`. Giữ kế hoạch triển khai tại `docs/PLAN.md`.

Thêm chỉ dẫn sau vào AGENTS.md ở gốc dự án, không thay toàn bộ nội dung đã có:

```markdown
## Design — Rạp bóng nhỏ
Trước khi tạo/sửa UI, màn chơi hoặc asset, đọc docs/DESIGN_SYSTEM.md.
Tái sử dụng token và component hiện có; không tự thay palette, nhân vật,
cửa trăng, đèn mặt trời hay bố cục điều khiển.
Luật gameplay tham chiếu PRODUCT.md/PLAN.md; ảnh mockup không thay thế collision data.
Thiết kế màn mới phải có preview và được chủ sản phẩm duyệt trước khi code.
```

## 18. Nhật ký quyết định

| Phiên bản | Quyết định | Trạng thái |
| --- | --- | --- |
| 1.0 | Dùng hướng sân khấu giấy “Rạp bóng nhỏ” thay bản tường be | Hướng mỹ thuật được người dùng chấp nhận |
| 1.0 | Chuẩn hóa token, component, bố cục và quy trình duyệt trong tài liệu này | Đề xuất chuẩn thực thi v1 |
| 1.0 | Chapter màn 4–20 và các màn chức năng | Định hướng, từng design cụ thể chưa được duyệt |
| 1.1 | UI Kit mới làm chuẩn component cho toàn hệ thống | Chủ sản phẩm cung cấp và yêu cầu áp dụng; các component M2 hiện có đã cập nhật |

Mọi thay đổi phá vỡ nhận diện chung phải có quyết định rõ và cập nhật tài liệu trước khi lan sang các màn còn lại. Thay đổi một màn không được âm thầm tạo thành chuẩn mới.
