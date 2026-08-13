// Builds Runiac_User_Manual.docx from docs/user-manual/RUNIAC_USER_MANUAL.md
//
// Differences from the final-report builder this is derived from:
//   * one source file, not eleven chapters
//   * the source markdown is hard-wrapped, so paragraphs are reflowed from
//     consecutive non-blank lines rather than one paragraph per line
//   * `> ...` blockquotes become boxed Note / Caution / Warning callouts
//   * `![alt](path){ width=NN% }` is honoured: 95% is a full-width web or
//     console capture, 38% a portrait phone screenshot
//   * every figure gets a numbered caption derived from its alt text, a
//     bookmark, and an entry in a List of Figures with live PAGEREF fields

const fs = require('fs');
const path = require('path');
const D = require('docx');
const {
  Document, Packer, Paragraph, TextRun, HeadingLevel, AlignmentType,
  Table, TableRow, TableCell, WidthType, ShadingType, BorderStyle,
  TableOfContents, PageBreak, Header, Footer, PageNumber,
  VerticalAlign, convertInchesToTwip, ImageRun, Bookmark, InternalHyperlink,
  PageReference, TabStopType,
} = D;

const dir = __dirname;
const BODY_FONT = 'Times New Roman';
const CONTENT_WIDTH = 9026;   // A4 portrait minus 1" margins, in DXA
const HEADING_COLOR = '000000';

// ---------- inline markdown -> TextRun[] ----------
function inlineRuns(text, base = {}) {
  const runs = [];
  const re = /(\*\*[^*]+\*\*|\*[^*]+\*|`[^`]+`)/g;
  let last = 0, m;
  const push = (t, opts) => {
    if (t === '') return;
    runs.push(new TextRun({ text: t, font: BODY_FONT, ...base, ...opts }));
  };
  while ((m = re.exec(text)) !== null) {
    push(text.slice(last, m.index), {});
    const tok = m[0];
    // Bold and italic spans may contain `code`, so their contents are parsed
    // again rather than emitted as one literal run.
    if (tok.startsWith('**')) runs.push(...inlineRuns(tok.slice(2, -2), { ...base, bold: true }));
    else if (tok.startsWith('`')) push(tok.slice(1, -1), { font: 'Consolas', size: (base.size || 22) - 2 });
    else runs.push(...inlineRuns(tok.slice(1, -1), { ...base, italics: true }));
    last = m.index + tok.length;
  }
  push(text.slice(last), {});
  if (runs.length === 0) push(' ', {});
  return runs;
}

