var Group = require('./group').group;

function group_dao(){
	
	this.retrieve = function(id, params, callback){
		var groups = [];		
		var group = new Group('1', 'GroupA', 'BJ', 20);
		groups.push(group);
		callback(groups);
	};
	
	this.list = function(id, params, callback){
	    var groups = [];		
		var group = new Group('1', 'GroupA', 'BJ', 20);
		groups.push(group);
		group = new Group('2', 'GroupB', 'SH', 10);
		groups.push(group);
		callback(groups);
	};
}

exports.dao = group_dao;
