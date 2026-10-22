# Quy trình audit app Flutter trước khi gửi Google Play

Ngày đối chiếu nguồn: **16/10/2026**. Ngôn ngữ báo cáo: tiếng Việt.

## 1. Mục đích và cách sử dụng

Dùng tài liệu này làm yêu cầu giao việc cho AI coding agent, developer và QA: kiểm tra mã nguồn, bản Android release, backend và hồ sơ Play Console; xuất báo cáo có phương án sửa **và phương án thay thế** cho mọi mục chưa đạt.

Đây là khung audit, chưa phải kết luận về một app cụ thể. Chưa có mã nguồn, bản build và quyền xem hồ sơ nên trạng thái ban đầu của mọi mục là **CHƯA XÁC MINH**. Không tài liệu hay điểm số nào bảo đảm Google Play sẽ duyệt. Google đánh giá hành vi của sản phẩm và thông tin khai báo; kiến trúc đẹp hoặc test chạy xanh không thay thế tuân thủ.

**Cách dùng:** đặt file trong repository, cung cấp đầu vào ở mục 3 và giao cho người/agent đánh giá theo toàn bộ quy trình. Chỉ tạo báo cáo và đề xuất; triển khai thay đổi khi phạm vi công việc cho phép. Khi thực hiện sửa, đánh giá lại đúng artifact cuối cùng.

### Chỉ dẫn cho người/AI thực hiện audit

1. Đọc project và hướng dẫn repository trước khi kết luận. Xác định loại app, tính năng, nhóm tuổi, quốc gia, dữ liệu và mô hình doanh thu.
2. Lập danh sách chính sách áp dụng. Mở nguồn chính thức ở mục 15 để xác minh phiên bản, ngày hiệu lực và ngoại lệ tại ngày dự kiến gửi app. Nếu không truy cập được, ghi rõ giới hạn.
3. Kiểm tra cả mã Dart, Android native, dependency, manifest đã merge, SDK, backend, bản release và khai báo Console. Không suy luận hành vi SDK chỉ từ tên package.
4. Chạy các kiểm tra khả dụng; lưu lệnh, kết quả, môi trường và bằng chứng. Không giả lập kết quả test, screenshot, log hay trạng thái Console.
5. Với mỗi vấn đề, ghi vị trí cụ thể, tác động, nguồn yêu cầu, cách tái hiện, cách sửa chính và ít nhất một phương án thay thế khả thi.
6. Phân biệt lỗi xác nhận với nghi vấn. Thiếu quyền truy cập/backend/thiết bị phải ghi CHƯA XÁC MINH, không đánh dấu ĐẠT hoặc KHÔNG ÁP DỤNG.
7. Xuất báo cáo theo mục 12, backlog theo mục 13 và quyết định gửi theo mục 14. Không chỉ xuất checklist hoặc lời khuyên chung.
8. Không che chức năng với reviewer, giả dữ liệu tuân thủ, đổi hành vi theo tài khoản review, hoặc dùng remote config để bật lại tính năng vi phạm sau duyệt. Phương án thay thế phải đáp ứng chính sách và vẫn có giá trị cho người dùng.

## 2. Quy ước đánh giá

### Loại tiêu chí

| Nhãn | Ý nghĩa | Cách sử dụng |
| --- | --- | --- |
| POLICY | Yêu cầu chính sách hoặc điều kiện nộp/phân phối của Google Play | Bắt buộc khi thuộc phạm vi áp dụng; gắn nguồn chính thức và ngày hiệu lực |
| QUALITY | Tiêu chuẩn kỹ thuật/UX của đội dự án | Hỗ trợ chất lượng, không tự coi là điều kiện duyệt của Google |
| CONDITIONAL | Nhánh cần xác định phạm vi, sau đó phân loại POLICY/QUALITY | Không tự bỏ qua khi chưa biết sản phẩm có tính năng liên quan |

### Trạng thái và mức độ

- **ĐẠT:** có bằng chứng hợp lệ cho build và phạm vi đang xét.
- **CHƯA ĐẠT:** đã xác nhận không đáp ứng tiêu chí.
- **CHƯA XÁC MINH:** thiếu bằng chứng hoặc chưa chạy kiểm tra.
- **KHÔNG ÁP DỤNG:** ghi lý do và bằng chứng tính năng/đối tượng liên quan không tồn tại.

| Mức | Ví dụ | Xử lý nội bộ |
| --- | --- | --- |
| P0 | Lộ bí mật đặc quyền, truy cập chéo tài khoản, mất dữ liệu/thanh toán nghiêm trọng | Dừng gửi, khoanh vùng và khắc phục ngay |
| P1 | Vi phạm chính sách áp dụng, không khởi động, reviewer không truy cập được, luồng chính hỏng | Chặn gửi cho đến khi sửa và retest |
| P2 | Lỗi UX, hiệu năng hoặc khả năng bảo trì có ảnh hưởng đáng kể | Sửa trước gửi nếu cản trở trải nghiệm chính; nếu hoãn phải có người chịu trách nhiệm |
| P3 | Cải thiện nhỏ, tài liệu, tối ưu ít tác động | Lập kế hoạch |

Không dùng điểm tổng để bù cho vi phạm. Một POLICY chưa đạt vẫn chặn gửi dù mọi mục QUALITY đều tốt. Quy định P0–P3 và điều kiện chặn ở đây là quy trình nội bộ.

