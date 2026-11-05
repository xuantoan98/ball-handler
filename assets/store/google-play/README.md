# Little Shadow Theatre — Google Play graphics

| File | Size | Description |
| --- | --- | --- |
| `app-icon-512.png` | 512 × 512, RGBA | Store icon from the approved 1254 × 1254 app icon. |
| `feature-graphic-1024x500.png` | 1024 × 500, RGB | Promotional cut-paper theatre illustration, title added using the game's Nunito font. |
| `feature-graphic-vi-1024x500.png` | 1024 × 500, RGB | Same illustration with a Vietnamese tagline. |
| `01-home.png` | 1080 × 1920, RGB | Home. |
| `02-first-stage.png` | 1080 × 1920, RGB | First stage and lamp/shadow tutorial. |
| `03-moving-obstacle.png` | 1080 × 1920, RGB | Moving hazard during play. |
| `04-zigzag.png` | 1080 × 1920, RGB | Later-stage zigzag layout. |
| `05-victory.png` | 1080 × 1920, RGB | Completion effect. |
| `06-languages.png` | 1080 × 1920, RGB | Vietnamese/English setting. |
| `en-US/01-home.png`–`04-languages.png` | 1080 × 1920, RGB | Four localized English screenshots. |

Screenshots are composed from **actual Redmi K30 5G captures** in `docs/qa`; only Android status/navigation bars were trimmed, the UI was resized without changing its content, and a caption/frame was added. The feature graphic is an illustration, not a gameplay screenshot. The six root screenshots use Vietnamese UI; the four `en-US` screenshots use English UI. Sources and export logic: `feature-art-source.png`, `assets/branding/app-icon-source.png`, and `tool/export_play_graphics.py`. Listing copy and plan: [ASO.md](ASO.md), [vi-VN](listing-vi-VN.md), [en-US](listing-en-US.md).

Google Play currently specifies [512 × 512 PNG for the store icon, 1024 × 500 PNG/JPEG for the feature graphic, and up to eight screenshots per phone type](https://support.google.com/googleplay/android-developer/answer/9866151). Do not upload `feature-art-source.png`; it is the editable source for the final feature graphic.
