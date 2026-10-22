# Người điều khiển bóng — Kế hoạch thực thi cùng AI

> Cập nhật 21/10/2026: chủ sản phẩm đã chọn Flutter + Dart cho dự án. Các phần web-first và đề xuất Vite/Phaser bên dưới là giả định lịch sử, không còn là quyết định triển khai. Xem `docs/DECISIONS.md` và `docs/PLAN.md` cho nền tảng đang áp dụng.

Trạng thái: phương án đề xuất v1, chưa phải sản phẩm đã được xây dựng hay kiểm thử.
Mục tiêu: người làm sản phẩm có thể giao từng nhiệm vụ cho AI coding agent, kiểm tra kết quả và tiếp tục cho tới bản phát hành.

## 1. Chốt hướng sản phẩm

Game giải đố 2D, một người chơi, ưu tiên điện thoại màn hình dọc và có thể chơi trên trình duyệt desktop. Người chơi di chuyển nguồn sáng; bóng nhân vật trên tường thay đổi vị trí theo nguồn sáng. Đưa bóng chạm công tắc theo đúng thứ tự, mở cửa và đưa toàn bộ bóng vào cửa trong 1 giây để thắng. Vùng đỏ là cảm biến báo động: bóng chạm vào khi đang chơi sẽ thất bại.

Điểm đáng thử: thao tác kéo đèn tạo ra chuyển động bóng ngược hướng, rồi kết hợp với trình tự công tắc và cửa chắn. Không tuyên bố cơ chế chưa từng xuất hiện; trước khi chốt tên và hình ảnh, cần khảo sát các game bóng/ánh sáng tương tự và ghi lại những điểm khác biệt thực tế.

Giả định khởi đầu: làm web trước để thử gameplay nhanh. Nếu mục tiêu bắt buộc ngay từ đầu là ứng dụng Flutter native, phải quyết định lại nền tảng ở mốc 0; không vừa làm web vừa viết lại bằng Flutter. Việc đưa lên Google Play là một nhánh phát hành sau khi vòng chơi đạt yêu cầu, không phải điều kiện để kiểm chứng ý tưởng.

### Phạm vi v1 đề xuất

- 20 màn thiết kế thủ công; chỉ mở rộng sau khi 3 màn đầu chứng minh cách điều khiển có thể hiểu và đủ hấp dẫn.
- Điều chỉnh sau kiểm thử 22/10/2026 (ưu tiên hơn các dòng M3 cũ bên dưới): tối đa 3 lượt; bắt đầu không trừ; chỉ kết quả thua đã lưu mới trừ 1; thắng reset về 3 lượt cho màn tiếp theo.
- 3 lượt tối đa; bắt đầu một lần thử tiêu hao 1 lượt. (Luật M3 cũ, đã được thay thế bởi điều chỉnh ở trên.)
- Thắng thì lần chơi màn tiếp theo vẫn cần 1 lượt. Thua, chơi lại hoặc bỏ ván đã bắt đầu không hoàn lượt.
- Lượt hồi tự nhiên: 1 lượt mỗi 30 phút, tối đa 3. Đây là cấu hình thử nghiệm, có thể điều chỉnh sau playtest.
- Quảng cáo tự nguyện: hoàn thành một quảng cáo được cộng 1 lượt khi chưa đầy. Bản web thử nghiệm chỉ mô phỏng; tích hợp quảng cáo thật là nhiệm vụ riêng.
- Tiến độ màn, số lượt, cài đặt âm thanh được lưu. Không có tài khoản, bảng xếp hạng hoặc tiền mua vật phẩm trong v1.
- Có hướng dẫn, chọn màn, tạm dừng, kết quả, hết lượt, cài đặt và phần ghi nguồn tài nguyên.

Không đưa vào v1: 3D, vật lý nhân vật đi bộ, bóng mềm vật lý, nhiều nguồn sáng, multiplayer, màn sinh ngẫu nhiên. Các phần này làm tăng chi phí trước khi biết game có vui hay không.

