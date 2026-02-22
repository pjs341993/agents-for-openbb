#!/usr/bin/env python3
"""
Script to download the OpenBB Desktop Platform (ODP) installer.

This script detects the operating system and downloads the appropriate
installer for the OpenBB Desktop Platform from the latest GitHub release.
"""

import argparse
import platform
import sys
from pathlib import Path
from urllib.parse import urlparse

try:
    import httpx
except ImportError:
    print("Error: httpx module is required. Install it with: pip install httpx")
    sys.exit(1)


GITHUB_API_URL = "https://api.github.com/repos/OpenBB-finance/OpenBB/releases/latest"
DEFAULT_DOWNLOAD_DIR = Path.home() / "Downloads"

# Fallback direct download URLs (updated periodically)
# Note: These URLs point to the latest release. The actual file names may vary.
FALLBACK_URLS = {
    "macos": "https://github.com/OpenBB-finance/OpenBB/releases/download/ODP/OpenBB.dmg",
    "windows": "https://github.com/OpenBB-finance/OpenBB/releases/download/ODP/OpenBB-Setup.exe",
    "linux": "https://github.com/OpenBB-finance/OpenBB/releases/download/ODP/OpenBB.AppImage",
}


def get_os_type():
    """Detect the operating system."""
    system = platform.system().lower()
    os_mapping = {
        "darwin": "macos",
        "windows": "windows",
        "linux": "linux",
    }
    return os_mapping.get(system, "unknown")


def get_installer_pattern(os_type):
    """Get the installer file pattern for the given OS."""
    patterns = {
        "macos": [".dmg", "Darwin", "macOS"],
        "windows": [".exe", ".msi", "Windows"],
        "linux": [".AppImage", ".deb", ".rpm", "Linux"],
    }
    return patterns.get(os_type, [])


def extract_filename_from_url(url):
    """Extract filename from URL using proper URL parsing."""
    parsed = urlparse(url)
    # Get the last part of the path
    filename = parsed.path.rstrip("/").split("/")[-1]

    # Validate that we got a reasonable filename
    if not filename or "." not in filename:
        return None

    return filename


def fetch_latest_release():
    """Fetch the latest release information from GitHub."""
    try:
        headers = {
            "Accept": "application/vnd.github.v3+json",
            "User-Agent": "OpenBB-Installer-Script",
        }
        with httpx.Client(timeout=30.0) as client:
            response = client.get(GITHUB_API_URL, headers=headers)
            response.raise_for_status()
            return response.json()
    except httpx.HTTPError as e:
        print(f"Warning: Could not fetch release information from GitHub API: {e}")
        print("Falling back to direct download URLs...")
        return None


def find_installer_asset(assets, os_type):
    """Find the appropriate installer asset for the given OS."""
    patterns = get_installer_pattern(os_type)

    for asset in assets:
        asset_name = asset.get("name", "")
        # Check if asset name contains any of the patterns
        for pattern in patterns:
            if pattern.lower() in asset_name.lower():
                return asset

    return None


def download_file(url, destination, filename):
    """Download a file from URL to destination."""
    filepath = Path(destination) / filename

    print(f"Downloading {filename}...")
    print(f"URL: {url}")
    print(f"Destination: {filepath}")

    try:
        with httpx.stream("GET", url, follow_redirects=True, timeout=300.0) as response:
            response.raise_for_status()
            total_size = int(response.headers.get("content-length", 0))

            with open(filepath, "wb") as f:
                downloaded = 0
                for chunk in response.iter_bytes(chunk_size=8192):
                    f.write(chunk)
                    downloaded += len(chunk)

                    if total_size > 0:
                        percent = (downloaded / total_size) * 100
                        print(f"\rProgress: {percent:.1f}%", end="", flush=True)

            print("\n✓ Download complete!")
            print(f"File saved to: {filepath}")
            return filepath

    except Exception as e:
        print(f"\n✗ Download failed: {e}")
        if filepath.exists():
            filepath.unlink()
        return None


