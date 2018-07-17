var urlParser = require('url').parse;

var _events = ['list', 'retrieve'];

function router(req, res, callback){
	var method = req.method.toUpperCase();
	var event = emitEvent(method, req.resource);
	console.log('event: ' + event);
	if(supportEvent(event)){
			return execute(req, event, callback);
	}else{
		return 'No supported event found!';
	}
}

function execute(req, event, callback){
	req.params = req.params || {};
	if(req.method === 'POST' || req.method === 'PUT'){
	}else{
		var urlParams = urlParser(req.url, true).query;
		clone(req.params, urlParams);
		return invoke(req, event, callback);
	}
}

function invoke(req, event, callback){
	var module = require( './model/' + req.resource['resource'] + '_dao'),
	model = new module.dao(),
	fn = model[event];
	fn(req.resource.id, req.params, function(result){
		//console.log('Execute result');
		//console.log(result);
		var stringfyResult = JSON.stringify(result);
		callback(stringfyResult);
	});
}
function emitEvent(method, resource){
	 var  localEvent;
	 switch(method){
		case 'GET' : 
				localEvent = resource.id == 0 ? 'list' : 'retrieve'; break;
		case 'PUT' : 
				localEvent = resource.id == 0 ? 'putCollection' : 'update'; break;
		case 'POST' : 
				localEvent = resource.id == 0 ? 'create' : 'postMember'; break;
		case 'DELETE' : 
				localEvent = resource.id == 0 ? 'deleteCollection' : 'deleteMember'; break;	
	 }
	 return localEvent;
}

function supportEvent(event){
	var result = false;
	_events.forEach(function(_event){
		if(event === _event){
			result = true;
		}
	});
	return result;
}

function clone(obj1, obj2){
	for(var key in obj2){
		obj1[key] = obj2[key];
	}
}
exports.router = router;