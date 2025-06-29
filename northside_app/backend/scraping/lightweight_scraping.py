# Ultra-lightweight scraping for Pi - no browser needed
import requests
import time
import json
from bs4 import BeautifulSoup

def try_api_endpoints():
    """
    Try to find API endpoints that the website uses
    """
    print("Looking for API endpoints...")
    
    # Common API patterns for sports websites
    base_url = "https://www.northsideprepathletics.com"
    
    potential_apis = [
        "/api/schedule",
        "/api/schedule/2025-2026",
        "/api/events",
        "/schedule.json",
        "/data/schedule.json",
        "/wp-json/wp/v2/events",  # WordPress
        "/api/v1/schedule",
    ]
    
    headers = {
        'User-Agent': 'Mozilla/5.0 (X11; Linux armv7l) AppleWebKit/537.36',
        'Accept': 'application/json, text/plain, */*',
        'Accept-Language': 'en-US,en;q=0.9',
        'Referer': 'https://www.northsideprepathletics.com/schedule?year=2025-2026'
    }
    
    for endpoint in potential_apis:
        try:
            url = base_url + endpoint
            print(f"Trying: {url}")
            
            response = requests.get(url, headers=headers, timeout=10)
            
            if response.status_code == 200:
                content_type = response.headers.get('content-type', '').lower()
                
                if 'json' in content_type:
                    try:
                        data = response.json()
                        print(f"✓ Found JSON API: {url}")
                        print(f"  Data keys: {list(data.keys()) if isinstance(data, dict) else 'List with ' + str(len(data)) + ' items'}")
                        return url, data
                    except:
                        pass
                elif len(response.content) > 1000:
                    print(f"✓ Found data endpoint: {url} ({len(response.content)} bytes)")
                    
        except Exception as e:
            print(f"  Failed: {e}")
    
    return None, None

def analyze_network_requests():
    """
    Try to simulate what the browser does to load schedule data
    """
    print("Analyzing main page for network requests...")
    
    try:
        # First, get the main page
        headers = {
            'User-Agent': 'Mozilla/5.0 (X11; Linux armv7l) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
        }
        
        response = requests.get("https://www.northsideprepathletics.com/schedule?year=2025-2026", 
                              headers=headers, timeout=15)
        
        if response.status_code != 200:
            print(f"Failed to get main page: {response.status_code}")
            return None
        
        print(f"Got main page: {len(response.content)} bytes")
        
        # Look for JavaScript that makes API calls
        content = response.text.lower()
        
        # Look for common patterns
        api_patterns = [
            'fetch(',
            'axios.',
            '$.get',
            '$.post',
            'xmlhttprequest',
            '/api/',
            '.json',
            'schedule',
            'events'
        ]
        
        found_patterns = []
        for pattern in api_patterns:
            if pattern in content:
                found_patterns.append(pattern)
        
        print(f"Found JS patterns: {found_patterns}")
        
        # Look for script tags that might load data
        soup = BeautifulSoup(response.content, 'html.parser')
        scripts = soup.find_all('script', src=True)
        
        print(f"Found {len(scripts)} external scripts")
        
        # Look for inline scripts with data
        inline_scripts = soup.find_all('script', src=False)
        data_scripts = []
        
        for script in inline_scripts:
            script_text = script.get_text()
            if any(word in script_text.lower() for word in ['schedule', 'event', 'sport', 'game']):
                if len(script_text) > 100:  # Substantial content
                    data_scripts.append(script_text[:200] + "...")
        
        if data_scripts:
            print(f"Found {len(data_scripts)} scripts with sports data")
            for i, script in enumerate(data_scripts[:3]):  # Show first 3
                print(f"  Script {i+1}: {script}")
        
        return response.text
        
    except Exception as e:
        print(f"Analysis failed: {e}")
        return None

def extract_static_data():
    """
    Extract whatever we can from the static HTML
    """
    print("Extracting data from static HTML...")
    
    try:
        headers = {
            'User-Agent': 'Mozilla/5.0 (X11; Linux armv7l) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
            'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
            'Accept-Language': 'en-US,en;q=0.5',
            'Accept-Encoding': 'gzip, deflate',
            'Connection': 'keep-alive',
        }
        
        response = requests.get("https://www.northsideprepathletics.com/schedule?year=2025-2026", 
                              headers=headers, timeout=15)
        
        soup = BeautifulSoup(response.content, 'html.parser')
        
        # Look for any schedule data in the HTML
        schedule_elements = {
            'dates': soup.find_all(['h3', 'h2', 'h1'], class_=lambda x: x and 'date' in str(x).lower()),
            'times': soup.find_all(['p', 'span', 'div'], class_=lambda x: x and 'time' in str(x).lower()),
            'sports': soup.find_all(['p', 'span', 'div'], class_=lambda x: x and any(word in str(x).lower() for word in ['sport', 'activity', 'game'])),
            'events': soup.find_all(['div', 'article', 'section'], class_=lambda x: x and any(word in str(x).lower() for word in ['event', 'schedule', 'game']))
        }
        
        for category, elements in schedule_elements.items():
            print(f"{category.capitalize()}: found {len(elements)} elements")
            if elements:
                for i, elem in enumerate(elements[:3]):  # Show first 3
                    text = elem.get_text(strip=True)[:100]
                    print(f"  {i+1}: {text}")
        
        # Look for JSON data embedded in HTML
        scripts = soup.find_all('script', type='application/json')
        if scripts:
            print(f"\nFound {len(scripts)} JSON scripts:")
            for i, script in enumerate(scripts):
                try:
                    data = json.loads(script.get_text())
                    print(f"  Script {i+1}: {type(data)} with {len(data) if isinstance(data, (list, dict)) else 'N/A'} items")
                except:
                    print(f"  Script {i+1}: Invalid JSON")
        
        return len(schedule_elements['events']) > 0
        
    except Exception as e:
        print(f"Static extraction failed: {e}")
        return False

def main():
    print("=== Ultra-Lightweight Scraping Approach ===")
    print("This avoids browsers entirely - perfect for low-memory Pi")
    print()
    
    # Step 1: Try to find API endpoints
    api_url, api_data = try_api_endpoints()
    
    if api_data:
        print("✓ Found API data! No browser needed.")
        return True
    
    print("-" * 40)
    
    # Step 2: Analyze the page structure
    page_content = analyze_network_requests()
    
    print("-" * 40)
    
    # Step 3: Extract static data
    has_static_data = extract_static_data()
    
    if has_static_data:
        print("\n✓ Found some static data, but likely need JavaScript rendering")
    else:
        print("\n✗ No usable static data found")
    
    print("\n=== Recommendations ===")
    print("1. Try the playwright approach (more memory efficient than Selenium)")
    print("2. Increase swap space first: bash increase_swap.sh")
    print("3. Contact the website developers for API access")
    print("4. Consider running scraping on a more powerful machine")

if __name__ == "__main__":
    main()