## 2. Đặc tả cơ chế để AI không tự diễn giải

### 2.1 Mô hình ánh sáng

Dùng hình chiếu phối cảnh đơn giản với ba lớp song song:

- Đèn L ở mặt phẳng z = 0.
- Vật tạo bóng P ở z = 1, cố định trong một màn.
- Tường nhận bóng ở z = 3.
- Với mỗi điểm P của vật tạo bóng: S = L + 3 × (P − L) = 3P − 2L, tính riêng cho trục x và y.

Bóng dịch chuyển ngược đèn với hệ số 2; hình dạng có tỷ lệ phóng đại cố định 3 lần. V1 không thay đổi độ sâu đèn nên không thay đổi kích thước bóng. Đây là mô hình hình học phục vụ gameplay, không mô phỏng chiếu sáng 3D đầy đủ.

Vật tạo bóng ban đầu là hình chữ nhật. Hình vẽ nhân vật trang trí nằm trong đường bao này; hiển thị đường bao va chạm nhẹ để người chơi biết chính xác cạnh nào sẽ chạm cảm biến. Không dùng sprite khác hình để rồi va chạm bằng một hộp vô hình lớn hơn.

Vùng kéo đèn và vùng tường phải được phân biệt bằng nhãn, màu và vị trí. Kéo đèn bằng chuột hoặc một ngón tay. Khi chạm điều khiển, giữ độ lệch giữa con trỏ và tay cầm đèn; không teleport đèn tới điểm chạm mới. Bắt pointer cho tới khi thả, hủy thao tác khi nhận pointercancel.

### 2.2 Luật một lần thử

1. Chọn màn: xem bố cục và yêu cầu, chưa mất lượt, chưa di chuyển đèn.
2. Bấm “Bắt đầu · 1 lượt”: kiểm tra còn lượt và không có phiên đang hoạt động; lưu phiên và trừ đúng 1 lượt; mở điều khiển.
3. Bóng chạm công tắc: công tắc được kích hoạt và giữ trạng thái đến hết lần thử. Nếu màn yêu cầu thứ tự, công tắc chưa đến lượt không kích hoạt; phát phản hồi rõ ràng, không xử thua.
4. Cửa chắn chỉ mở khi đủ điều kiện. Bóng chạm cửa chắn đóng sẽ dừng chuyển động đèn ở vị trí hợp lệ gần nhất, không tự đi xuyên.
5. Bóng chạm cảm biến đỏ: thất bại. Nếu đồng thời chạm cửa thoát và vùng đỏ, xử thất bại trước.
6. Khi toàn bộ hộp bóng nằm trong cửa thoát đã mở liên tục 1 giây: thắng. Nếu rời cửa, tiến độ 1 giây về 0.
7. Khi thắng/thua: khóa điều khiển và hiển thị kết quả một lần. Không tự bắt đầu hoặc tự trừ lượt cho màn kế tiếp.
8. Tạm dừng hoặc ứng dụng mất focus: dừng mô phỏng và bộ đếm cửa. Tiếp tục không tiêu hao thêm lượt.
9. Reload khi đang chơi: khôi phục cùng phiên tại điểm bắt đầu màn, không trừ thêm; công tắc và đồng hồ cửa được reset. Phiên kết thúc rồi thì không được khôi phục như phiên đang chơi.

Không có giới hạn thời gian ván ở v1; mục tiêu là giải đố, không ép người chơi phản xạ sớm.

### 2.3 Chống đi xuyên và tính nhất quán

Chuyển động nhanh vẫn phải kiểm tra toàn bộ đường đi của hộp bóng từ vị trí cũ tới mới, không chỉ vị trí cuối frame. Dùng swept AABB hoặc chia bước với giới hạn dựa vào kích thước vật cản nhỏ nhất. Kiểm tra lần lượt các tiếp xúc trên đường đi để không bật công tắc ở phía sau cửa đang đóng. Nếu chia bước, phải có kiểm thử chứng minh không lọt vật cản mỏng ở tốc độ kéo tối đa.

