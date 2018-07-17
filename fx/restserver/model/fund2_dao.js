var sqlite3 = require('sqlite3');
var keys = ['ETF-场内', 'QDII', 'QDII-ETF', 'QDII-指数', '保本型',
			'债券型', '债券指数', '分级杠杆', '固定收益', '定开债券',
			'混合-FOF', '混合型', '理财型', '联接基金', '股票型',
			'股票指数', '货币型'];
var keys2 = [' and name like "%股票%"', ' and name like "%债券%"', ' and name like "%混合%"',
			' and (name not like "%股票%" and name not like "%债券%" and name not like "%混合%")', 
			' and (name like "%标普%" or name like "%纳斯达克%")', ' and (name not like "%标普%" and name not like "%纳斯达克%")',
			''];
var n = 200;

Date.prototype.yyyymmdd = function() {
  var mm = this.getMonth() + 1; // getMonth() is zero-based
  var dd = this.getDate();

  return [this.getFullYear(),
          (mm>9 ? '' : '0') + mm,
          (dd>9 ? '' : '0') + dd
         ].join('-');
};

function fund2_dao(){
	this.retrieve = function(id, params, callback){
		/*
		var fund2 = [
			            ['funds', '2015', '2016', '2017'],
			            ['工银深证红利ETF(159905)', 43.3, 85.8, 93.7],
			            ['大成深证成长40ETF(159906)', 83.1, 73.4, 55.1],
			            ['广发中小板300ETF(159907)', 86.4, 65.2, 82.5]
		        	];
		callback(fund2);
		*/
		var db = new sqlite3.Database("C:/rou/db/abc.db");
		var fund2 = [['funds']];
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
				fund2[0][dts[dt]]=dt;
				j += 1;
			}
			i += 1;
		}
		var k = parseInt(id);
		var pat2 = k%10;
		if (pat2 == 0 || pat2 > keys2.length) pat2 = keys2.length;
		var pat = parseInt(k/10);
		if (pat == 0 || pat > keys.length) pat = 1;
		var sql = 	"select r.key key,b.name name,b.name2 name2,r.code code,r.dt dt,r.price1 prc \
					from fund_r r,fund_b b \
					where r.code in \
					(select distinct(code) c from fund_b where type = '" + keys[pat-1] + "'" + keys2[pat2-1] + ") \
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
			    		fund2[n] = [];
			    		fund2[n][0] = rows[i].name2 + '(' + rows[i].code + ')';
			    		cd = rows[i].code;
			    	}
			    	if (dts[rows[i].dt]) {
			    		fund2[n][dts[rows[i].dt]] = parseFloat(rows[i].prc ? rows[i].prc : 0);
			    	}
				}
				var k = Object.keys(dts);
				for (var i = 0; i < k.length; i++) {
					for (var j = 0; j < fund2.length; j++) {
						if (!fund2[j][dts[k[i]]]) fund2[j][dts[k[i]]] = 0;
					}
				}
				db.close();
				callback(fund2);
			}
		);
	};
}

exports.dao = fund2_dao;
