'use strict';
let mongoose = require('../../db');
let autoIncrement = require('mongoose-auto-increment');
let Schema = mongoose.Schema;

let SearchSchema = new Schema({
    search_id: {
        type: Number,
        required: true,
    },
    user_id: {
        type: Number,
        required: true
    },
    keyword: {
        type: String,
        required: true
    },
    created_at: {
        type: Date,
        default: Date.now
    }
});

SearchSchema.plugin(autoIncrement.plugin, {
    model: 'Search',
    field: 'search_id'
});

module.exports = mongoose.model('Search', SearchSchema);