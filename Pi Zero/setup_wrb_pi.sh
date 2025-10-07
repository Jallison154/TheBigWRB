#!/bin/bash

# WRB Pi Setup Script
# Run this on your Pi Zero after fresh install

echo "=== WRB Pi Setup Script ==="

# Update system
echo "Updating system packages..."
sudo apt update
sudo apt upgrade -y

# Install required packages
echo "Installing required packages..."
sudo apt install -y python3-pygame python3-serial python3-gpiozero python3-pip

# Create directory structure
echo "Creating directory structure..."
mkdir -p ~/WRB/sounds

# Create the main PiScript
echo "Creating PiScript..."
cat > ~/WRB/PiScript << 'EOF'
#!/usr/bin/env python3
import os, glob, time, random, sys, serial
from gpiozero import LED

# Audio device (your USB card is card0)
os.environ.setdefault("SDL_AUDIODRIVER","alsa")
os.environ.setdefault("AUDIODEV","plughw:0,0")

BAUD=115200
SERIAL=os.getenv("WRB_SERIAL","/dev/ttyACM0")
READY_PIN=18
READY_ACTIVE_LOW=True
MIX_FREQ=44100
MIX_BUF=512               # a touch more headroom now that keepalive is gone
RESCAN_SEC=1.0

def usb_mount_dirs():
    base="/media"
    return [os.path.join(base,d) for d in sorted(os.listdir(base)) 
            if os.path.isdir(os.path.join(base,d)) and os.path.ismount(os.path.join(base,d))] if os.path.isdir(base) else []

def pick_source():
    # Prefer USB with files; fall back to local
    for mnt in usb_mount_dirs():
        B1=sorted(glob.glob(os.path.join(mnt,"button1*.wav")))
        B2=sorted(glob.glob(os.path.join(mnt,"button2*.wav")))
        H1=sorted(glob.glob(os.path.join(mnt,"hold1*.wav")))
        H2=sorted(glob.glob(os.path.join(mnt,"hold2*.wav")))
        if B1 or B2 or H1 or H2:
            return (f"USB:{mnt}", mnt, B1[:1], B2, H1[:1], H2)
    local=os.path.expanduser("~/WRB/sounds"); os.makedirs(local, exist_ok=True)
    B1=sorted(glob.glob(os.path.join(local,"button1*.wav")))
    B2=sorted(glob.glob(os.path.join(local,"button2*.wav")))
    H1=sorted(glob.glob(os.path.join(local,"hold1*.wav")))
    H2=sorted(glob.glob(os.path.join(local,"hold2*.wav")))
    return ("LOCAL", local, B1[:1], B2, H1[:1], H2)

def load_sounds(B1, B2, H1, H2):
    import pygame
    button1 = pygame.mixer.Sound(B1[0]) if B1 and os.path.exists(B1[0]) else None
    button2 = [pygame.mixer.Sound(p) for p in B2 if os.path.exists(p)]
    hold1 = pygame.mixer.Sound(H1[0]) if H1 and os.path.exists(H1[0]) else None
    hold2 = [pygame.mixer.Sound(p) for p in H2 if os.path.exists(p)]
    return button1, button2, hold1, hold2

def classify(s):
    u=s.strip().upper()
    if "BTN1" in u and "HOLD" not in u: return 'B1'
    if "BTN2" in u and "HOLD" not in u: return 'B2'
    if "BTN1" in u and "HOLD" in u: return 'H1'
    if "BTN2" in u and "HOLD" in u: return 'H2'
    return None

def init_audio():
    import pygame
    for i in range(10):
        try:
            pygame.mixer.init(frequency=MIX_FREQ,size=-16,channels=2,buffer=MIX_BUF)
            pygame.mixer.set_num_channels(16)
            print("[WRB] audio: mixer ready", flush=True)
            return
        except Exception as e:
            print(f"[WRB] audio init retry {i+1}: {e}", flush=True); time.sleep(0.5)
    raise SystemExit("audio init failed")

def wait_serial():
    prefs=[SERIAL,"/dev/ttyACM0","/dev/ttyACM1","/dev/ttyUSB0","/dev/ttyUSB1","/dev/serial0","/dev/ttyAMA0","/dev/ttyS0"]
    print("[WRB] waiting for serial…", flush=True)
    while True:
        for p in prefs:
            try: return serial.Serial(p, BAUD, timeout=0.1)
            except: pass
        time.sleep(0.3)

