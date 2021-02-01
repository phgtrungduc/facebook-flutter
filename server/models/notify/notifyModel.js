'use strict';

let mongoose = require('../../db');
let autoIncrement = require('mongoose-auto-increment');
let Schema = mongoose.Schema;

let NotifySchema = new Schema({
    notify_id: {
        type: Number,
        required: true,
    },
    info_user: {
        user_id: {
            type: Number,
            default: null
        },
        username: {
            type: String,
            default: null
        },
        avatar: {
            type: String,
            default: null
        }
    },
    post_id: {
        type: Number,
        default: null,
    },
    user_id: {
        type: Number,
        required: true
    },
    type: {
        type: String,
        default: "message"
    },
    seen: {
        type: Boolean,
        default: false
    },
    created_at: {
        type: Date,
        default: Date.now
    }
});

NotifySchema.plugin(autoIncrement.plugin, {
    model: 'Notify',
    field: 'notify_id'
});

module.exports = mongoose.model('Notify', NotifySchema);