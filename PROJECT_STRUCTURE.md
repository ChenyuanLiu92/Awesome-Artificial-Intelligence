# Awesome Machine Learning Project Structure

```
awesome-machine-learning/
├── README.md                           # Main content file
├── CONTRIBUTING.md                     # Contribution guidelines
├── CHANGELOG.md                        # Update log
├── LICENSE                            # MIT license
├── PROJECT_STRUCTURE.md               # This file - project structure documentation
├── .gitignore                         # Git ignore rules
├── .github/                           # GitHub configuration files
│   └── [GitHub templates]            # Issue/PR templates (if configured)
├── .git/                             # Git repository data
│   └── hooks/                        # Git hooks for automation
│       ├── pre-commit                # Auto-update paper dates before commit
│       └── pre-push                  # Auto-update "Last Updated" before push
└── scripts/                          # Automation scripts
    ├── README.md                     # Scripts documentation
    ├── arxiv_date_extractor.sh       # Extract arXiv paper dates
    ├── update_and_sort_papers.sh     # Update and sort papers by date
    ├── install_hook.sh               # Install git hooks for automation
    └── test_hook.sh                  # Test git hooks locally
```

## File Descriptions

### Core Files
- **README.md**: Main project content with categorized machine learning resources
- **CONTRIBUTING.md**: Detailed contribution guide to help new contributors understand participation
- **CHANGELOG.md**: Records project version updates and important changes
- **LICENSE**: MIT open source license
- **PROJECT_STRUCTURE.md**: Documentation of the project structure and file descriptions
- **.gitignore**: Specifies files and directories to be ignored by Git

### Automation System
- **scripts/**: Directory containing all automation scripts
  - **arxiv_date_extractor.sh**: Extracts publication dates from arXiv URLs
  - **update_and_sort_papers.sh**: Automatically updates arXiv dates and sorts papers by publication date
  - **install_hook.sh**: Sets up Git hooks for complete automation
  - **test_hook.sh**: Tests Git hooks locally before committing
- **.git/hooks/**: Git hooks for automation
  - **pre-commit**: Runs before every commit to update paper dates and sort by date
  - **pre-push**: Runs before every push to update "Last Updated" field

### GitHub Configuration
- **.github/**: GitHub-specific configuration files (templates, workflows, etc.)

## Automation Workflow

### Pre-commit Hook
- Triggers automatically before every `git commit`
- Runs `scripts/update_and_sort_papers.sh` if README.md is being committed
- Extracts dates from arXiv URLs and sorts papers by publication date
- Automatically stages updated README.md to include in the commit

### Pre-push Hook
- Triggers automatically before every `git push`
- Updates the "Last Updated" date in README.md to current date
- Automatically commits the updated date

## Content Organization Principles

### Classification Logic
1. **By Usage**: Papers, tools, datasets, courses, etc.
2. **By Domain**: NLP, CV, reinforcement learning, and other technical directions
3. **By Time**: Priority display of latest and most relevant content
4. **By Authority**: Preference for top conferences and renowned institutions

### Quality Control
- All resources are manually reviewed
- Regular checking of link validity
- Priority given to authoritative and high-quality sources
- Maintaining content timeliness and relevance

## Maintenance Plan

### Regular Tasks
- **Weekly**: Check new submitted PRs and Issues
- **Monthly**: Update latest papers and tools
- **Quarterly**: Organize research trends, clean outdated content
- **Annually**: Major structural adjustments and annual summaries

### Automation Tools (Available)
- **arXiv Date Extractor**: Automatically extracts publication dates from arXiv papers
- **Paper Sorter**: Sorts papers by publication date within each section
- **Git Hooks**: Automatically processes papers and updates dates on commit/push
- **Backup System**: Creates backup files before making changes

### Automation Tools (Planned Development)
- Link validity checker
- Content format validator
- Duplicate content detector
- Update reminder system
