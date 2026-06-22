class my_report_server extends uvm_default_report_server;

    function new();
        super.new();
    endfunction : new
    

	static function string get_filename_wo_directory(string fullname);
		const byte delimiter = "/";
		string stripped_name;

		stripped_name = fullname;
		for (int i = fullname.len() - 1; i >= 0; i--)begin
			if (fullname[i] == delimiter) begin
				stripped_name = fullname.substr(i + 1, fullname.len() - 1);
				break;
			end
		end

		return stripped_name;
	endfunction

	virtual function string compose_report_message(uvm_report_message report_message, string report_object_name = "");

    	string sev_string;
    	uvm_severity l_severity;
    	uvm_verbosity l_verbosity;
    	string filename_line_string;
    	string time_str;
    	// string line_str;
    	string context_str;
    	string verbosity_str;
    	string terminator_str;
    	string msg_body_str;
    	uvm_report_message_element_container el_container;
    	string prefix;
    	uvm_report_handler l_report_handler;
	
		string uvc_id;

		// Original
		int severity_length = 12;
		int uvc_id_length   = 18;
	
		bit disable_filename	= 1;
		bit disable_report_obj	= 1;
		bit disable_context		= 1;

		//-----------------------------------------
		// Severity
		//-----------------------------------------
	    l_severity = report_message.get_severity();
	    sev_string = l_severity.name();

		//-----------------------------------------
		// Verbosity
		//-----------------------------------------
	    if (show_verbosity) begin
	    	if ($cast(l_verbosity, report_message.get_verbosity()))
	    		verbosity_str = l_verbosity.name();
	    	else
	    		verbosity_str.itoa(report_message.get_verbosity());

	    	verbosity_str = {"(", verbosity_str, ")"};
	    end

		//-----------------------------------------
		// Filename/Line
		//-----------------------------------------
	    $swrite(filename_line_string, "%s(%4d)", get_filename_wo_directory(report_message.get_filename()), report_message.get_line());

		//-----------------------------------------
		// Time String
		//-----------------------------------------
    	$swrite(time_str, "%12t %s", $time, "ns");

		//-----------------------------------------
		// Report Object Name
		//-----------------------------------------
	    if (report_object_name == "") begin
	    	l_report_handler = report_message.get_report_handler();
	    	report_object_name = l_report_handler.get_full_name();
	    end

		//-----------------------------------------
		// Context
		//-----------------------------------------
    	if (report_message.get_context() != "")
    		context_str = {"@@", report_message.get_context()};

		//-----------------------------------------
		// UVC ID
		//-----------------------------------------
		uvc_id = report_message.get_id();

		//-----------------------------------------
		// UVC ID
		//-----------------------------------------
    	el_container = report_message.get_element_container();
    	if (el_container.size() == 0)
    		msg_body_str = report_message.get_message();
    	else begin
    		prefix = uvm_default_printer.knobs.prefix;
    		uvm_default_printer.knobs.prefix = " +";
    		msg_body_str = {report_message.get_message(), "\n", el_container.sprint()};
    		uvm_default_printer.knobs.prefix = prefix;
    	end

		//-----------------------------------------
		// Terminator
		//-----------------------------------------
    	if (show_terminator)
    	  terminator_str = {" -",sev_string};

		// Allign the str length
		for(int i=sev_string.len; i<severity_length; i++) sev_string = {sev_string," "};
		for(int i=uvc_id.len;     i<uvc_id_length;   i++) uvc_id     = {uvc_id    ," "};

		// Disable part str
		if(disable_filename)	filename_line_string = "";
		if(disable_report_obj)	report_object_name	 = "";
		if(disable_context)		context_str 		 = "";

		// Output Message
    	compose_report_message = {sev_string, verbosity_str, " ", filename_line_string, "@ ",
	    	time_str, ": ", report_object_name, context_str,
    		" [", uvc_id, "] ", msg_body_str, terminator_str};

	endfunction

    function void report_summarize(UVM_FILE file = 0);
        super.report_summarize(file);
    endfunction

endclass : my_report_server
