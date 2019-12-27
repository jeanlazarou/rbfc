const { openBrowser, closeBrowser, goto, text } = require('taiko');

describe('Brainfuck program in browser', () => {

  test('Run cat program', async () => {
    await openBrowser();
    await goto("file:///tmp/cat.bf.html");
    await expect(await text('Hello world!').exists()).toBeTruthy();
  });

  afterAll(async () => {
    await closeBrowser();
  });

});
