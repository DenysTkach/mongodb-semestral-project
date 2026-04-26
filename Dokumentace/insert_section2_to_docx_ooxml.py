from __future__ import annotations

import re
import shutil
import sys
import xml.etree.ElementTree as ET
from pathlib import Path
from zipfile import ZIP_DEFLATED, ZipFile


ROOT = Path(__file__).resolve().parents[1]
SOURCE_DOCX = ROOT / "Data" / "Pdf_sema" / "docx" / "MongoDB-Denys-Tkach.docx"
OUTPUT_DOCX = ROOT / "Data" / "Pdf_sema" / "docx" / "MongoDB-Denys-Tkach-draft.docx"
MARKDOWN = ROOT / "Dokumentace" / "architektura-prepis.md"

W_NS = "http://schemas.openxmlformats.org/wordprocessingml/2006/main"
XML_NS = "http://www.w3.org/XML/1998/namespace"
ET.register_namespace("w", W_NS)


def w(tag: str) -> str:
    return f"{{{W_NS}}}{tag}"


def paragraph_text(paragraph: ET.Element) -> str:
    parts: list[str] = []
    for node in paragraph.iter():
        if node.tag == w("t") and node.text:
            parts.append(node.text)
    return re.sub(r"\s+", " ", "".join(parts)).strip()


def make_text_run(text: str, *, bold: bool = False, code: bool = False) -> ET.Element:
    run = ET.Element(w("r"))
    if bold or code:
        rpr = ET.SubElement(run, w("rPr"))
        if bold:
            ET.SubElement(rpr, w("b"))
        if code:
            fonts = ET.SubElement(rpr, w("rFonts"))
            fonts.set(w("ascii"), "Consolas")
            fonts.set(w("hAnsi"), "Consolas")
            size = ET.SubElement(rpr, w("sz"))
            size.set(w("val"), "18")

    t = ET.SubElement(run, w("t"))
    if text.startswith(" ") or text.endswith(" "):
        t.set(f"{{{XML_NS}}}space", "preserve")
    t.text = text
    return run


def make_paragraph(text: str, style: str = "af8", *, code: bool = False) -> ET.Element:
    paragraph = ET.Element(w("p"))
    ppr = ET.SubElement(paragraph, w("pPr"))
    pstyle = ET.SubElement(ppr, w("pStyle"))
    pstyle.set(w("val"), style)
    paragraph.append(make_text_run(text.replace("`", ""), code=code))
    return paragraph


def make_table(rows: list[list[str]]) -> ET.Element:
    table = ET.Element(w("tbl"))

    tbl_pr = ET.SubElement(table, w("tblPr"))
    borders = ET.SubElement(tbl_pr, w("tblBorders"))
    for edge in ["top", "left", "bottom", "right", "insideH", "insideV"]:
        border = ET.SubElement(borders, w(edge))
        border.set(w("val"), "single")
        border.set(w("sz"), "4")
        border.set(w("space"), "0")
        border.set(w("color"), "auto")

    tbl_grid = ET.SubElement(table, w("tblGrid"))
    col_count = max((len(row) for row in rows), default=0)
    for _ in range(col_count):
        grid_col = ET.SubElement(tbl_grid, w("gridCol"))
        grid_col.set(w("w"), "2500")

    for row_index, row in enumerate(rows):
        tr = ET.SubElement(table, w("tr"))
        for cell_text in row:
            tc = ET.SubElement(tr, w("tc"))
            tc_pr = ET.SubElement(tc, w("tcPr"))
            tc_w = ET.SubElement(tc_pr, w("tcW"))
            tc_w.set(w("w"), "2500")
            tc_w.set(w("type"), "dxa")

            p = ET.SubElement(tc, w("p"))
            ppr = ET.SubElement(p, w("pPr"))
            pstyle = ET.SubElement(ppr, w("pStyle"))
            pstyle.set(w("val"), "af8")
            p.append(make_text_run(cell_text.replace("`", ""), bold=(row_index == 0)))

    return table


def parse_markdown_table(lines: list[str]) -> list[list[str]]:
    rows: list[list[str]] = []
    separator = re.compile(r"^\|?\s*:?-{3,}:?\s*(\|\s*:?-{3,}:?\s*)+\|?$")
    for line in lines:
        stripped = line.strip()
        if separator.match(stripped):
            continue
        cells = [cell.strip().strip("`") for cell in stripped.strip("|").split("|")]
        rows.append(cells)
    return rows


def clean_heading(text: str) -> str:
    return re.sub(r"^\d+(\.\d+)*\s+", "", text.strip())


def is_list_line(text: str) -> bool:
    return text.startswith("- ") or bool(re.match(r"^\d+\.\s+", text))


