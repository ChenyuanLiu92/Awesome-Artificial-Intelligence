#!/bin/bash

# Enhanced Install Git Hook Script
# This script sets up automatic Last Updated date updater AND arXiv date extraction/sorting

echo "🔧 Setting up enhanced git hook with arXiv date automation..."

# Check if we're in the scripts directory
if [ ! -d "../.git" ]; then
    echo "❌ Error: Please run this script from the scripts directory"
    echo "Current working directory should be: /path/to/repo/scripts/"
    exit 1
fi

# Create hooks directory if it doesn't exist
mkdir -p ../.git/hooks

# Create the enhanced pre-push hook
cat > ../.git/hooks/pre-push << 'EOF'
#!/bin/bash

# Enhanced pre-push hook to:
# 1. Update Last Updated date in README.md
# 2. Extract arXiv dates and sort papers by publication date
# This script runs before every git push

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Pre-push: Running enhanced automation...${NC}"

# Step 1: Update arXiv dates and sort papers
echo -e "${YELLOW}📅 Step 1: Extracting arXiv dates and sorting papers...${NC}"

if [ -f "scripts/update_and_sort_papers.sh" ]; then
    # Run the paper sorting script
    cd scripts
    ./update_and_sort_papers.sh
    cd ..
    
    # Check if README.md was modified
    if git diff --quiet README.md; then
        echo -e "${GREEN}✅ No changes needed for paper dates${NC}"
    else
        echo -e "${GREEN}📝 Papers updated and sorted by date${NC}"
        git add README.md
    fi
else
    echo -e "${YELLOW}⚠️  Paper sorting script not found, skipping...${NC}"
fi

# Step 2: Update Last Updated date
echo -e "${YELLOW}📅 Step 2: Updating Last Updated date...${NC}"

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

echo -e "${GREEN}🎉 Enhanced pre-push automation completed successfully!${NC}"
echo -e "${BLUE}📋 Summary: Papers sorted by date + Last Updated timestamp refreshed${NC}"
exit 0
EOF

# Make the hook executable
chmod +x ../.git/hooks/pre-push

echo "✅ Enhanced git hook installed successfully!"
echo ""
echo "🎯 What this enhanced hook does:"
echo "   1. 📅 Extracts dates from arXiv papers and sorts them by publication date"
echo "   2. 🕒 Updates the 'Last Updated' date in README.md"
echo "   3. 📝 Commits any changes automatically"
echo ""
echo "🔄 When it runs:"
echo "   - Automatically before every 'git push'"
echo "   - Ensures your README is always up-to-date and well-organized"
echo ""
echo "🧪 Test the hook:"
echo "   cd .. && ./scripts/test_hook.sh"
echo ""
echo "🚀 Usage:"
echo "   Just use 'git push' as normal - full automation will run!"
