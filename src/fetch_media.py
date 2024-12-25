import yaml
import subprocess
import time
import logging
from logging.handlers import RotatingFileHandler
import argparse
from pathlib import Path
import os
import sys
from PIL import Image, UnidentifiedImageError


# Parse command-line arguments
parser = argparse.ArgumentParser(description="Sync iCloud photos and maintain storage limits.")
parser.add_argument("ICLOUD_SLIDESHOW_PATH", type=str, help="The project directory path.")
args = parser.parse_args()

ICLOUD_SLIDESHOW_PATH = Path(args.ICLOUD_SLIDESHOW_PATH).resolve()
CONFIG_PATH = ICLOUD_SLIDESHOW_PATH / "config/config.yaml"

# Load configuration from config.yaml
with open(CONFIG_PATH, "r") as config_file:
    config = yaml.safe_load(config_file)

USER_NAME = config.get("USER_NAME", "clemens.christoph@hotmail.com")
ALBUM_NAME = config.get("ALBUM_NAME", "All Photos")
PHOTOS_ONLY = config.get("PHOTOS_ONLY", True)
TEMP_FOLDER = Path(ICLOUD_SLIDESHOW_PATH, config.get("TEMP_FOLDER", "media")).resolve()
MEDIA_FOLDER = Path(ICLOUD_SLIDESHOW_PATH, config.get("MEDIA_FOLDER", "media-rotated")).resolve()
RECENT_PHOTOS = config.get("RECENT_PHOTOS", 50)
MAX_MEDIA_STORED = config.get("MAX_MEDIA_STORED", 1000)
MAX_MEDIA_SIZE_GB = config.get("MAX_MEDIA_SIZE_GB", 10)
LOG_FILE_PATH = Path(ICLOUD_SLIDESHOW_PATH, "log", "fetch_media.log").resolve()
ROTATE_IMAGES = config.get("ROTATE_IMAGES", False)

TEMP_FOLDER.mkdir(parents=True, exist_ok=True)
MEDIA_FOLDER.mkdir(parents=True, exist_ok=True)

log_dir = os.path.dirname(LOG_FILE_PATH)
if not os.path.exists(log_dir):
    os.makedirs(log_dir)

# Set up logging with file size limit of 1MB
log_handler = RotatingFileHandler(LOG_FILE_PATH, maxBytes=1 * 1024 * 1024, backupCount=3)  # 1MB max size, 3 backup files
log_handler.setLevel(logging.INFO)
formatter = logging.Formatter("%(asctime)s - %(levelname)s - %(message)s")
log_handler.setFormatter(formatter)

logger = logging.getLogger()
logger.addHandler(log_handler)
logger.setLevel(logging.INFO)

logger.info(f"*"*50)

logger.info("Proejct directory: " + str(ICLOUD_SLIDESHOW_PATH))
logger.info("Logging to file: " + str(LOG_FILE_PATH))

logger.info(f"USER_NAME: {USER_NAME}")
logger.info(f"ALBUM_NAME: {ALBUM_NAME}")
logger.info(f"PHOTOS_ONLY: {PHOTOS_ONLY}")
logger.info(f"TEMP_FOLDER: {TEMP_FOLDER}")
logger.info(f"RECENT_PHOTOS: {RECENT_PHOTOS}")
logger.info(f"MAX_MEDIA_STORED: {MAX_MEDIA_STORED}")
logger.info(f"MAX_MEDIA_SIZE_GB: {MAX_MEDIA_SIZE_GB}")

# Function to calculate total folder size in GB
def get_folder_size_in_gb(folder: Path):
    total_size = sum(f.stat().st_size for f in folder.rglob('*') if f.is_file())
    return total_size / (1024 ** 3)

# Function to delete the oldest files if exceeding limits
def maintain_storage_limits(folder):
    media_files = sorted(folder.glob('*'), key=lambda f: f.stat().st_ctime)
    
    # Ensure the number of stored media doesn't exceed the maximum
    popped_count = 0
    while len(media_files) > MAX_MEDIA_STORED:
        oldest_file = media_files.pop(0)
        popped_count += 1
        oldest_file.unlink()
        logger.info(f"Deleted file {oldest_file} to maintain max media count.")

    logger.info(f"Deleted {popped_count} files to maintain max media count.")
    logger.info(f"Current media count: {len(media_files)}")

    # Ensure the total size doesn't exceed the maximum
    popped_count = 0
    while get_folder_size_in_gb(folder) > MAX_MEDIA_SIZE_GB:
        oldest_file = media_files.pop(0)
        popped_count += 1
        oldest_file.unlink()
        logger.info(f"Deleted file {oldest_file} to maintain max media size.")

    logger.info(f"Deleted {popped_count} files to maintain max media size.")
    logger.info(f"Current media size: {get_folder_size_in_gb(folder)} GB")
    
def move_files():  
    # Move all rotated files to the rotated folder
    for file in TEMP_FOLDER.glob('*'):
        if file.is_file():
            try:
                file.rename(MEDIA_FOLDER / file.name)
            except Exception as e:
                logger.error(f"Error moving file {file} to rotated folder: {e}")

try:
    logger.info("Starting iCloud photo sync...")

    # First maintain storage limits before syncing
    maintain_storage_limits(TEMP_FOLDER)  # Assume this is defined elsewhere
    logger.info("Maintained storage limits")

    result = subprocess.run([
        "icloudpd",
        "--username", str(USER_NAME),
        "--directory", str(TEMP_FOLDER),
        "--album", ALBUM_NAME,
        "--log-level", "error",
        "--recent", str(RECENT_PHOTOS),
        "--folder-structure", "None",
        "--skip-videos",
        "--skip-live-photos"  # Optional: Adjust based on requirements
    ], check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)  # Capture stderr
    
    logger.info(f"iCloud sync completed successfully. {result.stdout}")

except subprocess.CalledProcessError as e:
    # Catch errors like non-zero return codes
    logger.error(f"Error in subprocess: Return code {e.returncode}. Error output: {e.stderr}")
    # Check if the error output contains structured JSON data
    if "KeyError" in e.stderr:
        errMsg = f"Album not detected: {e.stderr.split('KeyError')[1].strip()}"
        logger.error(errMsg)
        print(errMsg)
        sys.exit(1)
        
    elif "NewConnectionError" in e.stderr:
        errMsg = f"Internet connection error"
        logger.error(errMsg)
        print(errMsg)
        sys.exit(1)
    elif "Authentication failed" in e.stderr:
        # TODO
        pass
    else:
        # Print raw error if it's not in JSON format
        logger.error("Raw error output:")
        logger.error(e.stderr)
        sys.exit(1)

except Exception as e:
    # Catch other exceptions
    logger.error(f"Something went wrong: {str(e)}")

# Ensure storage limits are maintained after syncing
maintain_storage_limits(TEMP_FOLDER)
logger.info("Maintained storage limits")

logger.info("Finished this media fetch")

move_files()
maintain_storage_limits(MEDIA_FOLDER)

logger.info("Rotated and moved files")
    
logger.info(f"*"*50)
logger.info(f"")

