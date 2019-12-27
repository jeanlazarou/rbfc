function getInput() {
  const url = new URL(window.location.href);

  const input = url.searchParams.get("input");
  
  return input ? input : "Hello world!";
}

function* createStream(data) {
 const stream = data
  .split("")
  .map(c => c.charCodeAt(0));

 for(const x of stream) yield x;
   
 for(;;) { yield 0 };
}

function toS(x) {
  switch(x) {
    case 10: return "<br>";
    case 32: return "&nbsp;";
    default: return String.fromCharCode(x);
  }
};

const input = {
  stream: createStream(getInput()),

  getbyte: function() {
    return this.stream.next().value;
  }
}

const output = {
  putc: function(x) {
    const out = document.querySelector("#output");
    
    out.innerHTML = out.innerText + toS(x);
  }
}
