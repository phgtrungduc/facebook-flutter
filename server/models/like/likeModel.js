'use strict';

let mongoose = require('../../db');
let autoIncrement = require('mongoose-auto-increment');
let Schema = mongoose.Schema;

let LikeSchema = new Schema({
    like_id: {
        type: Number,
        required: true,
    },
    user_id: {
        type: Number //id nguoi like
    },
    id: {
        type: Number, //id bai viet
        required: true
    },
    created_at: {
        type: Date,
        default: Date.now
    }
});

LikeSchema.plugin(autoIncrement.plugin, {
    model: 'Like',
    field: 'like_id'
});

module.exports = mongoose.model('Like', LikeSchema);