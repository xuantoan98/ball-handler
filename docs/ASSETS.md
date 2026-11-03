# Asset nền sân khấu M2

## Bàn đèn M5 v3 (03/11/2026)

`assets/controls/lamp-desk-v3.webp` là ảnh trang trí 1121×510 RGB, WebP quality 84, SHA-256 `e58da7093888fefa40f6a2674a2436b4c99d36a65ea1618b8fae7d39c2a897a0`. Dùng built-in `image_gen` để chỉnh từ [preview v3](superpowers/specs/m5-control-preview-v3.png) đã duyệt: giữ viền vàng, mặt giấy lilac, lá và đèn lồng; xóa hình mặt trời, hào quang và hai trục chấm. Prompt yêu cầu mặt oval rộng, yên tĩnh và không có chữ/nút/vật có nghĩa va chạm. Đèn vàng thật tiếp tục vẽ bằng Flutter tại `attempt.lamp`; bitmap không quyết định vị trí hay hitbox.

## Âm thanh M5 (03/11/2026)

Nhạc `music.ogg` lấy nguyên bản `Heavenly Loop_0.ogg` của isaiah658 tại [OpenGameArt](https://opengameart.org/content/heavenly-loop), tác giả ghi CC0. Sáu file hiệu ứng lấy nguyên bản từ `ui_ogg.zip` của Robin Lamb tại [OpenGameArt](https://opengameart.org/content/ui-sound-effects-button-clicks-user-feedback-notifications), trang ghi CC0; nguồn gốc ban đầu là VCSL/VSCO 2 CE theo tác giả. Không biên tập hoặc đổi format; `win.ogg` và `gate.ogg` cùng dùng `chimes.ogg`. Quyền CC0-1.0 và URL gốc ghi thêm tại `assets/audio/LICENSE.md`. Âm lượng trong code: nhạc 1,0, hiệu ứng 0,32. Nhạc đã nghe được sau khi sửa audio focus nhưng còn quá nhỏ ở hệ số 0,55 trên Redmi; mức mới cần được nghe lại bằng tai để chốt.

| File | File gốc | SHA-256 |
| --- | --- | --- |
| `music.ogg` | `Heavenly Loop_0.ogg` | `a842e9e054019132cacc8fd352e7b31c000ebb51e0b227a2511e1bccb4eb166e` |
| `menu.ogg` | `click_2.ogg` | `da523b03e042dde09cf4633615a42ad733cfb35899c5863b0cb9486269c78cd9` |
| `switch.ogg` | `Ding.ogg` | `bc69b15effae9314e8afb86229bb83acdab6afd79d552b786f53a4812d902980` |
| `gate.ogg`, `win.ogg` | `chimes.ogg` | `bb9c1826553beb87e47a534f9608a7dcd236614bb6194f4323d4661df81e895e` |
| `wrong.ogg` | `ding_deep.ogg` | `7e61202079948a5bb7bb6bb37f22d3d367abdcfb9afd73a52e6f883a93de24be` |
| `collision.ogg` | `negative_sound2.ogg` | `a068c1a2a375149da67bb8e547079987800b1ce21debb7f51ca556eeeaabd56a` |

Đã xác minh Ogg Vorbis và checksum. Chưa có bằng chứng nghe/thẩm định mức âm bằng tai trên thiết bị ở thời điểm thêm file.

Ngày tạo: 21/10/2026. Công cụ: built-in `image_gen` (không dùng API key/CLI). Ảnh `design/Midnight Shadow Theatre Game Board.png` do chủ sản phẩm cung cấp được dùng làm **tham chiếu phong cách**, không cắt thành sprite hoặc dùng làm dữ liệu va chạm. Ba file 1024 × 1536 RGB được đưa vào `assets/backgrounds/` và chỉ vẽ ở lớp hậu cảnh. Vật thể gameplay, chữ và nút vẫn được vẽ riêng bằng Flutter.

| Màn | File | Chủ đề |
| --- | --- | --- |
| 01 | `assets/backgrounds/stage-01.png` | Sân khấu lâu đài giấy, ánh hổ phách |
| 02 | `assets/backgrounds/stage-02.png` | Vườn tím đêm, vùng giữa tối để cảm biến coral rõ |
| 03 | `assets/backgrounds/stage-03.png` | Xưởng bánh răng giấy, hành lang giữa thoáng |

## Prompt đã dùng

### Màn 01

> Use case: stylized-concept. Asset type: a production game background layer for level 1, portrait 2:3 stage wall only (not a full UI screen). The attached approved design is STYLE REFERENCE ONLY. Create a polished, richly layered paper-cut midnight shadow theatre backdrop: indigo and plum handmade paper texture, ornate dark scalloped curtains/clouds across the very top edge, tiny warm hanging stars limited to upper edge, delicate distant castle silhouettes and foliage near side and bottom edges, warm amber atmospheric glow in the central wall. The central 75% of the image must remain clear, low-detail and readable for a moving dark shadow character and gameplay overlays; maintain strong contrast. High-quality illustration with visible fine paper grain, cut-paper depth, gold edge highlights, soft intentional lighting. No text, letters, numbers, buttons, frames, lamp, moon door, shadow character, switch, hazard, gate, or other gameplay object. No watermark. Full-bleed vertical art.

### Màn 02

> Use case: stylized-concept. Asset type: production game background layer for level 2, portrait 2:3 stage wall only, not a complete UI. The attached approved design is STYLE REFERENCE ONLY. Create a polished midnight paper-cut theatre garden: deep indigo textured paper wall, plum scalloped curtains/clouds at top edge, subdued purple foliage and layered paper flowers along the far left and right edges, a few small hanging warm gold stars near top, intricate gold-cut edge highlights and tactile paper grain. Keep central 75% clear, dark, and low-detail so a bright coral hazard stripe, mint door, and moving shadow character will be maximally legible when rendered separately. No coral/red flowers or other red marks, because coral is reserved for the hazard. No text, letters, numbers, buttons, frames, lamp, moon door, shadow character, switch, hazard, gate, or other gameplay object. No watermark. Full-bleed vertical art.

### Màn 03

> Use case: stylized-concept. Asset type: production game background layer for level 3, portrait 2:3 stage wall only, not a complete UI. The attached approved design is STYLE REFERENCE ONLY. Create a polished midnight paper-cut theatre workshop: deep textured navy and plum paper wall, ornate scalloped curtains at the top, intricate antique brass paper gears, clockwork details and tiny warm hanging stars confined to top and far side edges, layered cut-paper depth and fine grain, warm gold edge highlights. Keep central 75% open, dark and low-detail so a mint switch, a thin vertical barrier, mint moon door and moving shadow character remain readable when rendered as separate interactive layers. No text, letters, numbers, buttons, frames, lamp, moon door, shadow character, switch, hazard, gate, or other gameplay object. No watermark. Full-bleed vertical art.

Chưa đo dung lượng/memory và FPS trên điện thoại thật. Nếu asset thay đổi, giữ nguyên ranh giới: ảnh chỉ là nền, không được vẽ vật có ý nghĩa va chạm vào ảnh.

## Trang chủ v2 (02/11/2026)

`assets/backgrounds/home-stage-v2.png` (863 × 1823) được tạo bằng built-in `image_gen`, với ảnh do chủ sản phẩm cung cấp `design/Whimsical Shadow Theatre UI Kit.png` làm style reference. Bản concept gốc ở `docs/superpowers/specs/home-stage-concept-v2.png`; [preview có lớp chữ và nút](superpowers/specs/home-preview-v2.png) đã được chủ sản phẩm duyệt. Chỉ tranh sân khấu là bitmap; tiêu đề, câu giới thiệu, nút, lượt và popup là Flutter widget thật. Bóng/cửa/đèn trong tranh chỉ dùng nhận diện ở trang chủ, không có va chạm.

Prompt gốc: “Create a NEW single portrait mobile game HOME SCREEN art plate, 9:19 aspect ratio, in the exact visual identity and craftsmanship of the reference Whimsical Shadow Theatre UI Kit. Rich layered paper-cut midnight theatre: deep navy and plum backdrop, hand-cut gold ornamental border with filigree corners, partially opened velvet burgundy curtains, warm hanging lanterns, tiny gold stars, distant purple castle silhouettes. In the central illustration, a cute small flat black shadow puppet with two warm cream eyes and a slightly tilted three-point gold paper crown; to its right a luminous mint crescent moon door, to its left a warm yellow sun-shaped lamp. Keep lower central area and top central area dark and clear for live Flutter text and controls. Absolutely no letters, words, numbers, button labels or UI text. No advertising, no phone mockup, no gameplay obstacle geometry.”

## Hai mươi nền sân khấu v2 (02/11/2026)

`assets/backgrounds/stage-01-v2.webp` đến `stage-20-v2.webp` được tạo bằng built-in `image_gen`, mỗi màn một lệnh/ảnh riêng, dùng `home-stage-v2.png` và `design/Whimsical Shadow Theatre UI Kit.png` làm **style reference**, không cắt ghép asset người khác. Tất cả là tường hậu cảnh trang trí; Bóng Mơ, đèn, cửa, đạo cụ, cảm biến, sao, chữ và hitbox được vẽ từ Flutter/rules. Ảnh gốc 863×1823 RGBA được chuyển sang WebP quality 92 bằng Pillow để đóng gói; 20 file còn 11.76 MB. Game giải mã từng ảnh khi đổi màn và giải phóng ảnh trước. Cần đo FPS/bộ nhớ trên máy trước khi coi là release-ready.

Khi vẽ vào tường 360×480, `GamePainter` giữ tỷ lệ gốc của họa tiết ở đầu/cuối ảnh và nối trong vùng giấy tối giữa ảnh bằng fade ngắn. Cách này giữ rèm, đèn lồng và viền vàng không bị kéo giãn ngang; vùng ghép không tham gia va chạm.

| Màn | Cảnh riêng ở mép tường | Màn | Cảnh riêng ở mép tường |
| --- | --- | --- | --- |
| 01 | Rèm mở, lâu đài xa | 11 | Hai mặt đồng hồ cổ |
| 02 | Vườn gai hổ phách | 12 | Đài thiên văn giấy |
| 03 | Tháp đồng hồ mở màn | 13 | Sách mở đầu thư viện |
| 04 | Gốc cây trăng | 14 | Hành lang giá sách |
| 05 | Hồ lá tím | 15 | Phòng bản đồ trăng |
| 06 | Nhà kính trăng | 16 | Gác chuông giấy |
| 07 | Cổng hoa khuya | 17 | Rèm mở thiên hà |
| 08 | Màn chớp đầu tiên ở xưởng | 18 | Quỹ đạo trăng giấy |
| 09 | Bánh răng ngập sao | 19 | Rèm cuối và lâu đài xa |
| 10 | Ròng rọc giấy | 20 | Đại cảnh Rạp bóng nhỏ |

Prompt chung, với `{id}` và `{scene}` thay cho từng dòng trong bảng: “Use case: stylized-concept. Asset type: PRODUCTION DECORATIVE BACKGROUND WALL ONLY for level {id} of a portrait mobile shadow-puppet puzzle game. Style reference images: supplied home-stage and UI Kit. Unique scene: {scene}. Exquisite layered hand-cut paper theatre, deep navy and plum, restrained antique-gold filigree, fine grain, warm edge lantern light and depth equal to the polished home screen. Flat-on portrait wall, central 72 percent clean dark low-detail blue-violet paper for a small black projected shadow and separate collision objects; scenery concentrated along top, side and bottom perimeter. No walkable floor or platform illusion. No puppet, moon exit, sun lamp, coral/red danger, mint switch, gate, hazard, UI, text, letters, numbers, watermark. All interactive elements will be rendered separately from Flutter collision data.” Nhóm 01–04 dùng cùng ý nghĩa câu lệnh này với mô tả dài hơn cho từng cảnh và thêm ảnh Game Board làm reference chức năng.
