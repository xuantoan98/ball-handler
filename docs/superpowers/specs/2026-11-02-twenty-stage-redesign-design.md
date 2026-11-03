# Thiết kế lại 20 màn — Rạp bóng nhỏ

Ngày 02/11/2026. Trạng thái: **chủ sản phẩm đã duyệt tài liệu và ba concept, đang triển khai**. Nguồn: phản hồi sau khi chơi trên điện thoại thật; `docs/PRODUCT.md`, `docs/PLAN.md`, `docs/DESIGN_SYSTEM.md`, `design/Midnight Shadow Theatre Game Board.png`, `design/Whimsical Shadow Theatre UI Kit.png` và màn home v2 đã duyệt.

**Bổ sung sau playtest 03/11/2026:** Chủ sản phẩm yêu cầu các màn sau khó hơn, chớp dọc đi gần mép trên/dưới, thêm kiểu chớp ngang và đổi vị trí cửa. Bản triển khai mới dùng cửa giữa/dưới bên phải ở một số màn, không giữ cố định cửa trên phải như bản nhịp đề xuất dưới đây. Vẫn cần người chơi thử độ khó thực; replay engine chỉ xác minh đường thắng.

Ảnh duyệt: [bốn chapter](twenty-stages-chapter-concept-v1.png) · [Bóng Mơ](bong-mo-character-concept-v1.png) · [bàn kéo đèn](lamp-desk-concept-v2.png). Tạo bằng built-in `image_gen` với home, UI Kit và Game Board làm style reference. Đây là concept, **không phải ảnh production hay hình học va chạm**. Các bục trong ảnh chapter trông như game đi cảnh; sản phẩm thật vẫn là mặt tường phẳng với bóng dịch chuyển bằng phép chiếu. Bàn đèn bên phải trong ảnh nhân vật làm nút mặt trời quá lớn; lấy ảnh bàn kéo đèn v2 làm chuẩn tỷ lệ, để vùng kéo trống và nút nhỏ. Mọi chữ và nút của UI sản phẩm là Flutter thật.

## Ý định

Người chơi phải thấy mỗi màn là một cảnh sân khấu riêng, có thử thách mới dễ nhận ra và độ khó tăng theo những gì đã học. Vùng kéo đèn phải có độ hoàn thiện ngang trang chủ. Bóng Mơ trong game phải cùng nhận diện với nhân vật bé màu mực, mắt kem, vương miện giấy vàng và áo choàng xòe trong `assets/backgrounds/home-stage-v2.png`.

Thành công không chỉ là 20 lời giải tự động. Cần kiểm trên điện thoại thật: người mới hiểu điều khiển, nhận ra vật nào nguy hiểm/vật nào chỉ chắn đường, giải được trong 60 giây với ngón tay, và cảm thấy các màn sau khó hơn mà không bị đọc sai hình.

## Phạm vi và giới hạn

- Thiết kế lại **đủ 20 màn** trong cùng codebase Flutter/Dart Android và web; giữ số màn, tiến độ mở khóa và save hiện tại. Màn đã mở vẫn mở sau cập nhật.
- Giữ mô hình một đèn, một bóng `S = 3P − 2L`, tường logic 360×480, cửa trăng mint, đèn mặt trời vàng, công tắc sao, tối đa 60 giây, thắng khi toàn bộ bóng ở cửa 1 giây; giữ luật lượt và quảng cáo hiện có.
- Cho phép cơ chế mới có kiểm soát theo quyết định của chủ sản phẩm. Không thêm đèn thứ hai, vật lý đi bộ, 3D, puzzle ngẫu nhiên hoặc thao tác đa điểm.
- Ảnh nền chỉ là cảnh; mọi vật cản, công tắc, cửa và vùng đích có hitbox trong dữ liệu màn và hình vẽ phản ánh chính xác hitbox. Không dùng chi tiết trang trí màu coral/mint sáng làm mồi nhử sai.
- 20 cảnh có bản sắc riêng trong bốn chapter, nhưng dùng một bộ frame, HUD, nút và ngôn ngữ màu chung. Không dùng một ảnh chứa cả chữ/nút/vật gameplay làm màn chơi.
- Không công bố, upload store hay thay thông số ad release trong đợt này.

## Hướng đã xét

