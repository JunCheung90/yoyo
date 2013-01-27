if (typeof window == 'undefined' || window === null) {
  require('prelude-ls').installPrelude(global);
} else {
  prelude.installPrelude(window);
}
var ref$;
ref$ = typeof exports != 'undefined' && exports !== null ? exports : this;
ref$.mongo = {
  host: 'localhost',
  port: 27017,
  db: 'yoyo-test'
};
ref$.sequelize = [
  'spike_yoyo', 'yoyo', 'yoyo', {
    logging: false
  }
];