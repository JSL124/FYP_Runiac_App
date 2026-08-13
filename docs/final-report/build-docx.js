const fs = require('fs');
const path = require('path');
const D = require('docx');
const {
  Document, Packer, Paragraph, TextRun, HeadingLevel, AlignmentType,
  Table, TableRow, TableCell, WidthType, ShadingType, BorderStyle,
  TableOfContents, PageBreak, Header, Footer, PageNumber, TabStopType,
  VerticalAlign, convertInchesToTwip, ImageRun, PageOrientation,
} = D;

const BODY_FONT = 'Times New Roman';
const CONTENT_WIDTH = 9026; // A4 portrait minus 1" margins each side, in DXA

// ---------- inline markdown -> TextRun[] ----------
function inlineRuns(text, base = {}) {
  const runs = [];
  // tokenise **bold**, *italic*, `code`
  const re = /(\*\*[^*]+\*\*|\*[^*]+\*|`[^`]+`)/g;
  let last = 0, m;
  const push = (t, opts) => {
    if (t === '') return;
    runs.push(new TextRun({ text: t, font: BODY_FONT, ...base, ...opts }));
  };
  while ((m = re.exec(text)) !== null) {
    push(text.slice(last, m.index), {});
    const tok = m[0];
    if (tok.startsWith('**')) push(tok.slice(2, -2), { bold: true });
    else if (tok.startsWith('`')) push(tok.slice(1, -1), { font: 'Consolas' });
    else push(tok.slice(1, -1), { italics: true });
    last = m.index + tok.length;
  }
  push(text.slice(last), {});
  if (runs.length === 0) push(' ', {});
  return runs;
}

function bodyPara(text, opts = {}) {
  return new Paragraph({
    children: inlineRuns(text, { size: 22 }),
    spacing: { after: 160, line: 276 },
    alignment: AlignmentType.JUSTIFIED,
    ...opts,
  });
}

function captionPara(text) {
  return new Paragraph({
    children: inlineRuns(text.replace(/^\*|\*$/g, ''), { size: 19, italics: true }),
    alignment: AlignmentType.CENTER,
    spacing: { before: 60, after: 240 },
  });
}


// ---------- images ----------
const IMG_MAX_W = 600;   // px, ~6.25in at 96dpi — the content width
const IMG_MAX_H = 740;   // px, leaves room for a caption on the same page

function pngSize(buf) {
  // IHDR width/height are big-endian uint32 at byte offsets 16 and 20
  if (buf.length > 24 && buf.readUInt32BE(0) === 0x89504e47) {
    return { w: buf.readUInt32BE(16), h: buf.readUInt32BE(20) };
  }
  return jpgSize(buf);
}

// JPEG carries its dimensions in a start-of-frame marker rather than a fixed
// header offset, so the segment chain has to be walked to find one.
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
    if (isSOF) return { h: buf.readUInt16BE(i + 5), w: buf.readUInt16BE(i + 7) };
    i += 2 + len;
  }
  return null;
}

const TALL_MAX_H = 330;  // px, ~4.5in — cap for portrait phone screenshots
const LAND_MAX_W = 920;  // px, ~9.6in — landscape A4 content width
const LAND_MAX_H = 560;  // px, leaves room for the caption

// Marker emitted for a figure that should occupy its own landscape page.
class LandscapeFigure {
  constructor(children) { this.children = children; }
}

// Lay several images out on one line, scaled by a common factor so the row
// fills the content width without any image exceeding the height budget.
function imageRowPara(relPaths, landscape) {
  const maxW = landscape ? LAND_MAX_W : IMG_MAX_W;
  const maxH = landscape ? LAND_MAX_H : IMG_MAX_H;
  const GAP = 10;
  const imgs = [];
  for (const rel of relPaths) {
    const abs = path.isAbsolute(rel) ? rel : path.join(dir, rel);
    if (!fs.existsSync(abs)) continue;
    const buf = fs.readFileSync(abs);
    const nat = pngSize(buf);
    if (!nat) continue;
    imgs.push({ buf, ...nat });
  }
  if (imgs.length === 0) {
    return new Paragraph({
      alignment: AlignmentType.CENTER,
      children: [new TextRun({ text: `[missing images: ${relPaths.join(', ')}]`, font: BODY_FONT, size: 20, italics: true, color: 'B03030' })],
    });
  }
  const usable = maxW - GAP * (imgs.length - 1);
  const totalW = imgs.reduce((a, m) => a + m.w, 0);
  const tallest = Math.max(...imgs.map((m) => m.h));
  const scale = Math.min(usable / totalW, maxH / tallest, 1);
  return new Paragraph({
    alignment: AlignmentType.CENTER,
    spacing: { before: 120, after: 40 },
    children: imgs.map((m) => new ImageRun({
      data: m.buf,
      transformation: { width: Math.round(m.w * scale), height: Math.round(m.h * scale) },
    })),
  });
}

