`ifndef _H_MY_REPORT_SERVER_SV
`define _H_MY_REPORT_SERVER_SV


class my_report_server extends uvm_default_report_server;
    `uvm_object_utils(my_report_server)

    function new(string name = "my_report_server");
        super.new(name);
    endfunction

    virtual function string compose_report_message(uvm_report_message report_message,
                                                   string report_object_name = "");
        string       msg_body;
        string       id;
        uvm_severity severity;
        string       sev_str;

        // メッセージの構成要素を取得
        severity = report_message.get_severity();
        sev_str  = severity.name();  // "UVM_INFO" など
        id       = report_message.get_id();  // "SEQ" や "DRV" など
        msg_body = report_message.get_message();

        // --------------------------------------------------------
        // 好きなフォーマットで組み立てる（ここで長いパスを無視！）
        // 例: UVM_INFO @ 300000000: [SEQ] rdata:005a
        // --------------------------------------------------------
        return $sformatf("%s @ %0t: [%s] %s", sev_str, $time, id, msg_body);

        
    endfunction
endclass

`endif
