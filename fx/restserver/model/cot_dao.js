var Cot = require('./cot').cot, sqlite3 = require('sqlite3');

function cot_dao(){
	var db = new sqlite3.Database("D:/rou/sync/workspace/fx/db/abc.db");

	this.retrieve = function(id, params, callback){
		var cots = [];
		db.all("select As_of_Date_In_Form_YYMMDD a, Market_and_Exchange_Names b, \
			Dealer_Positions_Long_All c from cot where b like '%JAPANESE YEN%' and \
			rowid = ?", [id], function(err, rows, fields) {
			if (err) throw err;
		    for(var i=0; i<rows.length; i++){
				//var cot = new Cot(rows[i].As_of_Date_In_Form_YYMMDD, rows[i].Market_and_Exchange_Names, rows[i].Dealer_Positions_Long_All);
				var cot = new Cot(rows[i].a, rows[i].b, rows[i].c);
				cots.push(cot);
			}
			callback(cots);
			db.close();
		});
	};
	
	this.list = function(id, params, callback){
		var cots = [];
		db.all("select As_of_Date_In_Form_YYMMDD a, Market_and_Exchange_Names b, \
			Dealer_Positions_Long_All c from cot where b like '%JAPANESE YEN%'", 
			function(err, rows, fields) {
			if (err) throw err;
		    for(var i=0; i<rows.length; i++){
				//var cot = new Cot(rows[i].As_of_Date_In_Form_YYMMDD, rows[i].Market_and_Exchange_Names, rows[i].Dealer_Positions_Long_All);
				var cot = new Cot(rows[i].a, rows[i].b, rows[i].c);
				cots.push(cot);
			}
			callback(cots);
			db.close();
		});
	};
}

exports.dao = cot_dao;
