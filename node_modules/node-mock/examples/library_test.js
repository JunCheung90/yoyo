var util = require('util');

var definitions = require('../lib/definitions');

var Faker = require('../index');

// var card = Faker.Helpers.createCard();

// util.puts(JSON.stringify(card));

result = [];
for (var i = 0; i < 100; i++) {
	result.push(Faker.random.normal_distribution(0.0, 1.0));
}

console.log(result);


