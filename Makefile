
SUBDIRS = killswitch keyfinder pinfinder


.PHONY: subdirs $(SUBDIRS)
.PHONY: all install clean uninstall

subdirs: $(SUBDIRS)

all: subdirs
$(SUBDIRS):
	$(MAKE) -C $@


install:
	@for i in $(SUBDIRS); do \
	(cd $$i; $(MAKE) install); done
	
clean:
	@for i in $(SUBDIRS); do \
	(cd $$i; $(MAKE) clean); done
	
uninstall:
	@for i in $(SUBDIRS); do \
	(cd $$i; $(MAKE) uninstall); done

