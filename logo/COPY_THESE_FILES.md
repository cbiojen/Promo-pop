# Files to Copy to Your Local Promo-pop Repository

## Method 1: Look for Figma Make Export
Check the Figma Make interface for:
- A "Download" button (usually top-right)
- "Export" option in menus
- "Download Project" or "Export Code"

## Method 2: Manual Copy (if no download option)

Copy these files from Figma Make to your local VS Code:

### 1. Root Files
- `index.html`
- `vite.config.ts`
- `package.json`
- `.gitignore`

### 2. GitHub Workflow
- `.github/workflows/deploy.yml`

### 3. Source Files
- `src/main.tsx`
- `src/app/App.tsx`
- `src/app/components/PromoPopLogo.tsx`

### 4. Styles (if they exist in your project)
- `src/styles/index.css`
- `src/styles/theme.css`
- `src/styles/tailwind.css`
- `src/styles/fonts.css`

## After Copying to Local:

```bash
# In your local Promo-pop folder in VS Code terminal:
cd /path/to/Promo-pop

# Install dependencies (if package.json changed)
pnpm install

# Test locally
pnpm dev

# Commit and push
git add .
git commit -m "Add animated logo with GitHub Pages deployment"
git push origin main
```

## Enable GitHub Pages:
1. Go to: https://github.com/cbiojen/Promo-pop/settings/pages
2. Source: Select "GitHub Actions"
3. Wait 1-2 minutes for deployment

Your logo will be live at: https://cbiojen.github.io/Promo-pop/
