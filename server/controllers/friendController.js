'use strict';

let FriendRequest = require('../models/friend/friendRequestModel');
let Friend = require('../models/friend/friendModel');
let FriendBlock = require('../models/friend/friendBlockModel');
let User = require('../models/user/userModel');
let Notify = require('../models/notify/notifyModel');
const { findOne } = require('../models/user/userModel');
const e = require('cors');

exports.get_requested_friends = async (req, res) => {
    let count = parseInt(req.query.count);
    let index = parseInt(req.query.index);
    let total = await FriendRequest.countDocuments({ "info.user_id": req.jwtDecoded.data.id }).exec();
    await FriendRequest.find({ "info.user_id": req.jwtDecoded.data.id })
        .sort({ created_at: 1 })
        .limit(count)
        .skip(index)
        .then(function (data) {
            var X = [];
            data.forEach((u) => {
                let same_friend = sameFriend(req.jwtDecoded.data.id, u.user_id);
                u.user_send.same_friends = same_friend;
                X.push(u);
            });
            return Promise.all(X);
        })
        .then(function (X) {
            res.json({
                code: 1000,
                message: 'OK',
                data: {
                    friends: X,
                    total: total
                }
            });
        }).catch(function (err) {
            res.json({
                code: 9999,
                message: err
            });
        });

    // FriendRequest.find({ "info.user_id": req.jwtDecoded.data.id })
    //     .sort({ created_at: 1 })
    //     .limit(count)
    //     .skip(index)
    //     .exec((err, data) => {
    //         if (err)
    //             res.json({
    //                 code: 9999,
    //                 message: err
    //             });
    //         else {
    //             if (data) {
    //                 for (let i = 0; i < data.length; i++) {
    //                     let same_friend = sameFriend(req.jwtDecoded.data.id, data[i].user_id);
    //                     console.log(same_friend);
    //                     data[i].user_send.same_friend = same_friend;
    //                 }
    //                 res.json({
    //                     code: 1000,
    //                     message: 'OK',
    //                     data: {
    //                         friends: data,
    //                         total: total
    //                     }
    //                 });
    //             } else {
    //                 return res.json({
    //                     code: 9994,
    //                     message: 'No Data'
    //                 });
    //             }
    //         }
    //     });
}

async function sameFriend(user_id_1, user_id_2) {
    let friend_user_1 = await Friend.find({ "user_id": user_id_1 }).exec();
    let same_friend = 0;
    if (friend_user_1.length) {
        for (let i = 0; i < friend_user_1.length; i++) {
            let ok = await Friend.find({ "info.user_id": friend_user_1[i].info.user_id, "user_id": user_id_2 }).exec();
            if (ok.length != 0) same_friend++;
        }
    }
    return same_friend;
}

