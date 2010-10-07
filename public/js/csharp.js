CodeHighlighter.addStyle("csharp",{
	comment : {
		exp  : /(\/\/[^\n]*(\n|$))|(\/\*[^*]*\*+([^\/][^*]*\*+)*\/)/
	},
	brackets : {
		exp  : /\(|\)/
	},
	string : {
		exp  : /'[^'\\]*(\\.[^'\\]*)*'|"[^"\\]*(\\.[^"\\]*)*"/
	},
	keywords : {
		exp  : /\b(using|public|private|protected|do|foreach|action|break|case|continue|default|do|else|false|for|if|in|instanceof|new|null|return|switch|this|true|typeof|var|void|while|with)\b/
	}
});