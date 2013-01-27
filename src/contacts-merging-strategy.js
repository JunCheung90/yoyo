if (typeof window == 'undefined' || window === null) {
  require('prelude-ls').installPrelude(global);
} else {
  prelude.installPrelude(window);
}
var contactsMergingStrategy;
contactsMergingStrategy = {
  directMerging: ['actByUser', 'emails'],
  recommandMerging: ['phones', 'ims', 'sns']
};
module.exports = contactsMergingStrategy;