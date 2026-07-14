const fs = require('fs');
const path = require('path');

const THEMES_DIR = path.join(__dirname, 'wwwroot');
const SOURCE_THEME = 'THEME_TIBBIT';
const SOURCE_FILE = 'vendor.css';

// Colors that should NOT be replaced (semantic or neutral)
const PRESERVED_COLORS = new Set([
    '#34a853', '#137333', '#e6f4ea',
    '#ea4335', '#c5221f', '#fce8e6',
    '#888', '#555', '#333', '#000', '#fff',
    '#d5d5d5', '#e0e0e0', '#eee', '#ddd',
    '#f8f9fa', '#fafafa', '#bbb', '#e8e8e8',
    '#fcfcfc', '#f4f6f9', '#6c757d', '#545b62',
    '#f30a0a',
]);

// Gold tones from TIBBIT —> palette key mapping
const GOLD_TO_PALETTE = {
    '#efa63e': 'primary',
    '#d29237': 'dark1',
    '#d4882a': 'dark2',
    '#f8d7a8': 'light1',
    '#fdf2e2': 'light2',
    '#fef8f0': 'lightest',
    '#f8f0e3': 'light3',
    '#f0d8a8': 'light4',
    '#f0e0c8': 'light2',
    '#7a6530': 'dark4',
    '#483213': 'dark6',
    '#bf8532': 'dark2',
    '#604219': 'dark4',
    '#181106': 'dark7',
};

function getPrimaryColor(theme) {
    const cssPath = path.join(THEMES_DIR, theme, 'styleMaster.css');
    const css = fs.readFileSync(cssPath, 'utf8');
    const match = css.match(/\.btn-primry[^}]*?background-color:\s*(#[0-9a-fA-F]+)/);
    if (!match) throw new Error(`Can't find primary in ${theme}/styleMaster.css`);
    return match[1].toLowerCase().slice(0, 7);
}

function hexToRgb(hex) {
    // Normalize 3-digit hex to 6-digit
    if (hex.length === 4) {
        hex = '#' + hex[1] + hex[1] + hex[2] + hex[2] + hex[3] + hex[3];
    }
    return {
        r: parseInt(hex.slice(1, 3), 16),
        g: parseInt(hex.slice(3, 5), 16),
        b: parseInt(hex.slice(5, 7), 16)
    };
}

function rgbToHex(r, g, b) {
    return '#' + [r, g, b].map(c => Math.round(c).toString(16).padStart(2, '0')).join('');
}

function mix(c1, c2, w) {
    const a = hexToRgb(c1), b = hexToRgb(c2);
    return rgbToHex(a.r + (b.r - a.r) * w, a.g + (b.g - a.g) * w, a.b + (b.b - a.b) * w);
}

function generatePalette(primary) {
    const p = { primary };
    p.lightest = mix(primary, '#fff', 0.95);
    [0.92, 0.85, 0.78, 0.70, 0.60, 0.50, 0.38].forEach((w, i) => p[`light${i+1}`] = mix(primary, '#fff', w));
    [0.20, 0.35, 0.50, 0.60, 0.72, 0.82, 0.90, 0.95].forEach((w, i) => p[`dark${i+1}`] = mix(primary, '#000', w));
    return p;
}

// Process each theme (skip TIBBIT — it IS the source)
const themes = fs.readdirSync(THEMES_DIR).filter(f => f.startsWith('THEME_') && f !== SOURCE_THEME);
console.log(`Syncing vendor.css from ${SOURCE_THEME} to ${themes.length} themes...\n`);

for (const theme of themes) {
    const destDir = path.join(THEMES_DIR, theme, 'CustomCSS');
    const destPath = path.join(destDir, SOURCE_FILE);
    if (!fs.existsSync(destDir)) { console.log(`  SKIP  ${theme}`); continue; }

    const primary = getPrimaryColor(theme);
    const palette = generatePalette(primary);

    // Read source fresh each time to avoid cross-contamination
    const sourcePath = path.join(THEMES_DIR, SOURCE_THEME, 'CustomCSS', SOURCE_FILE);
    let css = fs.readFileSync(sourcePath, 'utf8');

    // Replace gold hex colors
    css = css.replace(/#[0-9a-fA-F]{6}\b/g, (match) => {
        const hex = match.toLowerCase();
        if (PRESERVED_COLORS.has(hex)) return match;
        const key = GOLD_TO_PALETTE[hex];
        return key ? palette[key].toUpperCase() : match;
    });

    // Replace rgba() gold references
    css = css.replace(/rgba\(239,\s*166,\s*62,[^)]+\)/gi, () => {
        const c = hexToRgb(palette.primary);
        return `rgba(${c.r}, ${c.g}, ${c.b}, 0.1)`;
    });
    css = css.replace(/rgba\(239,\s*166,\s*62,\s*0\.15\)/gi, () => {
        const c = hexToRgb(palette.primary);
        return `rgba(${c.r}, ${c.g}, ${c.b}, 0.15)`;
    });

    fs.writeFileSync(destPath, css, 'utf8');
    console.log(`  ${theme}  → ${SOURCE_FILE} (primary: ${primary})`);
}

console.log(`\nDone! ${themes.length} themes synced (${SOURCE_THEME} skipped — it is the source).`);