## 3. Đầu vào cần thu thập

| Nhóm | Thông tin/bằng chứng cần có |
| --- | --- |
| Sản phẩm | Tên, mục đích, chân dung người dùng, 3 luồng chính, điểm giá trị, tính năng đã hoàn thiện |
| Phát hành | Ngày gửi, quốc gia, loại tài khoản developer, ngày tạo tài khoản, track, device/form factor được hỗ trợ |
| Source | Repository, commit SHA, Flutter/Dart version, flavor, `pubspec.yaml`, `pubspec.lock`, `analysis_options.yaml`, CI |
| Android | Gradle/AGP/Kotlin/JDK, `applicationId`, SDK levels, manifest theo flavor và manifest đã merge, permission, service, provider, native `.so` |
| Artifact | AAB release sẽ gửi, versionName/versionCode, checksum, thông tin signing không chứa khóa bí mật |
| Backend | API specification, môi trường production/review tương đương về chức năng, auth, rules, retention, cơ chế xóa tài khoản |
| Dữ liệu | Data inventory, sơ đồ luồng dữ liệu, danh sách SDK và nhà cung cấp, consent, privacy policy, Data safety draft |
| Doanh thu | Ads, mediation, IAP/subscription, quốc gia/chương trình billing nếu có ngoại lệ |
| Console | App content, app access, rating, target audience, khai báo quyền, pre-launch report, lỗi/warning khi tải AAB |
| Kiểm thử | Test account an toàn, thiết bị/OS, test plan, test report, crash/ANR nếu đã có người dùng, feedback closed test |
| Nội dung | Store listing, ảnh thực tế, icon, giấy phép asset, nội dung UGC/AI nếu có |

Thiếu đầu vào vẫn kiểm tra các phần còn lại. Liệt kê phần bị chặn, người cần cung cấp và quyết định nào chưa thể đưa ra. Không đưa mật khẩu, token, dữ liệu cá nhân thật hoặc signing key vào báo cáo.

## 4. Các điều kiện Google Play cần kiểm tra trước

| ID | Loại | Tiêu chí và cách xác minh | Sửa chính nếu chưa đạt | Phương án thay thế |
| --- | --- | --- | --- | --- |
| GP-01 | POLICY | Xác minh tài khoản, thông tin liên hệ, thỏa thuận và nhiệm vụ Console đã hoàn tất; kiểm tra dashboard thực tế [S01] | Hoàn tất xác minh đúng danh tính | Hoãn gửi để giải quyết điều kiện tài khoản; không mượn danh tính/tài khoản để né hạn chế |
| GP-02 | POLICY | Với app mobile mới/cập nhật thông thường, nguồn [S02] hiện quy định target Android 16/API 36 từ 31/08/2026; kiểm tra artifact, deadline và ngoại lệ theo form factor | Nâng SDK/toolchain/plugin tương thích và test thay đổi hành vi | Dùng extension chỉ khi được Console xác nhận hợp lệ cho trường hợp này; nếu không phải hoãn, không hạ target để né |
| GP-03 | POLICY | Với tài khoản cá nhân tạo sau 13/11/2023, kiểm tra closed test tối thiểu 12 tester opted-in liên tục ít nhất 14 ngày và thủ tục xin production access [S03] | Chạy closed test thực chất, thu feedback và sửa lỗi | Tiếp tục test/hoãn production đến khi đủ điều kiện; không coi đủ ngày là tự động được cấp quyền |
| GP-04 | POLICY | App mới dùng Android App Bundle; kiểm tra Play App Signing, package/version, khả năng cài từ test track [S01][S04] | Tạo AAB release và cấu hình signing đúng | Sửa pipeline rồi nộp lại; APK debug/sideload không thay cho yêu cầu nộp AAB |
| GP-05 | POLICY | Kiểm tra hỗ trợ 64-bit theo phạm vi áp dụng và 16 KB page size; Flutter engine và plugin đều có thể chứa native code [S05][S06] | Nâng engine/plugin/NDK phù hợp, xác minh toàn bộ `.so` và chạy trên môi trường 16 KB | Thay hoặc gỡ plugin native lỗi; giữ chức năng bằng triển khai không phụ thuộc thư viện đó nếu khả thi |
| GP-06 | POLICY | App access cho phép reviewer sử dụng toàn bộ chức năng cần review; kiểm tra tài khoản, entitlement, hướng dẫn, điều kiện truy cập [S07] | Cấp tài khoản ổn định, hướng dẫn tái lập và dữ liệu thử an toàn | Cung cấp phương thức truy cập thay thế phù hợp hướng dẫn Console, chức năng tương đương; không phát hành app bị khóa ngoài khả năng review |
| GP-07 | POLICY | Rating, target audience, khai báo ads/quyền/health/financial và các form được Console yêu cầu khớp sản phẩm [S07] | Sửa khai báo theo hành vi và tính năng thực tế | Bỏ thật tính năng chưa sẵn sàng khỏi release và cập nhật mọi mô tả liên quan |

Không lấy `minSdk`, `compileSdk` hoặc cấu hình Dart làm bằng chứng cho `targetSdk` trong AAB. Không coi việc chạy được trên máy 4 KB là bằng chứng hỗ trợ 16 KB. Kiểm tra cảnh báo Play Console và công cụ alignment theo [S05].

## 5. Quyền riêng tư, dữ liệu và bảo mật

