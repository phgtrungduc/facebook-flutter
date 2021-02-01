"use strict";
let User = require("../models/user/userModel");
let Post = require("../models/post/postModel");
let Comment = require("../models/comment/commentModel");
let Friend = require('../models/friend/friendModel');
let FriendRequest = require('../models/friend/friendRequestModel');
let FriendBlock = require('../models/friend/friendBlockModel');
let Notify = require('../models/notify/notifyModel');

let multer = require('multer');
let path = require('path');
let bcrypt = require('bcrypt');
const { ok } = require("assert");
const saltRounds = parseInt(process.env.SALT_ROUNDS) || 10;

let storageAvatar = multer.diskStorage({
    destination: (req, file, callback) => { callback(null, './data'); },
    filename: (req, file, callback) => {
        callback(null, path.parse(file.originalname).name + '-' + Date.now() + path.extname(file.originalname));
    }
});
let uploadAvatar = multer({ storage: storageAvatar }).single('avatar');

exports.change_info_after_signup = async (req, res) => {
    try {
        let user = await User.findOne({
            id: req.jwtDecoded.data.id,
        }).exec();

        await uploadAvatar(req, res, async (err) => {
            if (err) {
                return res.json({
                    code: 9999,
                    message: err
                });
            } else {
                console.log(req.body.name, user)
                let link = 'data/' + req.file.filename;
                user.name = req.body.name;
                user.avatar = link;
                await user.save();
                res.json({
                    code: 1000,
                    message: "OK",
                    data: user
                })
            }
        });
    } catch (err) {
        res.json({
            code: 9999,
            message: err
        });
    }
};

exports.change_password = async (req, res) => {
    let user = await User.findOne({ id: req.jwtDecoded.data.id }).exec();
    const match = await bcrypt.compare(req.body.password, user.password);
    if (!match) {
        return res.json({
            code: 2000,
            message: "Old password is wrong"
        });
    }
    else {
        let newpassword = await bcrypt.hash(req.body.new_password, saltRounds);
        user.password = newpassword;
        await user.save();
        res.json({
            code: 1000,
            message: "OK",
        });
    }
};

