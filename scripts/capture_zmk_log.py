#!/usr/bin/env python
r"""Capture ZMK USB debug log from a board built with the zmk-usb-logging snippet.

Windows' .NET SerialPort/FileStream choke on Zephyr CDC-ACM ports; pyserial works.
Zephyr's CDC-ACM console only transmits once the host asserts DTR (and, with
CONFIG_UART_LINE_CTRL, it may also wait for a baud-rate SET_LINE_CODING), so we
explicitly toggle DTR/RTS after opening and send a newline to nudge the shell.

Usage: python capture_zmk_log.py [--port COM13] [--seconds 30] [--out S:\TEMP\zmk_log.txt]
"""
import argparse
import sys
import time

import serial
import serial.tools.list_ports


def find_log_port():
    zmk = [p for p in serial.tools.list_ports.comports() if p.vid == 0x1D50]
    if not zmk:
        sys.exit("No ZMK (VID 1D50) serial ports found")
    print("ZMK ports:", ", ".join(f"{p.device} ({p.hwid})" for p in zmk))
    zmk.sort(key=lambda p: int(p.device[3:]))
    return zmk[-1].device


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--port")
    ap.add_argument("--seconds", type=float, default=30)
    ap.add_argument("--out", default=r"S:\TEMP\zmk_log.txt")
    a = ap.parse_args()

    port = a.port or find_log_port()
    print(f"Opening {port} for {a.seconds}s -> {a.out}", flush=True)
    chunks = []
    s = serial.Serial()
    s.port = port
    s.baudrate = 115200
    s.timeout = 0.2
    s.dtr = True   # set BEFORE open so DTR is asserted as part of open()
    s.rts = True
    for attempt in range(5):
        try:
            s.open()
            break
        except serial.SerialException as e:
            print(f"  open attempt {attempt+1} failed: {e}", flush=True)
            time.sleep(1.5)
    else:
        sys.exit("could not open port")
    with s:
        # Belt and braces: pulse DTR so a "DTR rising edge" gated console wakes up.
        try:
            s.dtr = False
            time.sleep(0.1)
            s.dtr = True
            s.rts = True
            s.write(b"\r\n")
        except Exception as e:
            print("  line-ctrl toggle failed:", e)
        print(f"  DTR={s.dtr} RTS={s.rts} CTS={s.cts} DSR={s.dsr} CD={s.cd}", flush=True)
        deadline = time.time() + a.seconds
        while time.time() < deadline:
            data = s.read(4096)
            if data:
                text = data.decode("ascii", "replace")
                sys.stdout.write(text)
                sys.stdout.flush()
                chunks.append(text)
    with open(a.out, "w", encoding="utf-8") as f:
        f.write("".join(chunks))
    print(f"\n--- saved {sum(map(len, chunks))} chars to {a.out}")


if __name__ == "__main__":
    main()
