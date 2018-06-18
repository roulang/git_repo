//[1..7]
var curs = [
	['EURUSD','EUR',1],['USDJPY','JPY',-1],['AUDUSD','AUD',1],['NZDUSD','AUD',1],
	['USDCAD','CAD',-1],['GBPUSD','GBP',1],['USDCHF','CHF',-1]
];

var Imp = require('./imp').imp, sqlite3 = require('sqlite3');

function imp_dao(){
	var db = new sqlite3.Database("D:/rou/sync/workspace/fx/db/abc.db");

	this.retrieve = function(id, params, callback){
		//var cots = [];
		var imps = {};
		var catgs = [];
		var data = {};
		var d1 = [];
		var d2 = [];
		var n = parseInt(id);
		var sql = '';
		if (n>0) {
			//sql = "select As_of_Date_In_Form_YYMMDD a, Market_and_Exchange_Names b, " +
			//pats[pat-1] + " c from cot where b = '" + curs[cur-1] + "' order by a";
			sql = "select dtm,title,cur,open_p,close_p,high_p,low_p from cur_str where cur = '" + curs[n-1][0] + "' order by dtm desc";
			//console.log("sql=");
			//console.log(sql);
		}
		db.all(sql, [], 
			function(err, rows, fields) {
				if (err) throw err;
			    for(var i=rows.length-1; i>=0; i--){
			    	t = '(' + rows[i].dtm + ') ' + rows[i].title
					catgs.push(t);
					p1 = Math.round((rows[i].open_p - rows[i].close_p)*10000*curs[n-1][2])/100
					p2 = Math.round((rows[i].high_p - rows[i].low_p)*10000)/100
					d1.push(p1);
					d2.push(p2);
				}
				data['diff_oc'] = d1;
				data['diff_hl'] = d2;
				imps['catg'] = catgs;
				imps['data'] = data;
				callback(imps);
				db.close();
			}
		);
	};
	this.list = function(id, params, callback){
		var imps = [];
		db.all('select dtm,title,cur,open_p,close_p,high_p,low_p from cur_str order by dtm desc, cur', 
			function(err, rows, fields) {
			if (err) throw err;
		    for(var i=0; i<rows.length; i++){
				var imp = new Imp(rows[i].dtm, rows[i].title, rows[i].cur, rows[i].open_p, rows[i].close_p, rows[i].high_p, rows[i].low_p);
				imps.push(imp);
			}
			callback(imps);
			db.close();
		});
	};
}

exports.dao = imp_dao;
