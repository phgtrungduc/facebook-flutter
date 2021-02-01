"use strict";

let Setting = require("../models/setting/settingModel");

exports.get_push_settings = (req, res) => {
    Setting.findOne({
        user_id: req.jwtDecoded.data.id
    }).exec(function (err, data) {
        if (err)
            res.json({
                code: 9999,
                message: err
            });
        else {
            if (data) {
                res.json({
                    code: 1000,
                    message: "OK",
                    data: data
                });
            } else {
                res.json({
                    code: 9992,
                    message: "Setting is not existed!"
                });
            }
        }
    });
}

exports.set_push_settings = (req, res) => {
    req.body.user_id = req.jwtDecoded.data.id;
    let setting = new Setting(req.body);
    setting.save((err, data) => {
        if (err)
            res.json({
                code: 1010,
                message: "action has been done previously by this user",
            });
        else {
            if (data) {
                res.json({
                    code: 1000,
                    message: "OK",
                });
            }
        }
    })
}