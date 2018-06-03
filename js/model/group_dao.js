var Group = require('./group').group, sqlite3 = require('sqlite3');

function group_dao(){
	var db = new sqlite3.Database("D:/rou/sync/db/abc.db");

	this.retrieve = function(id, params, callback){
		var groups = [];
		db.all('select id,name,location,size from grp where id = ?', [id], function(err, rows, fields) {
			if (err) throw err;
		    for(var i=0; i<rows.length; i++){
				var group = new Group(rows[i].id, rows[i].name, rows[i].location, rows[i].size);
				groups.push(group);
			}
			callback(groups);
			db.close();
		});
	};
	
	this.list = function(id, params, callback){
		var groups = [];
		db.all('select id,name,location,size from grp', function(err, rows, fields) {
			if (err) throw err;
		    for(var i=0; i<rows.length; i++){
				var group = new Group(rows[i].id, rows[i].name, rows[i].location, rows[i].size);
				groups.push(group);
			}
			callback(groups);
			db.close();
		});
	};
}

exports.dao = group_dao;
