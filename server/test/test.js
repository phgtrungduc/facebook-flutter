'use strict';
let mongoose = require('mongoose');
let autoIncrement = require('mongoose-auto-increment');
let DB = process.env.DATBASE_NAME || "facebookapp";
let mongoDB = "mongodb://127.0.0.1:27017/" + DB;
let User = require("../models/user/user");
mongoose.set('useNewUrlParser', true);
mongoose.set('useCreateIndex', true);
mongoose.set('useUnifiedTopology', true);
mongoose.set('useFindAndModify', false);

mongoose.connect(mongoDB);
let db = mongoose.connection;
db.on('error', console.error.bind(console, 'MongoDB connection error:'));

autoIncrement.initialize(db);
let user = await User.findOne({
    phone: req.body.phone
}).exec();
