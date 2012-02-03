// ----------------------------------------------------------------------------
// markItUp!
// ----------------------------------------------------------------------------
// Copyright (C) 2008 Jay Salvat
// http://markitup.jaysalvat.com/
// ----------------------------------------------------------------------------
myBbcodeSettings = {
  nameSpace:          "bbcode", // Useful to prevent multi-instances CSS conflict
  previewParserPath:  "~/sets/bbcode/preview.php",
  markupSet: [
      {name:'Bold', key:'B', openWith:'[b]', closeWith:'[/b]'}, 
      {name:'Italic', key:'I', openWith:'[i]', closeWith:'[/i]'}, 
      {name:'Underline', key:'U', openWith:'[u]', closeWith:'[/u]'}, 
      {separator:'---------------' },
      {name:'Picture', key:'P', replaceWith:'[img=[![Url]!]][/img]'},
//	{name:'Picture', key:'P', replaceWith:'[img][![Url]!][/img]'}, 
      {name:'Link', key:'L', openWith:'[url=[![Url]!]]', closeWith:'[/url]', placeHolder:'Your text to link here...'},
      {separator:'---------------' },
      {name:'Colors', openWith:'[color=[![Color]!]]', closeWith:'[/color]', dropMenu: [
          {name:'Yellow', openWith:'[color=yellow]', closeWith:'[/color]', className:"col1-1" },
          {name:'Orange', openWith:'[color=orange]', closeWith:'[/color]', className:"col1-2" },
          {name:'Red', openWith:'[color=red]', closeWith:'[/color]', className:"col1-3" },
          {name:'Blue', openWith:'[color=blue]', closeWith:'[/color]', className:"col2-1" },
          {name:'Purple', openWith:'[color=purple]', closeWith:'[/color]', className:"col2-2" },
          {name:'Green', openWith:'[color=green]', closeWith:'[/color]', className:"col2-3" },
          {name:'White', openWith:'[color=white]', closeWith:'[/color]', className:"col3-1" },
          {name:'Gray', openWith:'[color=gray]', closeWith:'[/color]', className:"col3-2" },
          {name:'Black', openWith:'[color=black]', closeWith:'[/color]', className:"col3-3" }
      ]},
      {name:'Size', key:'S', openWith:'[size=[![Text size]!]]', closeWith:'[/size]', dropMenu :[
        {name:'h1', openWith:'[h1]', closeWith:'[/h1]' },
	{name:'h2', openWith:'[h2]', closeWith:'[/h2]' },
	{name:'h3', openWith:'[h3]', closeWith:'[/h3]' },
	{name:'h4', openWith:'[h4]', closeWith:'[/h4]' },
	{name:'h5', openWith:'[h5]', closeWith:'[/h5]' },
	{name:'h6', openWith:'[h6]', closeWith:'[/h6]' },
	{name:'h7', openWith:'[h7]', closeWith:'[/h7]' },
	{name:'h8', openWith:'[h8]', closeWith:'[/h8]' },
	{name:'h9', openWith:'[h9]', closeWith:'[/h9]' },  
	{name:'Big', openWith:'[size=200]', closeWith:'[/size]' },
        {name:'Normal', openWith:'[size=100]', closeWith:'[/size]' },
        {name:'Small', openWith:'[size=50]', closeWith:'[/size]' }
      ]},
      {separator:'---------------' },
      {name:'Bulleted list', openWith:'[ul]\n', closeWith:'\n[/ul]'}, 
      {name:'Numeric list', openWith:'[ol=[![Starting number]!]]\n', closeWith:'\n[/ol]'}, 
      {name:'List item', openWith:'[li] ', closeWith:' [/li]'}, 
      //{name:'List item', openWith:'[*] '}, 
      {separator:'---------------' },
      {name:'Quotes', openWith:'[quote]', closeWith:'[/quote]'}, 
      {name:'Code', openWith:'[code]', closeWith:'[/code]'}, 
      {separator:'---------------' },
      {name:'Remove formatting from selection', className:"clean", replaceWith:function(h) { return h.selection.replace(/\[(.*?)\]/g, "") } }
      // ,
      // {name:'Preview', className:"preview", call:'preview' }
   ]
}