Dùng cùng hình học cho hiển thị, va chạm, gợi ý và kiểm tra đường giải. Tọa độ logic cố định, ví dụ 360 × 480 cho vùng tường; màn hình thật chỉ scale và letterbox. Tỷ lệ đèn/tường chuyển đổi qua một hàm riêng, không lấy pixel CSS làm tọa độ game.

## 3. Quy định lượt và quảng cáo

### 3.1 Trạng thái lượt

Lưu một bản ghi có version: lives, nextRefillAt, activeAttempt, processedRewardIds, progression và settings. Tất cả thao tác thay đổi lượt đi qua một service; UI và scene không được tự sửa số lượt.

- Cài mới: 3 lượt, chưa có mốc hồi.
- Từ 3 xuống 2: đặt nextRefillAt = hiện tại + 30 phút.
- Tiêu thêm lượt khi chưa đầy: giữ nguyên nextRefillAt.
- Khi tới mốc: cộng số lượt hồi theo thời gian đã qua; giới hạn 3; nếu chưa đầy thì tiến mốc theo bội số 30 phút. Đầy thì xóa mốc.
- Quảng cáo cộng lượt khi chưa đầy; giữ lịch hồi cũ nếu vẫn chưa đầy, xóa lịch nếu đã đầy.
- Lượt âm hoặc vượt 3 là dữ liệu không hợp lệ; chuẩn hóa có kiểm soát và ghi lỗi phát triển.
- Khóa nút trong lúc bắt đầu ván hoặc đang yêu cầu quảng cáo. Chống double-click, multi-touch và callback trùng.
- Demo web: chỉ cho một tab hoạt động ghi dữ liệu; tab khác chuyển sang chỉ đọc và hướng dẫn quay lại tab đang chơi. Không dùng localStorage như cơ chế chống gian lận sản phẩm thương mại.

Lưu local là đủ cho bản thử nghiệm không có tiền thật/bảng xếp hạng. Nếu cần đồng bộ thiết bị hoặc bảo vệ phần thưởng, chuyển tính lượt và xác minh thưởng sang backend có thời gian máy chủ; không tuyên bố đồng hồ thiết bị/localStorage chống được chỉnh giờ.

### 3.2 Trạng thái quảng cáo

idle → loading → showing → earned hoặc cancelled/error → idle.

Bản mock hiển thị “Quảng cáo mô phỏng”, tiến trình 5 giây và nút đóng. Chỉ kết thúc đầy đủ mới trả về earned. Có công cụ phát triển mô phỏng lỗi tải, hủy, callback trùng và mất focus; không để công cụ cộng lượt trong build phát hành.

Mỗi lần xem có rewardId duy nhất. earned chỉ cộng một lần cho cùng ID, kể cả callback lặp. Đóng overlay, hết timeout, quay lại app hoặc dismiss không đồng nghĩa earned. Nếu app bị tắt trước khi đã lưu earned, mock không tự tạo phần thưởng khi mở lại.

Hiển thị rõ: “Xem quảng cáo để nhận +1 lượt”; lúc đủ 3 thì vô hiệu hóa và giải thích “Lượt đã đầy”. Hết lượt vẫn cho xem màn đã mở, hướng dẫn và thời gian hồi. Không tự mở quảng cáo, không bắt bấm quảng cáo để chơi tiếp khi lượt tự nhiên đã hồi.

Quảng cáo thật: dùng adapter cho nền tảng đã chọn, đơn vị quảng cáo thử nghiệm khi phát triển, cấp thưởng từ tín hiệu được SDK xác nhận. Nếu thêm SSV thì chống trùng theo transaction ID trên máy chủ và quy định rõ cách hòa giải với trạng thái pending trên thiết bị. Web không tự có AdMob native chỉ vì đã có nút mock.

## 4. Kiến trúc đề xuất

