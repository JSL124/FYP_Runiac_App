# Runiac User Manual — typographic convention

Settled 9 August 2026. It matches the convention already in force for the Final Project
Document, so the two submitted documents read as one set.

---

## 1. Headings

Black (`000000`), Times New Roman, bold, sized by level. No colour is used for emphasis
anywhere in the document.

## 2. Bold — a label, not emphasis

> **Bold names the block of text that follows it. It is never used to raise the voice
> inside a sentence.**

### Bold IS used — three cases only

1. **A label that opens a paragraph or a numbered item**, in one of these forms:
   - the label stands alone on its line — `**Privacy Policy**`, `**Tour step 3**`,
     `**Step 1 — Summary**`, `**Re-captured**`
   - the label is followed by an em dash — `**Home** — what Runiac is, with an email sign-up.`
   - the label itself ends in a full stop or question mark —
     `**Where do you usually run?**`, `**The cool-down screens are not included.**`
   - the item is nothing but the label and a full stop — `2. **Features**.`
2. **Table header rows.**
3. **The stub column of a label/value table** (every row), where such a table is used.

### Bold is NOT used

- Mid-sentence emphasis of any kind. Restructure the sentence instead.
- Interface names — see rule 3.
- Product, platform and tier names in running text: Runiac, Android, iOS, Premium, Basic.
- Terms being defined (`double opt-in`), or a few cells inside a table body.

**Test:** *is this a label naming what comes next, or am I raising my voice?*
If the second, no bold. A bold run that wraps past one line is almost always wrong.

## 3. Interface names — typographic double quotes, normal weight

Every button, tab, screen, menu path, on-screen chip, field label and on-screen message is
quoted, not bolded:

    press “Notify Me”                    the “Before you install” section
    choose “Allow While Using App”       “Menu → Profile”
    the page confirms: “Thanks. Check your inbox to confirm your subscription.”
    a “PREMIUM” chip beside your name    “Edit profile → Retake onboarding”

Quotes are the typographic pair `“ ”` (U+201C / U+201D), never `"`. Apostrophes are `’`
(U+2019). Italics are not used for interface names.

Where an interface name opens a paragraph or list item as its label, rule 2 wins and it is
bolded without quotes — `**Home** — what Runiac is` — because there it is naming the block,
not being pressed.

## 4. Callout boxes

None. The Note / Caution / Warning boxes were removed on 9 August 2026; anything worth
saying is said in the body text.

## 5. Figure captions

`Figure <section>.<n> — <title>`, centred under the figure, label bold and title italic,
numbered by the enclosing section. Every caption has a bookmark and an entry in the List of
Figures. Never hand-number a figure — the builder does it, so deleting a figure renumbers the
rest automatically.

---

## Audit before delivery

    bold runs that are not paragraph-leading labels    → 0
    bold runs longer than one line                     → 0
    straight " or ' anywhere in the body               → 0
    interface names in bold rather than quotes         → 0
    heading colours other than 000000                  → 0