function plain(text) {
  return text.replace(/\*\*/g, '').replace(/`/g, '').replace(/\*/g, '').trim();
}

function bodyPara(text, opts = {}) {
  return new Paragraph({
    children: inlineRuns(text, { size: 22 }),
    spacing: { after: 160, line: 276 },
    alignment: AlignmentType.JUSTIFIED,
    ...opts,
  });
}

// ---------- images ----------
const IMG_MAX_W = 600;   // px, the full content width at 96dpi
const IMG_MAX_H = 700;
const TALL_MAX_H = 340;  // px, cap for portrait phone screenshots — two per page

function pngSize(buf) {
  if (buf.length > 24 && buf.readUInt32BE(0) === 0x89504e47) {
    return { w: buf.readUInt32BE(16), h: buf.readUInt32BE(20), type: 'png' };
  }
  return jpgSize(buf);
}

function jpgSize(buf) {
  if (buf.length < 4 || buf[0] !== 0xff || buf[1] !== 0xd8) return null;
  let i = 2;
  while (i + 9 < buf.length) {
    if (buf[i] !== 0xff) { i += 1; continue; }
    const marker = buf[i + 1];
    if (marker === 0xd8 || marker === 0x01 || (marker >= 0xd0 && marker <= 0xd7)) { i += 2; continue; }
    const len = buf.readUInt16BE(i + 2);
    const isSOF = marker >= 0xc0 && marker <= 0xcf
      && marker !== 0xc4 && marker !== 0xc8 && marker !== 0xcc;
    if (isSOF) return { h: buf.readUInt16BE(i + 5), w: buf.readUInt16BE(i + 7), type: 'jpg' };
    i += 2 + len;
  }
  return null;
}

const missing = [];

function imagePara(relPath, widthPct) {
  const abs = path.isAbsolute(relPath) ? relPath : path.join(dir, relPath);
  if (!fs.existsSync(abs)) {
    missing.push(relPath);
    return new Paragraph({
      alignment: AlignmentType.CENTER,
      children: [new TextRun({ text: `[missing image: ${relPath}]`, font: BODY_FONT, size: 20, italics: true, color: 'B03030' })],
    });
  }
  const buf = fs.readFileSync(abs);
  const nat = pngSize(buf) || { w: IMG_MAX_W, h: IMG_MAX_H, type: 'png' };

  // A portrait phone screenshot is capped by height so that a figure, its
  // caption and a paragraph of text share a page. A wide web or console
  // capture is bounded by the content width instead.
  const portrait = nat.w / nat.h < 0.75;
  const maxW = portrait ? IMG_MAX_W : Math.round(IMG_MAX_W * ((widthPct || 95) / 95));
  const maxH = portrait ? TALL_MAX_H : IMG_MAX_H;
  const scale = Math.min(maxW / nat.w, maxH / nat.h, 1);

  return new Paragraph({
    alignment: AlignmentType.CENTER,
    spacing: { before: 140, after: 20 },
    keepNext: true,
    children: [new ImageRun({
      data: buf,
      type: nat.type,
      transformation: { width: Math.round(nat.w * scale), height: Math.round(nat.h * scale) },
    })],
  });
}

// ---------- figure numbering ----------
const figures = [];   // { label, title, bookmark }
let figSection = '1';
let figCounter = 0;

function setFigSection(sec) {
  if (sec !== figSection) { figSection = sec; figCounter = 0; }
}

function figureCaption(altText) {
  figCounter += 1;
  const label = `Figure ${figSection}.${figCounter}`;
  const title = plain(altText) || 'Screen';
  const bookmark = `fig_${label.replace(/[^0-9]/g, '_')}_${figures.length}`;
  figures.push({ label, title, bookmark });
  return new Paragraph({
    alignment: AlignmentType.CENTER,
    spacing: { before: 0, after: 240 },
    children: [new Bookmark({
      id: bookmark,
      children: [
        new TextRun({ text: `${label} — `, font: BODY_FONT, size: 19, bold: true }),
        new TextRun({ text: title, font: BODY_FONT, size: 19, italics: true }),
      ],
    })],
  });
}

// ---------- callouts ----------
const CALLOUT_STYLES = {
  Note: { fill: 'EEF3FA', border: '4A6FA5' },
  Caution: { fill: 'FCF3E4', border: 'C08A2E' },
  Warning: { fill: 'FBECEC', border: 'B03030' },
};

function calloutBlock(text) {
  const kindMatch = /^\*\*(Note|Caution|Warning|Premium[^*]*)\.?\*\*/.exec(text.trim());
  const kind = kindMatch ? kindMatch[1].split(' ')[0] : 'Note';
  const style = CALLOUT_STYLES[kind] || CALLOUT_STYLES.Note;
  const border = { style: BorderStyle.SINGLE, size: 4, color: style.border };
  return new Table({
    columnWidths: [CONTENT_WIDTH],
    width: { size: CONTENT_WIDTH, type: WidthType.DXA },
    borders: {
      top: { style: BorderStyle.NONE }, bottom: { style: BorderStyle.NONE },
      right: { style: BorderStyle.NONE }, left: border,
      insideHorizontal: { style: BorderStyle.NONE }, insideVertical: { style: BorderStyle.NONE },
    },
    rows: [new TableRow({
      cantSplit: true,
      children: [new TableCell({
        width: { size: CONTENT_WIDTH, type: WidthType.DXA },
        shading: { type: ShadingType.CLEAR, fill: style.fill, color: 'auto' },
        margins: { top: 120, bottom: 120, left: 200, right: 160 },
        children: [new Paragraph({
          children: inlineRuns(text, { size: 21 }),
          spacing: { after: 0, line: 264 },
        })],
      })],
    })],
  });
}

// ---------- tables ----------
function splitRow(line) {
  let s = line.trim();
  if (s.startsWith('|')) s = s.slice(1);
  if (s.endsWith('|')) s = s.slice(0, -1);
  return s.split('|').map((c) => c.trim());
}

function cellParagraphs(raw, isHeader, keepNext) {
  const parts = String(raw).split(/<br\s*\/?>/i);
  return parts.map((p, i) => new Paragraph({
    children: inlineRuns(p.trim() === '' ? ' ' : p.trim(), { size: 18, bold: isHeader || undefined }),
    spacing: { before: i === 0 ? 40 : 20, after: 40 },
    keepNext: keepNext || undefined,
  }));
}

function buildTable(rows) {
  const header = rows[0];
  const cols = Math.max(...rows.map((r) => r.length));

  const weights = [];
  for (let c = 0; c < cols; c++) {
    let total = 0;
    for (const r of rows) {
      const v = (r[c] || '').replace(/<br\s*\/?>/gi, ' ').replace(/[*`]/g, '');
      total += Math.sqrt(v.length + 1);
    }
    weights.push(total / rows.length);
  }
  const minW = Math.max(620, Math.floor(CONTENT_WIDTH / (cols * 3)));
  const sum = weights.reduce((a, b) => a + b, 0);
  const colWidths = weights.map((x) => Math.max(minW, Math.floor((x / sum) * CONTENT_WIDTH)));
  const over = colWidths.reduce((a, b) => a + b, 0) - CONTENT_WIDTH;
  if (over !== 0) {
    const widest = colWidths.indexOf(Math.max(...colWidths));
    colWidths[widest] -= over;
  }

  // Table palette matched to the PRD (FYP26S238_PRD.docx): EFEFEF header row,
  // B0B0B0 outer rule, D9D9D9 hairline grid, white body cells.
  const outerBorder = { style: BorderStyle.SINGLE, size: 4, color: 'B0B0B0' };
  const innerBorder = { style: BorderStyle.SINGLE, size: 2, color: 'D9D9D9' };
  const borders = {
    top: outerBorder, bottom: outerBorder, left: outerBorder, right: outerBorder,
    insideHorizontal: innerBorder, insideVertical: innerBorder,
  };

  const emptyHeader = header.every((c) => (c || '').trim() === '');
  const dataRows = emptyHeader ? rows.slice(1) : rows;
  const isShort = dataRows.length <= 12;

  const trs = dataRows.map((cells, ri) => new TableRow({
    tableHeader: ri === 0 && !emptyHeader && !isShort,
    cantSplit: true,
    children: Array.from({ length: cols }, (_, ci) => new TableCell({
      width: { size: colWidths[ci], type: WidthType.DXA },
      margins: { top: 60, bottom: 60, left: 90, right: 90 },
      verticalAlign: VerticalAlign.TOP,
      shading: (ri === 0 && !emptyHeader)
        ? { type: ShadingType.CLEAR, fill: 'EFEFEF', color: 'auto' }
        : { type: ShadingType.CLEAR, fill: 'FFFFFF', color: 'auto' },
      children: cellParagraphs(
        cells[ci] === undefined ? '' : cells[ci],
        ri === 0 && !emptyHeader,
        isShort && ri < dataRows.length - 1,
      ),
    })),
  }));

  return new Table({ columnWidths: colWidths, width: { size: CONTENT_WIDTH, type: WidthType.DXA }, borders, rows: trs });
}

