/*
 * Created by Wang, Qing. All rights reserved.
 */
var contactsMergingStrategy;
contactsMergingStrategy = {
  directMerging: {
    'actByUser': ['same'],
    'emails': ['same'],
    'phones': ['same'],
    'ims': ['same'],
    'sns': ['same']
  },
  recommandMerging: {
    'names': ['similar-name'],
    'emails': ['same-owner-dif-provider']
  }
};
module.exports = contactsMergingStrategy;