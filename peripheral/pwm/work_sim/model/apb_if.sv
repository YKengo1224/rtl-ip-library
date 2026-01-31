interface apb_if (
    input logic pclk,    // クロック
    input logic presetn  // リセット（Active Low）
);
    // ---------------------------------------------
    // APB Signals
    // ---------------------------------------------
    logic [31:0] paddr;
    logic        psel;
    logic        penable;
    logic        pwrite;
    logic [31:0] pwdata;
    logic [31:0] prdata;
    logic        pready;
    logic        pslverr;

    // ---------------------------------------------
    // Clocking Block
    // (競合を避けて安全に信号を駆動するための仕組み)
    // ---------------------------------------------
    clocking cb @(posedge pclk);
        default input #1step output #1ns;  // タイミング定義
        output paddr, psel, penable, pwrite, pwdata;
        input prdata, pready, pslverr;
    endclocking

    // ---------------------------------------------
    // BFM Tasks (Write / Read)
    // ---------------------------------------------

    // ★ Write Task
    task automatic write(input [31:0] addr, input [31:0] data);
        // 1. Setup Phase
        @cb;  // クロック立ち上がりを待つ
        cb.paddr   <= addr;
        cb.pwdata  <= data;
        cb.pwrite  <= 1'b1;
        cb.psel    <= 1'b1;
        cb.penable <= 1'b0;        

        // 2. Access Phase
        @cb;
        cb.penable <= 1'b1;

        // 3. Wait for PREADY
        // PREADYが1になるまで待機 (Wait states対応)
        wait (cb.pready == 1'b1);

        // 4. Teardown (Idle)
        // データのホールド時間を確保するため、次のクロックで下げる
        @cb;
        cb.psel    <= 1'b0;
        cb.penable <= 1'b0;
        cb.pwrite  <= 1'b0;
        cb.paddr   <= '0;
        cb.pwdata  <= '0;
    endtask

    // ★ Read Task
    task automatic read(input [31:0] addr, output [31:0] data);
        // 1. Setup Phase
        @cb;
        cb.paddr   <= addr;
        cb.pwrite  <= 1'b0; // Read
        cb.psel    <= 1'b1;
        cb.penable <= 1'b0;

        // 2. Access Phase
        @cb;
        cb.penable <= 1'b1;

        // 3. Wait for PREADY
        wait (cb.pready == 1'b1);

        // 4. Sample Data & Teardown
        // PREADYが立った瞬間のデータを取得
        data = cb.prdata;

        @cb;
        cb.psel    <= 1'b0;
        cb.penable <= 1'b0;
        cb.paddr   <= '0;
    endtask

    // ★ Reset Task (初期化用)
    task automatic assert_reset();
        cb.psel    <= 0;
        cb.penable <= 0;
        cb.pwrite  <= 0;
        cb.paddr   <= 0;
        cb.pwdata  <= 0;
    endtask

endinterface
