outdir = out
$(outdir)/document.pdf: document.tex
	latexmk -interaction=nonstopmode -pdf -lualatex -file-line-error -synctex=1 -outdir=$(outdir) $<
