

// Main assignment
use test

db.users.insert({first_name : "Alex", last_name: "Smith", contacts : {p1 : "+1 494 9494", p2 : "+1 202 3234", address : "23, Clear road"}})
db.users.insert({first_name : "Mary", last_name: "Jones", contacts : {p1 : "+1 423 9234", p2 : "+1 202 1876", fax : "+1 490 2890", address : "11, Fifth Avenue"}})

db.users.find()


// Additional assignment
db.test.aggregate([
{
$project: 
{
first_name: 1, last_name, 1, 
contacts: {
$objectToArray: "contacts" 
}
}
}])