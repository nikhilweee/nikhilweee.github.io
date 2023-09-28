.PHONY: all

help:           ## show this help
	@sed -ne '/@sed/!s/## //p' $(MAKEFILE_LIST)

serve:          ## run hugo server
	hugo server --bind 0.0.0.0 --buildDrafts --disableFastRender --navigateToChanged
