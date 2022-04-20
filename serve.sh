echo "Building Citations ..."
citation-js -i content/references.bib -o content/bibliography --no-input-generate-graph

if [ "$1" == "lt" ]; then
    echo "Starting LocalTunnel ..."
    lt -p 1313 -l 127.0.0.1 -s nikhilweee &
fi

echo "Starting Server ..."
hugo server --buildDrafts --disableFastRender --navigateToChanged \
    # --renderToDisk --cleanDestinationDir

