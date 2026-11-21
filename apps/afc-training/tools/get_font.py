#!/usr/bin/env python3
"""Download the open-license Noto Sans Cyrillic font before building an offline certificate app."""
from pathlib import Path
from urllib.request import urlopen, Request
target=Path(__file__).resolve().parent.parent/"assets"/"fonts"/"NotoSans-Regular.ttf"
url="https://raw.githubusercontent.com/googlefonts/noto-fonts/main/hinted/ttf/NotoSans/NotoSans-Regular.ttf"
target.parent.mkdir(parents=True,exist_ok=True)
if target.exists() and target.stat().st_size > 20000:
    print("Шрифт уже установлен:",target)
else:
    with urlopen(Request(url,headers={"User-Agent":"AFC-Training/2.0"}), timeout=45) as response:
        raw=response.read()
    if len(raw) < 20000 or raw[:4] not in (b"\x00\x01\x00\x00", b"OTTO", b"true"):
        raise ValueError("Некорректный файл шрифта")
    target.write_bytes(raw)
    print("Получен Unicode-шрифт для офлайн-сертификатов:",target)
print("Лицензия Noto Fonts: SIL Open Font License; перед коммерческим распространением проверьте условия и NOTICE.")