exports.get_user_info = (req, res) => {
    let user_id = req.query.user_id;
    //neu id khong phai chu cua tai khoan
    if (user_id != req.jwtDecoded.data.id) {
        User.findOne({
            id: user_id,
        }).exec(async (err, data_main) => {
            if (err)
                res.json({
                    code: 9999,
                    message: err
                });
            else {
                //trong danh sach ban be cua minh tim xem co no khong
                if (data_main) {
                    let listing = await Friend.countDocuments({ "info.user_id": user_id }).exec();
                    await Friend.findOne({ "info.user_id": req.jwtDecoded.data.id, "user_id": user_id }, async (err, data1) => {
                        if (err)
                            return res.json({
                                code: 9999,
                                message: err
                            });
                        else {
                            if (data1) {
                                console.log(data_main);
                                res.json({
                                    code: 1000,
                                    message: "OK",
                                    data: {
                                        name: data_main.name,
                                        status: data_main.status,
                                        cover_photo: data_main.cover_photo,
                                        avatar: data_main.avatar,
                                        birthday: data_main.birthday,
                                        address: data_main.address,
                                        city: data_main.city,
                                        country: data_main.country,
                                        phone: data_main.phone,
                                        created_at: data_main.created_at,
                                        id: data_main.id,
                                        listing: listing,
                                        is_friend: 1, //la ban be
                                        online: 0,
                                        _id:data_main._id
                                    }
                                });
                            } else {
                                //tim trong danh sach request no co dang nam trong danh sach minh gui loi moi ket ban hay khong
                                await FriendRequest.findOne({ "user_id": req.jwtDecoded.data.id, "info.user_id": user_id }, async (err, data2) => {
                                    if (err) {
                                        return res.json({
                                            code: 9999,
                                            message: err
                                        });
                                    }
                                    else {
                                        if (data2) {
                                            res.json({
                                                code: 1000,
                                                message: "OK",
                                                data: {
                                                    name: data_main.name,
                                                    status: data_main.status,
                                                    cover_photo: data_main.cover_photo,
                                                    avatar: data_main.avatar,
                                                    birthday: data_main.birthday,
                                                    address: data_main.address,
                                                    city: data_main.city,
                                                    country: data_main.country,
                                                    phone: data_main.phone,
                                                    created_at: data_main.created_at,
                                                    id: data_main.id,
                                                    listing: listing,
                                                    is_friend: -1, //minh dang gui loi moi ket ban den no
                                                    online: 0,
                                                    _id:data_main._id
                                                }
                                            });
                                        }
                                        else {
                                            //kiem tra xem no co dang gui loi moi ket ban den minh hay khong ==> accept
                                            await FriendRequest.findOne({ "user_id": user_id, "info.user_id": req.jwtDecoded.data.id }, (err, data3) => {
                                                if (err) {
                                                    return res.json({
                                                        code: 9999,
                                                        message: err
                                                    });
                                                }
                                                else {
                                                    if (data3) {
                                                        res.json({
                                                            code: 1000,
                                                            message: "OK",
                                                            data: {
                                                                name: data_main.name,
                                                                status: data_main.status,
                                                                cover_photo: data_main.cover_photo,
                                                                avatar: data_main.avatar,
                                                                birthday: data_main.birthday,
                                                                address: data_main.address,
                                                                city: data_main.city,
                                                                country: data_main.country,
                                                                phone: data_main.phone,
                                                                created_at: data_main.created_at,
                                                                id: data_main.id,
                                                                listing: listing,
                                                                is_friend: -2, //chap nhan
                                                                online: 0,
                                                                _id:data_main._id
                                                            }
                                                        });
                                                    }
                                                    else {
                                                        FriendBlock.findOne({ "info.user_id": req.jwtDecoded.data.id, "user_id": user_id }, async (err, data5) => {
                                                            if (err)
                                                                return res.json({
                                                                    code: 9999,
                                                                    message: err
                                                                });
                                                            else {
                                                                if (data5) {
                                                                    return res.json({
                                                                        code: 9999,
                                                                        message: 'No data'
                                                                    });
                                                                }
                                                            }
                                                        });

                                                        FriendBlock.findOne({ "info.user_id": user_id, "user_id": req.jwtDecoded.data.id }, async (err, data4) => {
                                                            if (err)
                                                                return res.json({
                                                                    code: 9999,
                                                                    message: err
                                                                });
                                                            else {
                                                                if (data4) {
                                                                    res.json({
                                                                        code: 9999,
                                                                        message: 'No data'
                                                                    });
                                                                }
                                                                else {
                                                                    res.json({
                                                                        code: 1000,
                                                                        message: "OK",
                                                                        data: {
                                                                            name: data_main.name,
                                                                            status: data_main.status,
                                                                            cover_photo: data_main.cover_photo,
                                                                            avatar: data_main.avatar,
                                                                            birthday: data_main.birthday,
                                                                            address: data_main.address,
                                                                            city: data_main.city,
                                                                            country: data_main.country,
                                                                            phone: data_main.phone,
                                                                            created_at: data_main.created_at,
                                                                            id: data_main.id,
                                                                            listing: listing,
                                                                            is_friend: 0, //chang la gi ca
                                                                            online: 0,
                                                                            _id:data_main._id
                                                                        }
                                                                    })
                                                                }
                                                            }
                                                        })
                                                    }
                                                }
                                            })
                                        }
                                    }
                                })
                            }
                        }
                    })
                }
                else {
                    res.json({
                        code: 9999,
                        message: 'No data'
                    });
                }
            }
        })
    }
    else {
        User.findOne({
            id: user_id,
        }).exec(async (err, data) => {
            if (err)
                res.json({
                    code: 9999,
                    message: err
                });
            else {
                if (data) {
                    let listing = await Friend.countDocuments({ user_id: user_id }).exec();
                    await User.findOne({
                        id: req.jwtDecoded.data.id
                    }).exec(async (err, data) => {
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
                                    data: {
                                        name: data.name,
                                        status: data.status,
                                        cover_photo: data.cover_photo,
                                        avatar: data.avatar,
                                        birthday: data.birthday,
                                        address: data.address,
                                        city: data.city,
                                        country: data.country,
                                        phone: data.phone,
                                        created_at: data.created_at,
                                        id: data.id,
                                        listing: listing,
                                        _id:data._id
                                    }
                                });
                            }
                        }
                    })
                }
                else {
                    res.json({
                        code: 9999,
                        message: 'No data'
                    });
                }
            }
        })
    }
}

exports.set_user_info = async (req, res) => {
    User.findOne({
        id: req.jwtDecoded.data.id
    }).exec(async (err, data) => {
        if (err)
            res.json({
                code: 9999,
                message: err
            });
        else {
            if (data) {
                let user = new User(data);
                user.name = req.data.name;
                user.address = req.data.address;
                user.country = req.data.country;
                user.birthday = req.data.birthday;

                await Post.update({ "author.id": req.jwtDecoded.data.id }, { "author.avatar": link, "author.name": req.data.name }, { multi: true });
                await Comment.update({ "author.id": req.jwtDecoded.data.id }, { "author.avatar": link, "author.name": req.data.name }, { multi: true });
                await Friend.update({ "info.user_id": req.jwtDecoded.data.id }, { "info.avatar": link, "info.name": req.data.name }, { multi: true });
                await FriendRequest.update({ "user_id": req.jwtDecoded.data.id }, { "user_send.avatar": link, "user_send.username": req.data.name }, { multi: true });
                await FriendRequest.update({ "info.user_id": req.jwtDecoded.data.id }, { "info.avatar": link, "info.username": req.data.name }, { multi: true });
                await Notify.update({ "user_info.user_id": req.jwtDecoded.data.id }, { "user_info.avatar": link, "user_info.username": req.data.name }, { multi: true });

                await user.save(async (err, data) => {
                    if (err)
                        res.json({
                            code: 9999,
                            message: err
                        });
                    else {
                        res.json({
                            code: 1000,
                            message: "OK",
                            data: data
                        });
                    }
                })
            }
        }
    })
}

