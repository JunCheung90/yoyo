(function(){
  var user, fs;
  user = {
    uid: 'xxxx',
    isPerson: true,
    name: '张三',
    nicknames: ['小张', '小三'],
    avatars: ['s-aid-1', 's-aid-2', 'u-aid-1', 'u-aid-2'],
    currentAvatar: 's-aid-2',
    phones: [
      {
        phoneNumber: '3456789',
        isActive: true,
        startUsingTime: '2012-11-05'
      }, {
        phoneNumber: '1',
        isActive: false,
        startUsingTime: '2010-01-01',
        endUsingTime: '2012-11-01'
      }
    ],
    emails: ['zhangsan@fake.com'],
    ims: [
      {
        type: 'QQ',
        account: '111111',
        isActive: true,
        apiKey: 'qq可能给出的api key'
      }, {
        type: 'AOL',
        account: '222222',
        isActive: true,
        apiKey: 'AOL可能给出的api key'
      }
    ],
    sns: [{
      snName: '豆瓣',
      accountName: '张三豆',
      apiKey: 'xxxx'
    }],
    addresses: ['广州 大学城 中山大学 至善园 307'],
    tags: ['程序员'],
    isRegistered: true,
    lastModifiedDate: '2013-01-09',
    isMergePending: false,
    mergedTo: null,
    mergedFrom: [],
    contacts: [
      {
        cid: 'owner-uid-c-timestamp_of_add-seqno',
        actByUser: 'uid_lisi',
        names: ['李小四'],
        phones: ['123456'],
        emails: ['lisi@fake.com'],
        ims: [{
          type: 'QQ',
          account: 'lisi111'
        }],
        sns: [],
        tags: []
      }, {
        mergedTo: null,
        mergedFrom: [],
        pendingMerges: [{
          pendingMergeTo: null,
          pendingMergeFrom: [],
          userDecision: null
        }]
      }
    ],
    asContactOf: ['uid-of-zhangsan', 'uid-of-zhaowu'],
    contactedStrangers: ['uid-of-stranger-1', 'uid-of-stranger-2'],
    contactedByStrangers: ['uid-of-stranger-3', 'uid-of-stranger-2']
  };
  fs = require('fs');
  fs.writeFile('zhangsan.json', JSON.stringify(user, null, '\t'), function(err){
    if (err) {
      throw new Error(err);
    }
    console.log("user data have been exported to zhangsan.json");
  });
}).call(this);
