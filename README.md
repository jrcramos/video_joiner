# Video Joiner

A Windows command-line tool to join multiple video files into a single output file with standardized encoding using FFmpeg.

## Features

- **Easy to Use**: Interactive command-line interface with drag-and-drop support
- **Video Standardization**: Automatically normalizes all input videos to consistent settings (resolution, bitrate, frame rate)
- **Maximum Compatibility**: Outputs standardized MP4 files that work across all platforms and devices
- **GPU Acceleration**: Uses NVIDIA hardware encoding (h264_nvenc) for faster processing when available
- **Configurable Settings**: Easily customize output quality, resolution, and encoding parameters
- **Auto-Detection**: Automatically finds FFmpeg installation in common locations

## Prerequisites

### Required
- **Windows OS** (Windows 7 or later)
- **FFmpeg** - A complete, cross-platform solution to record, convert and stream audio and video

### Optional
- **NVIDIA GPU** with NVENC support for hardware-accelerated encoding (falls back to software encoding if not available)

## Installation

### Step 1: Install FFmpeg

1. **Download FFmpeg**
   - Visit [https://ffmpeg.org/download.html](https://ffmpeg.org/download.html)
   - For Windows, download a build from [gyan.dev](https://www.gyan.dev/ffmpeg/builds/) or [BtbN](https://github.com/BtbN/FFmpeg-Builds/releases)

2. **Install FFmpeg** (choose one method):

   **Method A: Add to System PATH (Recommended)**
   - Extract the downloaded archive
   - Add the `bin` folder to your system PATH environment variable
   - The script will auto-detect FFmpeg

   **Method B: Manual Installation**
   - Extract to `C:\ffmpeg\` (or any location)
   - Update the `ffmpeg` path in the script's CONFIGURATION SECTION (line 13)

### Step 2: Download Video Joiner

1. Download `video_joiner.cmd` from this repository
2. Save it to any folder on your computer (e.g., `C:\Tools\` or your Desktop)

## Usage

### Basic Usage

1. **Run the Script**
   - Double-click `video_joiner.cmd` or run it from Command Prompt

2. **Enter Output Filename**
   - Type the desired name for your output file (without extension)
   - Example: `merged_video`

3. **Add Video Files**
   - Enter the full path to each video file, one per line
   - **TIP**: You can drag and drop files into the command window to paste their paths
   - Press ENTER on an empty line when you're done adding files

4. **Wait for Processing**
   - The script will standardize each video (this may take time depending on file size)
   - Then it will concatenate them into a single file (this is fast)

5. **Find Your Output**
   - The merged video will be saved in the same folder as the script
   - Filename: `[your_chosen_name].mp4`

### Example Session

```
================================
   FFmpeg Video Joiner v2.1
(Standardizes & Joins for Max Compatibility)
================================

Enter output file name (without extension): my_merged_video

Enter video file paths (one per line).
Press ENTER on an empty line when done.
TIP: You can drag and drop a file into this window to paste its path.

File path (or ENTER to finish): C:\Videos\clip1.mp4
Added: C:\Videos\clip1.mp4
File path (or ENTER to finish): C:\Videos\clip2.mp4
Added: C:\Videos\clip2.mp4
File path (or ENTER to finish): 

Processing file 1 of 2: "clip1.mp4"
...
Concatenating all standardized videos...
SUCCESS! Merge complete.
Output saved to: "C:\Tools\my_merged_video.mp4"
```

## Configuration

The script includes a **CONFIGURATION SECTION** at the top where you can customize various settings. Open `video_joiner.cmd` in a text editor and modify these variables:

### FFmpeg Path
```batch
set "ffmpeg=C:\ffmpeg\bin\ffmpeg.exe"
```
- Change this if FFmpeg is installed in a different location
- Leave as-is if FFmpeg is in your system PATH (it will auto-detect)

### Temporary Directory
```batch
set "tempDir=C:\ffmpeg\temp"
```
- Directory used for temporary processing files
- If this path doesn't exist, the script will use your system's temp folder automatically
- Change this if you want to use a specific location with adequate free space

### Video Quality Settings

```batch
set "VIDEO_BITRATE=4M"
```
- Controls output video quality
- Higher = better quality but larger file size
- Examples: `2M` (lower quality), `4M` (balanced), `8M` (high quality)

```batch
set "VIDEO_RESOLUTION=1280x720"
```
- Output video resolution (width x height)
- Common options:
  - `1920x1080` (Full HD)
  - `1280x720` (HD)
  - `854x480` (SD)

```batch
set "FRAME_RATE=30"
```
- Frames per second for output video
- Common options: `24`, `30`, `60`

```batch
set "AUDIO_BITRATE=192k"
```
- Audio quality for output
- Common options: `128k`, `192k`, `256k`

## How It Works

1. **Standardization Phase**
   - Each input video is re-encoded to ensure consistent:
     - Video codec (H.264 with NVENC hardware acceleration)
     - Resolution
     - Frame rate
     - Audio codec (AAC)
     - Bitrate
   - This ensures all videos can be seamlessly joined

2. **Concatenation Phase**
   - Standardized videos are joined using FFmpeg's concat demuxer
   - This is a fast, lossless copy operation
   - No re-encoding occurs in this phase

3. **Cleanup**
   - Temporary files are automatically deleted
   - Only the final merged video remains

## Troubleshooting

### "ffmpeg not found" Error

**Solution**: 
- Download and install FFmpeg (see Installation section)
- Add FFmpeg to your system PATH, or
- Update the `ffmpeg` variable in the script to point to your ffmpeg.exe location

### "Pre-processing failed" Error

**Possible causes**:
- **No NVIDIA GPU**: The script uses h264_nvenc (NVIDIA hardware encoder)
  - **Fix**: Edit line 109 in the script, change `-c:v h264_nvenc -preset p5` to `-c:v libx264 -preset medium` for software encoding
- **Corrupted input video**: Try the video in a media player first
- **Insufficient disk space**: Check available space in your temp directory
- **Unsupported format**: FFmpeg should handle most formats, but some proprietary codecs may need additional libraries

### Videos Not Synchronized After Merging

**Solution**:
- This script standardizes frame rates and audio to prevent sync issues
- If problems persist, ensure all input videos have audio tracks (add silent audio to those that don't)

### Processing is Very Slow

**Causes**:
- **No GPU acceleration**: Software encoding is slower
  - Check if you have an NVIDIA GPU with NVENC support
- **Large files**: Processing time scales with file size and length
- **High bitrate settings**: Lower the `VIDEO_BITRATE` in configuration

### Output File is Too Large

**Solution**:
- Reduce `VIDEO_BITRATE` (e.g., from `4M` to `2M`)
- Reduce `VIDEO_RESOLUTION` (e.g., from `1920x1080` to `1280x720`)
- Reduce `AUDIO_BITRATE` (e.g., from `192k` to `128k`)

## Technical Details

- **Video Codec**: H.264 (via NVENC or libx264)
- **Audio Codec**: AAC
- **Container Format**: MP4
- **Color Space**: yuv420p (maximum compatibility)
- **Frame Rate Mode**: Constant frame rate (CFR)

## License

This project is open source. Feel free to modify and distribute as needed.

## Contributing

Contributions are welcome! Feel free to submit issues or pull requests.

## Credits

This tool is built on [FFmpeg](https://ffmpeg.org/), a powerful multimedia framework.
