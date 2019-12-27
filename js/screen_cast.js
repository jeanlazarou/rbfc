const { openBrowser, closeBrowser, click, screencast } = require('taiko');

(async () => {
    try {
        await openBrowser();
        await setViewPort({width:400, height:200})
        await goto("file:///tmp/cat.bf.html");
        await screencast.startScreencast('demo.gif');
    } finally {
        await screencast.stopScreencast();
        await closeBrowser();
    }
})();
