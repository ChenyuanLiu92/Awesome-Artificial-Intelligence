# 🛠️ Scripts Directory

This directory contains automation tools for managing the Awesome Machine Learning repository.

## 📋 Available Scripts

### 📅 Paper Date Management

#### `arxiv_date_extractor.sh`
Extracts publication dates and metadata from arXiv URLs.

**Usage:**
```bash
./scripts/arxiv_date_extractor.sh https://arxiv.org/abs/2504.07958
./scripts/arxiv_date_extractor.sh 2504.07958
```

**Output:**
- Publication date
- Title
- Authors
- Abstract summary

#### `update_and_sort_papers.sh`
Automatically updates all arXiv paper dates in README.md and sorts papers by publication date.

**Usage:**
```bash
./scripts/update_and_sort_papers.sh
```

**Features:**
- 🔍 Scans README.md for arXiv links
- 📅 Extracts and adds publication dates
- 📋 Sorts papers by date (newest first)
- 🗂️ Papers without dates go to the end
- 💾 Creates backup file automatically

### 🔄 Git Automation

#### `install_hook.sh`
Installs enhanced git hooks (pre-commit + pre-push) that automatically manage paper dates and README updates.

**Usage:**
```bash
./scripts/install_hook.sh
```

**What it does:**
- � **Pre-commit hook**: Extracts dates from arXiv papers and sorts them when README.md is committed
- � **Pre-push hook**: Updates the "Last Updated" field before each push
- ⚡ **Full automation**: No manual steps needed after setup!

#### `test_hook.sh`
Tests the git hook functionality locally without actually pushing to remote.

**Usage:**
```bash
./scripts/test_hook.sh
```

## 🚀 Quick Start for Contributors

### Enhanced Automation (Recommended)
```bash
./scripts/install_hook.sh
```
**This will automatically:**
- Extract dates from arXiv papers and sort them on each commit
- Update "Last Updated" date on each push
- Handle everything automatically with git hooks

### Manual Workflow (Alternative)
1. **Add new papers to README.md manually**

2. **Update dates and sort papers:**
   ```bash
   ./scripts/update_and_sort_papers.sh
   ```

3. **Commit and push:**
   ```bash
   git add .
   git commit -m "Add new papers"
   git push origin main
   ```

## 📝 Usage Examples

### Adding a New Paper
1. Add the paper entry to README.md:
   ```markdown
   - **New Paper Title** &#160;&#160;[[Paper]](https://arxiv.org/abs/2507.XXXXX) &#160; [[Code]](https://github.com/author/repo)
   ```

2. Run the update script:
   ```bash
   ./scripts/update_and_sort_papers.sh
   ```

3. The script will automatically:
   - Extract the date: `*(July 2025)`
   - Sort it to the correct position
   - Create a backup file

### Checking a Paper's Details
```bash
./scripts/arxiv_date_extractor.sh https://arxiv.org/abs/2507.XXXXX
```

## ⚠️ Notes

- Scripts require bash environment (macOS/Linux)
- Make sure scripts have execute permissions: `chmod +x scripts/*.sh`
- Backup files (`.backup`) are automatically created and excluded from git
- The git hook only affects local repository - each contributor needs to install it separately