Đề xuất mặc định: TypeScript + Vite + Phaser cho game 2D trên web. Chốt major phiên bản sau khi đọc tài liệu hiện hành, ghi phiên bản thực tế vào lockfile và tránh trộn API giữa các major. UI menu có thể dùng DOM/CSS; không cần thêm React nếu không có nhu cầu cụ thể.

Các module:

- core/geometry: phép chiếu, AABB, kiểm tra đường đi; hàm thuần, độc lập engine.
- core/rules: công tắc, cửa, cảm biến, điều kiện thắng; cập nhật có thứ tự.
- core/attempt: trạng thái phiên chơi, pause, resume, terminal result.
- services/lives: lượt và hồi lượt; nhận Clock được inject để kiểm thử.
- services/rewarded-ads: interface và MockRewardedAds; native adapter tách riêng.
- services/save: lưu bản ghi nguyên khối, schemaVersion, migration, phục hồi dữ liệu lỗi.
- content/levels: dữ liệu màn và đường giải tham chiếu.
- game/scenes: tải game, menu, chọn màn, gameplay, kết quả.
- ui: HUD, dialog, trạng thái nhận lượt, settings.
- tests: unit hình học/rules/service và kiểm tra luồng tích hợp.

Cấu trúc tài liệu trong repository:

- AGENTS.md ở gốc: quy tắc giao việc cho AI.
- docs/PRODUCT.md: đặc tả sản phẩm đã chốt.
- docs/PLAN.md: lộ trình này.
- docs/DECISIONS.md: quyết định kỹ thuật và lý do.
- docs/PROGRESS.md: trạng thái task, bằng chứng, blocker, task tiếp theo.
- docs/QA.md: checklist và kết quả kiểm tra.
- docs/RELEASE.md: build, cấu hình, phát hành, rollback.

Đừng đưa toàn bộ chi tiết đặc tả vào AGENTS.md; file đó chỉ dẫn tới tài liệu tương ứng.

## 5. Lộ trình và cổng nghiệm thu

Mỗi giai đoạn chia thành task nhỏ, một thay đổi có thể kiểm tra và commit. Không cho AI tự đánh dấu “hoàn thiện” chỉ vì build thành công.

### M0 — Chốt thiết kế và dựng repo

Đầu ra: PRODUCT.md, DECISIONS.md, task board; repo chạy được, build được, có bản mock màn game. Kiểm tra repo đang có trước khi tạo mới, không ghi đè dự án khác.

Nghiệm thu: ghi rõ nền tảng mặc định, công thức bóng, luật lượt, phạm vi v1 và các phần ngoài phạm vi. Ghim phụ thuộc, có lệnh dev/build/test/lint phù hợp. Chưa quảng cáo thật.

Prompt:
> Đọc SHADOW_CONTROLLER_PLAN.md và kiểm tra repository hiện có. Thiết lập M0 cho game Người điều khiển bóng theo giả định web-first. Tạo tài liệu và skeleton tối thiểu; xác minh API theo tài liệu chính thức hiện hành. Không triển khai các giai đoạn sau. Chạy build, báo các quyết định đã chốt và phần còn chưa xác minh.

### M1 — Chứng minh hình học và điều khiển

Đầu ra: một màn sandbox có đèn kéo được, vật tạo bóng cố định, bóng hình chữ nhật, vùng kéo và tọa độ debug chỉ trong dev.

Nghiệm thu: kéo trên desktop/mobile đúng hướng; không nhảy vị trí khi bắt đầu kéo; không cuộn trang trong vùng điều khiển; đổi kích thước không đổi vị trí logic. Có unit test các tọa độ biết trước, cạnh biên và phép đổi tọa độ. Không menu phức tạp hoặc mỹ thuật tốn công.

Prompt:
> Thực hiện M1. Tách phép chiếu khỏi engine. Kiểm thử công thức S = 3P − 2L, pointer mapping và giới hạn chuyển động. Chạy trên viewport desktop và mobile, ghi rõ đã kiểm tra giả lập hay thiết bị thật. Chỉ hoàn thành khi có thể điều khiển ổn định bằng một ngón tay.

