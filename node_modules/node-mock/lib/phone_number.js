var Faker = require('../index');
var Helpers = require('./helpers');

var phone = {
    phoneNumber: function () {
        return Helpers.replaceSymbolWithNumber("1##########");
    },
    telPhoneNumber: function () {
		return Helpers.replaceSymbolWithNumber(Faker.random.phone_formats());
    }
};

module.exports = phone;
