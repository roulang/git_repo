var sqlite3 = require('sqlite3').verbose();
var file = "D:/rou/sync/workspace/fx/db/abc.db";
var db = new sqlite3.Database(file);
db.all("select key from cot", function(err, rows) {
        rows.forEach(function (row) {
            console.log(row.key);
        })
	});	
db.close();