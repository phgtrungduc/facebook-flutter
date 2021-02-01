'use strict';
let mongoose = require('../../db');
let autoIncrement = require('mongoose-auto-increment');
let Schema = mongoose.Schema;

let CommentSchema = new Schema({
    comment_id: {
        required: true,
        type: Number
    },
    comment: {
        type: String,
        required: true
    },
    author: {
        type: Object,
        required: true
    },
    id: {
        type: Number,
        required: true
    },
    created_at: {
        type: Date,
        default: Date.now
    }
});

CommentSchema.plugin(autoIncrement.plugin, {
    model: 'Comment',
    field: 'comment_id'
});

module.exports = mongoose.model('Comment', CommentSchema);