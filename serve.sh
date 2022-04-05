echo "Building Citations ..."
citation-js -i content/references.bib -o content/bibliography --no-input-generate-graph  
echo "Starting Server ..."
hugo server --buildDrafts --disableFastRender