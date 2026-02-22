# OpenBB Desktop Platform (ODP) Installer Downloader

This script allows you to download the latest OpenBB Desktop Platform (ODP) installer for your operating system.

## Requirements

- Python 3.7+
- httpx library

Install dependencies:
```bash
pip install httpx
```

## Usage

### Basic Usage

Download the installer for your current operating system:
```bash
python3 download_odp_installer.py
```

The installer will be downloaded to your `~/Downloads` directory by default.

### Specify Download Directory

Download to a custom directory:
```bash
python3 download_odp_installer.py -d /path/to/directory
```

### Specify Operating System

Override automatic OS detection:
```bash
python3 download_odp_installer.py -o macos
python3 download_odp_installer.py -o windows
python3 download_odp_installer.py -o linux
```

### List Available Installers

See what installers are available without downloading:
```bash
python3 download_odp_installer.py --list
```

### Custom Download URL

If you have a specific download URL:
```bash
python3 download_odp_installer.py -u https://example.com/installer.dmg -f OpenBB.dmg
```

## Command-Line Options

- `-h, --help` - Show help message
- `-d DESTINATION, --destination DESTINATION` - Download destination directory (default: ~/Downloads)
- `-o {macos,windows,linux}, --os {macos,windows,linux}` - Override OS detection
- `-l, --list` - List available installers without downloading
- `-u URL, --url URL` - Custom download URL
- `-f FILENAME, --filename FILENAME` - Custom filename for download (only used with --url)

## Examples

### Download for macOS
```bash
python3 download_odp_installer.py -o macos
```

### Download to specific directory for Windows
```bash
python3 download_odp_installer.py -o windows -d /tmp/installers
```

### Download using custom URL
```bash
python3 download_odp_installer.py \
  -u https://github.com/OpenBB-finance/OpenBB/releases/download/v1.0.0/OpenBB.dmg \
  -f OpenBB-v1.0.0.dmg \
  -d ~/Desktop
```

## How It Works

1. The script first attempts to fetch the latest release information from the GitHub API
2. If the API is unavailable (e.g., rate limiting), it falls back to predefined direct download URLs
3. The script detects your operating system and downloads the appropriate installer
4. Progress is shown during the download
5. The installer is saved to the specified directory

## Troubleshooting

### GitHub API Rate Limiting

If you see a 403 error when fetching release information, the script will automatically fall back to direct download URLs. This is normal and expected behavior.

### Download Failures

If the download fails with a 404 error, the installer URL may have changed. You can:
1. Check the [OpenBB releases page](https://github.com/OpenBB-finance/OpenBB/releases) for the correct URL
2. Use the `--url` option to specify the direct download URL manually

### Permission Errors

Make sure you have write permissions to the destination directory. If you get permission errors, try:
- Specifying a different directory with `-d`
- Running with appropriate permissions

## Support

For issues related to the OpenBB Desktop Platform itself, please visit:
- [OpenBB GitHub Repository](https://github.com/OpenBB-finance/OpenBB)
- [OpenBB Documentation](https://docs.openbb.co/)

## License

This script is part of the agents-for-openbb repository and follows the same license terms.
