#!/usr/bin/env python3
# Импорт четырнадцати исходных PPTX, по пять слайдов из каждой презентации.
# Slide 6 in every presentation is deliberately excluded.
import argparse
import asyncio
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile

try:
    import fitz  # pymupdf
    from pptx import Presentation
except ImportError:
    sys.exit("Установите зависимости: python -m pip install -r tools/requirements-import.txt")

ROOT = Path(__file__).resolve().parent.parent
OUT_SLIDES = ROOT / "assets" / "slides"
OUT_AUDIO = ROOT / "assets" / "audio"
OUT_NOTES = ROOT / "assets" / "content" / "notes.json"
SECTIONS = set(range(4, 18))

def convert_with_office(source: Path, output: Path):
    if sys.platform == "win32":
        try:
            import win32com.client
            office = win32com.client.DispatchEx("PowerPoint.Application")
            try:
                obj = office.Presentations.Open(str(source.resolve()), WithWindow=False)
                try:
                    obj.SaveAs(str(output.resolve()), 32)  # 32 = PDF
                finally:
                    obj.Close()
            finally:
                office.Quit()
            if output.exists():
                return
        except Exception as exc:
            print("PowerPoint COM недоступен, пробуем LibreOffice:", exc)
    soffice = shutil.which("soffice") or shutil.which("libreoffice")
    if soffice is None:
        raise RuntimeError("Нужен установленный Microsoft PowerPoint (Windows) или LibreOffice.")
    cmd = [soffice, "--headless", "--convert-to", "pdf", "--outdir",
           str(output.parent), str(source)]
    p = subprocess.run(cmd, capture_output=True, text=True, timeout=180)
    if p.returncode != 0 or not output.exists():
        raise RuntimeError("Ошибка конвертации: " + p.stdout + " " + p.stderr)

def extract_text(slide):
    notes = ""
    try:
        frame = slide.notes_slide.notes_text_frame
        if frame:
            notes = "\n".join(line.strip() for line in frame.text.splitlines()
                              if line.strip() and not re.match(r"^\d+$", line.strip()))
    except Exception:
        pass
    if notes and len(notes) > 35:
        return notes.strip()
    texts = []
    for shape in slide.shapes:
        if getattr(shape, "has_text_frame", False) and shape.text.strip():
            texts.append(shape.text.strip())
    return ". ".join(texts)[:1800]

async def make_audio(data: dict, voice: str, rate: str):
    try:
        import edge_tts
    except ImportError:
        raise RuntimeError("Для аудио: python -m pip install edge-tts")
    OUT_AUDIO.mkdir(parents=True, exist_ok=True)
    for key, narration in data.items():
        path = OUT_AUDIO / (key + ".mp3")
        if not narration:
            print("Пропуск пустой озвучки:", key)
            continue
        communicate = edge_tts.Communicate(narration, voice, rate=rate)
        await communicate.save(str(path))
        print("Аудио:", path.name)

def main():
    ap = argparse.ArgumentParser(description="Импорт 14 PPTX в 70 уроков Flutter")
    ap.add_argument("pptx_dir", type=Path, help="Папка с исходными PPTX (разделы 04–17)")
    ap.add_argument("--audio", action="store_true",
                    help="Создать MP3 по заметкам через сетевой TTS (требуется интернет)")
    ap.add_argument("--voice", default="ru-RU-SvetlanaNeural")
    ap.add_argument("--rate", default="-12%")
    args = ap.parse_args()
    if not args.pptx_dir.is_dir():
        ap.error("Папка не найдена")
    paths = {}
    for p in args.pptx_dir.glob("*.pptx"):
        m = re.search(r"(?:Раздел|Razdel)[_\s-]*(\d{2})", p.name, re.I)
        if m:
            index = int(m.group(1))
            if index in SECTIONS:
                if index in paths:
                    ap.error("Несколько файлов раздела " + str(index))
                paths[index] = p
    absent = SECTIONS - paths.keys()
    if absent:
        ap.error("Не найдены презентации разделов: " + ", ".join(map(str, sorted(absent))))
    OUT_SLIDES.mkdir(parents=True, exist_ok=True)
    OUT_NOTES.parent.mkdir(parents=True, exist_ok=True)
    notes = {}
    with tempfile.TemporaryDirectory() as temp:
        t = Path(temp)
        for n in sorted(paths):
            original = paths[n]
            deck = Presentation(str(original))
            if len(deck.slides) != 6:
                raise RuntimeError(original.name + ": ожидалось 6 слайдов, найдено " + str(len(deck.slides)))
            pdf = t / (original.stem + ".pdf")
            convert_with_office(original, pdf)
            doc = fitz.open(str(pdf))
            if len(doc) < 5:
                raise RuntimeError(original.name + ": после преобразования получено меньше 5 страниц")
            for i in range(5):   # deliberately skips the sixth slide
                key = f"{n:02d}_{i+1:02d}"
                pix = doc[i].get_pixmap(matrix=fitz.Matrix(1.4, 1.4), alpha=False)
                pix.save(str(OUT_SLIDES / (key + ".png")))
                notes[key] = extract_text(deck.slides[i])
                print("Слайд", key)
            doc.close()
    OUT_NOTES.write_text(json.dumps(notes, ensure_ascii=False, indent=2), encoding="utf-8")
    if len(notes) != 70:
        raise RuntimeError("Не сформированы 70 слайдов")
    print("ГОТОВО: 70 PNG, шестые слайды исключены.")
    if args.audio:
        print("Создаём аудио. Убедитесь, что права на коммерческое использование голоса согласованы.")
        asyncio.run(make_audio(notes, args.voice, args.rate))
if __name__ == "__main__":
    main()
