#!/usr/bin/env python3
import csv
import math
from pathlib import Path

# システムクロック周波数のリスト (Hz単位)
# ユーザーが自由に追加・変更できます
SYS_CLK_FREQS = [
    12_000_000,   # 12 MHz
    24_000_000,   # 24 MHz
    25_000_000,   # 25 MHz
    36_864_000,   # 36.864 MHz (Baudrate friendly)
    50_000_000,   # 50 MHz
    73_728_000,   # 73.728 MHz (Baudrate friendly)
    73_750_000,   # 73.750 MHz (Fractional MMCM target, Added)
    100_000_000,  # 100 MHz
    147_456_000,  # 147.456 MHz (Baudrate friendly)
    200_000_000   # 200 MHz
]

# 一般的にPC等でサポートされるボーレートのリスト
BAUD_RATES = [
    110, 300, 600, 1200, 2400, 4800, 9600, 14400,
    19200, 38400, 57600, 115200, 230400, 460800, 921600
]

# 本UART IPで対応しているオーバーサンプリング倍率
OVER_SAMPLES = [8, 16, 32]

def calculate_errors():
    doc_dir = Path(__file__).parent
    output_file = doc_dir / "baudrate_error_report.csv"
    
    headers = [
        "SysClk (MHz)", 
        "Target Baudrate (bps)", 
        "Over Sampling", 
        "Ideal Div", 
        "Actual Div", 
        "Actual Baudrate (bps)", 
        "Error (%)"
    ]
    
    rows = []
    
    for f_clk in SYS_CLK_FREQS:
        f_mhz = f_clk / 1_000_000
        for baud in BAUD_RATES:
            for osr in OVER_SAMPLES:
                # 理想の分周比 (浮動小数点)
                ideal_div = f_clk / (baud * osr)
                
                # 最も近い整数値 (分周比は1以上、16ビット幅なので最大65535)
                actual_div = round(ideal_div)
                
                # clk_divの範囲チェック (16ビットレジスタ: 1〜65535)
                if actual_div < 1 or actual_div > 65535:
                    rows.append([
                        f_mhz, 
                        baud, 
                        osr, 
                        f"{ideal_div:.2f}", 
                        "N/A", 
                        "N/A", 
                        "Out of Range"
                    ])
                else:
                    actual_baud = f_clk / (actual_div * osr)
                    error = ((actual_baud - baud) / baud) * 100
                    rows.append([
                        f_mhz, 
                        baud, 
                        osr, 
                        f"{ideal_div:.2f}", 
                        actual_div, 
                        f"{actual_baud:.2f}", 
                        f"{error:.4f}%"
                    ])
                    
    with open(output_file, 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        writer.writerow(headers)
        writer.writerows(rows)
        
    print(f"Baudrate error report generated at: {output_file}")

if __name__ == "__main__":
    calculate_errors()