def markdown_section_nodes(lines: list[str]) -> list[ET.Element]:
    nodes: list[ET.Element] = []
    i = 0

    while i < len(lines):
        line = lines[i]
        stripped = line.strip()

        if not stripped:
            i += 1
            continue

        if stripped.startswith("```"):
            i += 1
            code_lines: list[str] = []
            while i < len(lines) and not lines[i].strip().startswith("```"):
                code_lines.append(lines[i].rstrip())
                i += 1
            if i < len(lines):
                i += 1
            for code_line in code_lines:
                nodes.append(make_paragraph(code_line, code=True))
            continue

        if stripped.startswith("|") and i + 1 < len(lines) and lines[i + 1].strip().startswith("|"):
            table_lines: list[str] = []
            while i < len(lines) and lines[i].strip().startswith("|"):
                table_lines.append(lines[i])
                i += 1
            nodes.append(make_table(parse_markdown_table(table_lines)))
            continue

        if stripped.startswith("#### "):
            nodes.append(make_paragraph(clean_heading(stripped[5:]), "3"))
            i += 1
            continue

        if stripped.startswith("### "):
            heading = clean_heading(stripped[4:])
            style = "3" if "docker-compose" in heading else "2"
            nodes.append(make_paragraph(heading, style))
            i += 1
            continue

        if stripped.startswith("## "):
            heading = clean_heading(stripped[3:])
            style = "Nadpis1-bezsla" if heading == "Úvod" else "1"
            nodes.append(make_paragraph(heading, style))
            i += 1
            continue

        if is_list_line(stripped):
            nodes.append(make_paragraph(stripped))
            i += 1
            continue

        paragraph_lines = [stripped]
        i += 1
        while (
            i < len(lines)
            and lines[i].strip()
            and not lines[i].strip().startswith("#")
            and not lines[i].strip().startswith("|")
            and not lines[i].strip().startswith("```")
            and not is_list_line(lines[i].strip())
        ):
            paragraph_lines.append(lines[i].strip())
            i += 1

        nodes.append(make_paragraph(" ".join(paragraph_lines)))

    return nodes


def documentation_lines() -> list[str]:
    lines = MARKDOWN.read_text(encoding="utf-8").splitlines()
    for index, line in enumerate(lines):
        if line.startswith("## Úvod"):
            return lines[index:]
    raise RuntimeError("Documentation content was not found in markdown file.")


def markdown_section_lines(section_number: str) -> list[str]:
    lines = MARKDOWN.read_text(encoding="utf-8").splitlines()
    start_index = None
    start_marker = f"## {section_number} "
    next_section = str(int(section_number) + 1)
    next_marker = f"## {next_section} "

    for index, line in enumerate(lines):
        if line.startswith(start_marker):
            start_index = index
            break

    if start_index is None:
        raise RuntimeError(f"Section {section_number} was not found in markdown file.")

    end_index = len(lines)
    for index in range(start_index + 1, len(lines)):
        if lines[index].startswith(next_marker):
            end_index = index
            break

    return lines[start_index:end_index]


def replace_documentation_block() -> None:
    if not SOURCE_DOCX.exists():
        raise FileNotFoundError(SOURCE_DOCX)

    shutil.copyfile(SOURCE_DOCX, OUTPUT_DOCX)

    with ZipFile(OUTPUT_DOCX, "r") as zin:
        files = {name: zin.read(name) for name in zin.namelist()}

    document_xml = files["word/document.xml"]
    root = ET.fromstring(document_xml)
    body = root.find(w("body"))
    if body is None:
        raise RuntimeError("Word body was not found.")

    children = list(body)
    start_index = None
    end_index = None

    for idx, child in enumerate(children):
        if child.tag != w("p"):
            continue
        text = paragraph_text(child)
        if start_index is None and idx > 10 and text == "Úvod":
            start_index = idx
            continue
        if start_index is not None and text == "Případy užití a případové studie":
            end_index = idx
            break

    if start_index is None or end_index is None:
        raise RuntimeError("Could not locate section 2 boundaries in the Word document.")

    new_nodes = markdown_section_nodes(documentation_lines())

    for child in children[start_index:end_index]:
        body.remove(child)

    for offset, node in enumerate(new_nodes):
        body.insert(start_index + offset, node)

    files["word/document.xml"] = ET.tostring(root, encoding="utf-8", xml_declaration=True)

    with ZipFile(OUTPUT_DOCX, "w", ZIP_DEFLATED) as zout:
        for name, data in files.items():
            zout.writestr(name, data)


def replace_section_in_docx(
    source_docx: Path,
    output_docx: Path,
    section_heading: str,
    next_heading: str,
    markdown_lines: list[str],
) -> None:
    if not source_docx.exists():
        raise FileNotFoundError(source_docx)

    if source_docx.resolve() != output_docx.resolve():
        shutil.copyfile(source_docx, output_docx)

    with ZipFile(output_docx, "r") as zin:
        files = {name: zin.read(name) for name in zin.namelist()}

    root = ET.fromstring(files["word/document.xml"])
    body = root.find(w("body"))
    if body is None:
        raise RuntimeError("Word body was not found.")

    children = list(body)
    start_index = None
    end_index = None

    for idx, child in enumerate(children):
        if child.tag != w("p"):
            continue
        text = paragraph_text(child)
        if start_index is None and text == section_heading:
            start_index = idx
            continue
        if start_index is not None and text == next_heading:
            end_index = idx
            break

    if start_index is None or end_index is None:
        raise RuntimeError(
            f"Could not locate section boundaries: {section_heading} -> {next_heading}"
        )

    new_nodes = markdown_section_nodes(markdown_lines)

    for child in children[start_index:end_index]:
        body.remove(child)

    for offset, node in enumerate(new_nodes):
        body.insert(start_index + offset, node)

    files["word/document.xml"] = ET.tostring(root, encoding="utf-8", xml_declaration=True)

    with ZipFile(output_docx, "w", ZIP_DEFLATED) as zout:
        for name, data in files.items():
            zout.writestr(name, data)


if __name__ == "__main__":
    try:
        replace_documentation_block()
    except Exception as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        raise
    print(OUTPUT_DOCX)
