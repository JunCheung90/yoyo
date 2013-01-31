if (typeof window == 'undefined' || window === null) {
  require('prelude-ls').installPrelude(global);
} else {
  prelude.installPrelude(window);
}
/*
 * Created by Wang, Qing. All rights reserved.
 */
var contactsMergingStrategy;
contactsMergingStrategy = {
  directMerging: {
    'actByUser': ['same'],
    'emails': ['one-same'],
    'phones': ['one-same'],
    'ims': ['one-same'],
    'sns': ['one-same']
  },
  recommandMerging: {
    'names': ['similar-name'],
    'emails': ['same-owner-dif-provider']
  }
};
module.exports = contactsMergingStrategy;