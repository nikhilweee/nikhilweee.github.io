echo "Building Citations ..."
citation-js -i content/references.bib -o content/bibliography --no-input-generate-graph  
echo "Starting LocalTunnel ..."
lt -p 1313 -l 127.0.0.1 -s nikhilweee &
echo "Starting Server ..."
hugo server --buildDrafts --disableFastRender --navigateToChanged