exports.set_avatar = async (req, res) => {
    let user = await User.findOne({ id: req.jwtDecoded.data.id }).exec();

    await uploadAvatar(req, res, async (err) => {
        if (err) {
            return res.json({
                code: 9999,
                message: err
            });
        } else {
            let link = 'data/' + req.file.filename;
            await Post.update({ "author.id": req.jwtDecoded.data.id }, { "author.avatar": link }, { multi: true });
            await Comment.update({ "author.id": req.jwtDecoded.data.id }, { "author.avatar": link }, { multi: true });
            await Friend.update({ "info.user_id": req.jwtDecoded.data.id }, { "info.avatar": link }, { multi: true });
            await FriendRequest.update({ "user_id": req.jwtDecoded.data.id }, { "user_send.avatar": link }, { multi: true });
            await FriendRequest.update({ "info.user_id": req.jwtDecoded.data.id }, { "info.avatar": link }, { multi: true });
            await Notify.update({ "user_info.user_id": req.jwtDecoded.data.id }, { "user_info.avatar": link }, { multi: true });
            user.avatar = link;
            await user.save((err, data) => {
                if (err) {
                    return res.json({
                        code: 9999,
                        message: err
                    });
                } else {
                    res.json({
                        code: 1000,
                        message: "OK",
                        data: data
                    })
                }
            });
        }
    });
}

let storageCover = multer.diskStorage({
    destination: (req, file, callback) => { callback(null, './data'); },
    filename: (req, file, callback) => {
        callback(null, path.parse(file.originalname).name + '-' + Date.now() + path.extname(file.originalname));
    }
});
let uploadCover = multer({ storage: storageCover }).single('cover');
exports.set_cover = async (req, res) => {
    let user = await User.findOne({
        id: req.jwtDecoded.data.id,
    }).exec();

    await uploadCover(req, res, async (err) => {
        if (err) {
            return res.json({
                code: 9999,
                message: err
            });
        } else {
            let link = 'data/' + req.file.filename;
            user.cover_photo = link;
            await user.save((err, data) => {
                res.json({
                    code: 1000,
                    message: "OK",
                    data: user
                })
            });
        }
    });
}

exports.info_user = (req, res) => {
    let user_id = req.body.user_id;
    User.findById((user_id), (err, data) => {
        if (err)
            res.json({
                code: 9999,
                message: err.message
            });
        else {
            if (data) {
                let info_user = data;
                res.json({
                    code: 1000,
                    message: 'OK',
                    data: data
                })
            }
            else {
                res.json({
                    code: 9999,
                    message: 'No data'
                });
            }
        }
    })
}

exports.edit_address = (req, res) => {
    User.findOne({
        id: req.jwtDecoded.data.id
    }).exec(async (err, data) => {
        if (err)
            res.json({
                code: 9999,
                message: err
            });
        else {
            if (data) {
                let user = new User(data);
                user.address = req.body.address;
                await user.save(async (err, data) => {
                    if (err)
                        res.json({
                            code: 9999,
                            message: err
                        });
                    else {
                        res.json({
                            code: 1000,
                            message: "OK",
                            data: data
                        });
                    }
                })
            }
        }
    })
}

exports.edit_name = (req, res) => {
    User.findOne({
        id: req.jwtDecoded.data.id
    }).exec(async (err, data) => {
        if (err)
            res.json({
                code: 9999,
                message: err
            });
        else {
            if (data) {
                await Post.update({ "author.id": req.jwtDecoded.data.id }, { "author.name": req.body.name }, { multi: true });
                await Comment.update({ "author.id": req.jwtDecoded.data.id }, { "author.name": req.body.name }, { multi: true });
                await Friend.update({ "info.user_id": req.jwtDecoded.data.id }, { "info.name": req.body.name }, { multi: true });
                await FriendRequest.update({ "user_id": req.jwtDecoded.data.id }, { "user_send.username": req.body.name }, { multi: true });
                await FriendRequest.update({ "info.user_id": req.jwtDecoded.data.id }, { "info.username": req.body.name }, { multi: true });
                await Notify.update({ "user_info.user_id": req.jwtDecoded.data.id }, { "user_info.username": req.body.name }, { multi: true });
                let user = new User(data);
                user.name = req.body.name;
                await user.save(async (err, data) => {
                    if (err)
                        res.json({
                            code: 9999,
                            message: err
                        });
                    else {
                        res.json({
                            code: 1000,
                            message: "OK",
                            data: data
                        });
                    }
                })
            }
        }
    })
} 