exports.get_user_friends = async (req, res) => {
    let count = parseInt(req.query.count);
    let index = parseInt(req.query.index);
    let target = parseInt(req.jwtDecoded.data.id);
    if (req.query.user_id != undefined) target = parseInt(req.query.user_id);
    let total = await Friend.countDocuments({ "user_id": parseInt(target) }).exec();

    await Friend.find({ "user_id": parseInt(target) })
        .sort({ created_at: 1 })
        .limit(count)
        .skip(index)
        .exec((err, data) => {
            if (err) {
                res.json({
                    code: 9999,
                    message: err
                });
            }
            else {
                if (data) {
                    for (let i = 0; i < data.length; i++) {
                        let same_friend = sameFriend(parseInt(target), parseInt(data[i].user_id));
                        data[i].info.same_friend = same_friend;
                    }
                    res.json({
                        code: 1000,
                        message: 'OK',
                        data: {
                            friends: data,
                            total: total
                        }
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

exports.set_accept_friend = async (req, res) => {
    let user_id = req.body.user_id; //chap nhan loi moi ket ban tu user_id
    let is_accept = req.body.is_accept;

    if (is_accept === 1) {
        await FriendRequest.findOne({ "info.user_id": req.jwtDecoded.data.id, "user_id": user_id }, async (err, data) => {
            if (err)
                res.json({
                    code: 9999,
                    message: err
                });
            else {
                if (data) {
                    let friend = new Friend({
                        user_id: user_id,
                        info: data.info
                    })

                    await friend.save((err) => {
                        if (err)
                            res.json({
                                code: 9999,
                                message: err
                            });
                        else {
                            FriendRequest.deleteOne({ "info.user_id": req.jwtDecoded.data.id, "user_id": user_id }, async (err) => {
                                if (err) res.json({
                                    code: 9999,
                                    message: err
                                });
                                else {
                                    let user = await User.findOne({ "id": user_id }).exec();
                                    let same_friend = await sameFriend(parseInt(user_id), parseInt(user.id));
                                    let friend = new Friend({
                                        user_id: req.jwtDecoded.data.id,
                                        info: {
                                            user_id: user.id,
                                            username: user.name,
                                            avatar: user.avatar,
                                            same_friend: same_friend,
                                        }
                                    })
                                    await friend.save((err) => {
                                        if (err)
                                            res.json({
                                                code: 9999,
                                                message: err
                                            });
                                        else {
                                            res.json({
                                                code: 1000,
                                                message: "OK",
                                                same_friends: same_friend
                                            })
                                        }
                                    })
                                }
                            })
                        }
                    })
                }
                else {
                    return res.json({
                        code: 9994,
                        message: 'No Data'
                    });
                }
            }
        })
    }
    else {
        await FriendRequest.findOneAndDelete({ "user_id": user_id, "info.user_id": req.jwtDecoded.data.id }, (err, data) => {
            if (err) res.json({
                code: 9999,
                message: err
            });
            else {
                res.json({
                    code: 1000,
                    message: "OK",
                })
            }
        })
    }
}

exports.set_request_friend = async (req, res) => {
    let user_id = req.body.user_id; //nguoi duoc gui loi moi ket ban
    let user_info = await User.findOne({ id: user_id }).exec(); //thong tin nguoi duoc gui ket ban
    let user_send = await User.findOne({ id: req.jwtDecoded.data.id }).exec();

    let friendRequest = new FriendRequest({
        user_id: req.jwtDecoded.data.id,
        info: {
            user_id: user_info.id,
            username: user_info.name,
            avatar: user_info.avatar,
        },
        user_send: {
            user_id: user_send.id,
            username: user_send.name,
            avatar: user_send.avatar,
        }
    });

    FriendRequest.findOne({ user_id: req.jwtDecoded.data.id, "info.user_id": user_id }, async (err, data) => {
        if (err) {
            res.json({
                code: 9999,
                message: err
            });
        }
        else {
            if (data == null) {
                let notify = new Notify({
                    info_user: {
                        user_id: user_send.id,
                        username: user_send.name,
                        avatar: user_send.avatar,
                    },
                    user_id: user_id,
                    type: 'request'
                })
                await notify.save();
                await friendRequest.save(async (err, data) => {
                    if (err) {
                        res.json({
                            code: 9999,
                            message: err
                        });
                    }
                    else {
                        let requested_friends = await FriendRequest.countDocuments({ "user_id": req.jwtDecoded.data.id }).exec();
                        res.json({
                            code: 1000,
                            message: "OK",
                            data: {
                                requested_friends: requested_friends
                            },
                        });
                    }
                });
            }
            else {
                res.json({
                    code: 1010,
                    message: "action has been done previously by this user",
                });
            }
        }
    })
}

exports.get_list_blocks = (req, res) => {
    let count = parseInt(req.query.count);
    let index = parseInt(req.query.index);

    FriendBlock.find({ "user_id": req.jwtDecoded.data.id })
        .sort({ created_at: -1 })
        .limit(count)
        .skip(index)
        .exec((err, data) => {
            if (err)
                res.json({
                    code: 9999,
                    message: err
                });
            else {
                if (data) {
                    res.json({
                        code: 1000,
                        message: 'OK',
                        data: data
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

exports.set_block = async (req, res) => {
    let user_id = req.body.user_id;
    let user = await User.findOne({ id: user_id }).exec();
    let friendBlock = new FriendBlock({
        user_id: req.jwtDecoded.data.id,
        info: {
            user_id: user.id,
            username: user.name,
            avatar: user.avatar,
        }
    });
    FriendBlock.findOne({ user_id: req.jwtDecoded.data.id, "info.user_id": user_id }, (err, data) => {
        if (err) {
            res.json({
                code: 9999,
                message: err
            });
        }
        else {
            if (data == null) {
                friendBlock.save(async (err, data) => {
                    if (err) {
                        res.json({
                            code: 9999,
                            message: err
                        });
                    }
                    else {
                        console.log(user_id);
                        await FriendRequest.findOneAndRemove({ "info.user_id": user_id }).exec();
                        await FriendRequest.findOneAndRemove({ "user_send.user_id": user_id }).exec();
                        await Friend.findOneAndRemove({ "info.user_id": user_id }).exec();
                        await Friend.findOneAndRemove({ "user_id": user_id }).exec();
                        let blocked_friends = await FriendBlock.countDocuments({ user_id: req.jwtDecoded.data.id }).exec();
                        res.json({
                            code: 1000,
                            message: "OK",
                            data: {
                                blocked_friends: blocked_friends
                            },
                        });
                    }
                });
            }
            else {
                res.json({
                    code: 1010,
                    message: "action has been done previously by this user",
                });
            }
        }
    })
}

exports.set_unblock = (req, res) => {
    let conditions = {
        "info.user_id": req.body.user_id,
        "user_id": req.jwtDecoded.data.id,
    };
    FriendBlock.deleteOne(conditions, function (err, data) {
        if (err)
            res.send(err);
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

function compareNumbers(a, b) {
    return a.info.same_friend - b.info.same_friend;
}

let X = async function (req, myFriend) {
    let result = [];
    for (let i = 0; i < myFriend.length; i++) {
        Friend.find({ "user_id": myFriend[i].info.user_id }, async (err, myYourFriend) => {
            if (myYourFriend) {
                for (let j = 0; j < myYourFriend.length; j++) {
                    if (myYourFriend[j].user_id == req.jwtDecoded.data.id || myYourFriend[j].info.user_id == req.jwtDecoded.data.id) {
                        continue;
                    }
                    else {
                        let same_friend = await sameFriend(parseInt(req.jwtDecoded.data.id), parseInt(myYourFriend[j].info.user_id));
                        myYourFriend[j].info.same_friends = same_friend;
                        result.push(myYourFriend[j]);
                    }
                }
            }
        });
    }
    return result;
}

exports.get_list_suggested_friends = (req, res) => {
    Friend.find({ "user_id": req.jwtDecoded.data.id }, async (err, myFriend) => {
        if (err) {
            res.json({
                code: 9999,
                message: err
            });
        }
        else {
            if (myFriend) {
                X(req, myFriend).then((result) => {
                    result.sort(compareNumbers);
                    res.json({
                        code: 1000,
                        message: 'OK',
                        data: {
                            friends: result.slice(0, 10),
                        }
                    });
                });
            }
        }
    })
}

exports.unfriend = (req, res) => {
    let id = parseInt(req.query.id);
    Friend.findOneAndRemove({ "info.user_id": id, user_id: req.jwtDecoded.data.id }, async (err, data) => {
        if (err) {
            res.json({
                code: 9999,
                message: err
            });
        }
        else {
            await Friend.findOneAndRemove({ "info.user_id": req.jwtDecoded.data.id, user_id: id }, (err) => {
                if (err) {
                    res.json({
                        code: 9999,
                        message: err
                    });
                }
                else {
                    return res.json({
                        code: 1000,
                        message: 'OK'
                    });
                }
            })
        }
    })
}

exports.del_request_friend = async (req, res) => {
    let user_id = parseInt(req.query.user_id);
    FriendRequest.findOneAndRemove({ "info.user_id": user_id, user_id: req.jwtDecoded.data.id }, (err, data) => {
        if (err) {
            res.json({
                code: 9999,
                message: err
            });
        }
        else {
            if (data) {
                return res.json({
                    code: 1000,
                    message: 'OK'
                });
            }
            else {
                return res.json({
                    code: 9994,
                    message: 'No Data'
                });
            }
        }
    })
}

exports.upload = (req, res) => {

}


