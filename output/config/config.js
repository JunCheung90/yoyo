var ref$;
ref$ = typeof exports != 'undefined' && exports !== null ? exports : this;
ref$.mysql = {
  host: 'localhost',
  user: 'yoyo',
  password: 'yoyo',
  database: 'spike_yoyo'
};
ref$.couch = {
  url: 'http://localhost:5984',
  version: '*',
  db: 'test_db'
};
ref$.sequelize = [
  'test_sequelize', 'yoyo', 'yoyo', {
    logging: false
  }
];