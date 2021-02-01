'use strict';

let mongoose = require('../../db');
let autoIncrement = require('mongoose-auto-increment');
let Schema = mongoose.Schema;

let PostSchema = new Schema({
    id: {
        type: Number,
        required: true,
    },
    described: {
        type: String,
        default: null,
    },
    like: {
        type: Number,
        default: 0
    },
    comment: {
        type: Number,
        default: 0
    },
    images: {
        type: Array,
        default: null
    },
    is_liked: {
        type: Boolean,
        default: false
    },
    video: {
        type: Array,
        default: null
    },
    author: {
        type: Object,
        required: true
    },
    status: {
        type: String,
        default: null
    },
    modified: {
        type: Boolean,
        required: true,
        default: true
    },
    is_blocked: {
        type: Boolean,
        required: true,
        default: false
    },
    can_edit: {
        type: Boolean,
        required: true,
        default: true
    },
    banned: {
        type: Boolean,
        required: true,
        default: false
    },
    can_comment: {
        type: Boolean,
        required: true,
        default: true
    },
    created_at: {
        type: Date,
        default: Date.now
    }
});

PostSchema.plugin(autoIncrement.plugin, {
    model: 'Post',
    field: 'id'
});

module.exports = mongoose.model('Post', PostSchema);