### M2 — Vòng chơi 3 màn

Đầu ra: preview → start → play → win/fail → retry/next; pause/resume; một công tắc, một cửa chắn, cảm biến, cửa thoát. Tạm thời chưa giới hạn lượt để tập trung gameplay.

Ba màn đầu: (1) học chuyển động ngược; (2) đi vòng cảm biến; (3) bật công tắc rồi đi qua cửa đã mở.

Nghiệm thu: mỗi màn có đường giải tham chiếu thực thi bằng cùng rules của game. Kéo thật nhanh không xuyên vùng cấm; không thắng trước khi cửa mở; cảnh báo có phản hồi ngay. Thử với 3–5 người mới; mục tiêu thiết kế là phần lớn tự hoàn thành màn 1 trong 60 giây và diễn đạt được cách điều khiển. Đây là tiêu chí dự kiến, chưa phải số liệu đã đạt.

Nếu khó hiểu: tăng vùng kéo, thêm mũi tên liên hệ đèn/bóng, làm lại hướng dẫn. Nếu chỉ là kéo qua mê cung nhàm chán: thử bố cục có trình tự công tắc và đường quay lại trước khi thêm nội dung. Không dùng quảng cáo để kéo dài trải nghiệm chưa hấp dẫn.

Prompt:
> Hoàn thành M2 với ba màn có lời giải kiểm chứng. Tập trung khả năng đọc bố cục và chống đi xuyên. Tự kiểm tra thắng, thua, pause, reset, resize; cung cấp checklist cho người thật chơi thử. Không tự bịa kết quả playtest.

### M3 — Lượt, lưu game và quảng cáo mô phỏng

Đầu ra: LivesService, SaveService, mock ad, countdown hồi lượt và xử lý reload phiên.

Nghiệm thu theo kịch bản:

1. Cài mới thấy 3; bắt đầu một ván còn 2; bấm nhanh nhiều lần vẫn chỉ trừ 1.
2. Thắng/thua không trừ thêm; retry hoặc next có xác nhận bắt đầu mới và trừ đúng 1.
3. Hết 0 thì không bắt đầu được, có countdown và nút nhận lượt.
4. Xem mock đủ thời lượng +1; đóng sớm/lỗi +0; callback trùng +1 tổng cộng.
5. Refresh không reset về 3; khôi phục ván đang chơi không trừ tiếp.
6. Hồi sau 30/60/90 phút đúng; không vượt 3; chỉnh giờ lùi không làm lượt âm.
7. Tab thứ hai không cùng ghi; dữ liệu lỗi hoặc hết quota lưu không làm UI báo bắt đầu thành công giả.
8. Trước khi lưu thành công giao dịch trừ lượt, gameplay chưa được mở. Lưu thất bại thì giữ trạng thái trước và thông báo cho người chơi.

Prompt:
> Thực hiện M3 đúng luật trong đặc tả. Viết test có Clock giả cho hồi lượt và ID giả cho thưởng. Xử lý double-click, refresh, callback trùng, ad cancel/error và lỗi lưu. Không dùng thời gian thật chờ 30 phút để test. Chưa tích hợp SDK quảng cáo production.

### M4 — Công cụ màn và 20 màn hợp lệ

Đầu ra: schema dữ liệu màn; validator; editor dev đơn giản có kéo đối tượng, sửa thứ tự công tắc, export/import JSON và chạy thử; 20 màn có đường giải tham chiếu.

Dữ liệu tối thiểu: id, schemaVersion, logicalBounds, lightBounds, initialLight, caster, hazards, switches, gates, exit, solutionWaypoints. Tọa độ dùng đơn vị logic. Thời gian giữ tại cửa thoát phải có trong replay lời giải.

