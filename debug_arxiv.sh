#!/bin/bash

# Debug version to check why SAM paper isn't getting processed

echo "🔍 Debugging arXiv date processing..."

# Test the specific line
TEST_LINE="- **Segment Anything** &#160;&#160;[[Paper]](https://arxiv.org/abs/2304.02643) &#160;&#160; [[Code]](https://github.com/facebookresearch/segment-anything)"

echo "Testing line: $TEST_LINE"

# Test Python regex
python3 - << EOF
import re

line = "$TEST_LINE"
print(f"Testing line: {line}")

# Check if it has a date already
if '*(' in line and ')' in line:
    print("✅ Line already has date")
else:
    print("❌ Line missing date")

# Check for arXiv URL
arxiv_match = re.search(r'\[Paper\]\(https://arxiv\.org/abs/[^)]+\)', line)
if arxiv_match:
    print(f"✅ Found arXiv URL: {arxiv_match.group(0)}")
    
    # Extract URL
    url_match = re.search(r'https://arxiv\.org/abs/(\d{4}\.\d{4,5})', arxiv_match.group(0))
    if url_match:
        arxiv_id = url_match.group(1)
        print(f"✅ Extracted arXiv ID: {arxiv_id}")
        
        # Parse date
        id_parts = arxiv_id.split('.')
        year_month = id_parts[0]
        print(f"Year-month part: {year_month}")
        
        if len(year_month) == 4 and int(year_month) > 2099:
            year = "20" + year_month[:2]
            month = year_month[2:]
            print(f"Parsed as YYMM format: year={year}, month={month}")
        else:
            print(f"Not YYMM format")
    else:
        print("❌ Could not extract arXiv ID from URL")
else:
    print("❌ No arXiv URL found")
EOF