| Hướng | Được gì | Đổi lại |
| --- | --- | --- |
| **Mỗi chapter dạy một thử thách, sau đó kết hợp dần — đã chọn** | Nhịp học rõ, hình ảnh/chướng ngại thay đổi có lý do, màn 20 tổng kết kỹ năng | Cần mở rộng rules/schema/validator và playtest nhiều hơn |
| Một bộ cơ chế dùng suốt 20 màn, tăng độ khó bằng hình học | Ít rủi ro engine hơn | Dễ lặp lại cảm giác “né thanh đỏ, chạm sao bên trái” hiện tại |
| Thêm nhiều cơ chế độc lập cho từng màn | Mỗi màn bất ngờ | Khó dạy, khó kiểm soát 60 giây và dễ làm hình ảnh nhiễu |

Chủ sản phẩm đã chọn hướng đầu và đồng ý thêm cơ chế mới có kiểm soát. Ba cơ chế dưới đây là **đề xuất thiết kế của người thực hiện**, cần duyệt qua tài liệu/key visual này trước khi code.

## Ngôn ngữ hình ảnh

Mỗi màn là một lát cắt rạp giấy nhiều lớp: rèm nhung, viền vàng chạm, lâu đài xa và chi tiết sân khấu sắc như màn home. Vùng tường vẫn là mặt phẳng tối, ít chi tiết ở hành lang bóng đi qua. Mỗi level có một bố cục cảnh riêng (điểm nhìn, silhouette xa, hoa văn ở mép, màu phụ trong hệ xanh tím), không chỉ đổi thứ tự ba PNG cũ. Cảnh 01–03 cũng được làm lại để chất lượng mở đầu không thấp hơn chapter sau.

Vùng điều khiển là bàn đèn sân khấu: mặt lilac có viền đồng chạm, đường quỹ đạo mảnh, vệt ánh đèn phản hồi theo vị trí, đèn mặt trời nhiều lớp và điểm chạm lớn; khu vực di chuyển thực vẫn là hình chữ nhật x49..341/y694..782. Mũi tên hoặc đường đi chỉ là hướng dẫn khi cần, không giả rằng đèn bị khóa một trục. Bỏ những nét trang trí có thể bị hiểu là waypoint bắt buộc.

Bóng Mơ lấy **tỷ lệ và tính cách** từ hình home: đầu tròn hơi lệch, mắt kem lớn, vương miện vàng ba chóp lệch, thân áo choàng xòe thành những lớp giấy nhỏ, hai tay và chân ngắn. Sprite gameplay dựng lại riêng, nền trong suốt; không cắt trực tiếp nhân vật từ tranh home vì dính ánh sáng/cảnh nền. Silhouette nằm trong hitbox 36×54 đang dùng hoặc hitbox được đổi đồng bộ với hình vẽ và validator. Khi đứng yên có nhịp nổi nhẹ; khi kéo đèn, nghiêng/vẫy ít và **vị trí va chạm luôn bám theo bóng hiển thị**. Bóng Mơ ở dải ngăn dùng cùng sprite và màu, không thành nhân vật thứ hai.

## Ba thử thách mới có kiểm soát

1. **Đạo cụ chắn bóng**: vật thể tối viền đồng, chặn đường nhưng không gây thua. Có thể là tủ sách, đảo đá giấy, bánh răng đứng yên, cột sân khấu; hình và hitbox là hợp của các rect rõ ràng. Khi kéo đèn vào nó, bóng dừng ở mép. Người chơi học phân biệt “chạm là dừng” với cảm biến coral “chạm là thua”.
2. **Màn chớp chuyển động**: một cảm biến nguy hiểm chạy theo quỹ đạo ngắn, có sọc coral và nhịp báo trước nhìn được. **Chạm là thua**, kể cả khi bóng đứng yên và màn chớp đi tới; không có biến thể chớp chỉ dừng bóng. Chỉ xuất hiện sau khi người chơi đã hiểu vật chắn tĩnh. Pause/background dừng cùng đồng hồ 60 giây. Quỹ đạo và pha đầu cố định để replay và reset có kết quả lặp lại. Không đặt nhiều màn chớp chồng nhau ở level đầu.
3. **Sao giữ cửa có thời hạn**: công tắc mint bật theo thứ tự như cũ, nhưng ở màn được đánh dấu, sau sao cuối người chơi có một khoảng thời gian rộng để đi qua cửa trước khi nó khép lại. UI hiện vòng đếm ngay trên cửa/công tắc. Khi hết hạn, **toàn bộ chuỗi sao của cửa đó** trở về OFF. Cửa khép khi bóng không còn chồng hitbox cửa; nếu đang chồng hitbox cửa, cửa chờ bóng rời mép rồi mới khép để không nhốt bóng vào vật cản. Nếu bóng đã nằm trọn trong cửa trăng và đang giữ 1 giây, cửa duy trì mở tới khi xét thắng hoặc bóng rời cửa. Người chơi có thể bật lại chuỗi sao trong cùng ván nếu vẫn còn thời gian tổng. Chỉ dùng từ chapter Thư viện đêm; không buộc người chơi nhớ thời gian ẩn. Đây là áp lực cục bộ bên trong đồng hồ ván 60 giây, không thay luật hết giờ.

