# Deployment Instructions for GitHub Pages

Follow these steps to deploy your PromoPop logo to GitHub Pages:

## Step 1: Create a GitHub Repository

1. Go to [GitHub](https://github.com) and create a new repository
2. Name it `promopop-logo` (or whatever you prefer)
3. **Important:** Make sure the repository name matches the `base` path in `vite.config.ts`
   - Current setting: `base: '/promopop-logo/'`
   - If you use a different repo name, update this line

## Step 2: Push Your Code

```bash
cd /path/to/your/project
git init
git add .
git commit -m "Initial commit: PromoPop animated logo"
git branch -M main
git remote add origin https://github.com/yourusername/promopop-logo.git
git push -u origin main
```

## Step 3: Enable GitHub Pages

1. Go to your repository on GitHub
2. Click on **Settings** → **Pages** (in the left sidebar)
3. Under "Build and deployment":
   - **Source**: Select "GitHub Actions"
4. That's it! The workflow will automatically deploy when you push to main

## Step 4: Access Your Live Logo

After the GitHub Action completes (usually 1-2 minutes), your logo will be live at:

```
https://yourusername.github.io/promopop-logo/
```

## Using the Logo in Your README

Add this to your main project's README.md:

```markdown
## Logo

![PromoPop Logo](https://yourusername.github.io/promopop-logo/preview.gif)

[View Animated Logo](https://yourusername.github.io/promopop-logo/)
```

## Updating the Deployment

Every time you push to the `main` branch, GitHub Actions will automatically rebuild and deploy your changes.

## Troubleshooting

### Build fails
- Check the Actions tab in your repository to see error logs
- Ensure all dependencies are correctly listed in package.json

### Page shows 404
- Make sure GitHub Pages is enabled in Settings → Pages
- Verify the `base` path in `vite.config.ts` matches your repo name
- Wait a few minutes after the first deployment

### Different Repository Name?
If you used a different repository name, update `vite.config.ts`:

```typescript
export default defineConfig({
  base: '/your-repo-name/',  // Change this
  // ... rest of config
})
```

## For Custom Domain (Optional)

If you want to use a custom domain:

1. Add a `CNAME` file to the `/public` folder with your domain
2. Configure DNS settings with your domain provider
3. Enable HTTPS in GitHub Pages settings
