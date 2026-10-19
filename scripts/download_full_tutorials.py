import os
import subprocess
import sys
import json
import time

YT_DLP_PATH = '/opt/homebrew/bin/yt-dlp'
FFMPEG_PATH = '/opt/homebrew/bin/ffmpeg'

OUTPUT_DIR = 'assets/videos'
TEMP_DIR = 'scripts/temp_vids'

os.makedirs(OUTPUT_DIR, exist_ok=True)
os.makedirs(TEMP_DIR, exist_ok=True)

EXERCISES = [
    # Day 1: Upper Hypertrophy
    ('chest_supported_row', 'chest supported row form tutorial shorts'),
    ('incline_db_press', 'incline dumbbell press form tutorial shorts'),
    ('lat_pulldown', 'lat pulldown form tutorial shorts'),
    ('face_pulls', 'face pulls form tutorial shorts'),
    ('incline_curl', 'incline dumbbell curl form tutorial shorts'),
    ('overhead_triceps', 'overhead cable tricep extension form tutorial shorts'),

    # Day 2: Lower & Posterior Chain
    ('hip_thrust', 'barbell hip thrust form tutorial shorts'),
    ('db_rdl', 'dumbbell romanian deadlift form tutorial shorts'),
    ('seated_leg_curl', 'seated leg curl form tutorial shorts'),
    ('bulgarian_split_squat', 'bulgarian split squat form tutorial shorts'),
    ('ab_wheel', 'ab wheel rollout form tutorial shorts'),
    ('reverse_crunch', 'reverse crunch form tutorial shorts'),

    # Day 3: Push Hypertrophy
    ('flat_db_press', 'flat dumbbell bench press form tutorial shorts'),
    ('db_shoulder_press', 'seated dumbbell shoulder press form tutorial shorts'),
    ('cable_fly', 'cable chest fly form tutorial shorts'),
    ('cable_lateral_raise', 'cable lateral raise form tutorial shorts'),
    ('straight_bar_pushdown', 'straight bar cable pushdown form tutorial shorts'),

    # Day 4: Pull & Upper Back
    ('chest_supported_db_row', 'chest supported dumbbell row form tutorial shorts'),
    ('close_grip_pulldown', 'close grip lat pulldown form tutorial shorts'),
    ('lat_prayer', 'lat prayer cable pullover form tutorial shorts'),
    ('reverse_pec_deck', 'reverse pec deck rear delt form tutorial shorts'),
    ('preacher_curl', 'preacher curl form tutorial shorts'),
    ('hammer_curl', 'dumbbell hammer curl form tutorial shorts'),

    # Day 5: Legs & Anterior Core
    ('hack_squat', 'hack squat form tutorial shorts'),
    ('cable_pull_through', 'cable pull through form tutorial shorts'),
    ('lying_leg_curl', 'lying leg curl form tutorial shorts'),
    ('standing_calf_raise', 'standing calf raise form tutorial shorts'),
    ('pallof_press', 'pallof press form tutorial shorts'),

    # APT Pre-Workout Protocol
    ('breathing_9090', '90 90 breathing exercise form tutorial shorts'),
    ('couch_stretch', 'couch stretch hip flexor form tutorial shorts'),
    ('deadbug', 'deadbug exercise form tutorial shorts'),
    ('glute_bridge', 'glute bridge exercise form tutorial shorts'),
]

def download_and_encode(filename, query):
    target_mp4 = os.path.join(OUTPUT_DIR, f'{filename}.mp4')
    raw_template = os.path.join(TEMP_DIR, f'{filename}_raw.%(ext)s')
    raw_mp4 = os.path.join(TEMP_DIR, f'{filename}_raw.mp4')

    print(f'===> [{filename}] Query: {query}')

    # Step 1: yt-dlp search and download full video (no crop)
    cmd_dl = [
        YT_DLP_PATH,
        '--match-filter', 'duration <= 75 & duration >= 10',
        '-f', 'bestvideo[height<=720]+bestaudio/best[height<=720]/best',
        '--merge-output-format', 'mp4',
        f'ytsearch3:{query}',
        '--max-downloads', '1',
        '-o', raw_template,
        '--no-playlist',
    ]

    res = subprocess.run(cmd_dl, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    if not os.path.exists(raw_mp4):
        # Fallback without strict duration filter
        print(f'Retrying [{filename}] with broader search...')
        cmd_dl_fallback = [
            YT_DLP_PATH,
            '--match-filter', 'duration <= 180',
            '-f', 'bestvideo[height<=720]+bestaudio/best[height<=720]/best',
            '--merge-output-format', 'mp4',
            f'ytsearch1:{query}',
            '-o', raw_template,
            '--no-playlist',
        ]
        subprocess.run(cmd_dl_fallback, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)

    if not os.path.exists(raw_mp4):
        print(f'FAILED to download {filename}')
        return False

    # Step 2: ffmpeg high-efficiency H.264 encode (keeping the entire full video tutorial)
    cmd_enc = [
        FFMPEG_PATH,
        '-y',
        '-i', raw_mp4,
        '-c:v', 'libx264',
        '-crf', '26',
        '-preset', 'fast',
        '-pix_fmt', 'yuv420p',
        '-vf', "scale='min(720,iw)':-2",
        '-c:a', 'aac',
        '-b:a', '128k',
        '-movflags', '+faststart',
        target_mp4,
    ]

    subprocess.run(cmd_enc, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)

    if os.path.exists(raw_mp4):
        os.remove(raw_mp4)

    if os.path.exists(target_mp4):
        sz = os.path.getsize(target_mp4) / (1024 * 1024)
        print(f'SUCCESS: {target_mp4} ({sz:.2f} MB)')
        return True
    return False

def main():
    start = time.time()
    success_count = 0
    for filename, query in EXERCISES:
        if download_and_encode(filename, query):
            success_count += 1

    elapsed = time.time() - start
    print(f'Completed {success_count}/{len(EXERCISES)} in {elapsed:.1f}s')

if __name__ == '__main__':
    main()
