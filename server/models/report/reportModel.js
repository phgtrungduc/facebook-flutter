'use strict';
let mongoose = require('../../db');
let Schema = mongoose.Schema;
let autoIncrement = require('mongoose-auto-increment');

let ReportSchema = new Schema({
    report_id : {
        type: Number,
    },
    author_id: {
        type: Number,
    },
    post_id: {
        type: Number,
    },
    subject: {
        type: String,
        default: null
    },
    detail: {
        type: String,
        default: null
    },
    created_at: {
        type: Date,
        default: Date.now()
    }
});

ReportSchema.plugin(autoIncrement.plugin, {
    model: 'Report',
    field: 'report_id'
});

module.exports = mongoose.model('Report', ReportSchema);