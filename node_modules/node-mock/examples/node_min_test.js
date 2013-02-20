#!/usr/bin/env node

var util = require('util');

var Faker = require('../index');

var yoyoer = Faker.Helpers.createYoYoUser();

util.puts(JSON.stringify(yoyoer, null, '\t'));