+++
+++

{{< rawhtml>}}

    <link href="/pagefind/pagefind-ui.css" rel="stylesheet">
    <script src="/pagefind/pagefind-ui.js"></script>
    <div id="search"></div>
    <script>
        window.addEventListener('DOMContentLoaded', (event) => {
            new PagefindUI({
                element: "#search",
                showSubResults: false,
                showImages: false,
                resetStyles: false
            });
        });
    </script>

{{< /rawhtml>}}
