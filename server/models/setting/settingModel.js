'use strict';
let mongoose = require('../../db');
let autoIncrement = require('mongoose-auto-increment');
let Schema = mongoose.Schema;

let SettingSchema = new Schema({
    setting_id: {
        required: true,
        type: Number
    },
    like_comment: {
        type: Number,
        default: 1
    },
    from_friends: {
        type: Number,
        default: 1
    }, 
    requested_friend: {
        type: Number,
        default: 1
    },
    suggested_friend: {
        type: Number,
        default: 1
    },
    birthday: {
        type: Number,
        default: 1
    },
    video: {
        type: Number,
        default: 1
    },
    report: {
        type: Number,
        default: 1
    },
    sound_on: {
        type: Number,
        default: 1
    },
    notification_on: {
        type: Number,
        default: 1
    },
    vibrant_on: {
        type: Number,
        default: 1
    },
    let_on: {
        type: Number,
        default: 1
    },
    user_id: {
        type: Number,
        required: true,
        unique: true
    },
    created_at: {
        type: Date,
        default: Date.now
    }
});

SettingSchema.plugin(autoIncrement.plugin, {
    model: 'Setting',
    field: 'setting_id'
});

module.exports = mongoose.model('Setting', SettingSchema);