def main():
    import pygame
    led=LED(READY_PIN, active_high=(not READY_ACTIVE_LOW))
    led.off()  # OFF until ready

    init_audio()
    src_tag, base, B1, B2, H1, H2 = pick_source()
    BUTTON1, BUTTON2, HOLD1, HOLD2 = load_sounds(B1, B2, H1, H2)
    print(f"[WRB] source={src_tag} button1={B1[:1]} button2={len(BUTTON2)} hold1={H1[:1]} hold2={len(HOLD2)}", flush=True)

    ser=wait_serial()
    print(f"[WRB] serial: {ser.port}", flush=True)

    led.on(); print("[WRB] READY", flush=True)
    last_scan=time.time()

    while True:
        # Hot-swap USB/local
        if time.time()-last_scan > RESCAN_SEC:
            new_tag, new_base, nB1, nB2, nH1, nH2 = pick_source()
            if (new_tag != src_tag) or (nB1 != B1) or (nB2 != B2) or (nH1 != H1) or (nH2 != H2):
                for ch in range(0,15): pygame.mixer.Channel(ch).stop()
                BUTTON1, BUTTON2, HOLD1, HOLD2 = load_sounds(nB1, nB2, nH1, nH2)
                src_tag, base, B1, B2, H1, H2 = new_tag, new_base, nB1, nB2, nH1, nH2
                print(f"[WRB] reloaded: source={src_tag} button1={B1[:1]} button2={len(BUTTON2)} hold1={H1[:1]} hold2={len(HOLD2)}", flush=True)
            last_scan=time.time()

        try: line=ser.readline().decode(errors="ignore")
        except Exception: time.sleep(0.05); continue
        if not line: continue
        t=classify(line)
        if t=='B1':
            if BUTTON1: pygame.mixer.Channel(0).play(BUTTON1)
            print("[WRB] BUTTON1 (src=%s loaded=%s)"%(src_tag,bool(BUTTON1)), flush=True)
            try: led.off(); time.sleep(0.04); led.on()
            except: pass
        elif t=='B2':
            if BUTTON2: pygame.mixer.Channel(1).play(random.choice(BUTTON2))
            print("[WRB] BUTTON2 (src=%s loaded=%d)"%(src_tag,len(BUTTON2)), flush=True)
            try: led.off(); time.sleep(0.04); led.on()
            except: pass
        elif t=='H1':
            if HOLD1: pygame.mixer.Channel(2).play(HOLD1)
            print("[WRB] HOLD1 (src=%s loaded=%s)"%(src_tag,bool(HOLD1)), flush=True)
            try: led.off(); time.sleep(0.04); led.on()
            except: pass
        elif t=='H2':
            if HOLD2: pygame.mixer.Channel(3).play(random.choice(HOLD2))
            print("[WRB] HOLD2 (src=%s loaded=%d)"%(src_tag,len(HOLD2)), flush=True)
            try: led.off(); time.sleep(0.04); led.on()
            except: pass

if __name__=="__main__":
    main()
EOF

# Make PiScript executable
chmod +x ~/WRB/PiScript

# Create the systemd service file
echo "Creating systemd service..."
sudo tee /etc/systemd/system/WRB-enhanced.service >/dev/null << 'EOF'
[Unit]
Description=WRB Enhanced Audio System
After=network.target sound.target
Wants=network.target

[Service]
Type=simple
User=pi
Group=pi
WorkingDirectory=/home/pi/WRB
Environment=WRB_SERIAL=/dev/ttyACM0
Environment=SDL_AUDIODRIVER=alsa
Environment=AUDIODEV=plughw:0,0
ExecStart=/usr/bin/python3 /home/pi/WRB/PiScript
Restart=always
RestartSec=5
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

# Create sample sound files
echo "Creating sample sound files..."
sudo apt install -y sox

# Create sample button sounds
sox -n -r 44100 -c 2 ~/WRB/sounds/button1.wav synth 0.5 sine 800 fade h 0.1 0.1
sox -n -r 44100 -c 2 ~/WRB/sounds/button2.wav synth 0.5 sine 400 fade h 0.1 0.1
sox -n -r 44100 -c 2 ~/WRB/sounds/hold1.wav synth 1.0 sine 1000 fade h 0.1 0.1
sox -n -r 44100 -c 2 ~/WRB/sounds/hold2.wav synth 1.0 sine 600 fade h 0.1 0.1

# Reload systemd and enable service
echo "Setting up systemd service..."
sudo systemctl daemon-reload
sudo systemctl enable WRB-enhanced.service

# Add pi user to audio group
sudo usermod -a -G audio pi

echo "=== Setup Complete! ==="
echo ""
echo "To start the service:"
echo "  sudo systemctl start WRB-enhanced.service"
echo ""
echo "To check status:"
echo "  sudo systemctl status WRB-enhanced.service"
echo ""
echo "To view logs:"
echo "  journalctl -u WRB-enhanced.service -f"
echo ""
echo "To test manually:"
echo "  cd ~/WRB && python3 PiScript"
echo ""
echo "Sample sound files created in ~/WRB/sounds/"
echo "Replace with your own button1*.wav, button2*.wav, hold1*.wav, hold2*.wav files"
