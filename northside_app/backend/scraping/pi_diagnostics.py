# Ultra-lightweight scraping for Raspberry Pi
from bs4 import BeautifulSoup
import requests
import time
import subprocess
import os

def try_lightweight_browser():
    """
    Try using a lightweight browser like lynx or w3m if available
    """
    print("Trying lightweight browser approach...")
    
    # Check if lynx is available
    try:
        result = subprocess.run(['which', 'lynx'], capture_output=True, text=True)
        if result.returncode == 0:
            print("Found lynx browser, attempting to scrape...")
            
            # Use lynx to dump the page
            cmd = ['lynx', '-dump', '-nonumbers', '-listonly', 
                   'https://www.northsideprepathletics.com/schedule?year=2025-2026']
            
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=60)
            
            if result.returncode == 0:
                print(f"Lynx output length: {len(result.stdout)}")
                # This won't get dynamic content, but can test connectivity
                return result.stdout
            else:
                print(f"Lynx failed: {result.stderr}")
                
    except Exception as e:
        print(f"Lynx approach failed: {e}")
    
    return None

def minimal_selenium_test():
    """
    Absolute minimal selenium test
    """
    print("Trying minimal selenium...")
    
    try:
        from selenium import webdriver
        from selenium.webdriver.firefox.options import Options
        from selenium.webdriver.firefox.service import Service
        import signal
        
        # Minimal options
        options = Options()
        options.add_argument("--headless")
        options.add_argument("--disable-gpu")
        options.add_argument("--no-sandbox")
        
        # Very simple service
        service = Service(executable_path="/usr/local/bin/geckodriver")
        
        print("Creating minimal Firefox driver...")
        
        def timeout_handler(signum, frame):
            raise TimeoutError("Driver creation timeout")
        
        signal.signal(signal.SIGALRM, timeout_handler)
        signal.alarm(45)  # 45 second timeout
        
        try:
            driver = webdriver.Firefox(options=options, service=service)
            signal.alarm(0)
            print("✓ Driver created successfully!")
            
            print("Testing simple navigation...")
            driver.get("https://httpbin.org/html")  # Simple test page
            
            title = driver.title
            print(f"Test page title: {title}")
            
            driver.quit()
            print("✓ Simple test passed - Firefox works!")
            return True
            
        except TimeoutError:
            print("✗ Driver creation timed out")
            signal.alarm(0)
            return False
            
    except Exception as e:
        print(f"✗ Minimal selenium failed: {e}")
        return False

def check_firefox_directly():
    """
    Test Firefox directly from command line
    """
    print("Testing Firefox directly...")
    
    try:
        # Test Firefox version
        result = subprocess.run(['firefox', '--version'], 
                              capture_output=True, text=True, timeout=10)
        if result.returncode == 0:
            print(f"Firefox version: {result.stdout.strip()}")
        else:
            print(f"Firefox version check failed: {result.stderr}")
            
        # Test Firefox in headless mode
        result = subprocess.run(['firefox', '--headless', '--screenshot=/tmp/test.png', 
                               'https://httpbin.org/html'], 
                              capture_output=True, text=True, timeout=30)
        
        if result.returncode == 0:
            if os.path.exists('/tmp/test.png'):
                print("✓ Firefox headless mode works!")
                os.remove('/tmp/test.png')
                return True
            else:
                print("Firefox ran but no screenshot created")
        else:
            print(f"Firefox headless test failed: {result.stderr}")
            
    except subprocess.TimeoutExpired:
        print("✗ Firefox test timed out")
    except Exception as e:
        print(f"✗ Firefox direct test failed: {e}")
    
    return False

def check_memory_usage():
    """
    Check available memory
    """
    print("Checking system resources...")
    
    try:
        # Check memory
        with open('/proc/meminfo', 'r') as f:
            meminfo = f.read()
            
        for line in meminfo.split('\n'):
            if 'MemTotal:' in line:
                total_mem = int(line.split()[1]) // 1024  # Convert to MB
                print(f"Total memory: {total_mem} MB")
            elif 'MemAvailable:' in line:
                avail_mem = int(line.split()[1]) // 1024  # Convert to MB
                print(f"Available memory: {avail_mem} MB")
                
                if avail_mem < 512:
                    print("⚠️  Warning: Low available memory (< 512MB)")
                    print("   Consider closing other applications")
                    
        # Check CPU
        with open('/proc/cpuinfo', 'r') as f:
            cpuinfo = f.read()
            
        cpu_count = cpuinfo.count('processor')
        print(f"CPU cores: {cpu_count}")
        
        # Check if running on Pi
        if 'BCM' in cpuinfo or 'ARM' in cpuinfo:
            print("✓ Running on ARM-based system (likely Raspberry Pi)")
            
    except Exception as e:
        print(f"Resource check failed: {e}")

def main():
    print("=== Raspberry Pi Web Scraping Diagnostics ===")
    print()
    
    check_memory_usage()
    print("-" * 40)
    
    check_firefox_directly()
    print("-" * 40)
    
    minimal_selenium_test()
    print("-" * 40)
    
    try_lightweight_browser()
    print("-" * 40)
    
    print("\n=== Installation suggestions ===")
    print("If Firefox is hanging, try:")
    print("1. sudo apt install lynx  # Lightweight browser")
    print("2. sudo systemctl stop firefox  # Stop any running Firefox")
    print("3. pkill firefox  # Kill any hanging Firefox processes")
    print("4. free -h  # Check available memory")
    print("5. Consider using Chrome instead:")
    print("   - Install: sudo apt install chromium-browser chromium-chromedriver")

if __name__ == "__main__":
    main()
