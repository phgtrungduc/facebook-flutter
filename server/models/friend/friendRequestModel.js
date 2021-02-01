'use strict';
let mongoose = require('../../db');
let autoIncrement = require('mongoose-auto-increment');
let Schema = mongoose.Schema;

let FriendRequestSchema = new Schema({
    request_id: {
        required: true,
        type: Number
    },
    info: {
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
        },
        same_friends: {
            type: Number,
            default: 0
        },
        created: {
            type: Date,
            default: null
        }
    },
    user_send: {
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
        },
        same_friends: {
            type: Number,
            default: 0
        },
        created: {
            type: Date,
            default: null
        }
    },
    user_id: {
        type: Number,
        required: true
    },
    created_at: {
        type: Date,
        default: Date.now
    }
});

FriendRequestSchema.plugin(autoIncrement.plugin, {
    model: 'FriendRequest',
    field: 'request_id'
});

module.exports = mongoose.model('FriendRequest', FriendRequestSchema);