Nguồn chính: User Data [S08], Data safety [S09], account deletion [S10], sensitive permissions [S11]. Mỗi dòng phải có bằng chứng từ app lẫn backend/SDK nếu liên quan.

| ID | Loại | Điều kiện và phép kiểm tra | Sửa chính | Phương án thay thế |
| --- | --- | --- | --- | --- |
| DATA-01 | POLICY | Có privacy policy truy cập công khai, dùng được trong app và listing, nội dung khớp xử lý dữ liệu [S08] | Viết theo thực tế, sửa URL và nội dung | Giảm dữ liệu/SDK rồi cập nhật policy tương ứng; không dùng policy mẫu sai thực tế |
| DATA-02 | POLICY | Data safety phản ánh cả code và SDK, kể cả analytics/ads; dùng đúng định nghĩa collected/shared của Google [S09] | Lập inventory, đối chiếu khai báo và traffic | Loại SDK/dữ liệu không cần thiết; xác minh lại trước khi sửa khai báo |
| DATA-03 | POLICY | Khi cần prominent disclosure/consent, thông báo trong app trước thu thập; runtime permission không thay consent [S08] | Bổ sung giải thích rõ và cơ chế đồng ý phù hợp | Thiết kế chức năng không thu dữ liệu ngoài kỳ vọng; tắt thu thập không cần thiết |
| DATA-04 | POLICY | Nếu cho tạo tài khoản trong app hoặc dẫn ra luồng tạo tài khoản, có đường yêu cầu xóa trong app và trang web bên ngoài [S10] | Nối luồng xóa vào backend, xóa dữ liệu liên quan và xử lý nhà cung cấp | Dùng trang yêu cầu xóa có quy trình vận hành thực sự, truy cập từ app; hoặc bỏ account nếu sản phẩm không cần |
| DATA-05 | POLICY | Xóa tài khoản không chỉ là logout/disable; dữ liệu giữ lại có lý do chính đáng được công bố [S10] | Định nghĩa phạm vi xóa, retention và kiểm tra hoàn tất | Thu hẹp dữ liệu lưu; phương án xử lý thủ công có theo dõi nếu đáp ứng chính sách và tải vận hành |
| DATA-06 | POLICY | Quyền nhạy cảm gắn với chức năng cốt lõi đủ điều kiện; kiểm tra merged manifest và khai báo bắt buộc [S11] | Gỡ quyền thừa, xin đúng thời điểm, khai báo đúng | Chọn ảnh qua system picker, chọn file qua system UI, nhập vị trí thủ công thay truy cập rộng khi phù hợp |
| SEC-01 | QUALITY | Không có server secret/private key/service-account credential trong app, git, asset hoặc log; obfuscation không giữ được bí mật | Thu hồi/rotate khóa lộ; chuyển thao tác đặc quyền về backend | Dùng API client công khai có giới hạn thích hợp và backend proxy cho phần đặc quyền |
| SEC-02 | QUALITY | Auth và authorization được kiểm tra server-side; test user A đọc/sửa dữ liệu user B | Sửa rules/API, validate ownership và role | Tạm bỏ chức năng chia sẻ/admin chưa an toàn khỏi release |
| SEC-03 | QUALITY | Token/dữ liệu nhạy cảm được lưu phù hợp; HTTPS, backup/log/cache được kiểm soát | Dùng kho bảo mật phù hợp, giảm log và thời gian lưu | Không persist token/dữ liệu khi không cần; buộc xác thực lại cho thao tác quan trọng |
| SEC-04 | QUALITY | Deep link, WebView bridge, exported components, file upload và đầu vào đều kiểm tra ranh giới tin cậy | Allowlist, validate, kiểm soát quyền và dữ liệu đầu vào | Dùng browser/system flow thay WebView bridge có quyền cao; bỏ component thừa |
| SEC-05 | QUALITY | Package/SDK còn được duy trì, không có lỗ hổng nghiêm trọng chưa xử lý; kiểm tra transitive native SDK | Cập nhật có kiểm thử và khóa version | Thay thư viện, fork có người bảo trì hoặc bỏ tính năng; không chỉ tăng version mù quáng |

Mẫu inventory bắt buộc:

| Dữ liệu | Nguồn | Mục đích | Đích nhận/SDK | Lưu ở đâu và bao lâu | Cơ chế xóa | Disclosure/consent | Đối chiếu Data safety | Bằng chứng |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Điền theo app thực tế | | | | | | | | |

## 6. Giá trị sản phẩm, nội dung và kiếm tiền

