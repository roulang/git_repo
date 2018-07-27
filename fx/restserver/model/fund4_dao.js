var Fund = require('./fund').fund, sqlite3 = require('sqlite3');
var keys = ['code in ("161116","096001","040046","000043","486001","163208","005613",\
"000369","486002","160216","070031","161129","004243")'];

function fund4_dao(){
	var db = new sqlite3.Database("C:/rou/db/abc.db");

	this.list = function(id, params, callback){
		var funds = [];
		db.all('select code,name2,type,mgr,com,st,trace from fund_b where ' + keys[0] + ' order by code', 
			function(err, rows, fields) {
			if (err) throw err;
		    for(var i=0; i<rows.length; i++){
				var fund = new Fund(rows[i].code, rows[i].name2, rows[i].type, rows[i].mgr, rows[i].com, rows[i].st, rows[i].trace);
				funds.push(fund);
			}
			callback(funds);
			db.close();
		});
	};
}

exports.dao = fund4_dao;