def main():
    """Main function to download ODP installer."""
    parser = argparse.ArgumentParser(
        description="Download OpenBB Desktop Platform (ODP) installer"
    )
    parser.add_argument(
        "-d",
        "--destination",
        type=Path,
        default=DEFAULT_DOWNLOAD_DIR,
        help=f"Download destination directory (default: {DEFAULT_DOWNLOAD_DIR})",
    )
    parser.add_argument(
        "-o",
        "--os",
        choices=["macos", "windows", "linux"],
        help="Override OS detection (default: auto-detect)",
    )
    parser.add_argument(
        "-l",
        "--list",
        action="store_true",
        help="List available installers without downloading",
    )
    parser.add_argument(
        "-u", "--url", type=str, help="Custom download URL (overrides auto-detection)"
    )
    parser.add_argument(
        "-f",
        "--filename",
        type=str,
        help="Custom filename for download (only used with --url)",
    )

    args = parser.parse_args()

    # Handle custom URL option
    if args.url:
        print(f"Using custom download URL: {args.url}")

        # Create destination directory
        args.destination.mkdir(parents=True, exist_ok=True)

        # Use provided filename or extract from URL
        if args.filename:
            filename = args.filename
        else:
            filename = extract_filename_from_url(args.url)

        if not filename:
            print(
                "Error: Could not determine filename from URL. Please provide --filename option."
            )
            sys.exit(1)

        result = download_file(args.url, args.destination, filename)

        if result:
            print("\n✓ Successfully downloaded installer!")
            sys.exit(0)
        else:
            print("\n✗ Failed to download installer")
            sys.exit(1)

    # Detect or use provided OS
    os_type = args.os if args.os else get_os_type()

    if os_type == "unknown":
        print("Error: Could not detect operating system.")
        print("Please specify OS manually with --os option.")
        sys.exit(1)

    print(f"Operating System: {os_type}")
    print("Fetching latest ODP release information...")

    # Fetch release data
    release_data = fetch_latest_release()

    # If API fetch failed, use fallback URLs
    if not release_data:
        if args.list:
            print("\nUsing fallback download URLs:")
            for os_name, url in FALLBACK_URLS.items():
                print(f"  - {os_name}: {url}")
            return

        print(f"\nUsing fallback download URL for {os_type}...")
        fallback_url = FALLBACK_URLS.get(os_type)

        if not fallback_url:
            print(f"Error: No fallback URL available for {os_type}")
            sys.exit(1)

        # Extract filename from URL
        filename = extract_filename_from_url(fallback_url)

        if not filename:
            print(f"Error: Could not extract filename from URL: {fallback_url}")
            sys.exit(1)

        # Create destination directory if it doesn't exist
        args.destination.mkdir(parents=True, exist_ok=True)

        # Download using fallback URL
        result = download_file(fallback_url, args.destination, filename)

        if result:
            print("\n✓ Successfully downloaded ODP installer!")
            sys.exit(0)
        else:
            print("\n✗ Failed to download ODP installer")
            sys.exit(1)

    release_name = release_data.get("name", "Unknown")
    release_tag = release_data.get("tag_name", "Unknown")
    assets = release_data.get("assets", [])

    print(f"\nLatest Release: {release_name} ({release_tag})")

    if args.list:
        print("\nAvailable installers:")
        for asset in assets:
            size_mb = asset.get("size", 0) / (1024 * 1024)
            print(f"  - {asset['name']} ({size_mb:.2f} MB)")
        return

    # Find appropriate installer
    installer_asset = find_installer_asset(assets, os_type)

    if not installer_asset:
        print(f"\nError: No installer found for {os_type}")
        print("\nAvailable installers:")
        for asset in assets:
            print(f"  - {asset['name']}")
        sys.exit(1)

    # Create destination directory if it doesn't exist
    args.destination.mkdir(parents=True, exist_ok=True)

    # Download the installer
    download_url = installer_asset.get("browser_download_url")
    filename = installer_asset.get("name")

    if not download_url or not filename:
        print("Error: Invalid asset information")
        sys.exit(1)

    result = download_file(download_url, args.destination, filename)

    if result:
        print("\n✓ Successfully downloaded ODP installer!")
        sys.exit(0)
    else:
        print("\n✗ Failed to download ODP installer")
        sys.exit(1)


if __name__ == "__main__":
    main()
