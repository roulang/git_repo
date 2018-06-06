//48 [1,2,3,4,5,6,7]
var curs = [
'CANADIAN DOLLAR - CHICAGO MERCANTILE EXCHANGE',
'SWISS FRANC - CHICAGO MERCANTILE EXCHANGE',
'BRITISH POUND STERLING - CHICAGO MERCANTILE EXCHANGE',
'JAPANESE YEN - CHICAGO MERCANTILE EXCHANGE',
'EURO FX - CHICAGO MERCANTILE EXCHANGE',
'AUSTRALIAN DOLLAR - CHICAGO MERCANTILE EXCHANGE',
'EURO FX/BRITISH POUND XRATE - CHICAGO MERCANTILE EXCHANGE',
'RUSSIAN RUBLE - CHICAGO MERCANTILE EXCHANGE',
'MEXICAN PESO - CHICAGO MERCANTILE EXCHANGE',
'BRAZILIAN REAL - CHICAGO MERCANTILE EXCHANGE',
'NEW ZEALAND DOLLAR - CHICAGO MERCANTILE EXCHANGE',
'SOUTH AFRICAN RAND - CHICAGO MERCANTILE EXCHANGE',
'DJIA Consolidated - CHICAGO BOARD OF TRADE',
'DOW JONES INDUSTRIAL AVG- x $5 - CHICAGO BOARD OF TRADE',
'S&P 500 Consolidated - CHICAGO MERCANTILE EXCHANGE',
'S&P 500 STOCK INDEX - CHICAGO MERCANTILE EXCHANGE',
'E-MINI S&P CONSU STAPLES INDEX - CHICAGO MERCANTILE EXCHANGE',
'E-MINI S&P ENERGY INDEX - CHICAGO MERCANTILE EXCHANGE',
'E-MINI S&P 500 STOCK INDEX - CHICAGO MERCANTILE EXCHANGE',
'E-MINI S&P FINANCIAL INDEX - CHICAGO MERCANTILE EXCHANGE',
'E-MINI S&P HEALTH CARE INDEX - CHICAGO MERCANTILE EXCHANGE',
'E-MINI S&P TECHNOLOGY INDEX - CHICAGO MERCANTILE EXCHANGE',
'E-MINI S&P UTILITIES INDEX - CHICAGO MERCANTILE EXCHANGE',
'NASDAQ-100 Consolidated - CHICAGO MERCANTILE EXCHANGE',
'NASDAQ-100 STOCK INDEX (MINI) - CHICAGO MERCANTILE EXCHANGE',
'E-MINI RUSSELL 2000 INDEX - CHICAGO MERCANTILE EXCHANGE',
'RUSSELL 2000 MINI INDEX FUTURE - ICE FUTURES U.S.',
'NIKKEI STOCK AVERAGE - CHICAGO MERCANTILE EXCHANGE',
'NIKKEI STOCK AVERAGE YEN DENOM - CHICAGO MERCANTILE EXCHANGE',
'MSCI EAFE MINI INDEX - ICE FUTURES U.S.',
'MSCI EMERGING MKTS MINI INDEX - ICE FUTURES U.S.',
'E-MINI S&P 400 STOCK INDEX - CHICAGO MERCANTILE EXCHANGE',
'S&P 500 ANNUAL DIVIDEND INDEX - CHICAGO MERCANTILE EXCHANGE',
'U.S. TREASURY BONDS - CHICAGO BOARD OF TRADE',
'ULTRA U.S. TREASURY BONDS - CHICAGO BOARD OF TRADE',
'2-YEAR U.S. TREASURY NOTES - CHICAGO BOARD OF TRADE',
'10-YEAR U.S. TREASURY NOTES - CHICAGO BOARD OF TRADE',
'ULTRA 10-YEAR U.S. T-NOTES - CHICAGO BOARD OF TRADE',
'5-YEAR U.S. TREASURY NOTES - CHICAGO BOARD OF TRADE',
'30-DAY FEDERAL FUNDS - CHICAGO BOARD OF TRADE',
'3-MONTH EURODOLLARS - CHICAGO MERCANTILE EXCHANGE',
'10 YEAR DELIVERABLE IR SWAP - CHICAGO BOARD OF TRADE',
'5 YEAR DELIVERABLE IR SWAP - CHICAGO BOARD OF TRADE',
'BITCOIN-USD - CBOE FUTURES EXCHANGE',
'BITCOIN - CHICAGO MERCANTILE EXCHANGE',
'U.S. DOLLAR INDEX - ICE FUTURES U.S.',
'VIX FUTURES - CBOE FUTURES EXCHANGE',
'BLOOMBERG COMMODITY INDEX - CHICAGO BOARD OF TRADE'
];
//16 [7,8,9,10,11,12,15,16]
var pats = [
'Dealer_Positions_Long_All',
'Dealer_Positions_Short_All',
'Dealer_Positions_Spread_All',
'Asset_Mgr_Positions_Long_All',
'Asset_Mgr_Positions_Short_All',
'Asset_Mgr_Positions_Spread_All',
'Lev_Money_Positions_Long_All',
'Lev_Money_Positions_Short_All',
'Lev_Money_Positions_Spread_All',
'Other_Rept_Positions_Long_All',
'Other_Rept_Positions_Short_All',
'Other_Rept_Positions_Spread_All',
'Tot_Rept_Positions_Long_All',
'Tot_Rept_Positions_Short_All',
'NonRept_Positions_Long_All',
'NonRept_Positions_Short_All'
];

