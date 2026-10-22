# Asset nền sân khấu M2

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
