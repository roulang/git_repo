var curs = {'EURUSD':1, 'USDJPY':-1, 'AUDUSD':1, 'NZDUSD':1, 'USDCAD':-1, 'GBPUSD':1, 'USDCHF':-1};
var digs = {'EURUSD':10000, 'USDJPY':100, 'AUDUSD':10000, 'NZDUSD':10000, 'USDCAD':10000, 'GBPUSD':10000, 'USDCHF':10000};

function imp(dtm, country, title, cur, ped, open_p, close_p, high_p, low_p){
	this.dtm = dtm;
	this.country = country;
	this.title = title;
	this.cur = cur;
	this.ped = ped;
	this.open_p = open_p;
	this.close_p = close_p;
	this.high_p = high_p;
	this.low_p = low_p;
	this.diff_oc = Math.round((close_p - open_p)/open_p*10000)*curs[cur]/100;
	this.diff_hl = Math.round((high_p - low_p)/open_p*10000)/100;
	this.diff_oc2 = Math.round((close_p - open_p)*digs[cur]);
	this.diff_hl2 = Math.round((high_p - low_p)*digs[cur]);
}

exports.imp=imp;