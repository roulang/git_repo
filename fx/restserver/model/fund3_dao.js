var sqlite3 = require('sqlite3');
var keys = ['c in ("000369","005613","486001","000043","040046","096001")'];
var n = 200;

Date.prototype.yyyymmdd = function() {
  var mm = this.getMonth() + 1; // getMonth() is zero-based
  var dd = this.getDate();

  return [this.getFullYear(),
          (mm>9 ? '' : '0') + mm,
          (dd>9 ? '' : '0') + dd
         ].join('-');
};

function fund3_dao(){
	this.retrieve = function(id, params, callback){
		/*
		var fund3 = [
			            ['funds', '2015', '2016', '2017'],
			            ['工银深证红利ETF(159905)', 43.3, 85.8, 93.7],
			            ['大成深证成长40ETF(159906)', 83.1, 73.4, 55.1],
			            ['广发中小板300ETF(159907)', 86.4, 65.2, 82.5]
		        	];
		callback(fund3);
		*/
		var db = new sqlite3.Database("C:/rou/db/abc.db");
		var fund3 = [['funds']];
		var dts = {};
		var today = new Date();
		var i = 1, j = 1;
		while (j <= n) {
			var date = new Date();
			date.setDate(today.getDate() - i)
			var wd = date.getDay();
			if (wd > 0 && wd < 6) {
				var dt = date.yyyymmdd();
				dts[dt] = n - j + 1;
				fund3[0][dts[dt]]=dt;
				j += 1;
			}
			i += 1;
		}
		var k = parseInt(id);
		var sql = 	"select r.key key,b.name name,b.name2 name2,r.code code,r.dt dt,r.price1 prc \
					from fund_r r,fund_b b \
					where r.code in \
					(select distinct(code) c from fund_b where " + keys[k-1] + ") \
					and r.code = b.code \
					order by r.code,r.dt";
		console.log("sql=", sql);
		db.all(sql, [], 
			function(err, rows, fields) {
				if (err) throw err;
				var n = 0, cd = '';
			    for(var i=0; i<rows.length; i++){
			    	if (cd != rows[i].code) {
			    		n += 1;
			    		fund3[n] = [];
			    		fund3[n][0] = rows[i].name2 + '(' + rows[i].code + ')';
			    		cd = rows[i].code;
			    	}
			    	if (dts[rows[i].dt]) {
			    		fund3[n][dts[rows[i].dt]] = parseFloat(rows[i].prc ? rows[i].prc : 0);
			    	}
				}
				var k = Object.keys(dts);
				for (var i = 0; i < k.length; i++) {
					for (var j = 0; j < fund3.length; j++) {
						if (!fund3[j][dts[k[i]]]) fund3[j][dts[k[i]]] = 0;
					}
				}
				db.close();
				callback(fund3);
			}
		);
	};
}

exports.dao = fund3_dao;
