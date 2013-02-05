var Faker = require('../index');
var Helpers = require('./helpers');

var internet = {
    email: function () {
        return this.userName() + "@" + this.domainName();
    },

    userName: function () {
        switch (Faker.random.number(2)) {
        case 0:
            return Faker.random.first_name();
        case 1:
            return Faker.random.first_name() + Faker.random.array_element([".", "_"]) + Faker.random.last_name();
        }
    },

    domainName: function () {
        return this.domainWord() + "." + Faker.random.domain_suffix();
    },

    domainWord:  function () {
        return Faker.random.first_name().toLowerCase();
    },

    ip: function () {
        var randNum = function () {
            return (Math.random() * 254 + 1).toFixed(0);
        };

        var result = [];
        for (var i = 0; i < 4; i++) {
            result[i] = randNum();
        }

        return result.join(".");
    },

    qq : function () {
        return Faker.random.range(100000, 100000000);
    },

    snType : function () {
        return Helpers.randomize(['豆瓣', '新浪微博', '腾讯微博', '人人']);
    },
    
    birthday : function () {
        return Helpers.replaceSymbolWithNumber("19##-0#-1#");
    }

};

module.exports = internet;