| ID | Loại | Tiêu chí và phép kiểm tra | Sửa chính | Phương án thay thế |
| --- | --- | --- | --- | --- |
| PROD-01 | POLICY | App có chức năng hữu ích, ổn định, đủ nội dung; không placeholder hoặc luồng chính hỏng [S12] | Hoàn thiện một nhu cầu cốt lõi end-to-end | Thu hẹp phạm vi thành sản phẩm nhỏ nhưng hoàn chỉnh; chưa gửi nếu vẫn không đủ giá trị |
| PROD-02 | POLICY | Không spam/lặp lại; kiểm tra nguồn nội dung và quyền dùng website nếu có WebView [S13] | Tạo nội dung/dịch vụ có giá trị và quyền hợp lệ | Gộp các app tương tự; xây workflow hữu ích riêng. WebView không mặc nhiên bị cấm |
| PROD-03 | POLICY | Listing, ảnh, icon, tên và lời hứa khớp app; không mạo danh hoặc dùng asset không có quyền [S07][S18] | Chụp màn hình release thật, sửa claims và giấy phép | Dùng nội dung/asset tự tạo hoặc được cấp phép; bỏ claim chưa chứng minh |
| MONEY-01 | POLICY | Bán tính năng/nội dung số dùng Play Billing trừ ngoại lệ/chương trình áp dụng; phân biệt hàng vật lý [S14] | Tích hợp billing đúng và kiểm tra thị trường | Phát hành miễn phí hoặc bỏ luồng bán số; dùng phương án khác chỉ khi đủ điều kiện được xác minh |
| MONEY-02 | QUALITY | Xác thực purchase/entitlement; xử lý pending/cancel/duplicate/refund/reinstall đúng | Backend xác minh giao dịch và cập nhật quyền idempotent | Bỏ IAP chưa an toàn khỏi phiên bản đầu; không cấp quyền chỉ theo biến local |
| MONEY-03 | POLICY | Subscription công bố giá, kỳ thanh toán, gia hạn, trial và cách quản lý/hủy rõ ràng [S15] | Sửa paywall/terms và nối quản lý thuê bao | Chuyển sang sản phẩm mua một lần hoặc miễn phí nếu phù hợp; vẫn tuân thủ Billing |
| ADS-01 | POLICY | Ads không lừa click, không giống UI hệ thống, không gián đoạn trái chính sách; khai báo có ads [S16][S07] | Đổi vị trí/tần suất, cơ chế đóng và SDK | Banner/native ad rõ nhãn hoặc bỏ quảng cáo khỏi bản đầu |
| ADS-02 | QUALITY | Nếu có rewarded ads: hiển thị phần thưởng, xử lý no-fill/error/đóng sớm; không cộng hai lần | State machine và transaction reward idempotent; callback hợp lệ | Cho nhận lượt theo thời gian/nhiệm vụ miễn phí, hoặc bỏ cơ chế reward nếu chưa ổn |
| ADS-03 | CONDITIONAL | Kiểm tra consent, đối tượng quảng cáo, Advertising ID và khu vực theo [S08][S16][S18] | Cấu hình SDK/consent và khai báo đúng phạm vi | Tắt cá nhân hóa hoặc ads khi phù hợp; vẫn kiểm tra dữ liệu còn thu thập |

Không tự cho rằng “app chỉ là utility nên sẽ được duyệt”, hoặc “cần nhiều tính năng mới đủ chất lượng”. Giá trị được đánh giá theo nhu cầu app phục vụ và trải nghiệm thực tế.

## 7. Các nhánh chính sách đặc thù

Trước audit, đánh dấu từng nhánh Có/Không/Chưa biết. Nếu Có, mở chính sách đầy đủ tại [S18], bổ sung ID, điều kiện áp dụng và test riêng. Bảng này là bước sàng lọc, không thay toàn bộ quy định của từng ngành.

| Nhánh | Phần phải đánh giá thêm | Hướng thay thế khi chưa đáp ứng |
| --- | --- | --- |
| Trẻ em / nhóm tuổi hỗn hợp | Families, dữ liệu trẻ em, SDK ads phù hợp, nội dung và age screening nếu áp dụng | Thiết kế lại dữ liệu/ads và trải nghiệm đúng nhóm tuổi; không đổi nhãn tuổi trái đối tượng thực tế |
| UGC, chat, social, dating | Terms, report/block theo phạm vi, moderation, xử lý lạm dụng và tiêu chuẩn an toàn trẻ em nếu áp dụng | Giới hạn nội dung curated hoặc hoãn UGC đến khi có cơ chế vận hành |
| Generative AI | Nội dung bị cấm, kiểm soát đầu vào/đầu ra và chức năng report/flag trong app khi chính sách yêu cầu | Dùng nội dung được duyệt sẵn hoặc giới hạn tác vụ có kiểm soát |
| Sức khỏe / Health Connect | Health declaration, permission/data usage, giới hạn claims, tư cách cung cấp dịch vụ | Bỏ claims/tính năng chưa có căn cứ; không đổi tên để né phân loại |
| Tài chính, khoản vay, crypto | Financial declaration, giấy phép, quốc gia, disclosures và điều kiện riêng | Thu hẹp tính năng/thị trường hợp lệ hoặc hoãn phát hành |
| Gambling, giải thưởng có giá trị, loot box | Phân loại cơ chế thưởng, quốc gia/giấy phép, odds disclosure khi áp dụng | Loại cơ chế tiền thật/đổi thưởng hoặc bỏ tính năng cho đến khi đủ điều kiện |
| Background location, SMS/call log, all-files, Accessibility API, VPN, foreground service, full-screen intent | Tính đủ điều kiện, mục đích cốt lõi, declaration và giới hạn sử dụng [S11] | Dùng system API/quyền hẹp hơn, chuyển thao tác sang foreground khi phù hợp, hoặc bỏ tính năng |
| Tin tức, chính phủ, nội dung bản quyền | Nguồn, thông tin publisher/ủy quyền, tính chính xác, sở hữu trí tuệ | Dùng nguồn có quyền, công bố quan hệ đúng thực tế hoặc bỏ nội dung |

## 8. Audit chất lượng code Flutter