function imagePara(relPath, landscape) {
  const abs = path.isAbsolute(relPath) ? relPath : path.join(dir, relPath);
  if (!fs.existsSync(abs)) {
    return new Paragraph({
      alignment: AlignmentType.CENTER,
      children: [new TextRun({ text: `[missing image: ${relPath}]`, font: BODY_FONT, size: 20, italics: true, color: 'B03030' })],
    });
  }
  const buf = fs.readFileSync(abs);
  const maxW = landscape ? LAND_MAX_W : IMG_MAX_W;
  let maxH = landscape ? LAND_MAX_H : IMG_MAX_H;
  const nat = pngSize(buf) || { w: maxW, h: maxH };
  // A tall phone screenshot never needs the full page height; capping it lets a
  // figure, its caption and a paragraph of text share a page.
  // The tall cap exists so a portrait phone screenshot does not consume a whole
  // page. Diagrams are also often tall, but they must stay legible, so they are
  // exempt and are bounded by the ordinary page-width and page-height limits.
  const isScreenshot = /screenshots?[\\/]/.test(relPath);
  if (!landscape && isScreenshot && nat.w / nat.h < 0.75) maxH = Math.min(maxH, TALL_MAX_H);
  const scale = Math.min(maxW / nat.w, maxH / nat.h, 1);
  return new Paragraph({
    alignment: AlignmentType.CENTER,
    spacing: { before: 120, after: 40 },
    children: [new ImageRun({
      data: buf,
      transformation: { width: Math.round(nat.w * scale), height: Math.round(nat.h * scale) },
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
  const parts = raw.split(/<br\s*\/?>/i);
  return parts.map((p, i) => new Paragraph({
    children: inlineRuns(p.trim() === '' ? ' ' : p.trim(), { size: 18, bold: isHeader || undefined }),
    spacing: { before: i === 0 ? 40 : 20, after: 40 },
    keepNext: keepNext || undefined,
  }));
}

function buildTable(rows) {
  const header = rows[0];
  const cols = header.length;

  // weight columns by typical content length, clamped so no column is unusable
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
  let colWidths = weights.map((x) => Math.max(minW, Math.floor((x / sum) * CONTENT_WIDTH)));
  // normalise back to exactly CONTENT_WIDTH
  const over = colWidths.reduce((a, b) => a + b, 0) - CONTENT_WIDTH;
  if (over !== 0) {
    const widest = colWidths.indexOf(Math.max(...colWidths));
    colWidths[widest] -= over;
  }

  const border = { style: BorderStyle.SINGLE, size: 4, color: 'AAAAAA' };
  const borders = { top: border, bottom: border, left: border, right: border };

  // a markdown table written as "| | |" has an intentionally empty header row —
  // don't render it as a shaded band
  // Tables whose first row is content, not a column header: the test-script
  // spec block (Objective / Classification / Pre-requisites) and the signature
  // block. Rendering these as a shaded header band misreads the sample format.
  const firstCell = (header[0] || '').replace(/\*/g, '').trim();
  const contentFirstRow = firstCell === 'Objective' || firstCell.startsWith("Tester's Name");
  const emptyHeader = header.every((c) => (c || '').trim() === '') || contentFirstRow;
  const dataRows = (emptyHeader && !contentFirstRow) ? rows.slice(1) : rows;

  // A short table that straddles a page break renders a stray blank row in some
  // viewers, so keep short tables on one page and only repeat the header band
  // for tables long enough to genuinely need it.
  const SHORT_TABLE_ROWS = 12;
  const isShort = dataRows.length <= SHORT_TABLE_ROWS;

  const trs = dataRows.map((cells, ri) => new TableRow({
    tableHeader: ri === 0 && !emptyHeader && !isShort,
    cantSplit: true,
    children: Array.from({ length: cols }, (_, ci) => new TableCell({
      width: { size: colWidths[ci], type: WidthType.DXA },
      margins: { top: 60, bottom: 60, left: 90, right: 90 },
      verticalAlign: VerticalAlign.TOP,
      shading: (ri === 0 && !emptyHeader)
        ? { type: ShadingType.CLEAR, fill: 'E8EDF3', color: 'auto' }
        : undefined,
      children: cellParagraphs(
        cells[ci] === undefined ? '' : cells[ci],
        ri === 0 && !emptyHeader,
        isShort && ri < dataRows.length - 1,
      ),
    })),
  }));

  return new Table({
    columnWidths: colWidths,
    width: { size: CONTENT_WIDTH, type: WidthType.DXA },
    borders,
    rows: trs,
  });
}

// ---------- markdown file -> docx children ----------
function convert(md) {
  const lines = md.split('\n');
  const out = [];
  let i = 0;
  let paraBuf = [];

  const flush = () => {
    if (paraBuf.length) {
      out.push(bodyPara(paraBuf.join(' ')));
      paraBuf = [];
    }
  };

  while (i < lines.length) {
    const line = lines[i];
    const t = line.trim();

    if (t === '') { flush(); i++; continue; }

    if (t === '---') { flush(); i++; continue; }

    const h = /^(#{1,6})\s+(.*)$/.exec(t);
    if (h) {
      flush();
      const lvl = h[1].length;
      const map = {
        1: HeadingLevel.HEADING_1,
        2: HeadingLevel.HEADING_2,
        3: HeadingLevel.HEADING_3,
        4: HeadingLevel.HEADING_4,
        5: HeadingLevel.HEADING_5,
      };
      const sizes = { 1: 32, 2: 26, 3: 23, 4: 22, 5: 22 };
      out.push(new Paragraph({
        heading: map[lvl] || HeadingLevel.HEADING_5,
        children: inlineRuns(h[2], { size: sizes[lvl] || 22, bold: true, color: '1F3864' }),
        spacing: { before: lvl === 1 ? 0 : 280, after: 140 },
        pageBreakBefore: false,
      }));
      i++;
      continue;
    }

    // table block
    if (t.startsWith('|') && i + 1 < lines.length && /^\|[\s:|-]+\|$/.test(lines[i + 1].trim())) {
      flush();
      const rows = [];
      rows.push(splitRow(lines[i])); i += 2;
      while (i < lines.length && lines[i].trim().startsWith('|')) {
        rows.push(splitRow(lines[i])); i++;
      }
      out.push(buildTable(rows));
      out.push(new Paragraph({ text: '', spacing: { after: 60 } }));
      continue;
    }

    // standalone image:  ![alt](relative/path.png)
    // a line holding two or more images becomes one side-by-side row
    if (/^(!\[[^\]]*\]\([^)]+\)\s*){2,}$/.test(t)) {
      flush();
      const paths = [...t.matchAll(/!\[[^\]]*\]\(([^)]+)\)/g)].map((m) => m[1].trim());
      out.push(imageRowPara(paths, false));
      i++;
      continue;
    }

    const im = /^!\[[^\]]*\]\(([^)]+)\)(\{landscape\})?$/.exec(t);
    if (im) {
      flush();
      const wide = Boolean(im[2]);
      const pic = imagePara(im[1].trim(), wide);
      if (!wide) { out.push(pic); i++; continue; }
      // a landscape figure takes its own page together with its caption
      const block = [pic];
      let j = i + 1;
      while (j < lines.length && lines[j].trim() === '') j++;
      const cap = j < lines.length ? lines[j].trim() : '';
      if (/^\*[^*].*\*$/.test(cap)) { block.push(captionPara(cap)); i = j + 1; } else { i++; }
      out.push(new LandscapeFigure(block));
      continue;
    }

    // caption / standalone italic line
    if (/^\*[^*].*\*$/.test(t) && !t.includes('  ')) {
      flush();
      out.push(captionPara(t));
      i++;
      continue;
    }

    // bullet
    const b = /^[-*]\s+(.*)$/.exec(t);
    if (b) {
      flush();
      out.push(new Paragraph({
        children: inlineRuns(b[1], { size: 22 }),
        bullet: { level: 0 },
        spacing: { after: 80 },
      }));
      i++;
      continue;
    }

    // every source line is its own paragraph (the chapter markdown is unwrapped)
    out.push(bodyPara(t));
    i++;
  }
  flush();
  return out;
}

