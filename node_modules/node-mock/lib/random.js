var definitions = require('./definitions');
var Config = require('./config').yoyoContact;

var random = {
    // returns a single random number based on a range
    number: function (range) {
        return Math.floor(Math.random() * range);
    },

    // [min, max) can not reach max
    range: function (min, max) {
        return min + Math.floor(Math.random() * (max - min));
    },

    // takes an array and returns the array randomly sorted
    array_element: function (array) {
        var r = Math.floor(Math.random() * array.length);
        return array[r];
    },

    //返回相应参数正态随机序列的元素
    normal_distribution: function (mean, std_dev) {
        return mean + (this.std_normal_distribution() * std_dev);
    },

    nd_random_in_range: function (arr) {
        var r;
        var mean = arr[0] || 0.0;
        var std = arr[1] || 1.0;
        var min = arr[2] || -5;
        var max = arr[3] || 5;
        do {
            r = this.normal_distribution(mean, std);
        } while (r < min || r > max);

        return r;
    },

    /*
     * 使用Marsaglia polar方法产生标准正态分布序列
     * 见http://en.wikipedia.org/wiki/Normal_distribution#Generating_values_from_normal_distribution
     */
    std_normal_distribution: function () {
        do {
            var u = 2 * Math.random() - 1;
            var v = 2 * Math.random() - 1;
            var r = u * u + v * v;
        } while (r == 0 || r >= 1);
        

        var c = Math.sqrt(-2 * Math.log(r) / r);
        return u * c;
    },

    city_prefix: function () {
        return this.array_element(definitions.city_prefix());
    },

    city_suffix: function () {
        return this.array_element(definitions.city_suffix());
    },

    street_suffix: function () {
        return this.array_element(definitions.street_suffix());
    },

    br_state: function () {
        return this.array_element(definitions.br_state());
    },

    br_state_abbr: function () {
        return this.array_element(definitions.br_state_abbr());
    },

    us_state: function () {
        return this.array_element(definitions.us_state());
    },

    us_state_abbr: function () {
        return this.array_element(definitions.us_state_abbr());
    },

    uk_county: function () {
        return this.array_element(definitions.uk_county());
    },

    uk_country: function () {
        return this.array_element(definitions.uk_country());
    },

    first_name: function () {
        return this.array_element(definitions.first_name());
    },

    last_name: function () {
        return this.array_element(definitions.last_name());
    },

    name_prefix: function () {
        return this.array_element(definitions.name_prefix());
    },

    name_suffix: function () {
        return this.array_element(definitions.name_suffix());
    },

    first_name_cn: function () {
        return this.array_element(definitions.first_name_cn());
    },

    last_name_cn: function () {
        return this.array_element(definitions.last_name_cn());
    },

    catch_phrase_adjective: function () {
        return this.array_element(definitions.catch_phrase_adjective());
    },

    catch_phrase_descriptor: function () {
        return this.array_element(definitions.catch_phrase_descriptor());
    },

    catch_phrase_noun: function () {
        return this.array_element(definitions.catch_phrase_noun());
    },

    bs_adjective: function () {
        return this.array_element(definitions.bs_adjective());
    },

    bs_buzz: function () {
        return this.array_element(definitions.bs_buzz());
    },

    bs_noun: function () {
        return this.array_element(definitions.bs_noun());
    },

    phone_formats: function () {
        return this.array_element(definitions.phone_formats());
    },

    domain_suffix: function () {
        return this.array_element(definitions.domain_suffix());
    }
};

module.exports = random;