Nghiệm thu: phát hiện ID trùng, tọa độ ngoài biên, công tắc tham chiếu sai, spawn chạm vùng đỏ, cửa không bao giờ mở và lời giải không chạy được. Validator không có đường giải thì chỉ được báo “chưa xác minh”, không kết luận màn có thể giải. Đường giải được kiểm tra lại sau mọi thay đổi hình học.

Lộ trình màn: 1–3 hướng dẫn; 4–7 đường đi và kích thước bóng; 8–12 trình tự công tắc; 13–16 đường vòng qua cửa; 17–20 kết hợp. Không thêm cơ chế mới chỉ để đủ 20 màn. Các màn có khoảng hở đủ cho ngón tay và sai số thao tác, tránh dựa vào khe hở sát một pixel.

Prompt:
> Thực hiện M4. Tạo dữ liệu và validator trước, sau đó editor dev tối thiểu, rồi từng nhóm màn. Mỗi màn phải có replay lời giải bằng engine rules hiện tại. Tách editor khỏi build phát hành. Báo màn nào chưa được người thật chơi thử.

### M5 — Hoàn thiện trải nghiệm

Đầu ra: hình ảnh thống nhất, phản hồi ánh sáng/công tắc/cửa, âm thanh có nguồn sử dụng rõ ràng, menu, hướng dẫn ngắn, chọn màn, cài đặt, trạng thái hết lượt, gợi ý.

Gợi ý v1: nhấn để xem mục tiêu công tắc tiếp theo hoặc vị trí đèn mốc tiếp theo; không gắn thêm quảng cáo gợi ý ở v1. Nếu gợi ý đường đi thì phải dùng dữ liệu lời giải, không vẽ tùy ý.

Nghiệm thu: chữ đọc được ở 360px; nút tối thiểu khoảng 44px; không chỉ dùng đỏ/xanh để truyền thông tin; tắt âm được và được lưu; âm thanh chỉ khởi động sau thao tác hợp lệ của người dùng. Có pause khi app nền, không âm thanh chồng hoặc listener tăng sau nhiều lần restart.

Prompt:
> Thực hiện M5 mà không thay luật core. Hoàn thiện giao diện sáng tối có chủ đích, đường bao bóng rõ, feedback ngắn và kiểm soát âm thanh. Kiểm tra vùng bấm, safe area và hướng màn hình. Ghi nguồn/license mọi asset, không lấy hình từ game khác.

### M6 — QA và bản web sẵn sàng phát hành

Đầu ra: bản candidate, QA.md có bằng chứng, danh sách bug, hướng dẫn build/rollback và bản chạy riêng tư khi người dùng yêu cầu triển khai.

Ma trận tối thiểu: desktop 1366×768; mobile 360×800 và 390×844; màn ngang; Android Chrome trên thiết bị thật; Safari iPhone nếu có thiết bị hoặc dịch vụ kiểm tra phù hợp. Giả lập viewport không được ghi thành đã kiểm thử thiết bị thật.

Nghiệm thu: lint/typecheck/build và test quan trọng qua; 20 replay lời giải qua; không lỗi console chưa xử lý; không có lỗi chặn start, mất tiến độ, trừ sai lượt hoặc thưởng trùng. Mục tiêu hiệu năng 60 FPS trên thiết bị thử đã ghi model; đo frame time, không chỉ nhìn thấy “mượt”. Nếu thấp, profile rồi tối ưu vùng render và effect trước.

Chạy ít nhất 30 chu kỳ start/retry/menu để phát hiện rò listener và tăng bộ nhớ bất thường. Kiểm tra mất mạng, ad lỗi, lưu lỗi, refresh, pause, đổi kích thước và quay lại sau thời gian hồi.

Prompt:
> Thực hiện M6 trên bản hiện tại. Ưu tiên lỗi blocker, sai luật lượt và màn không giải được. Chỉ chạy lại kiểm tra liên quan sau sửa đổi, rồi chạy smoke test cuối. Báo rõ thiết bị thật/giả lập, kiểm tra pass/fail/chưa thực hiện. Không gọi bản build là production-ready khi còn blocker.

