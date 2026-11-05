#!/usr/bin/env python3
"""Export Google Play listing graphics from approved art and real Redmi captures."""

from pathlib import Path
import random

from PIL import Image, ImageDraw, ImageFilter, ImageFont


ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "assets/store/google-play"
OUT.mkdir(parents=True, exist_ok=True)
FONT = ROOT / "assets/fonts/Nunito.ttf"


def rgb(path: Path) -> Image.Image:
    return Image.open(path).convert("RGB")


def center_crop(image: Image.Image, width: int, height: int) -> Image.Image:
    target_ratio = width / height
    source_ratio = image.width / image.height
    if source_ratio > target_ratio:
        crop_width = round(image.height * target_ratio)
        left = (image.width - crop_width) // 2
        image = image.crop((left, 0, left + crop_width, image.height))
    else:
        crop_height = round(image.width / target_ratio)
        top = (image.height - crop_height) // 2
        image = image.crop((0, top, image.width, top + crop_height))
    return image.resize((width, height), Image.Resampling.LANCZOS)


def draw_center(draw: ImageDraw.ImageDraw, text: str, y: int, font: ImageFont.FreeTypeFont, fill: tuple[int, int, int]) -> None:
    bounds = draw.textbbox((0, 0), text, font=font)
    draw.text(((1080 - (bounds[2] - bounds[0])) / 2, y), text, font=font, fill=fill, stroke_width=1, stroke_fill=fill)


def export_icon() -> None:
    icon = rgb(ROOT / "assets/branding/app-icon-source.png")
    icon = center_crop(icon, 512, 512).convert("RGBA")
    icon.save(OUT / "app-icon-512.png", optimize=True)


def export_feature(filename: str, subtitle: str) -> None:
    art = rgb(OUT / "feature-art-source.png")
    feature = center_crop(art, 1024, 500)
    # A soft panel gives the title contrast without hiding the stage scene.
    veil = Image.new("RGBA", feature.size, (0, 0, 0, 0))
    layer = ImageDraw.Draw(veil)
    layer.rounded_rectangle((132, 70, 730, 250), radius=30, fill=(12, 19, 46, 145))
    veil = veil.filter(ImageFilter.GaussianBlur(10))
    feature = Image.alpha_composite(feature.convert("RGBA"), veil)
    draw = ImageDraw.Draw(feature)
    large = ImageFont.truetype(str(FONT), 62)
    small = ImageFont.truetype(str(FONT), 23)
    draw.text((156, 82), "LITTLE SHADOW", font=large, fill="#FFF3D8", stroke_width=2, stroke_fill="#FFF3D8")
    draw.text((156, 146), "THEATRE", font=large, fill="#FFF3D8", stroke_width=2, stroke_fill="#FFF3D8")
    draw.text((160, 224), subtitle, font=small, fill="#FFE7A0")
    feature.convert("RGB").save(OUT / filename, optimize=True)


SCREENS = [
    ("01-home.png", "BƯỚC VÀO RẠP BÓNG", "Một ngọn đèn. Cả thế giới chuyển động.", "docs/qa/twenty-stages/home-redmi-v2.png"),
    ("02-first-stage.png", "KÉO ĐÈN, DẪN BÓNG", "Đưa Bóng Mơ đến cửa trăng.", "docs/qa/home-timer/preview-redmi.png"),
    ("03-moving-obstacle.png", "CANH NHỊP CHỚP ĐỘNG", "Tìm lối đi qua vùng nguy hiểm.", "docs/qa/twenty-stages/playing-08-redmi-v2.png"),
    ("04-zigzag.png", "GIẢI ĐƯỜNG ZICZAC", "Thử thách mới qua từng màn.", "docs/qa/stage-zigzag/stage15-redmi.png"),
    ("05-victory.png", "THẮP SÁNG SÂN KHẤU", "Khoảnh khắc chiến thắng rực rỡ.", "docs/qa/stage-zigzag/win-effect-redmi.png"),
    ("06-languages.png", "TIẾNG VIỆT & ENGLISH", "Chọn ngôn ngữ trong Cài đặt.", "docs/qa/language/settings-vi-redmi.png"),
]

EN_SCREENS = [
    ("01-home.png", "ENTER THE SHADOW THEATRE", "One lamp. A world in motion.", "docs/qa/m7-2026-11-04/resume-home.png"),
    ("02-first-stage.png", "MOVE LIGHT, GUIDE SHADOW", "Lead the little shadow to the moon door.", "docs/qa/code-opt-2026-11-04/preview-redmi.png"),
    ("03-pause.png", "PLAY AT YOUR PACE", "Pause and continue when ready.", "docs/qa/code-opt-2026-11-04/pause-redmi.png"),
    ("04-languages.png", "VIETNAMESE & ENGLISH", "Switch language in Settings.", "docs/qa/language/settings-en-redmi.png"),
]


def export_screens(screens: list[tuple[str, str, str, str]], destination: Path) -> None:
    destination.mkdir(parents=True, exist_ok=True)
    for index, (filename, title, subtitle, source) in enumerate(screens):
        canvas = Image.new("RGB", (1080, 1920), "#10152F")
        draw = ImageDraw.Draw(canvas)
        # Restrained motifs on the side rails keep the genuine capture central.
        rng = random.Random(20261105 + index)
        for _ in range(52):
            x = rng.choice((rng.randrange(18, 117), rng.randrange(963, 1062)))
            y = rng.randrange(210, 1890)
            radius = rng.choice((1, 2, 3))
            draw.ellipse((x-radius, y-radius, x+radius, y+radius), fill="#53628C")
        draw.rounded_rectangle((105, 22, 975, 194), radius=28, fill="#191C42", outline="#FFC65A", width=4)
        draw_center(draw, title, 51, ImageFont.truetype(str(FONT), 48), (255, 243, 216))
        draw_center(draw, subtitle, 116, ImageFont.truetype(str(FONT), 27), (196, 200, 225))

        capture = rgb(ROOT / source)
        # Remove Android's status/navigation bars; retain the app image itself.
        capture = capture.crop((0, 96, capture.width, capture.height - 55))
        capture.thumbnail((820, 1690), Image.Resampling.LANCZOS)
        x = (1080 - capture.width) // 2
        y = 215 + (1690 - capture.height) // 2
        canvas.paste(capture, (x, y))
        draw.rounded_rectangle((x-6, y-6, x+capture.width+6, y+capture.height+6), radius=21, outline="#FFC65A", width=5)
        canvas.save(destination / filename, optimize=True)


if __name__ == "__main__":
    export_icon()
    export_feature("feature-graphic-1024x500.png", "ONE LAMP. A WORLD IN MOTION.")
    export_feature("feature-graphic-vi-1024x500.png", "MỘT NGỌN ĐÈN. CẢ THẾ GIỚI CHUYỂN ĐỘNG.")
    export_screens(SCREENS, OUT)
    export_screens(EN_SCREENS, OUT / "en-US")
    for path in sorted(OUT.rglob("*.png")):
        with Image.open(path) as image:
            print(path.relative_to(ROOT), image.size, image.mode, path.stat().st_size)
