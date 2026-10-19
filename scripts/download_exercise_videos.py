import os
import subprocess
import json

EXERCISES = [
    # Day 1
    ("incline_db_press", "incline dumbbell press form demonstration", 10, 16),
    ("lat_pulldown", "lat pulldown exercise form demonstration", 10, 16),
    ("face_pulls", "cable face pull exercise form demonstration", 8, 14),
    ("incline_curl", "incline dumbbell curl exercise form", 8, 14),
    ("overhead_triceps", "overhead cable triceps extension form", 8, 14),

    # Day 2
    ("hip_thrust", "barbell hip thrust exercise form demonstration", 10, 16),
    ("db_rdl", "dumbbell romanian deadlift form demonstration", 10, 16),
    ("seated_leg_curl", "seated leg curl exercise form", 8, 14),
    ("bulgarian_split_squat", "bulgarian split squat form demonstration", 8, 14),
    ("ab_wheel", "ab wheel rollout exercise form", 8, 14),
    ("reverse_crunch", "bench reverse crunch pelvic curl form", 8, 14),

    # Day 3
    ("flat_db_press", "flat dumbbell bench press form demonstration", 10, 16),
    ("db_shoulder_press", "seated dumbbell shoulder press form", 10, 16),
    ("cable_fly", "cable chest fly form demonstration", 8, 14),
    ("cable_lateral_raise", "cable lateral raise exercise form", 8, 14),
    ("straight_bar_pushdown", "straight bar triceps pushdown form", 8, 14),

    # Day 4
    ("chest_supported_db_row", "single arm dumbbell row form demonstration", 8, 14),
    ("close_grip_pulldown", "close grip neutral lat pulldown form", 8, 14),
    ("lat_prayer", "straight arm cable lat pullover prayer form", 8, 14),
    ("reverse_pec_deck", "reverse pec deck rear delt fly form", 8, 14),
    ("preacher_curl", "ez bar preacher curl exercise form", 8, 14),
    ("hammer_curl", "dumbbell hammer curl form demonstration", 8, 14),

    # Day 5
    ("hack_squat", "hack squat exercise form demonstration", 10, 16),
    ("cable_pull_through", "cable pull through exercise form glutes", 8, 14),
    ("lying_leg_curl", "lying leg curl machine form", 8, 14),
    ("standing_calf_raise", "standing calf raise form demonstration", 8, 14),
    ("pallof_press", "cable pallof press core exercise form", 8, 14),

    # APT Routine
    ("breathing_9090", "90 90 breathing with pelvic tilt demonstration", 8, 14),
    ("couch_stretch", "half kneeling couch stretch hip flexor demonstration", 8, 14),
    ("deadbug", "deadbug exercise form lower back flat", 8, 14),
    ("glute_bridge", "glute bridge with pelvic tilt form demonstration", 8, 14),
]

OUTPUT_DIR = "assets/videos"
os.makedirs(OUTPUT_DIR, exist_ok=True)

def download_exercise(key, query, start_sec, end_sec):
    out_path = os.path.join(OUTPUT_DIR, f"{key}.mp4")
    if os.path.exists(out_path) and os.path.getsize(out_path) > 100000:
        print(f"[SKIP] {key}.mp4 already exists ({os.path.getsize(out_path)} bytes)")
        return True

    print(f"[DOWNLOAD] {key}: '{query}' ({start_sec}s - {end_sec}s)...")
    temp_template = f"temp_{key}.%(ext)s"
    
    # 1. Download short section using yt-dlp
    cmd_yt = [
        "yt-dlp",
        f"ytsearch1:{query}",
        "--download-sections", f"*{start_sec:02d}-{end_sec:02d}",
        "-f", "bestvideo[height<=720]+bestaudio/best[height<=720]/best",
        "-o", temp_template,
        "--no-playlist",
        "--quiet",
        "--no-warnings"
    ]
    try:
        subprocess.run(cmd_yt, check=True, timeout=60)
    except Exception as e:
        print(f"[ERROR yt-dlp] {key}: {e}")
        # Cleanup
        for f in os.listdir("."):
            if f.startswith(f"temp_{key}."):
                os.remove(f)
        return False

    # Find downloaded temp file
    temp_files = [f for f in os.listdir(".") if f.startswith(f"temp_{key}.")]
    if not temp_files:
        print(f"[ERROR] No temp file for {key}")
        return False

    temp_file = temp_files[0]

    # 2. Encode to clean H.264 MP4 without audio for smooth looping
    cmd_ff = [
        "ffmpeg", "-y", "-i", temp_file,
        "-c:v", "libx264",
        "-preset", "veryfast",
        "-crf", "24",
        "-pix_fmt", "yuv420p",
        "-an",
        "-movflags", "+faststart",
        out_path
    ]
    try:
        subprocess.run(cmd_ff, check=True, capture_output=True, timeout=30)
        print(f"[SUCCESS] Saved {out_path} ({os.path.getsize(out_path)} bytes)")
    except Exception as e:
        print(f"[ERROR ffmpeg] {key}: {e}")
    finally:
        for f in temp_files:
            try:
                os.remove(f)
            except:
                pass

if __name__ == "__main__":
    for item in EXERCISES:
        download_exercise(*item)
