'use strict';

let mongoose = require('../../db');
let autoIncrement = require('mongoose-auto-increment');
let Schema = mongoose.Schema;

let FriendBlockSchema = new Schema({
    block_id: {
        type: Number,
        required: true,
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
        same_friends: { //so ban chung
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

FriendBlockSchema.plugin(autoIncrement.plugin, {
    model: 'FriendBlock',
    field: 'block_id'
});

module.exports = mongoose.model('FriendBlock', FriendBlockSchema);