### M7 — Nhánh Android và quảng cáo thật, khi chọn phát hành mobile

Quyết định riêng trước khi triển khai: đóng gói web bằng Capacitor hoặc viết bản native bằng nền tảng khác. Hướng Capacitor tái sử dụng bản web; cần spike trên điện thoại thật để kiểm chứng hiệu năng, lifecycle và adapter SDK quảng cáo trước khi chốt. Không mặc định wrapper nào cũng đáp ứng yêu cầu cửa hàng.

Đầu ra: bản Android ký đúng, native ad adapter được xác minh, test ads trong môi trường phát triển, kiểm tra lifecycle/reward, hồ sơ dữ liệu và phát hành thử nghiệm theo yêu cầu hiện hành.

Nghiệm thu: kiểm tra tài liệu Google Play/AdMob tại thời điểm làm; rà quyền, dữ liệu SDK thu thập, khai báo đối tượng, privacy policy và yêu cầu consent theo phạm vi phát hành thực tế. Không tự tạo tuyên bố “không thu thập dữ liệu” khi SDK có thu thập. Các khóa ký và credential không commit. Công bố cần quyết định riêng của chủ sản phẩm; qua checklist không bảo đảm được store phê duyệt.

Prompt:
> Chỉ thực hiện M7 sau khi nền tảng phát hành được chốt. Đọc tài liệu chính thức hiện hành, lập adapter compatibility matrix và chạy spike trên thiết bị Android thật. Tích hợp quảng cáo test, kiểm tra reward/cancel/error/duplicate/lifecycle. Liệt kê chính xác những phần cần tài khoản, khóa ký hoặc hành động của chủ sản phẩm. Không tự xuất bản công khai.

## 6. Prompt điều phối để bắt đầu và tiếp tục

Dán prompt này cho AI coding agent ở đầu dự án, kèm file kế hoạch:

> Bạn là coding agent của dự án Người điều khiển bóng. Đọc AGENTS.md nếu có, docs/PRODUCT.md, docs/PLAN.md và docs/PROGRESS.md; nếu chưa có thì dùng kế hoạch đính kèm để tạo chúng. Kiểm tra mã nguồn và git trước khi sửa, giữ nguyên thay đổi không liên quan của người dùng. Mặc định web-first theo kế hoạch; không đổi framework hoặc mở rộng phạm vi khi chưa có lý do cụ thể.
>
> Triển khai tuần tự từ milestone chưa hoàn thành. Mỗi lần chọn một task nhỏ có tiêu chí nghiệm thu, thực hiện, chạy kiểm tra phù hợp, sửa lỗi và cập nhật tiến độ. Tiếp tục các task đã rõ mà không yêu cầu xác nhận sau từng file. Chỉ hỏi khi có quyết định ảnh hưởng nền tảng, chi phí, tài khoản, công khai sản phẩm hoặc yêu cầu mâu thuẫn không thể tự giải quyết.
>
> Không tự đánh dấu playtest, thiết bị thật, quảng cáo thật hoặc store review là pass nếu chưa có bằng chứng. Nếu không có môi trường kiểm tra, ghi NOT VERIFIED và cung cấp cách kiểm tra. Khi gameplay cần đánh giá của người thật, hoàn thành bản có thể chơi và checklist trước khi yêu cầu đánh giá.
>
> Kết thúc mỗi phiên: nêu chức năng đã chạy, cách mở thử, kiểm tra đã thực hiện, hạn chế và task tiếp theo; cập nhật PROGRESS.md để phiên AI khác có thể tiếp tục. Tạo commit gọn khi phù hợp và được phép trong môi trường hiện tại. Không gửi tin nhắn, mua dịch vụ hay công khai sản phẩm ngoài phạm vi đã được yêu cầu.

