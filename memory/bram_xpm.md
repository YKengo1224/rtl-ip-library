# xpm_memory_tdpram (True Dual Port RAM) 解説

このドキュメントでは、Xilinx Parameterized Macro (XPM) の真のデュアルポートRAM（True Dual Port RAM）マクロである `xpm_memory_tdpram` のパラメータ設定、ポート仕様、およびインスタンス化方法について解説します。

対象ソースファイル: [bram_xpm.sv](file:///home/kengo/work/personal/RTL/rtl-ip-library/memory/bram_xpm.sv)

---

## 1. 概要
`xpm_memory_tdpram` は、Xilinx FPGA デバイス向けにパラメータ化された True Dual Port RAM（真のデュアルポートRAM）を生成するためのマクロです。Vivado ツールが自動的に最適なハードウェアリソース（Block RAM, UltraRAM, Distributed RAMなど）へマッピングします。

---

## 2. 主要なパラメータ解説

パラメータは、メモリのサイズ、データ幅、リソースタイプ、動作モードなどを設定するために使用されます。

| パラメータ名 | データ型 | 設定範囲 / デフォルト値 | 説明 |
| :--- | :--- | :--- | :--- |
| **MEMORY_SIZE** | Integer | 2 - 150,994,944<br>(デフォルト: `2048`) | メモリの総ビット数。例えば、2K x 32-bit の場合は `65536` と設定します。 |
| **MEMORY_PRIMITIVE** | String | `"auto"`, `"block"`, `"distributed"`, `"ultra"`, `"mixed"` (デフォルト: `"auto"`) | メモリを構成するハードウェアリソースのタイプを指定します。<br>- `"auto"`: Vivadoが最適化して決定<br>- `"distributed"`: 分散メモリ (LUT RAM)<br>- `"block"`: ブロックRAM (BRAM)<br>- `"ultra"`: ウルトラRAM (URAM) |
| **CLOCKING_MODE** | String | `"common_clock"`, `"independent_clock"` (デフォルト: `"common_clock"`) | ポートAとポートBのクロック関係。<br>- `"common_clock"`: 両ポートを同じクロック (`clka`) で同期動作<br>- `"independent_clock"`: 独立した異なるクロック (`clka`, `clkb`) で非同期動作 |
| **ADDR_WIDTH_A / B** | Integer | 1 - 20 (デフォルト: `6`) | ポートAおよびポートBのアドレス幅（ビット数）。<br>メモリの深さを参照するために十分な幅を設定する必要があります。 |
| **WRITE_DATA_WIDTH_A / B** | Integer | 1 - 4608 (デフォルト: `32`) | 各ポートの書き込みデータ幅。 |
| **READ_DATA_WIDTH_A / B** | Integer | 1 - 4608 (デフォルト: `32`) | 各ポートの読み出しデータ幅（対応するWRITE_DATA_WIDTHと同一である必要があります）。 |
| **BYTE_WRITE_WIDTH_A / B** | Integer | 1 - 4608 (デフォルト: `32`) | バイト書き込みを有効にする場合のバイト幅（通常は `8` または `9`）。ワード単位で一括書き込みを行う場合は、`WRITE_DATA_WIDTH` と同じ値を指定します。 |
| **READ_LATENCY_A / B** | Integer | 0 - 100 (デフォルト: `2`) | 読み出しデータパスのレジスタステージ数。<br>- `0`: レジスタなし（分散RAMのみ可能、組み合わせ出力）<br>- `1`: メモリラッチのみ使用（ブロックRAMなどの最小遅延）<br>- `2`: 出力レジスタを使用（タイミングが最適化されます） |
| **WRITE_MODE_A / B** | String | `"no_change"`, `"read_first"`, `"write_first"` (デフォルト: `"no_change"`) | 同一アドレスに対して書き込みが発生した際の、読み出しポート (`dout`) の挙動。<br>- `"no_change"`: 読み出しデータは更新されない<br>- `"read_first"`: 書き込み前の古いデータが読み出される<br>- `"write_first"`: 書き込まれた新しいデータが即座に読み出される |
| **ECC_MODE** | String | `"no_ecc"`, `"both_encode_and_decode"`, `"decode_only"`, `"encode_only"` (デフォルト: `"no_ecc"`) | ECC (エラー訂正機能) のモード。<br>有効時はデータ幅の制限等が発生します。 |
| **WAKEUP_TIME** | String | `"disable_sleep"`, `"use_sleep_pin"` (デフォルト: `"disable_sleep"`) | ダイナミック低電力セービング（スリープ）機能の有無。 |
| **WRITE_PROTECT** | Integer | 0, 1 (デフォルト: `1`) | 書き込み保護機能。`1` の場合、ライトイネーブル (`we`) がイネーブル信号 (`en`) なしでアサートされても書き込みが行われないようにLUT論理が追加されます。 |

---

## 3. 主要なポート解説

### システム・制御信号
* **`clka`** (Input, 1bit): ポートAのクロック。`CLOCKING_MODE` が `"common_clock"` の場合はポートBのクロックも兼ねます。
* **`clkb`** (Input, 1bit): ポートBのクロック。`CLOCKING_MODE` が `"independent_clock"` の時のみ使用されます。
* **`ena` / `enb`** (Input, 1bit, Active-High): 各ポートのメモリエネーブル。リード・ライト時にアサート（`1`）する必要があります。
* **`regcea` / `regceb`** (Input, 1bit, Active-High): 最終出力レジスタのクロックイネーブル。通常は `1'b1` に固定します。
* **`rsta` / `rstb`** (Input, 1bit, Active-High): 最終出力レジスタのリセット信号。アサートされると、`dout` が `READ_RESET_VALUE` に同期リセットされます。
* **`sleep`** (Input, 1bit, Active-High): スリープ制御ピン。

### データ・アドレス信号
* **`addra` / `addrb`** (Input, `ADDR_WIDTH`-bit): 各ポートのアドレス入力。
* **`dina` / `dinb`** (Input, `WRITE_DATA_WIDTH`-bit): 各ポートの書き込みデータ入力。
* **`douta` / `doutb`** (Output, `READ_DATA_WIDTH`-bit): 各ポートの読み出しデータ出力。
* **`wea` / `web`** (Input, `WRITE_DATA_WIDTH / BYTE_WRITE_WIDTH`-bit): 書き込みイネーブル。
  * ワード単位で書き込む場合は 1ビット幅。
  * バイト書き込み時は、データバスのどのバイトを書き込むかを制御するビットベクタ（例: 32bit幅、バイト幅8bitの場合、4ビットのベクタとなり、`4'b0010` でバイト1 [15:8] のみ書き込み）。

### ECC / エラー制御信号 (ECC使用時のみ有効)
* **`sbiterra` / `sbiterrb`** (Output, 1bit): シングルビットエラー検出フラグ。
* **`dbiterra` / `dbiterrb`** (Output, 1bit): ダブルビットエラー検出フラグ。
* **`injectsbiterra` / `injectsbiterrb`** (Input, 1bit): テスト用シングルビットエラー注入トリガー。
* **`injectdbiterra` / `injectdbiterrb`** (Input, 1bit): テスト用ダブルビットエラー注入トリガー。

---

## 4. インスタンス化テンプレート

以下は SystemVerilog/Verilog におけるインスタンス化のコード例です。

```systemverilog
   // xpm_memory_tdpram: True Dual Port RAM
   // Xilinx Parameterized Macro (version 2023.1)
   xpm_memory_tdpram #(
      .ADDR_WIDTH_A            (6),               // アドレス幅 A (2^6 = 64 words)
      .ADDR_WIDTH_B            (6),               // アドレス幅 B
      .AUTO_SLEEP_TIME         (0),               // 自動スリープ時間 (0: 無効)
      .BYTE_WRITE_WIDTH_A      (32),              // ライト有効幅 (32: ワード書き込み)
      .BYTE_WRITE_WIDTH_B      (32),              //
      .CASCADE_HEIGHT          (0),               // カスケード高さ (0: 自動)
      .CLOCKING_MODE           ("common_clock"),  // クロックモード ("common_clock" または "independent_clock")
      .ECC_BIT_RANGE           ("7:0"),           // ECCビット範囲
      .ECC_MODE                ("no_ecc"),        // ECCモード
      .ECC_TYPE                ("none"),          // ECCタイプ
      .IGNORE_INIT_SYNTH       (0),               // 初期化ファイルの論理合成時無視設定
      .MEMORY_INIT_FILE        ("none"),          // 初期値メモリファイル (.mem)
      .MEMORY_INIT_PARAM       ("0"),             // 初期値パラメータ文字列
      .MEMORY_OPTIMIZATION     ("true"),          // メモリオプティマイズ
      .MEMORY_PRIMITIVE        ("auto"),          // リソースタイプ ("auto", "block", "distributed", "ultra")
      .MEMORY_SIZE             (2048),            // メモリサイズ (64 words * 32 bits = 2048 bits)
      .MESSAGE_CONTROL         (0),               // メッセージコントロール (衝突警告など)
      .RAM_DECOMP              ("auto"),          // 分割モード ("auto", "power", "area")
      .READ_DATA_WIDTH_A       (32),              // 読み出しデータ幅 A
      .READ_DATA_WIDTH_B       (32),              // 読み出しデータ幅 B
      .READ_LATENCY_A          (2),               // 読み出しレイテンシ A (出力レジスタあり)
      .READ_LATENCY_B          (2),               // 読み出しレイテンシ B
      .READ_RESET_VALUE_A      ("0"),             // リセット時の読み出し初期値 A
      .READ_RESET_VALUE_B      ("0"),             // リセット時の読み出し初期値 B
      .RST_MODE_A              ("SYNC"),          // リセットモード A ("SYNC" / "ASYNC")
      .RST_MODE_B              ("SYNC"),          // リセットモード B
      .SIM_ASSERT_CHK          (0),               // シミュレーション時の警告アサート (0: 無効, 1: 有効)
      .USE_EMBEDDED_CONSTRAINT (0),               // 埋め込み制約 (1: set_false_path有効)
      .USE_MEM_INIT            (1),               // 初期化メッセージ警告の有無
      .USE_MEM_INIT_MMI        (0),               // MMIファイル出力設定
      .WAKEUP_TIME             ("disable_sleep"), // スリープ起動時間設定
      .WRITE_DATA_WIDTH_A      (32),              // 書き込みデータ幅 A
      .WRITE_DATA_WIDTH_B      (32),              // 書き込みデータ幅 B
      .WRITE_MODE_A            ("no_change"),     // 書き込みモード A ("no_change", "read_first", "write_first")
      .WRITE_MODE_B            ("no_change"),     // 書き込みモード B
      .WRITE_PROTECT           (1)                // 書き込み保護有効
   )
   xpm_memory_tdpram_inst (
      // ステータス / 出力ポート
      .douta          (douta),           // ポートA 読み出しデータ出力
      .doutb          (doutb),           // ポートB 読み出しデータ出力
      .dbiterra       (dbiterra),        // ポートA ダブルビットエラー検出
      .dbiterrb       (dbiterrb),        // ポートB ダブルビットエラー検出
      .sbiterra       (sbiterra),        // ポートA シングルビットエラー検出
      .sbiterrb       (sbiterrb),        // ポートB シングルビットエラー検出

      // 入力ポート
      .clka           (clka),            // ポートA クロック
      .clkb           (clkb),            // ポートB クロック (独立クロック時のみ有効)
      .ena            (ena),             // ポートA エネーブル
      .enb            (enb),             // ポートB エネーブル
      .regcea         (regcea),          // ポートA 出力レジスタクロックエネーブル
      .regceb         (regceb),          // ポートB 出力レジスタクロックエネーブル
      .rsta           (rsta),            // ポートA リセット
      .rstb           (rstb),            // ポートB リセット
      .addra          (addra),           // ポートA アドレス入力
      .addrb          (addrb),           // ポートB アドレス入力
      .dina           (dina),            // ポートA 書き込みデータ入力
      .dinb           (dinb),            // ポートB 書き込みデータ入力
      .wea            (wea),             // ポートA ライトイネーブル
      .web            (web),             // ポートB ライトイネーブル
      .sleep          (sleep),           // スリープ制御入力

      // エラー注入ポート (通常は1'b0に固定)
      .injectdbiterra (injectdbiterra),  // ポートA ダブルビットエラー注入
      .injectdbiterrb (injectdbiterrb),  // ポートB ダブルビットエラー注入
      .injectsbiterra (injectsbiterra),  // ポートA シングルビットエラー注入
      .injectsbiterrb (injectsbiterrb)   // ポートB シングルビットエラー注入
   );
```
