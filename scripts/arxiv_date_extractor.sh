#!/bin/bash

# ArXiv Paper Date Extractor
# This script extracts publication dates from arXiv URLs

# Function to extract date from arXiv ID
get_arxiv_date() {
    local arxiv_id="$1"
    
    # Remove "abs/" or "pdf/" prefix if present
    arxiv_id=$(echo "$arxiv_id" | sed 's|.*/||' | sed 's|\.pdf$||')
    
    # Extract date from arXiv ID format
    # Format: YYMM.NNNNN (old) or YYYY.MM.NNNNN (new since 2007)
    if [[ $arxiv_id =~ ^([0-9]{4})\.([0-9]{2}) ]]; then
        # New format (2007+): YYYY.MM - but wait, this could be YYMM too!
        year="${BASH_REMATCH[1]}"
        month="${BASH_REMATCH[2]}"
        
        # If year is like 2304, it's actually 23(year) 04(month)
        if [ "$year" -gt 2099 ]; then
            # This is YYMM format: 2304 = 23(year) + 04(month)
            year_month="$year"
            year="20${year_month:0:2}"
            month="${year_month:2:2}"
        fi
    elif [[ $arxiv_id =~ ^([0-9]{2})([0-9]{2}) ]]; then
        # Old format: YYMM
        year_short="${BASH_REMATCH[1]}"
        month="${BASH_REMATCH[2]}"
        
        # Convert 2-digit year to 4-digit (assuming 20xx for recent papers)
        if [ "$year_short" -lt 10 ]; then
            year="20$year_short"
        else
            year="19$year_short"
        fi
    else
        echo "Unknown arXiv ID format: $arxiv_id"
        return 1
    fi
    
    # Convert month number to month name
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
        *) month_name="Unknown" ;;
    esac
    
    echo "$month_name $year"
}

# Function to get more detailed info using arXiv API (requires curl)
get_arxiv_detailed_info() {
    local arxiv_url="$1"
    
    # Extract arXiv ID from URL
    arxiv_id=$(echo "$arxiv_url" | sed 's|.*arxiv.org/[^/]*/||' | sed 's|\.pdf$||')
    
    # Call arXiv API
    if command -v curl &> /dev/null; then
        echo "Fetching detailed info from arXiv API..."
        api_response=$(curl -s "http://export.arxiv.org/api/query?id_list=$arxiv_id")
        
        if echo "$api_response" | grep -q "<entry>"; then
            # Extract title
            title=$(echo "$api_response" | grep -o '<title[^>]*>[^<]*</title>' | sed 's/<[^>]*>//g' | tail -1)
            
            # Extract published date
            published=$(echo "$api_response" | grep -o '<published>[^<]*</published>' | sed 's/<[^>]*>//g')
            
            # Extract authors
            authors=$(echo "$api_response" | grep -o '<name>[^<]*</name>' | sed 's/<[^>]*>//g' | head -3 | tr '\n' ', ' | sed 's/, $//')
            
            echo "Title: $title"
            echo "Authors: $authors"
            echo "Published: $published"
            echo "ArXiv ID: $arxiv_id"
        else
            echo "Failed to fetch data from arXiv API"
        fi
    else
        echo "curl not available, using ID-based date extraction only"
    fi
}

# Main script
if [ $# -eq 0 ]; then
    echo "Usage: $0 <arxiv_url_or_id>"
    echo ""
    echo "Examples:"
    echo "  $0 https://arxiv.org/abs/2504.07958"
    echo "  $0 2504.07958"
    echo "  $0 https://arxiv.org/pdf/2504.07958.pdf"
    echo ""
    exit 1
fi

input="$1"

echo "🔍 Analyzing arXiv paper: $input"
echo "================================"

# Extract arXiv ID from input
if [[ $input =~ arxiv\.org ]]; then
    arxiv_id=$(echo "$input" | sed 's|.*arxiv.org/[^/]*/||' | sed 's|\.pdf$||')
else
    arxiv_id="$input"
fi

echo "ArXiv ID: $arxiv_id"

# Get date from ID
date_from_id=$(get_arxiv_date "$arxiv_id")
echo "Date from ID: $date_from_id"

echo ""

# Get detailed info if possible
if [[ $input =~ ^https?:// ]]; then
    get_arxiv_detailed_info "$input"
fi