Prompt tiếp tục:
> Đọc trạng thái thực tế và docs/PROGRESS.md. Tiếp tục task tiếp theo chưa hoàn thành theo PLAN.md, không khởi tạo lại dự án. Xác minh các phần phụ thuộc trước khi code. Sửa lỗi phát hiện trong phạm vi task và cập nhật bằng chứng nghiệm thu; không sửa phần không liên quan.

Prompt sửa bug:
> Tái hiện lỗi sau bằng kịch bản cụ thể: [mô tả]. Xác định nguyên nhân ở hình học, rules, phiên chơi, lượt, lưu hoặc UI. Viết regression test nếu lỗi ảnh hưởng logic, sửa ở lớp sở hữu trách nhiệm và chạy lại kiểm tra liên quan. Báo cách tái hiện trước/sau; không dùng cách cộng bù lượt hoặc bỏ collision để che lỗi.

## 7. Cách bạn quản lý AI mà không cần đọc toàn bộ code

Với mỗi task, yêu cầu một phiếu: ID, mục tiêu, phụ thuộc, phạm vi sửa, tiêu chí pass, cách thử và trạng thái. Các trạng thái là TODO, DOING, BLOCKED, READY FOR REVIEW, DONE. AI chỉ chuyển DONE khi đã có bằng chứng kỹ thuật cần thiết; đánh giá cảm giác chơi của người thật có ô riêng.

Sau mỗi milestone, tự thử ba câu hỏi: tôi hiểu phải làm gì không; thao tác có đúng kỳ vọng không; tôi có muốn thử thêm màn không? Nếu câu cuối không đạt, quay lại thiết kế màn và phản hồi trước khi tăng quảng cáo hoặc số lượng nội dung.

Ưu tiên sửa: mất dữ liệu/sai thưởng → không chơi được → không giải được màn → thao tác khó hiểu → hiệu năng → hình ảnh. Không yêu cầu AI viết lại toàn bộ game mỗi khi đổi giao diện.

Không ước lượng thời gian bằng số giờ AI tự cam kết. Chia lịch theo cổng nghiệm thu: M0–M2 là chứng minh gameplay; M3–M4 là hệ thống và nội dung; M5–M6 là chất lượng bản web; M7 là nhánh Android riêng. Thời gian thực phụ thuộc playtest, lỗi thiết bị và tích hợp quảng cáo.

## 8. Định nghĩa “hoàn thiện v1”

- 20 màn có lời giải đã xác minh, hướng dẫn có người mới thử.
- Luật bóng, công tắc, cửa và thất bại nhất quán trên desktop/mobile.
- 3 lượt, hồi lượt và thưởng hoạt động đúng, không trừ/cộng lặp.
- Tiến độ khôi phục được; lưu lỗi không làm báo kết quả giả.
- Không còn bug chặn chơi hoặc sai số lượt đã biết; các hạn chế còn lại được công bố.
- Assets có quyền sử dụng, cấu hình build rõ ràng, có quy trình phục hồi bản trước.
- Bản web mock quảng cáo được ghi đúng là bản thử nghiệm. Bản có doanh thu quảng cáo phải qua nghiệm thu adapter thật trên nền tảng phát hành.
- Có hướng dẫn cho người vận hành: đổi level, điều chỉnh thời gian hồi, build, test, phát hành và rollback.

## 9. Tài liệu chính thức tham khảo

Các liên kết dưới đây là điểm khởi đầu; AI phải đọc lại theo phiên bản đã chốt khi thực hiện, không sao chép API từ tài liệu khác major.

- Phaser: https://docs.phaser.io/phaser/getting-started/what-is-phaser
- Capacitor: https://capacitorjs.com/docs
- Capacitor installation/sync: https://capacitorjs.com/docs/getting-started
- AdMob rewarded ads Android: https://developers.google.com/admob/android/rewarded
- AdMob server-side verification: https://developers.google.com/admob/android/ssv

Lưu ý về thiết kế: công thức chiếu, phạm vi 20 màn, 30 phút hồi lượt và tiêu chí playtest là quyết định đề xuất trong kế hoạch này, không phải kết luận từ các tài liệu trên.