var Cot = require('./cot').cot, sqlite3 = require('sqlite3');

function cot_dao(){
	var db = new sqlite3.Database("D:/rou/sync/workspace/fx/db/abc.db");

	this.retrieve = function(id, params, callback){
		//var cots = [];
		var cots = {};
		var catgs = [];
		var data = [];
		var n = parseInt(id);
		var pat = n%100;
		var cur = parseInt(n/100);
		//console.log("cur=");
		//console.log(cur);
		//console.log("pat=");
		//console.log(pat);
		var sql = '';
		if (cur>0 && pat>0) {
			sql = "select As_of_Date_In_Form_YYMMDD a, Market_and_Exchange_Names b, " +
			pats[pat-1] + " c from cot where b = '" + curs[cur-1] + "' order by a";
			//console.log("sql=");
			//console.log(sql);
		}
		//db.all("select As_of_Date_In_Form_YYMMDD a, Market_and_Exchange_Names b, \
		//	Dealer_Positions_Long_All c from cot where b = ? \
		//	and a = ?", [cur[3], id],
		db.all(sql, [], 
			function(err, rows, fields) {
				if (err) throw err;
			    for(var i=0; i<rows.length; i++){
					//var cot = new Cot(rows[i].As_of_Date_In_Form_YYMMDD, rows[i].Market_and_Exchange_Names, rows[i].Dealer_Positions_Long_All);
					//var cot = new Cot(rows[i].a, rows[i].b, rows[i].c);
					//cots.push(cot);
					catgs.push(rows[i].a);
					data.push(rows[i].c);
				}
				cots['catg'] = catgs;
				cots['data'] = data;
				callback(cots);
				db.close();
			}
		);
	};
	
	this.list = function(id, params, callback){
		//var cots = [];
		var cots = {};
		var catgs = [];
		var data = [];
		db.all("select As_of_Date_In_Form_YYMMDD a, Market_and_Exchange_Names b, \
			Dealer_Positions_Long_All c from cot where b like '%JAPANESE YEN%' \
			Order by a asc", 
			function(err, rows, fields) {
				if (err) throw err;
			    for(var i=0; i<rows.length; i++){
					//var cot = new Cot(rows[i].As_of_Date_In_Form_YYMMDD, rows[i].Market_and_Exchange_Names, rows[i].Dealer_Positions_Long_All);
					//var cot = new Cot(rows[i].a, rows[i].b, rows[i].c);
					//cots.push(cot);
					catgs.push(rows[i].a);
					data.push(rows[i].c);
				}
				cots['catg'] = catgs;
				cots['data'] = data;
				callback(cots);
				db.close();
			}
		);
	};
}

exports.dao = cot_dao;
