var Faker = require('../index');

// backword-compatibility
exports.randomNumber = function (range) {
    return Faker.random.number(range);
};

// backword-compatibility
exports.randomize = function (array) {
    return Faker.random.array_element(array);
};

// parses string for a symbol and replace it with a random number from 1-10
exports.replaceSymbolWithNumber = function (string, symbol) {
    // default symbol is '#'
    if (symbol === undefined) {
        symbol = '#';
    }

    var str = '';
    for (var i = 0; i < string.length; i++) {
        if (string[i] == symbol) {
            str += Math.floor(Math.random() * 10);
        } else {
            str += string[i];
        }
    }
    return str;
};

// takes an array and returns it randomized
exports.shuffle = function (o) {
    for (var j, x, i = o.length; i; j = parseInt(Math.random() * i, 10), x = o[--i], o[i] = o[j], o[j] = x);
    return o;
};

exports.createCard = function () {
    return {
        "name": Faker.Name.findName(),
        "username": Faker.Internet.userName(),
        "email": Faker.Internet.email(),
        "address": {
            "streetA": Faker.Address.streetName(),
            "streetB": Faker.Address.streetAddress(),
            "streetC": Faker.Address.streetAddress(true),
            "streetD": Faker.Address.secondaryAddress(),
            "city": Faker.Address.city(),
            "ukCounty": Faker.Address.ukCounty(),
            "ukCountry": Faker.Address.ukCountry(),
            "zipcode": Faker.Address.zipCode()
        },
        "phone": Faker.PhoneNumber.phoneNumber(),
        "website": Faker.Internet.domainName(),
        "company": {
            "name": Faker.Company.companyName(),
            "catchPhrase": Faker.Company.catchPhrase(),
            "bs": Faker.Company.bs()
        },
        "posts": [
            {
                "words": Faker.Lorem.words(),
                "sentence": Faker.Lorem.sentence(),
                "sentences": Faker.Lorem.sentences(),
                "paragraph": Faker.Lorem.paragraph()
            },
            {
                "words": Faker.Lorem.words(),
                "sentence": Faker.Lorem.sentence(),
                "sentences": Faker.Lorem.sentences(),
                "paragraph": Faker.Lorem.paragraph()
            },
            {
                "words": Faker.Lorem.words(),
                "sentence": Faker.Lorem.sentence(),
                "sentences": Faker.Lorem.sentences(),
                "paragraph": Faker.Lorem.paragraph()
            }
        ]
    };
};

exports.createYoYoUser = function () {
    return {
        "name": Faker.Name.findNameCn(),
        "phones": [{
            //MOBILE_PHONE
            "phoneNumber": Faker.PhoneNumber.phoneNumber(),
            "isActive": true
        }],
        "emails": [
            Faker.Internet.email()
        ],
        "ims": [{
            "type": "QQ",
            "account": Faker.Internet.qq(),
            "isActive": true
        }],
        "sns": [{
            "type": Faker.Internet.snType(),
            "accountName": Faker.Internet.userName(),
            "accountId": Faker.Internet.qq(),
            "appKey": null
        }],
        "addresses": [
            Faker.Address.streetAddress(true)
        ],
        "tags": null
    };
};

exports.generateFakeUsers = function (userAmount, contactsAmountConfig, contactsRepeatRateConfig, contactsSimilarRateConfig, callback) {
    var fact = [];
    var users = [];
    for (var i = 1; i <= userAmount; i++) {
        var user = Faker.User.owner(contactsAmountConfig, contactsRepeatRateConfig, contactsSimilarRateConfig);
        var userInfo = user.owner;
        var userFact = user.fact;
        var tmp = {};
        var userId = i + '';
        tmp[userId] = {};
        tmp[userId].repeatContactsAmount = userFact[0];
        tmp[userId].similarContactsAmount = userFact[1];
        tmp[userId].diffContactsAmount = userFact[2];
        fact.push(tmp);
        users.push(userInfo);
    }
    
    if (callback && typeof(callback) === "function") {
        return callback(users, fact);
    }
};