+++
title = "You probably don't need Zotero's File Sync"
categories = ['Tools']
date = '2024-02-18'
slug = 'zotero-sync'
draft = false
+++

I have a love-hate relationship with Zotero. It's not the best reference manager, but it does check
a lot of boxes. Most importantly, it's free, and is fairly popular at least amongst academics.

If you use Zotero on more than one devices, you must be aware of its built-in sync feature. Zotero
divides syncing into two parts -- file sync and data sync. As of this writing, you get 300MB for
file sync, whereas data sync is free and unlimited. Additional plans are available for purchase
[[1]].

[1]: https://www.zotero.org/support/sync

But wait, what if I told you that you don't _need_ the file sync feature? Let me elaborate.

# Syncing PDF Annotations

I like to annotate PDFs on Zotero, and my primary use case for file sync is to sync these
annotations. I want to be able to add an item to my library from one computer, annotate it, then
continue annotating the same item from another computer. If I have file sync turned on, Zotero
already allows me to do this. But what happens when file sync is turned off?

{{<figure src="https://i.imgur.com/BdSmWMt.jpg" caption="Zotero throws an error when file sync is disabled.">}}

Zotero syncs the library entry for the item, but Zotero does not sync the actual PDF. So if you try
to open the PDF entry attached to the synced item, you will get a File Not Found error. But if you
notice closely, your annotations will appear if you click on the PDF entry once.

{{<figure src="https://i.imgur.com/261XzG4.jpg" caption="Zotero syncs annotations independently of the PDF.">}}

So what's happening here? As a matter of fact, Zotero saves annotations in its database and not in
the PDF [[2]]. This means that Zotero uses data sync for annotations as opposed to file sync. If we
were to locate the missing PDF somehow, we would essentially have synced everything (that we care
about) without even using file sync! So how do we do this?

[2]: https://forums.zotero.org/discussion/comment/455487/#Comment_455487

# Find Available PDF

If you haven't noticed yet, Zotero already has the ability to find PDFs for items in your library.
But this option only appears if you don't already have a PDF entry associated with an item [[3]].

[3]: https://forums.zotero.org/discussion/comment/342161/#Comment_342161

{{<figure src="https://i.imgur.com/7VjkJIt.jpg" caption="Zotero has an option to Find Available PDF.">}}

In our case, however, Zotero has already synced the PDF entry from its database, which is why we
were able to see annotations in the first place. It's just that the actual file is missing.
Therefore, we don't see this option. Only if we had a way to hack into Zotero!

# Zotero JavaScript API

Say no more! It turns out that Zotero has a
[Javascript API](https://www.zotero.org/support/dev/client_coding/javascript_api) that we can use.
The API is severely underdocumented, but it allows us to access functionality which may be hidden.

You can use this API to interact with the Zotero client. From Zotero's menu, click `Tools` >
`Developer` > `Run JavaScript`. A new window will appear which allows you to write JS on the left,
and see results on the right. It's also helpful to open the `Error Console`, which also appears
under the `Developer` menu. Alright, let's write some code and hack into Zotero.

We will try to use the JS API to do the following:

1. Go through all items in our library.
2. Filter items which have missing PDFs.
3. Use "Find Available PDF" to download the missing PDF.
4. Move this new PDF to where Zotero expects it to be.

Here's the code snippet. It hasn't been tested thoroughly, so I should warn you to use it at your
own risk. This is also hosted at
[this](https://gist.github.com/nikhilweee/fdf7b471a31c2f1c2b9527c51d734d86) GitHub Gist in case you
want to check for updates.

```js
async function replacePDF(item) {
  // filter annotations, attachments, notes
  if (!item.isRegularItem()) {
    return;
  }
  let fileExists = [];
  let oldPDF = null;
  // filter multiple or existing PDFs
  const attachmentIDs = item.getAttachments();
  for (let itemID of attachmentIDs) {
    const attachment = Zotero.Items.get(itemID);
    if (!attachment.isPDFAttachment()) {
      continue;
    }
    oldPDF = attachment;
    const exists = await attachment.fileExists();
    fileExists.push(exists);
  }
  if (fileExists.length > 1) {
    return; // multiple PDFs found
  }
  if (fileExists.pop()) {
    return; // PDF already exists
  }
  console.log("Updating PDF for", item.getDisplayTitle());
  // manually invoke "Find Available PDF"
  const newPDF = await Zotero.Attachments.addAvailablePDF(item);
  if (oldPDF) {
    await OS.File.move(newPDF.getFilePath(), oldPDF.getFilePath());
    await newPDF.eraseTx();
  }
}

// loop replacePDF() over all items in our library
const libraryID = Zotero.Libraries.userLibraryID;
let items = await Zotero.Items.getAll(libraryID);

for (let item of items) {
  await replacePDF(item);
}
```

# The Fine Print

If you have a similar use case, I hope this helps. There are a couple of caveats though.

1. This approach involves pasting a few lines of code every time you need to sync.
1. Running JavaScript is not possible on iOS and Android versions.
1. As mentioned before, this code hasn't been tested, so please use at your own risk.

On the flip side, this approach is straightforward. you don't need to install an additional plugin.