Các chapter dùng vật cản có silhouette khác nhau nhưng cùng ngữ nghĩa: coral có sọc/cảnh báo là thua; vật mực viền đồng là dừng; cửa chắn có khóa là dừng tới khi sao bật; mint là tương tác/đích. Hình dạng trang trí phức tạp không được tạo mép collision vô hình. Nếu chuyển động của màn chớp làm mức khó quá cao trên máy, giảm vận tốc/khoảng chạy trong dữ liệu màn, không tắt kiểm tra va chạm.

## Nhịp 20 màn

Mỗi dòng nêu ý tưởng puzzle để author và thử; chưa phải tọa độ production hay tuyên bố đã giải được. Tọa độ/lời giải sẽ được chốt bằng editor và replay, sau đó thử trên máy.

| Màn | Cảnh riêng / kỹ năng chính | Bước tăng độ khó |
| --- | --- | --- |
| 01 | Mở rèm lâu đài; đèn trái → bóng phải → cửa | Học phép chiếu, đường rộng |
| 02 | Vườn gai hổ phách; cảm biến coral ngang ngắn | Học né bằng một góc cua |
| 03 | Tháp đồng hồ; một sao mở cửa có khóa | Học thứ tự sao trước cửa |
| 04 | Vườn trăng, gốc cây giấy; một đạo cụ chắn bóng | Học vật chắn khác vùng thua |
| 05 | Hồ lá tím; hai đảo giấy tạo lối chữ S rộng | Hai lần đổi hướng, chưa có thời gian động |
| 06 | Nhà kính trăng; vật chắn và cảm biến coral tách nhau | Chọn lối an toàn, phân biệt phản hồi |
| 07 | Cổng hoa đêm; ba cụm chắn tạo hành lang vòng | Bài tổng kết đường đi, khoảng hở ngón tay đủ rộng |
| 08 | Xưởng sao mở cửa; màn chớp chuyển động một trục | Quan sát nhịp, đi qua một khoảng mở lớn |
| 09 | Bàn máy đồng; màn chớp và đạo cụ tĩnh | Canh nhịp rồi rẽ, cửa vẫn trực tiếp |
| 10 | Ròng rọc giấy; một sao đặt sau khoảng chớp | Lấy sao đúng lúc, có lối chờ an toàn |
| 11 | Đồng hồ thiên văn; hai sao theo thứ tự, một chớp | Lập đường đi tránh phải qua nhịp hai lần |
| 12 | Xưởng sao đêm; hai chớp lệch nhịp, hai sao | Tổng kết nhịp; chỗ đứng chờ rõ ràng |
| 13 | Thư viện mở sách; sao có thời hạn, đường thẳng rộng | Học đếm cửa cục bộ trước khi có vật cản |
| 14 | Hành lang sách; sao có thời hạn sau góc cua | Chọn lộ trình ngắn, không đòi kéo cực nhanh |
| 15 | Phòng bản đồ; hai sao thứ tự + vật chắn, sao cuối có hạn | Lập thứ tự và vị trí trước khi bật sao cuối |
| 16 | Gác chuông giấy; một chớp + sao có hạn | Chờ nhịp trước, kích hoạt rồi đi |
| 17 | Sân khấu thiên hà mở màn; vật chắn, coral và chớp | Nhận dạng ba loại nguy hiểm/cản trong một cảnh |
| 18 | Quỹ đạo trăng; hai sao + chớp + cửa có hạn | Lên đường đi và canh nhịp; chỗ nghỉ vẫn có |
| 19 | Rèm cuối; ba sao, hai đường vòng và cửa có hạn | Kết hợp thứ tự với lựa chọn đường |
| 20 | Đại cảnh Rạp bóng nhỏ; các cơ chế đã học, cửa trăng trung tâm | Kết màn bằng một chuỗi rõ ràng, không thêm luật bất ngờ |

