from pathlib import Path

ADDR_W = 11
DEPTH = 1 << ADDR_W

def main():
    mem = [0x00] * DEPTH

    for a in range(0x001, 0x020):
        mem[a] = (a * 3) & 0xFF  # any deterministic non-X pattern is fine

    mem[0x000] = 0x05
    mem[0x049] = 0x05
    mem[0x0B5] = 0x00

    out_path = Path("../rtl/init_memory")
    out_path.write_text("\n".join(f"{b:02x}" for b in mem) + "\n", encoding="ascii")
    print(f"Wrote {DEPTH} bytes to {out_path}")

if __name__ == "__main__":
    main()

