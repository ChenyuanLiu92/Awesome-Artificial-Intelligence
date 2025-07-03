#!/bin/bash

# Update arXiv dates and sort papers by date
# This script extracts publication dates from arXiv URLs and sorts papers by date

echo "🔍 Updating arXiv dates and sorting papers by date..."

# Backup original file
cp ../README.md ../README.md.backup

# Check if arxiv_date_extractor.sh exists
if [ -f "./arxiv_date_extractor.sh" ]; then
    echo "📂 Found arXiv date extractor, using it for enhanced date extraction..."
else
    echo "⚠️  arXiv date extractor not found, using basic date extraction..."
fi

# Function to extract date from arXiv URL and format it
extract_and_format_date() {
    local url="$1"
    local arxiv_id
    
    # Extract arXiv ID from URL
    if [[ $url =~ arxiv\.org/abs/([0-9]{4}\.[0-9]{4,5}) ]]; then
        arxiv_id="${BASH_REMATCH[1]}"
    elif [[ $url =~ arxiv\.org/abs/([a-z-]+/[0-9]{7}) ]]; then
        arxiv_id="${BASH_REMATCH[1]}"
    else
        return 1
    fi
    
    # Get date using the existing function
    local date_info=$(get_arxiv_date "$arxiv_id")
    if [[ $date_info == *"Date:"* ]]; then
        # Extract the date part and format it
        local date_part=$(echo "$date_info" | grep "Date:" | sed 's/.*Date: //' | sed 's/ .*//')
        if [[ $date_part =~ ^([0-9]{4})-([0-9]{2}) ]]; then
            local year="${BASH_REMATCH[1]}"
            local month="${BASH_REMATCH[2]}"
            
            # Convert month number to name
            case $month in
                01) month_name="January" ;;
                02) month_name="February" ;;
                03) month_name="March" ;;
                04) month_name="April" ;;
                05) month_name="May" ;;
                06) month_name="June" ;;
                07) month_name="July" ;;
                08) month_name="August" ;;
                09) month_name="September" ;;
                10) month_name="October" ;;
                11) month_name="November" ;;
                12) month_name="December" ;;
            esac
            
            echo "$month_name $year|$year$month"
        fi
    fi
}

# Function to extract sort key from existing date
extract_sort_key() {
    local line="$1"
    if [[ $line =~ \*\(([A-Za-z]+)\ ([0-9]{4})\) ]]; then
        local month_name="${BASH_REMATCH[1]}"
        local year="${BASH_REMATCH[2]}"
        
        # Convert month name to number
        case $month_name in
            January) month="01" ;;
            February) month="02" ;;
            March) month="03" ;;
            April) month="04" ;;
            May) month="05" ;;
            June) month="06" ;;
            July) month="07" ;;
            August) month="08" ;;
            September) month="09" ;;
            October) month="10" ;;
            November) month="11" ;;
            December) month="12" ;;
        esac
        
        echo "$year$month"
    else
        echo "000000"  # For papers without dates, put them at the end
    fi
}

# Process the file
python3 - << 'EOF'
import re
import sys

def extract_sort_key(line):
    """Extract sort key from date in line"""
    match = re.search(r'\*\(([A-Za-z]+)\s+(\d{4})\)', line)
    if match:
        month_name, year = match.groups()
        month_map = {
            'January': '01', 'February': '02', 'March': '03', 'April': '04',
            'May': '05', 'June': '06', 'July': '07', 'August': '08',
            'September': '09', 'October': '10', 'November': '11', 'December': '12'
        }
        month = month_map.get(month_name, '00')
        return f"{year}{month}"
    return "000000"  # For papers without dates

def extract_and_format_date(url):
    """Extract date from arXiv URL and format it"""
    arxiv_match = re.search(r'arxiv\.org/abs/(\d{4}\.\d{4,5})', url)
    if not arxiv_match:
        return None, None
    
    arxiv_id = arxiv_match.group(1)
    year, month = arxiv_id.split('.')[:2]
    
    month_names = {
        '01': 'January', '02': 'February', '03': 'March', '04': 'April',
        '05': 'May', '06': 'June', '07': 'July', '08': 'August',
        '09': 'September', '10': 'October', '11': 'November', '12': 'December'
    }
    
    month_name = month_names.get(month, 'Unknown')
    formatted_date = f"{month_name} {year}"
    sort_key = f"{year}{month}"
    
    return formatted_date, sort_key

def process_section(lines, start_idx, end_idx):
    """Process a section and sort papers by date"""
    papers = []
    current_paper = []
    
    for i in range(start_idx, end_idx):
        line = lines[i]
        
        if line.strip().startswith('- **') and current_paper:
            # Process previous paper
            papers.append(current_paper)
            current_paper = [line]
        elif line.strip().startswith('- **'):
            current_paper = [line]
        elif current_paper:
            current_paper.append(line)
    
    if current_paper:
        papers.append(current_paper)
    
    # Sort papers by date
    def get_paper_sort_key(paper):
        paper_text = '\n'.join(paper)
        
        # Check if paper already has a date
        if '*(' in paper_text and ')' in paper_text:
            return extract_sort_key(paper_text)
        
        # Extract arXiv URL and get date
        arxiv_match = re.search(r'\[Paper\]\(https://arxiv\.org/abs/[^)]+\)', paper_text)
        if arxiv_match:
            url = arxiv_match.group(0)
            formatted_date, sort_key = extract_and_format_date(url)
            if formatted_date:
                # Add date to paper
                first_line = paper[0]
                if not ('*(' in first_line and ')' in first_line):
                    # Find where to insert the date
                    if '&#160;&#160;' in first_line:
                        parts = first_line.split('&#160;&#160;', 1)
                        paper[0] = f"{parts[0]} *({formatted_date}) &#160;&#160;{parts[1]}"
                    else:
                        paper[0] = first_line.rstrip() + f" *({formatted_date})"
                return sort_key
        
        return "000000"  # No date found
    
    papers.sort(key=get_paper_sort_key, reverse=True)
    return papers

# Read the file
with open('../README.md', 'r', encoding='utf-8') as f:
    lines = f.readlines()

# Find sections to process
result_lines = []
i = 0

while i < len(lines):
    line = lines[i]
    result_lines.append(line)
    
    # Check if this is a subsection header (####)
    if line.strip().startswith('####') and not line.strip().startswith('#####'):
        # Find the end of this subsection
        section_start = i + 1
        section_end = len(lines)
        
        # Look for next section header
        for j in range(i + 1, len(lines)):
            next_line = lines[j].strip()
            if (next_line.startswith('####') or 
                next_line.startswith('###') or 
                next_line.startswith('##') or
                next_line.startswith('<!-- -') or
                (next_line.startswith('- **') and 'Coming soon' in next_line)):
                section_end = j
                break
        
        # Process this section
        papers = process_section(lines, section_start, section_end)
        
        # Add processed papers to result
        for paper in papers:
            result_lines.extend(paper)
        
        # Skip the original section
        i = section_end - 1
    
    i += 1

# Write the result
with open('../README.md', 'w', encoding='utf-8') as f:
    f.writelines(result_lines)

print("✅ Papers updated and sorted by date successfully!")
EOF

echo "📝 README.md has been updated with dates and sorted by publication date!"
echo "🗂️ Backup saved as README.md.backup"
