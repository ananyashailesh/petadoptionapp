import os
import requests
from PIL import Image
from io import BytesIO
import time
from pathlib import Path

# Unsplash API access key (you'll need to replace this with your own)
UNSPLASH_ACCESS_KEY = "YOUR_UNSPLASH_ACCESS_KEY"

# Base directory for images
BASE_DIR = Path("assets/images/products")

# Product categories and their search terms
CATEGORIES = {
    "food": [
        "dog food",
        "cat food",
        "dog treats"
    ],
    "toys": [
        "cat scratching post",
        "cat toys",
        "interactive cat toy"
    ],
    "accessories": [
        "pet carrier",
        "dog leash collar",
        "fish tank decorations"
    ],
    "housing": [
        "bird cage",
        "dog bed",
        "small animal cage"
    ],
    "equipment": [
        "aquarium filter",
        "pet water fountain"
    ],
    "grooming": [
        "pet grooming kit",
        "dog shampoo"
    ]
}

def create_directories():
    """Create necessary directories for product images."""
    for category in CATEGORIES.keys():
        (BASE_DIR / category).mkdir(parents=True, exist_ok=True)

def download_and_resize_image(url, save_path, size=(800, 800)):
    """Download image from URL and resize it."""
    try:
        response = requests.get(url)
        if response.status_code == 200:
            img = Image.open(BytesIO(response.content))
            img = img.convert('RGB')
            img.thumbnail(size, Image.Resampling.LANCZOS)
            img.save(save_path, 'JPEG', quality=85)
            return True
    except Exception as e:
        print(f"Error processing image: {e}")
    return False

def get_unsplash_image(query):
    """Get image URL from Unsplash API."""
    try:
        url = f"https://api.unsplash.com/photos/random"
        headers = {
            "Authorization": f"Client-ID {UNSPLASH_ACCESS_KEY}"
        }
        params = {
            "query": query,
            "orientation": "landscape"
        }
        response = requests.get(url, headers=headers, params=params)
        if response.status_code == 200:
            data = response.json()
            return data['urls']['regular']
    except Exception as e:
        print(f"Error fetching from Unsplash: {e}")
    return None

def main():
    # Create directories
    create_directories()
    
    # Process each category
    for category, search_terms in CATEGORIES.items():
        print(f"\nProcessing category: {category}")
        
        # Process each search term
        for term in search_terms:
            print(f"Searching for: {term}")
            
            # Get image URL from Unsplash
            image_url = get_unsplash_image(term)
            if not image_url:
                print(f"Failed to get image URL for {term}")
                continue
            
            # Create filename from search term
            filename = term.replace(" ", "_") + ".jpg"
            save_path = BASE_DIR / category / filename
            
            # Download and resize image
            if download_and_resize_image(image_url, save_path):
                print(f"Successfully downloaded and resized: {filename}")
            else:
                print(f"Failed to process image for {term}")
            
            # Respect Unsplash API rate limits
            time.sleep(1)

if __name__ == "__main__":
    main() 