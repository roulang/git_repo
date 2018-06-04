var http = require('http');
var parse = require('url').parse;
var restparser = require('./restparser');
var restrouter = require('./router');

http.createServer(function (req, res) {
	var url = parse(req.url);
	var pathname = url.pathname;
	console.log('Request URL: http://127.0.0.1:8899' + url.href);
	// 解析 URL 参数到 resource 对象
	req.resource = restparser.parse(pathname);
	//resource.id 存在，表示是 RESTful 的请求

	if(req.resource.id){
		res.writeHead(200, {'Content-Type': 'text/plain'});
		res.writeHead(200, {'Access-Control-Allow-Origin': 'null'});
		restrouter.router(req, res, function(stringfyResult){
			res.end(stringfyResult);
		});
	}else{
		res.writeHead(200, {'Content-Type': 'text/plain'});
		res.end('Request URL is not in RESTful style!');
	}
}).listen(8899, '127.0.0.1');
console.log('Server running at http://127.0.0.1:8899/');