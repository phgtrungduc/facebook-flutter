'use strict';

let Search = require('../models/search/searchModel');
let Post = require('../models/post/postModel');
let Friend = require('../models/friend/friendModel');
let User = require("../models/user/userModel");

async function sameFriend(user_id_1, user_id_2) {
    let friend_user_1 = await Friend.find({ "info.user_id": user_id_1 }).exec();
    let same_friend = 0;

    for (let i = 0; i < friend_user_1.length; i++) {
        await Friend.findOne({ "info.user_id": user_id_2, "user_id": friend_user_1[i].user_id })
            .exec((err, data) => {
                if (err) { }
                else {
                    if (data !== null) {
                        same_friend = same_friend + 1;
                    }
                }
            })
    }
    return same_friend;
}

exports.search = (req, res) => {
    let keyword = req.query.keyword;
    let index = parseInt(req.query.index);
    let count = parseInt(req.query.count);
    let user_id = req.jwtDecoded.data.id;

    let search = new Search({
        user_id: user_id,
        keyword: keyword
    })
    search.save(async (err, data) => {
        if (err)
            return res.json({
                code: 9999,
                message: err
            });
        else {
            if (data) {
                let list_user_id = await Friend.find({ user_id: user_id });
                if (list_user_id.length !== 0) {
                    await Post
                        .find({
                            use_id: { $in: list_user_id }, described: { $regex: keyword }
                        })
                        .sort({ created_at: -1 })
                        .limit(count)
                        .skip(index)
                        .exec((err, data) => {
                            if (err)
                                return res.json({
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
                                        code: 1009,
                                        message: "Does not exist!"
                                    });
                                }
                            }
                        });
                }
                else {
                    res.json({
                        code: 1009,
                        message: "Does not exist!"
                    });
                }
            } else {
                res.json({
                    code: 1009,
                    message: "Save keyword unsuccessfully!"
                });
            }
        }
    })
}

exports.get_saved_search = (req, res) => {
    let count = parseInt(req.query.count);
    let index = parseInt(req.query.index);

    Search.find({ user_id: req.jwtDecoded.data.id })
        .sort({ created_at: -1 })
        .limit(count)
        .skip(index)
        .exec((err, data) => {
            if (err)
                return res.json({
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
                        code: 1009,
                        message: "Does not exist!"
                    });
                }
            }
        });
}

exports.del_saved_search = (req, res) => {
    let search_id = req.body.search_id;
    let all = req.body.all;

    if (all === 0) {
        let conditions = {
            "search_id": search_id,
            "user_id": req.jwtDecoded.data.id,
        };
        Search.deleteOne(conditions, (err, data) => {
            if (err)
                return res.json({
                    code: 9999,
                    message: err
                });
            else {
                console.log(data)
                if (data.deletedCount) {
                    res.json({
                        code: 1000,
                        message: 'OK'
                    });
                } else {
                    res.json({
                        code: 1009,
                        message: 'Not found keyword search'
                    });
                }
            }
        });
    } else {
        Search.deleteMany({}, (err, data) => {
            if (err)
                return res.json({
                    code: 9999,
                    message: err
                });
            else {
                if (data.deletedCount) {
                    res.json({
                        code: 1000,
                        message: 'OK'
                    });
                } else {
                    res.json({
                        code: 1009,
                        message: 'Not access'
                    });
                }
            }
        });
    }
}

exports.search_user = (req, res) => {
    let use_id = parseInt(req.query.user_id);
    let keyword = req.query.keyword;
    let index = parseInt(req.query.index);
    let count = parseInt(req.query.count);

    if (use_id === null) {
        use_id = req.jwtDecoded.data.id;
    }
    Friend.find({ user_id: use_id, "info.username": { $regex: keyword, $options: 'i' } })
        .sort({ created_at: -1 })
        .limit(count)
        .skip(index)
        .exec((err, data) => {
            if (err)
                return res.json({
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
                        code: 1009,
                        message: "Does not exist!"
                    });
                }
            }
        });
}

exports.search_post = (req, res) => {
    let use_id = parseInt(req.query.user_id);
    let keyword = req.query.keyword;
    let index = parseInt(req.query.index);
    let count = parseInt(req.query.count);

    if (use_id === null)
        use_id = req.jwtDecoded.data.id;
    Post
        .find({
            "author.id": use_id, "described": { $regex: keyword }
        })
        .sort({ created_at: -1 })
        .limit(count)
        .skip(index)
        .exec((err, data) => {
            if (err)
                return res.json({
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
                        code: 1009,
                        message: "Does not exist!"
                    });
                }
            }
        });
}

exports.search_user_home = async (req, res) => {
    let index = parseInt(req.query.index);
    let count = parseInt(req.query.count);
    let user_id = req.jwtDecoded.data.id;
    let keyword = req.query.keyword;
    let search = new Search({
        user_id: user_id,
        keyword: keyword
    })

    let result = await Search.findOne({ user_id: user_id, keyword: keyword }).exec();

    if (result !== null) {
        result.created_at = Date.now();
        result.save();
    }
    else {
        await search.save();
    }

    await User.find({ $or: [{ "name": { $regex: keyword, $options: 'i' } }] })
        .sort({ created_at: -1 })
        .limit(count)
        .skip(index)
        .exec(async (err, data) => {
            if (err)
                res.json({
                    code: 9999,
                    message: err
                });
            else {
                if (data) {
                    let result1 = [];
                    let result2 = [];

                    for (let i = 0; i < data.length; i++) {
                        let friend = await Friend.findOne({ "user_id": user_id, "info.user_id": data[i].id }).exec();
                        let same_friend = sameFriend(user_id, data[i].id);

                        if (friend) {
                            let temp = {
                                info: {
                                    user_id: friend.info.user_id,
                                    username: friend.info.username,
                                    avatar: friend.info.avatar,
                                    same_friend: friend.info.same_friend
                                }
                            }
                            result1.push(temp);
                        }
                        else {
                            let temp = {
                                info: {
                                    user_id: data[i].id,
                                    username: data[i].name,
                                    avatar: data[i].avatar,
                                    same_friend: same_friend
                                }
                            }
                            result2.push(temp);
                        }
                    }
                    result1 = result1.concat(result2);
                    res.json({
                        code: 1000,
                        message: 'OK',
                        data: result1
                    });
                } else {
                    return res.json({
                        code: 9994,
                        message: 'No Data'
                    });
                }
            }
        });
}

exports.search_post_home = (req, res) => {
    let index = parseInt(req.query.index);
    let count = parseInt(req.query.count);
    let user_id = req.jwtDecoded.data.id;
    let keyword = req.query.keyword;

    Post.find({ $or: [{ "described": { $regex: keyword } }] })
        .sort({ created_at: -1 })
        .limit(count)
        .skip(index)
        .exec(async (err, data) => {
            if (err)
                res.json({
                    code: 9999,
                    message: err
                });
            else {
                if (data) {
                    let result1 = [];
                    let result2 = [];
                    console.log(data);

                    for (let i = 0; i < data.length; i++) {
                        let friend = await Friend.findOne({ "user_id": user_id, "info.user_id": data[i].id }).exec();
                        if (friend) {
                            result1.push(data[i]);
                        }
                        else {
                            result2.push(data[i]);
                        }
                    }
                    result1 = result1.concat(result2);
                    res.json({
                        code: 1000,
                        message: 'OK',
                        data: result1
                    });
                } else {
                    return res.json({
                        code: 9994,
                        message: 'No Data'
                    });
                }
            }
        });
}