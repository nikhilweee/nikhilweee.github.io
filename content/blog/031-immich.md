+++
categories = ['Experiences']
date = '2023-08-22'
slug = 'immich'
subtitle = 'The Self-hosted Google Photos Alternative'
title = 'Immich'
draft = true
+++

1. Go to google takeout and request an export. Split downloads at 50GB for lesser files.
2. Click on the download link. When the download starts, go to download manager and right click -
   copy link URL. Then paste the link in a terminal

```console
wget -O archive.zip <paste copied link>
```

3. Use the CurlWget extension to copy the download link