// ---------- cover page ----------
function coverPage() {
  const c = [];
  const blank = (n) => { for (let k = 0; k < n; k++) c.push(new Paragraph({ text: '' })); };
  blank(1);
  c.push(imagePara('diagrams/title-logos.png', false));
  c.push(new Paragraph({
    alignment: AlignmentType.CENTER,
    spacing: { before: 200, after: 160 },
    children: [new TextRun({ text: 'CSCI321 - Final Year Project', font: BODY_FONT, size: 32, bold: true })],
  }));
  c.push(new Paragraph({
    alignment: AlignmentType.CENTER,
    spacing: { after: 320 },
    children: [new TextRun({ text: 'A Mobile Application for Wise Workout', font: BODY_FONT, size: 26, bold: true, underline: {} })],
  }));
  c.push(new Paragraph({
    alignment: AlignmentType.CENTER,
    spacing: { after: 80 },
    children: [new TextRun({ text: 'Supervisor: Mr Ee Kiam Keong', font: BODY_FONT, size: 22 })],
  }));
  c.push(new Paragraph({
    alignment: AlignmentType.CENTER,
    spacing: { after: 300 },
    children: [new TextRun({ text: 'Group Number: FYP-26-S2-38', font: BODY_FONT, size: 22 })],
  }));

  const team = [
    ['Name', 'UOW ID', 'SIM ID', 'SIM E-Mail Address'],
    ['Lee Jinseo', '9096978', '10256487', 'lee169@mymail.sim.edu.sg'],
    ['Kenji Yeo', '7906833', '10246841', 'Yeo009@mymail.sim.edu.sg'],
    ['Kaif Lim Er', '7906742', '10240265', 'Kelim003@mymail.sim.edu.sg'],
    ['LIUZHIHUI', '9182123', '10252641', 'zliu051@mymail.sim.edu.sg'],
    ['KONADA OBADIAH NAHSHON', '10266652', '9088829', 'konada001@mymail.sim.edu.sg'],
  ];
  c.push(buildTable(team));

  c.push(new Paragraph({ children: [new PageBreak()] }));
  return c;
}