Màn 01–03 là **khúc mở màn**, một nhóm art thứ năm lấy trực tiếp bố cục Game Board nhưng nâng độ hoàn thiện lên mức home; 04–07 là Vườn trăng; 08–12 là Xưởng sao; 13–16 là Thư viện đêm; 17–20 là Sân khấu thiên hà. Nhóm mở màn cần key visual riêng trước khi thay asset 01–03. Bốn chapter chính có một key visual duyệt riêng và các biến thể cảnh cho từng màn. Chỉ số cân bằng sau khi author: số góc cua, số sao, số lần phải đợi nhịp, khoảng hở nhỏ nhất và thời gian giải bằng kéo tay. Đặt mục tiêu lời giải tham chiếu có dư thời gian trong 60 giây; không tuyên bố một màn “khó hơn” chỉ vì có thêm rect.

## Cấu trúc triển khai sau duyệt

- Mở rộng `Level`/JSON schema có phiên bản, giữ decode catalog cũ cho editor; tách danh sách vật chắn, màn chớp, cấu hình sao có hạn. `GameAttempt` là nguồn chân lý cho trạng thái, clock, collision và timeout. Painter chỉ đọc state; không tự chạy vật cản bằng animation riêng.
- Gate theo yêu cầu sao của từng gate thay cho giả định hiện tại “mọi sao mở mọi gate”, nhưng không làm sai màn cũ. Chuyển động kiểm tra swept collision cả bóng lẫn màn chớp. Có kiểm tra điểm chờ và lối đi khi trạng thái cửa thay đổi.
- 20 màn được author thủ công trong catalog; mỗi màn có waypoint và nhịp chờ cho replay xác định. Validator kiểm tra spawn, biên, va chạm, đường giải và timeout; thêm chỉ số độ khó để phát hiện các màn gần trùng bố cục. Export JSON dùng cùng dữ liệu chạy Android/web.
- Asset nền: 20 tranh hậu cảnh/cảnh riêng theo bốn chapter, tách khỏi gameplay. Cùng bộ frame/desk/HUD và Bóng Mơ. Chỉ asset đã duyệt mới đi vào `assets/`; lưu prompt, nguồn và phiên bản trong `docs/ASSETS.md`.
- Soát mỗi màn trên viewport 360×800 và 390×844; thử kéo một ngón trên Android thật. Ghi các màn thắng bằng replay và màn đã được người thật giải, không đánh đồng hai loại bằng chứng.

## Cổng duyệt

Trước khi sửa gameplay/UI hoặc đưa ảnh vào build: chủ sản phẩm duyệt tài liệu này, concept Bóng Mơ/bàn đèn và hướng bốn chapter. Key visual khúc mở màn và key visual production của từng chapter sẽ được duyệt trước khi đưa asset tương ứng vào build. Sau khi duyệt, lập plan triển khai, làm lần lượt nhóm 01–03, 04–07, 08–12, 13–16, 17–20; mỗi nhóm chạy validator và kiểm trên máy. Nếu hình/nhịp cơ chế không đạt ở nhóm đầu, sửa hệ thống trước khi nhân ra 20 màn.

Các quyết định còn để người thực hiện sau khi duyệt: tọa độ cụ thể, vận tốc/chu kỳ chớp, thời hạn sao, kích thước asset theo bộ nhớ máy và cách cắt foreground; tất cả phải đáp ứng 60 giây, vùng chạm, hitbox nhìn thấy và kiểm thử nêu trên.

## Nguồn concept và prompt

Built-in `image_gen`, 02/11/2026; ba PNG trong cùng thư mục với tài liệu này. Prompt chapter yêu cầu bốn sân khấu mobile đặt cạnh nhau, lần lượt Vườn trăng, Xưởng sao, Thư viện đêm, Sân khấu thiên hà; tham chiếu home/UI Kit/Game Board; giấy cắt xanh tím, viền vàng, cửa mint, Bóng Mơ và bàn lilac chung; đạo cụ tối, chớp chuyển động, sao có hạn; không chữ hoặc watermark. Prompt nhân vật yêu cầu tấm hai cột: Bóng Mơ bám home ở nhiều biểu cảm trong silhouette dọc 2:3; cột phải thử chất liệu bàn đèn. Prompt bàn v2 yêu cầu riêng dải điều khiển ngang, mặt lilac trống ít nhất 80% chiều rộng, mặt trời vàng nhỏ khoảng 15%, chi tiết đồng chỉ ở viền, không chữ hoặc vật che vùng kéo. File concept là bản để duyệt hướng; trước khi sản xuất asset từng màn phải viết prompt riêng theo bố cục gameplay đã xác minh.
