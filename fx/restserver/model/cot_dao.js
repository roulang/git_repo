var cur = ['CANADIAN DOLLAR - CHICAGO MERCANTILE EXCHANGE',
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
'BLOOMBERG COMMODITY INDEX - CHICAGO BOARD OF TRADE'];

var Cot = require('./cot').cot, sqlite3 = require('sqlite3');

function cot_dao(){
	var db = new sqlite3.Database("D:/rou/sync/workspace/fx/db/abc.db");

	this.retrieve = function(id, params, callback){
		//var cots = [];
		var cots = {};
		var catgs = [];
		var data = [];
		db.all("select As_of_Date_In_Form_YYMMDD a, Market_and_Exchange_Names b, \
			Dealer_Positions_Long_All c from cot where b = ? \
			and a = ?", [cur[3], id], 
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