// ---------- markdown -> docx children ----------
const RE_IMG = /^!\[([^\]]*)\]\(([^)]+)\)(?:\{\s*width\s*=\s*(\d+)%\s*\})?$/;
const RE_OL = /^(\d+)\.\s+(.*)$/;
const RE_UL = /^[-*]\s+(.*)$/;

// Parts that also carry numbered subsections, e.g. Part 4 with a 4.1.
// A figure sitting directly under such a part is numbered N.0.k, so that it
// cannot be confused with the figures inside section N.1.
let partsWithSubsections = new Set();

function sectionFromHeading(text) {
  const part = /^Part\s+(\d+)/.exec(text);
  if (part) return partsWithSubsections.has(part[1]) ? `${part[1]}.0` : part[1];
  const num = /^(\d+(?:\.\d+)*)\s/.exec(text);
  if (num) return num[1];
  return null;
}

function convert(md) {
  const lines = md.split('\n');
  const out = [];
  let i = 0;

  // paragraph accumulator for hard-wrapped prose
  let buf = [];
  let bufKind = null;      // 'p' | 'ol' | 'ul' | 'quote'
  let bufNum = null;

  const flush = () => {
    if (!buf.length) { bufKind = null; return; }
    const text = buf.join(' ').replace(/\s+/g, ' ').trim();
    buf = [];
    if (text === '') { bufKind = null; return; }
    if (bufKind === 'quote') out.push(calloutBlock(text));
    else if (bufKind === 'ol') {
      out.push(new Paragraph({
        children: [
          new TextRun({ text: `${bufNum}.`, font: BODY_FONT, size: 22, bold: true }),
          new TextRun({ text: '\t', font: BODY_FONT, size: 22 }),
          ...inlineRuns(text, { size: 22 }),
        ],
        tabStops: [{ type: TabStopType.LEFT, position: 400 }],
        indent: { left: 400, hanging: 400 },
        spacing: { after: 140, line: 276 },
      }));
    } else if (bufKind === 'ul') {
      out.push(new Paragraph({
        children: inlineRuns(text, { size: 22 }),
        bullet: { level: 0 },
        spacing: { after: 100, line: 276 },
      }));
    } else {
      out.push(bodyPara(text));
    }
    bufKind = null;
  };

  while (i < lines.length) {
    const raw = lines[i];
    const t = raw.trim();

    if (t === '') { flush(); i++; continue; }
    if (t === '---') { flush(); i++; continue; }

    // heading
    const h = /^(#{1,6})\s+(.*)$/.exec(t);
    if (h) {
      flush();
      const lvl = h[1].length;
      const title = h[2].trim();
      const sec = sectionFromHeading(title);
      if (sec) setFigSection(sec);
      const map = { 1: HeadingLevel.HEADING_1, 2: HeadingLevel.HEADING_2, 3: HeadingLevel.HEADING_3, 4: HeadingLevel.HEADING_4 };
      const sizes = { 1: 30, 2: 25, 3: 23, 4: 22 };
      out.push(new Paragraph({
        heading: map[lvl] || HeadingLevel.HEADING_4,
        children: inlineRuns(title, { size: sizes[lvl] || 22, bold: true, color: HEADING_COLOR }),
        spacing: { before: lvl === 1 ? 0 : 300, after: 150 },
        pageBreakBefore: lvl === 1,
        keepNext: true,
      }));
      i++;
      continue;
    }

    // table
    if (t.startsWith('|') && i + 1 < lines.length && /^\|[\s:|-]+\|$/.test(lines[i + 1].trim())) {
      flush();
      const rows = [splitRow(lines[i])];
      i += 2;
      while (i < lines.length && lines[i].trim().startsWith('|')) { rows.push(splitRow(lines[i])); i++; }
      out.push(buildTable(rows));
      out.push(new Paragraph({ text: '', spacing: { after: 120 } }));
      continue;
    }

    // image + generated caption
    const im = RE_IMG.exec(t);
    if (im) {
      flush();
      out.push(imagePara(im[2].trim(), im[3] ? Number(im[3]) : undefined));
      out.push(figureCaption(im[1]));
      i++;
      continue;
    }

    // blockquote
    if (t.startsWith('>')) {
      if (bufKind !== 'quote') flush();
      bufKind = 'quote';
      buf.push(t.replace(/^>\s?/, ''));
      i++;
      continue;
    }

    // ordered list item
    const ol = RE_OL.exec(t);
    if (ol) { flush(); bufKind = 'ol'; bufNum = ol[1]; buf.push(ol[2]); i++; continue; }

    // bullet
    const ul = RE_UL.exec(t);
    if (ul) { flush(); bufKind = 'ul'; buf.push(ul[1]); i++; continue; }

    // continuation of whatever block is open, otherwise a new paragraph
    if (bufKind === null) bufKind = 'p';
    buf.push(t);
    i++;
  }
  flush();
  return out;
}

// ---------- front matter ----------
function coverPage() {
  const c = [];
  c.push(new Paragraph({ text: '' }));
  c.push(imagePara('assets/title-logos.png', 95));
  c.push(new Paragraph({
    alignment: AlignmentType.CENTER,
    spacing: { before: 260, after: 140 },
    children: [new TextRun({ text: 'CSCI321 - Final Year Project', font: BODY_FONT, size: 32, bold: true })],
  }));
  c.push(new Paragraph({
    alignment: AlignmentType.CENTER,
    spacing: { after: 100 },
    children: [new TextRun({ text: 'Runiac — User Manual', font: BODY_FONT, size: 30, bold: true, underline: {} })],
  }));
  c.push(new Paragraph({
    alignment: AlignmentType.CENTER,
    spacing: { after: 300 },
    children: [new TextRun({ text: 'Version 1.1 · 6 August 2026', font: BODY_FONT, size: 22 })],
  }));
  c.push(new Paragraph({
    alignment: AlignmentType.CENTER,
    spacing: { after: 80 },
    children: [new TextRun({ text: 'Supervisor: Mr Ee Kiam Keong', font: BODY_FONT, size: 22 })],
  }));
  c.push(new Paragraph({
    alignment: AlignmentType.CENTER,
    spacing: { after: 60 },
    children: [new TextRun({ text: 'Group Number: FYP-26-S2-38', font: BODY_FONT, size: 22 })],
  }));
  c.push(new Paragraph({
    alignment: AlignmentType.CENTER,
    spacing: { after: 300 },
    children: [new TextRun({ text: 'Topic Code: CSIT-26-S2-38', font: BODY_FONT, size: 22 })],
  }));
  c.push(buildTable([
    ['Name', 'UOW ID', 'SIM ID', 'SIM E-Mail Address'],
    ['Lee Jinseo', '9096978', '10256487', 'lee169@mymail.sim.edu.sg'],
    ['Kenji Yeo', '7906833', '10246841', 'Yeo009@mymail.sim.edu.sg'],
    ['Kaif Lim Er', '7906742', '10240265', 'Kelim003@mymail.sim.edu.sg'],
    ['LIUZHIHUI', '9182123', '10252641', 'zliu051@mymail.sim.edu.sg'],
    ['KONADA OBADIAH NAHSHON', '10266652', '9088829', 'konada001@mymail.sim.edu.sg'],
  ]));
  c.push(new Paragraph({ children: [new PageBreak()] }));
  return c;
}

function updateHint() {
  return new Paragraph({
    spacing: { after: 220 },
    children: [new TextRun({
      text: 'To populate this list in Word: click anywhere in it, then press F9 (or right-click and choose "Update Field" → "Update entire table").',
      font: BODY_FONT, size: 19, italics: true, color: '888888',
    })],
  });
}

function tocPage() {
  return [
    new Paragraph({
      heading: HeadingLevel.HEADING_1,
      children: [new TextRun({ text: 'Table of Contents', font: BODY_FONT, size: 30, bold: true, color: HEADING_COLOR })],
      spacing: { after: 220 },
    }),
    updateHint(),
    new TableOfContents('Table of Contents', { hyperlink: true, headingStyleRange: '1-3' }),
    new Paragraph({ children: [new PageBreak()] }),
  ];
}

// Built last, once every figure has been registered.
function listOfFigures() {
  const c = [
    new Paragraph({
      heading: HeadingLevel.HEADING_1,
      children: [new TextRun({ text: 'List of Figures', font: BODY_FONT, size: 30, bold: true, color: HEADING_COLOR })],
      spacing: { after: 220 },
    }),
    updateHint(),
  ];
  figures.forEach((f) => {
    c.push(new Paragraph({
      spacing: { after: 20, line: 240 },
      tabStops: [{ type: TabStopType.RIGHT, position: CONTENT_WIDTH, leader: 'dot' }],
      indent: { left: 1100, hanging: 1100 },
      children: [
        new InternalHyperlink({
          anchor: f.bookmark,
          children: [
            new TextRun({ text: `${f.label}`, font: BODY_FONT, size: 19 }),
            new TextRun({ text: '\t', font: BODY_FONT, size: 19 }),
          ],
        }),
        new TextRun({ text: `${f.title}\t`, font: BODY_FONT, size: 19 }),
        new PageReference(f.bookmark, { hyperlink: true }),
      ],
    }));
  });
  c.push(new Paragraph({ children: [new PageBreak()] }));
  return c;
}

function runningHeader() {
  return new Header({
    children: [new Paragraph({
      alignment: AlignmentType.RIGHT,
      border: { bottom: { style: BorderStyle.SINGLE, size: 4, color: 'CCCCCC', space: 4 } },
      children: [new TextRun({ text: 'Runiac User Manual — Version 1.1', font: BODY_FONT, size: 18, color: '666666' })],
    })],
  });
}

function runningFooter() {
  return new Footer({
    children: [new Paragraph({
      alignment: AlignmentType.CENTER,
      children: [
        new TextRun({ text: 'Page ', font: BODY_FONT, size: 18, color: '666666' }),
        new TextRun({ children: [PageNumber.CURRENT], font: BODY_FONT, size: 18, color: '666666' }),
        new TextRun({ text: ' of ', font: BODY_FONT, size: 18, color: '666666' }),
        new TextRun({ children: [PageNumber.TOTAL_PAGES], font: BODY_FONT, size: 18, color: '666666' }),
      ],
    })],
  });
}

// ---------- assemble ----------
let md = fs.readFileSync(path.join(dir, 'RUNIAC_USER_MANUAL.md'), 'utf8');

// The title block is replaced by the cover page; the body starts at Document Control.
const start = md.indexOf('## Document Control');
if (start > 0) md = md.slice(start);

partsWithSubsections = new Set(
  [...md.matchAll(/^##\s+(\d+)\.\d+\s/gm)].map((m) => m[1]),
);

const body = convert(md);

const children = [
  ...coverPage(),
  ...tocPage(),
  ...listOfFigures(),
  ...body,
];

const doc = new Document({
  creator: 'FYP-26-S2-38',
  title: 'Runiac User Manual',
  description: 'User Manual for the Runiac beginner-focused running application, version 1.1',
  styles: { default: { document: { run: { font: BODY_FONT, size: 22 } } } },
  sections: [{
    properties: {
      titlePage: true,
      page: {
        margin: {
          top: convertInchesToTwip(1), bottom: convertInchesToTwip(1),
          left: convertInchesToTwip(1), right: convertInchesToTwip(1),
        },
      },
    },
    headers: { first: new Header({ children: [new Paragraph({ text: '' })] }), default: runningHeader() },
    footers: { first: new Footer({ children: [new Paragraph({ text: '' })] }), default: runningFooter() },
    children,
  }],
});

Packer.toBuffer(doc).then((out) => {
  const target = path.join(dir, 'Runiac_User_Manual.docx');
  fs.writeFileSync(target, out);
  console.log(`written ${target} — ${out.length} bytes, ${figures.length} figures`);
  if (missing.length) console.error('MISSING IMAGES:\n' + missing.join('\n'));
});
