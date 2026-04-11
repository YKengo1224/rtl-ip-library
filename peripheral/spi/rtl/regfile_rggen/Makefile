CONFIG := config.json
OUT_DIR := out
REG_FILE := register.rb


.PHONY:gen,clean

gen:$(CONFIG) $(REG_FILE)
	rggen -c $(CONFIG) --output out $(REG_FILE)

clean:
	rm -rf $(OUT_DIR)