Các mục sau là **QUALITY nội bộ**, trừ khi phát hiện hành vi vi phạm chính sách thì lập thêm finding POLICY tương ứng. Google Play không yêu cầu phải dùng BLoC, Riverpod, GetX, Clean Architecture, hoặc một tỷ lệ coverage cố định.

| ID | Tiêu chí và bằng chứng cần kiểm tra | Cách sửa chính | Phương án thay thế |
| --- | --- | --- | --- |
| CODE-01 | Chạy analyzer, formatter, build; phân loại warning theo tác động thực tế | Sửa lỗi, nullable handling, import và dead code liên quan | Ghi ngoại lệ lint cục bộ có lý do; không tắt toàn bộ analyzer để che lỗi |
| CODE-02 | Logic nghiệp vụ có ranh giới để test, tránh phụ thuộc UI và globals | Tách service/repository/use case vừa đủ | Với app nhỏ, dùng lớp Dart thuần và dependency injection đơn giản |
| CODE-03 | Async có timeout/cancel/error; không dùng context sau dispose sai cách | Kiểm tra lifecycle/mounted, xử lý Future/Stream và cleanup | Giảm concurrent workflow, dùng một owner quản lý tác vụ |
| CODE-04 | State không bị reset/mâu thuẫn khi back/resume/retry; chống double submit | State rõ ràng, persist đúng chỗ và idempotency | Dùng flow tuần tự đơn giản hơn thay nhiều state chồng chéo |
| CODE-05 | API có validate dữ liệu, timeout, lỗi thân thiện; retry không nhân đôi giao dịch | Typed model, error mapping, retry có điều kiện | Bỏ retry tự động cho thao tác không an toàn; cho retry có kiểm soát |
| CODE-06 | DB/cache có migration, backup/restore phù hợp và hành vi upgrade được test | Migration có version, transaction và kiểm tra mất dữ liệu | Reset chỉ cache tái tạo được; không xóa dữ liệu người dùng để tránh viết migration |
| CODE-07 | Plugin/MethodChannel kiểm tra lỗi, permissions, thread, ABI và lifecycle | Nâng/sửa plugin, kiểm thử native | Dùng plugin được duy trì hoặc triển khai chức năng đơn giản hơn |
| CODE-08 | Không làm CPU/I/O nặng trong build/main isolate; đo profile | Chuyển xử lý nặng, pagination, tối ưu ảnh và rebuild theo số liệu | Bỏ hiệu ứng nặng, giảm kích thước dữ liệu/ảnh và tính toán trước |
| CODE-09 | Logging/crash capture không nuốt lỗi hoặc lộ PII; telemetry có consent khi cần | Error boundary, lọc dữ liệu và correlation ID an toàn | Log tối thiểu local đã redacted; không dùng SDK thu thập dư thừa |
| CODE-10 | Config/flavor không trỏ nhầm staging; release không có debug panel/secret | Kiểm tra config cuối, CI guards và allowlist môi trường | Một flavor release rõ ràng nếu chưa cần đa môi trường |
| CODE-11 | Unit/widget/integration test bao phủ rủi ro quan trọng | Test auth, tiền, deletion, migration, reward và lỗi mạng | Test tay có kịch bản và bằng chứng cho phần chưa tự động hóa; ghi rõ giới hạn |
| CODE-12 | Build tái lập được với lockfile/toolchain, provenance artifact rõ | Pin bộ công cụ tương thích và ghi commit/build metadata | Build có kiểm soát thủ công và lưu manifest môi trường nếu chưa có CI |

### Lệnh gợi ý

Chạy ở checkout phù hợp, kiểm tra hướng dẫn project. Ghi rõ lệnh nào thực sự đã chạy, exit code và artifact đầu ra. Không dùng lệnh không phù hợp làm bằng chứng lỗi của app.

```bash
flutter --version
flutter doctor -v
flutter pub get
flutter pub outdated
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter test integration_test -d <device-id>
flutter build appbundle --release
```

- Nếu không có thư mục `test` hoặc `integration_test`, điều chỉnh đường dẫn và ghi “chưa có test”; không ghi “test đạt”.
- Bổ sung `--flavor` và `--target` đúng ứng dụng. Kiểm tra quyền backend/credential trước các test có tác dụng phụ; dùng dữ liệu thử.
- `pub outdated` chỉ cho biết phiên bản; không phải công cụ chứng minh không có lỗ hổng.
- Phân tích profile trên thiết bị đại diện; test smoke và hành vi release trên bản cài qua Play test track. Debug build không đủ để kết luận hiệu năng hoặc signing.
- Lưu merged manifest, danh sách dependency, kết quả kiểm tra native alignment, báo cáo test và checksum AAB. Không phát tán file chứa bí mật.

## 9. Chất lượng đầu ra và UX

Các ngưỡng dưới đây là **mục tiêu nội bộ gợi ý**, không phải ngưỡng duyệt Google Play. Điều chỉnh theo loại app và thiết bị trước khi đo, không sửa mục tiêu sau test để hợp thức hóa kết quả.