function tocPage() {
  const c = [];
  c.push(new Paragraph({
    heading: HeadingLevel.HEADING_1,
    children: [new TextRun({ text: 'Table of Contents', font: BODY_FONT, size: 32, bold: true, color: '1F3864' })],
    spacing: { after: 240 },
  }));
  c.push(new Paragraph({
    spacing: { after: 200 },
    children: [new TextRun({
      text: 'To populate this table in Word: click anywhere in it, then press F9 (or right-click and choose "Update Field" → "Update entire table").',
      font: BODY_FONT, size: 19, italics: true, color: '888888',
    })],
  }));
  c.push(new TableOfContents('Table of Contents', {
    hyperlink: true,
    headingStyleRange: '1-3',
  }));
  c.push(new Paragraph({ children: [new PageBreak()] }));
  return c;
}

function draftNotice() {
  const c = [];
  c.push(new Paragraph({
    heading: HeadingLevel.HEADING_1,
    children: [new TextRun({ text: 'About This Document', font: BODY_FONT, size: 32, bold: true, color: '1F3864' })],
    spacing: { after: 200 },
  }));
  const paras = [
    'This document describes the Runiac application as it was actually built. The four earlier project documents (the Project Proposal, the Project Requirements Document, the Preliminary Technical Document and the Project Design Document) supply the structure, the requirement numbering and the justification narrative, because those were the agreed project commitments. Where an earlier document and the delivered implementation disagree, the implementation is authoritative. The text states what was built and declares the difference rather than leaving a reader to find it.',
    'Chapter 1 is the second version of the Project Proposal and keeps its nine sections in their original order. Chapter 2 is the second version of the requirement specifications, consolidating the functional hierarchy, access levels, dependencies, use cases and non-functional requirements from the Preliminary Technical Document and the Project Requirements Document. Chapters 3 to 6 cover the database, architecture, component and interface design. Chapter 7 reports the testing, Chapters 8 and 9 the marketing plan and the future work, and Chapter 10 the conclusion. Annex F holds the seventy-five executed manual test scripts.',
    'Two editorial decisions apply throughout. The user role model is three roles: Unregistered User, Registered User (Basic or Premium) and Platform Administrator. The Medical Trainer / Expert role described in the earlier documents is not part of this project. The feature set is ten, F1 to F10, with the distance-challenge subsystem documented inside F5.',
  ];
  paras.forEach((p) => c.push(bodyPara(p)));
  c.push(new Paragraph({ children: [new PageBreak()] }));
  return c;
}


