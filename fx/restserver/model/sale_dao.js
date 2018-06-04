
function sale_dao(){
	
	this.retrieve = function(id, params, callback){
		var sales = {
			"catg": ['衬衫','羊毛衫','雪纺衫','裤子','高跟鞋','袜子'],
			"data": [5, 20, 36, 10, 10, 20]
		};
		callback(sales);
	};
	
	this.list = function(id, params, callback){
		var sales = {
			"catg": ['衬衫','羊毛衫','雪纺衫','裤子','高跟鞋','袜子'],
			"data": [5, 20, 36, 10, 10, 20]
		};
		callback(sales);
	};
}

exports.dao = sale_dao;