| ID | Tiêu chí / cách đo | Mục tiêu ban đầu | Cách sửa hoặc thay thế |
| --- | --- | --- | --- |
| UX-01 | Cài mới → hiểu mục đích → hoàn thành nhiệm vụ chính | Không bị chặn bởi màn hình rỗng/lỗi/đăng nhập không cần thiết | Rút gọn onboarding; guest mode nếu phù hợp |
| UX-02 | Loading/empty/error/offline/permission denied/session expired | Mỗi trạng thái có thông báo và bước tiếp theo | Bổ sung retry/cached view; giới hạn online-only nhưng nói rõ và phục hồi được |
| UX-03 | Back, predictive back nếu áp dụng, keyboard, safe area, edge-to-edge, xoay/resume | Không che nút hoặc mất trạng thái quan trọng | Sửa layout/lifecycle; giảm UI lồng nhau |
| UX-04 | Màn hình nhỏ, tablet nếu hỗ trợ, text scale 200% | Không overflow hoặc cắt mất hành động chính | Responsive layout; scroll và bố cục đơn giản hơn |
| UX-05 | TalkBack, labels/focus, màu và target cảm ứng [S17] | Luồng chính thao tác được; target khoảng 48 dp, contrast văn bản thường 4.5:1 | Bổ sung semantics, text/icon thay màu đơn thuần |
| PERF-01 | Cold start đến dùng được: đo 10 lần, ghi median/p95 và thiết bị | Đặt ngân sách theo app; ví dụ median ≤3 giây trên máy đại diện | Lazy init SDK, tải dữ liệu sau render đầu; bỏ splash chờ vô hạn |
| PERF-02 | Scroll/animation trong profile, tần số màn hình cụ thể | Đa số frame trong ngân sách refresh; ví dụ khoảng 16.7 ms tại 60 Hz | Tối ưu có đo lường, giảm blur/animation/ảnh lớn |
| REL-01 | Chạy các luồng trọng yếu lặp lại và kiểm tra log | Không có crash/ANR quan sát được trong tập test; không suy rộng thành “0% mọi thiết bị” | Sửa nguyên nhân, thay plugin hoặc bỏ chức năng gây lỗi |
| REL-02 | Mạng chậm/mất mạng/API lỗi/token hết hạn/low storage | Không mất dữ liệu hoặc sinh giao dịch trùng | Transaction, local draft và thông báo phục hồi |
| REL-03 | Nền/foreground, kill/reopen và nâng version | Khôi phục trạng thái phù hợp, không hỏng migration | Persist dữ liệu tối thiểu; workflow ngắn hơn |

Với app đã chạy thử, đối chiếu Android vitals và phản hồi thật; ghi lượng mẫu/khoảng thời gian. Crash/ANR thresholds, discoverability và technical quality có thể ảnh hưởng phân phối; không biến một ngưỡng vitals thành lời hứa được duyệt [S19].

## 10. Ma trận test tối thiểu theo rủi ro

Chọn thiết bị theo phạm vi công bố, gồm máy thật cấu hình thấp và Android hiện hành. Dùng emulator cho trường hợp khó tái hiện; ghi model, RAM, OS, ABI, page size, build/track và account thử.

| Nhóm | Kịch bản | Bằng chứng hoàn tất |
| --- | --- | --- |
| Cài đặt | Cài mới từ track; update từ version trước nếu có; cold start | Phiên bản, log, video hoặc test report |
| Nhiệm vụ chính | Luồng thành công + lỗi + quay lại + thao tác liên tục | Expected/actual cho từng bước |
| Auth | Signup/login/logout, token expired, revoke access, tài khoản review | Không lộ/mix dữ liệu giữa tài khoản |
| Permissions | Cho phép/từ chối/không hỏi lại/thu hồi từ Settings | Fallback đúng; không crash hoặc lặp hỏi cưỡng ép |
| Network | Offline, latency cao, timeout, 401/403/429/5xx | Trạng thái lỗi rõ, phục hồi được |
| Lifecycle | Đưa nền, kill process, reopen, xoay nếu hỗ trợ | Không mất dữ liệu quan trọng |
| Dữ liệu | Tạo/sửa/xóa, migration, logout rồi user khác login | Không mất dữ liệu hoặc cache chéo |
| Account deletion | Gửi yêu cầu từ app và web; xác minh xử lý backend | Request ID, dữ liệu đã xóa/giữ lại có lý do; không dùng PII trong report |
| Billing nếu có | Success, cancel, pending, duplicate, reinstall/restore, refund/revoke | Quyền truy cập khớp trạng thái giao dịch |
| Ads nếu có | Load/no-fill/fail/dismiss/reward/resume/repeated callback | Không click trap, reward đúng một lần |
| Khả năng tiếp cận | TalkBack, text scale, contrast, keyboard/safe area | Luồng chính thao tác được |
| Native | Máy/emu 16 KB, ABI hỗ trợ, tất cả plugin quan trọng | Alignment report + runtime test |
| Backend | Reviewer truy cập theo hướng dẫn, server và endpoint công khai cần thiết hoạt động | Thử từ môi trường tương đương reviewer, không cần tác vụ hỗ trợ tức thời |

## 11. Kiểm tra hồ sơ và release cuối