function runningHeader() {
  return new Header({
    children: [new Paragraph({
      alignment: AlignmentType.RIGHT,
      border: { bottom: { style: BorderStyle.SINGLE, size: 4, color: 'CCCCCC', space: 4 } },
      children: [new TextRun({
        text: 'Runiac Final Project Document',
        font: BODY_FONT, size: 18, color: '666666',
      })],
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
const dir = '/home/claude/final-report';
const chapters = process.env.CHAPTERS
  ? process.env.CHAPTERS.split(',')
  : ['ch01-introduction.md', 'ch02-requirement-specifications.md', 'ch03-database-design.md', 'ch04-architecture-design.md', 'ch05-component-design.md', 'ch06-user-interface-design.md', 'ch07-system-testing.md', 'ch08-marketing-plan.md', 'ch09-future-enhancements.md', 'ch10-conclusion.md', 'annex-f-test-scripts.md'];

let children = [];
children = children.concat(coverPage());
children = children.concat(tocPage());
children = children.concat(draftNotice());

chapters.forEach((f, idx) => {
  const md = fs.readFileSync(path.join(dir, f), 'utf8');
  const conv = convert(md);
  if (idx > 0) children.push(new Paragraph({ children: [new PageBreak()] }));
  children = children.concat(conv);
});

// Split the flat child list wherever a landscape figure appears, so that each
// such figure gets its own landscape page and the body resumes portrait after.
const runs = [];
let buf = [];
children.forEach((c) => {
  if (c instanceof LandscapeFigure) {
    runs.push({ landscape: false, children: buf });
    runs.push({ landscape: true, children: c.children });
    buf = [];
  } else {
    buf.push(c);
  }
});
runs.push({ landscape: false, children: buf });
const sectionRuns = runs.filter((r) => r.children.length > 0);

const doc = new Document({
  creator: 'FYP-26-S2-38',
  title: 'Runiac Final Project Document',
  description: 'Final Project Document for the Runiac beginner-focused running application',
  styles: {
    default: {
      document: { run: { font: BODY_FONT, size: 22 } },
    },
  },
  sections: sectionRuns.map((run, ri) => ({
    properties: {
      titlePage: ri === 0,
      page: {
        size: run.landscape ? { orientation: PageOrientation.LANDSCAPE } : undefined,
        margin: {
          top: convertInchesToTwip(1),
          bottom: convertInchesToTwip(1),
          left: convertInchesToTwip(1),
          right: convertInchesToTwip(1),
        },
      },
    },
    headers: {
      first: new Header({ children: [new Paragraph({ text: '' })] }),
      default: runningHeader(),
    },
    footers: {
      first: new Footer({ children: [new Paragraph({ text: '' })] }),
      default: runningFooter(),
    },
    children: run.children,
  })),
});

Packer.toBuffer(doc).then((buf) => {
  fs.writeFileSync('/home/claude/final-report/Runiac_Final_Project_Document.docx', buf);
  console.log('written', buf.length, 'bytes');
});
