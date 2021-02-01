'use strict';
let mongoose = require('../../db');
let autoIncrement = require('mongoose-auto-increment');
let Schema = mongoose.Schema;

let FriendSchema = new Schema({
    friend_id: {
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
    user_id: {
        type: Number,
        required: true,
        default: -1
    },
    created_at: {
        type: Date,
        default: Date.now
    }
});

FriendSchema.plugin(autoIncrement.plugin, {
    model: 'Friend',
    field: 'friend_id'
});

module.exports = mongoose.model('Friend', FriendSchema);