- [ ] AAB/commit/flavor/version là bản đã kiểm tra, checksum được lưu; bản được Play phân phối đã smoke test.
- [ ] Không có P0/P1 mở; các POLICY áp dụng đều ĐẠT.
- [ ] Không còn mục CHƯA XÁC MINH liên quan tuân thủ hoặc luồng chính.
- [ ] Privacy URL, deletion URL nếu áp dụng, support contact hoạt động và đúng app.
- [ ] Data safety, target audience, rating, ads và các declaration khớp artifact, SDK, backend.
- [ ] Reviewer dùng được hướng dẫn và tài khoản truy cập toàn bộ phạm vi cần review.
- [ ] Store listing và ảnh phản ánh tính năng hiện có; quyền nội dung rõ ràng.
- [ ] Pre-launch report/Console warnings đã được xem và xử lý hoặc có kết luận có căn cứ; “không báo lỗi” không chứng minh tuân thủ đầy đủ.
- [ ] Điều kiện tài khoản, closed testing và production access hoàn tất nếu áp dụng.
- [ ] Có kế hoạch giám sát, hỗ trợ và dừng rollout khi có lỗi. Không giả định Google cho downgrade versionCode; khi cần sửa, chuẩn bị bản mới có versionCode lớn hơn.

Nếu bị từ chối: lưu nguyên văn lý do, policy link, version bị ảnh hưởng; tái hiện; đối chiếu finding; sửa mã/khai báo/backend liên quan; retest rồi gửi lại với mô tả thay đổi cụ thể. Chỉ appeal khi có căn cứ cho thấy kết luận sai, không chỉ đổi tên/package hoặc gửi lặp cùng bản lỗi.

## 12. Định dạng báo cáo bắt buộc sau audit

```markdown
# Báo cáo audit [Tên app]

## A. Kết luận
- Quyết định: SẴN SÀNG GỬI / CHƯA SẴN SÀNG / CHƯA ĐỦ BẰNG CHỨNG
- Ngày audit và ngày dự kiến nộp:
- Commit / flavor / AAB checksum / versionCode:
- Phạm vi thực sự kiểm tra:
- P0 / P1 / P2 / P3:
- Các blocker và điều kiện để gỡ:
- Giới hạn: đây là đánh giá readiness, không bảo đảm quyết định của Google.

## B. Ma trận tiêu chí
| ID | POLICY/QUALITY | Có áp dụng? + lý do | Trạng thái | Bằng chứng | Finding liên quan |
| --- | --- | --- | --- | --- | --- |

## C. Finding chi tiết
### [F-001] Tên vấn đề cụ thể
- Tiêu chí ID / POLICY hoặc QUALITY / mức P0–P3:
- Vị trí: file:line, màn hình, endpoint, SDK version hoặc mục Console:
- Build/thiết bị/môi trường:
- Expected / actual:
- Các bước tái hiện:
- Bằng chứng: log redacted, test ID, screenshot hoặc artifact:
- Tác động đến người dùng và review:
- Nguyên nhân xác nhận; giả thuyết còn cần kiểm tra:
- Nguồn chính thức, điều khoản, ngày hiệu lực; hoặc ghi “tiêu chuẩn nội bộ”:
- Cách sửa chính: thay đổi cụ thể ở code/UI/backend/Console:
- Phương án thay thế: cách triển khai khác hoặc thu hẹp tính năng có giá trị:
- So sánh: mức tuân thủ, UX, công sức, vận hành và rủi ro còn lại:
- Lựa chọn đề xuất và lý do:
- Acceptance criteria đo/kiểm thử được:
- Regression tests:
- Owner / ước lượng có giả định / phụ thuộc:
- Trạng thái retest / bằng chứng / người xác nhận:

## D. Kết quả chạy kiểm tra
| Lệnh/test | Môi trường | Kết quả thực tế | Bằng chứng | Giới hạn |
| --- | --- | --- | --- | --- |

## E. Dữ liệu còn thiếu
| Nội dung | Vì sao cần | Ai cung cấp | Quyết định đang bị chặn |
| --- | --- | --- | --- |

## F. Backlog và điều kiện gửi lại
[Theo mục 13 và 14]
```

Phương án thay thế không được chỉ ghi “tối ưu hơn”, “dùng package khác” hoặc “bỏ tính năng” mà không phân tích. Phải nêu loại giải pháp/ứng viên nếu đã xác minh, phần thay đổi, giá trị còn lại, yêu cầu dữ liệu/quyền, chi phí và điều kiện đủ để phát hành. Nếu chưa có lựa chọn tuân thủ khả thi, ghi rõ phải hoãn; không bịa phương án để lấp mẫu.

### Ví dụ minh họa một finding — không phải lỗi đã phát hiện trong app của bạn

**[F-DEMO] Chọn ảnh đại diện xin quyền đọc thư viện rộng trong khi chỉ cần một ảnh**

- Loại: POLICY nếu permission không đủ điều kiện theo quy định áp dụng; cần kiểm tra [S11] và artifact trước khi xác nhận. Mức: P1 khi vi phạm được xác nhận.
- Bằng chứng cần có: quyền trong merged manifest, màn hình xin quyền, luồng avatar và tài liệu plugin/version thực tế.
- Sửa chính: chuyển sang Android system photo picker qua tích hợp Flutter phù hợp; gỡ quyền đọc rộng nếu toàn app không cần.
- Thay thế: cho chọn avatar dựng sẵn hoặc dùng chữ cái tên, bỏ upload ảnh ở phiên bản đầu.
- Trade-off: picker giữ cá nhân hóa nhưng cần test API/lifecycle; avatar dựng sẵn giảm code/dữ liệu nhưng ít lựa chọn.
- Acceptance: cài mới không hỏi quyền đọc thư viện rộng; chọn/hủy/khôi phục đều đúng; manifest release không còn quyền thừa; cập nhật policy/Data safety nếu luồng dữ liệu thực tế đổi.

