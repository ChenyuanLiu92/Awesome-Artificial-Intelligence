#!/bin/bash

# Enhanced Install Git Hook Script with Pre-Commit Support
# This script sets up hooks for both commit and push events

echo "🔧 Setting up enhanced git hooks with full arXiv automation..."

# Detect the correct repository root directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

# Check if we can find the .git directory
if [ ! -d "$REPO_ROOT/.git" ]; then
    echo "❌ Error: Cannot find git repository"
    echo "Script location: $SCRIPT_DIR"
    echo "Looking for .git in: $REPO_ROOT"
    exit 1
fi

echo "📂 Repository found at: $REPO_ROOT"

# Create hooks directory if it doesn't exist
mkdir -p "$REPO_ROOT/.git/hooks"

# Create the pre-commit hook for arXiv processing
cat > "$REPO_ROOT/.git/hooks/pre-commit" << 'EOF'
#!/bin/bash

# Pre-commit hook to automatically process arXiv papers
# This script runs before every git commit

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}📝 Pre-commit: Processing arXiv papers...${NC}"

# Check if README.md is staged for commit
if git diff --cached --name-only | grep -q "README.md"; then
    echo -e "${YELLOW}📅 README.md is being committed, updating arXiv dates...${NC}"
    
    if [ -f "scripts/update_and_sort_papers.sh" ]; then
        # Run the paper sorting script
        ./scripts/update_and_sort_papers.sh
        
        # Check if README.md was modified
        if ! git diff --quiet README.md; then
            echo -e "${GREEN}📝 Papers updated and sorted by date${NC}"
            git add README.md
            echo -e "${GREEN}✅ Updated README.md added to commit${NC}"
        else
            echo -e "${GREEN}✅ No changes needed for paper dates${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️  Paper sorting script not found, skipping...${NC}"
    fi
else
    echo -e "${GREEN}ℹ️  README.md not being committed, skipping arXiv processing${NC}"
fi

echo -e "${GREEN}🎉 Pre-commit processing completed!${NC}"
exit 0
EOF

# Create the enhanced pre-push hook for Last Updated date
cat > "$REPO_ROOT/.git/hooks/pre-push" << 'EOF'
#!/bin/bash

# Pre-push hook to automatically update Last Updated date
# This script runs before every git push

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Pre-push: Updating Last Updated date...${NC}"

# Check if README.md exists
if [ ! -f "README.md" ]; then
    echo "README.md not found, skipping date update"
    exit 0
fi

# Set locale to English for consistent date format
export LC_TIME=en_US.UTF-8

# Get current date
CURRENT_DATE=$(date "+%B %d, %Y")

# Get current Last Updated date from README
CURRENT_LAST_UPDATED=$(grep "\*\*Last Updated\*\*" README.md | sed -n 's/.*\*\*Last Updated\*\*: \(.*\)/\1/p')

# Check if update is needed
if [ "$CURRENT_DATE" != "$CURRENT_LAST_UPDATED" ]; then
    echo -e "${YELLOW}📅 Updating Last Updated date from '$CURRENT_LAST_UPDATED' to '$CURRENT_DATE'${NC}"
    
    # Update the date using sed (macOS compatible)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' 's/\*\*Last Updated\*\*: .*/\*\*Last Updated\*\*: '"$CURRENT_DATE"'/' README.md
    else
        sed -i 's/\*\*Last Updated\*\*: .*/\*\*Last Updated\*\*: '"$CURRENT_DATE"'/' README.md
    fi
    
    # Verify the update
    if grep -F "**Last Updated**: $CURRENT_DATE" README.md > /dev/null; then
        echo -e "${GREEN}✅ Successfully updated Last Updated date${NC}"
        git add README.md
        echo -e "${GREEN}📝 Added updated README.md to commit${NC}"
    else
        echo "❌ Failed to update date"
        exit 1
    fi
else
    echo -e "${GREEN}✅ Last Updated date is already current${NC}"
fi

echo -e "${GREEN}🎉 Pre-push processing completed!${NC}"
exit 0
EOF

# Make both hooks executable
chmod +x "$REPO_ROOT/.git/hooks/pre-commit"
chmod +x "$REPO_ROOT/.git/hooks/pre-push"

echo "✅ Enhanced git hooks installed successfully!"
echo ""
echo "🎯 What these hooks do:"
echo "   📝 Pre-commit: Extracts arXiv dates and sorts papers when README.md is committed"
echo "   🚀 Pre-push: Updates 'Last Updated' date before each push"
echo ""
echo "🔄 When they run:"
echo "   - Pre-commit: Every time you run 'git commit' (if README.md is included)"
echo "   - Pre-push: Every time you run 'git push'"
echo ""
echo "🧪 Test the hooks:"
echo "   $SCRIPT_DIR/test_hook.sh"
echo ""
echo "🚀 Usage:"
echo "   Just use normal git commands - automation will run automatically!"
