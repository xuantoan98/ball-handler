"""Export launcher and web icons from the approved square source artwork.

Run from the repository root: python3 tool/generate_app_icons.py
Requires Pillow for asset authoring only.
"""

from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "assets/branding/app-icon-source.png"


def export(image: Image.Image, path: Path, size: int) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    image.resize((size, size), Image.Resampling.LANCZOS).save(
        path, format="PNG", optimize=True
    )


def main() -> None:
    image = Image.open(SOURCE).convert("RGB")
    if image.width != image.height or image.width < 1024:
        raise ValueError("App icon source must be square and at least 1024 px")

    for density, legacy_size in (
        ("mdpi", 48),
        ("hdpi", 72),
        ("xhdpi", 96),
        ("xxhdpi", 144),
        ("xxxhdpi", 192),
    ):
        mipmap = ROOT / f"android/app/src/main/res/mipmap-{density}"
        export(image, mipmap / "ic_launcher.png", legacy_size)
        export(image, mipmap / "ic_launcher_foreground.png", int(legacy_size * 2.25))

    for name, size in (
        ("Icon-192.png", 192),
        ("Icon-512.png", 512),
        ("Icon-maskable-192.png", 192),
        ("Icon-maskable-512.png", 512),
    ):
        export(image, ROOT / "web/icons" / name, size)
    export(image, ROOT / "web/favicon.png", 64)
    print("Exported Android legacy/adaptive and web icons from", SOURCE)


if __name__ == "__main__":
    main()