## 13. Backlog khắc phục và lựa chọn giải pháp

| Finding | Mức | Sửa chính | Thay thế | Lựa chọn + lý do | Phụ thuộc | Owner | Công sức + giả định | Acceptance/retest | Trạng thái |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Điền sau audit | | | | | | | | | |

Ưu tiên: P0 → POLICY/P1 → luồng chính → dữ liệu/tiền → UX/hiệu năng → bảo trì. Với mỗi phương án so sánh:

1. Có đáp ứng chính sách và đúng phạm vi quốc gia/đối tượng không?
2. Người dùng còn hoàn thành mục đích app không?
3. Cần thay code, backend, SDK, dữ liệu và form nào?
4. Mất bao nhiêu công sức với giả định nào? Ai chịu tải vận hành?
5. Bằng chứng nào gỡ blocker? Có tác dụng phụ/regression nào?

Không mặc định nâng toàn bộ dependencies hoặc viết lại kiến trúc là giải pháp tốt nhất. Chọn thay đổi giải quyết nguyên nhân với rủi ro chấp nhận được.

## 14. Quy tắc ra quyết định gửi

**CHƯA SẴN SÀNG** nếu có POLICY áp dụng CHƯA ĐẠT, P0/P1 chưa đóng, luồng chính không dùng được, hồ sơ sai hoặc reviewer không truy cập được.

**CHƯA ĐỦ BẰNG CHỨNG** nếu chưa có lỗi blocker xác nhận nhưng thiếu kiểm tra bắt buộc: artifact, quyền/SDK, dữ liệu, Console, chính sách đặc thù hoặc luồng trọng yếu. Ghi cụ thể phần cần bổ sung, không suy đoán “có lẽ đạt”.

**SẴN SÀNG GỬI** khi tất cả POLICY áp dụng có bằng chứng đạt, blocker đã retest, artifact cuối khớp hồ sơ và checklist mục 11 hoàn tất. P2/P3 còn lại phải được chấp nhận có người chịu trách nhiệm. Trạng thái này là kết luận nội bộ về mức sẵn sàng, Google vẫn quyết định kết quả review.

Sau mỗi thay đổi SDK, permission, backend, quốc gia, độ tuổi, quảng cáo hoặc cách kiếm tiền, rà lại phạm vi chính sách và khai báo thay vì chỉ chạy lại unit test.

## 15. Nguồn chính thức và cách cập nhật

Các liên kết dưới đây là điểm đối chiếu. Tại lần audit thực tế phải lưu ngày đọc, phần áp dụng và deadline; không đóng băng chính sách theo ngày của tài liệu này. Những nhánh chưa được kiểm tra đầy đủ phải giữ CHƯA XÁC MINH.

| Mã | Nguồn |
| --- | --- |
| S01 | [Create and set up your app](https://support.google.com/googleplay/android-developer/answer/9859152?hl=en) |
| S02 | [Target API level requirements](https://support.google.com/googleplay/android-developer/answer/11926878?hl=en) |
| S03 | [Testing requirements for new personal accounts](https://support.google.com/googleplay/android-developer/answer/14151465?hl=en) |
| S04 | [Flutter: Build and release an Android app](https://docs.flutter.dev/deployment/android) |
| S05 | [Android: Support 16 KB page sizes](https://developer.android.com/guide/practices/page-sizes) |
| S06 | [Android: Support 64-bit architectures](https://developer.android.com/google/play/requirements/64-bit) |
| S07 | [Prepare your app for review](https://support.google.com/googleplay/android-developer/answer/9859455?hl=en) |
| S08 | [Google Play: User Data](https://support.google.com/googleplay/android-developer/answer/10144311?hl=en) |
| S09 | [Provide information for the Data safety section](https://support.google.com/googleplay/android-developer/answer/10787469?hl=en) |
| S10 | [App account deletion requirements](https://support.google.com/googleplay/android-developer/answer/13327111?hl=en) |
| S11 | [Permissions and APIs that Access Sensitive Information](https://support.google.com/googleplay/android-developer/answer/16558241?hl=en) |
| S12 | [Functionality, Content, and User Experience](https://support.google.com/googleplay/android-developer/answer/9898783?hl=en) |
| S13 | [Spam](https://support.google.com/googleplay/android-developer/answer/9899034?hl=en) |
| S14 | [Payments](https://support.google.com/googleplay/android-developer/answer/9858738?hl=en) |
| S15 | [Subscriptions — từ trang Monetization and Ads](https://support.google.com/googleplay/android-developer/answer/9900533?hl=en) |
| S16 | [Ads](https://support.google.com/googleplay/android-developer/answer/9857753?hl=en) |
| S17 | [Android: Make apps more accessible](https://developer.android.com/guide/topics/ui/accessibility/apps) |
| S18 | [Developer Policy Center](https://play.google.com/about/developer-content-policy/) |
| S19 | [Play Console technical quality requirements](https://support.google.com/googleplay/android-developer/answer/17492799?hl=en) |

**Yêu cầu đầu ra cuối cùng:** người nhận báo cáo phải biết app đang vướng gì, bằng chứng ở đâu, sửa bằng cách nào, có thể thay bằng giải pháp nào, đánh đổi ra sao và kiểm tra thế nào để xác nhận đã giải quyết.
