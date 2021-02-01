'use strict';
let multer = require('multer');
let path = require('path');
let io = require("socket.io")
let fs = require('fs');
var buffer = require('buffer/').Buffer;

let Post = require('../models/post/postModel');
let Report = require('../models/report/reportModel');
let Comment = require('../models/comment/commentModel');
let Like = require('../models/like/likeModel');
let User = require('../models/user/userModel');
let Friend = require('../models/friend/friendModel');
let Notify = require('../models/notify/notifyModel');
const { findOne } = require('../models/post/postModel');

const storage = multer.diskStorage({
    destination: (req, file, callback) => { callback(null, './data'); },
    filename: (req, file, callback) => {
        callback(null, path.parse(file.originalname).name + '-' + Date.now() + path.extname(file.originalname));
    }
});
const upload = multer({ storage: storage }).array('data', 5);

exports.add_post = async (req, res) => {
    let user = await User.findOne({
        id: req.jwtDecoded.data.id,
    }).exec();
    var images = [];
    var videos = [];
    await upload(req, res, async (err) => {
        if (err) {
            return res.json({
                code: 9999,
                message: err
            });
        } else {
            if (req.body.type == "image") {
                req.files.forEach((item) => {
                    let link = 'data/' + item.filename;
                    images.push(link);
                });
            } else if (req.body.type == "video") {
                let tmp = req.files[0].filename.split('.');
                let link = 'data/';
                for (let i = 0; i < tmp.length - 1; i++) {
                    link += tmp[i];
                }
                link += '.mp4';
                videos.push(link);
            }
            let post = new Post({
                described: req.body.described,
                author: user,
                images: images,
                video: videos,
                status: req.body.status || null
            });

            await post.save((err, data) => {
                if (err) {
                    res.json({
                        code: 9999,
                        message: err
                    });
                }
                else {
                    res.json({
                        code: 1000,
                        message: "OK",
                        data: {
                            id: data.id
                        },
                    });
                }
            });
        }
    });
}

exports.get_post = (req, res) => {
    Post.findOne({
        id: req.query.id,
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
                    message: "Post is not existed!"
                });
            }
        }
    });
}

exports.edit_post = async (req, res) => {
    await Post.findOne({ "author.id": req.jwtDecoded.data.id, "id": req.body.post_id }, async (err, data) => {
        if (err) {
            res.json({
                code: 9999,
                message: err
            })
        }
        else {
            let post = new Post(data);
            if (req.body.described !== undefined)
                post.described = req.body.described;
            if (req.body.status !== undefined)
                post.status = req.body.status;
            if (req.body.images !== undefined)
                post.images = req.body.images;

            await post.save((err, data) => {
                if (err) {
                    res.json({
                        code: 9999,
                        message: err
                    });
                }
                else {
                    res.json({
                        code: 1000,
                        message: "OK",
                        data: {
                            id: data.id
                        },
                    });
                }
            });
        }
    });
}

exports.delete_post = (req, res) => {
    let conditions = {
        "id": req.body.id,
        "author.id": req.jwtDecoded.data.id,
    };
    Post.deleteOne(conditions, function (err, data) {
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

exports.report = async (req, res) => {
    await Post.findOne({ "id": req.body.id }, async (err, data) => {
        if (err) {
            res.json({
                code: 9999,
                message: err
            })
        }
        else {
            return res.json({
                code: 1000,
                message: 'OK'
            });
        }
    });
    // let post = await Post.findOne({ "id": req.body.id }).exec();
    // let report = {
    //     post_id: req.body.id,
    //     author_id: req.jwtDecoded.data.id,
    //     detail: req.body.detail,
    //     subject: req.body.subject
    // }
    // if (post !== null) {
    //     Report.findOneAndUpdate({ "id": req.body.id }, report, { upsert: true }, (err, data) => {
    //         if (err){
    //             console.log(err);
    //             return res.json({
    //                 code: 9999,
    //                 message: err
    //             });
    //         }
                
    //         else
    //             return res.json({
    //                 code: 1000,
    //                 message: 'OK'
    //             });
    //     })
    // }
    // else {
    //     return res.json({
    //         code: 9992,
    //         message: 'Post is not existed'
    //     });
    // }
}

exports.like = async (req, res) => {
    let id = req.body.id;
    let user_id = req.jwtDecoded.data.id;

    await Like.findOne({ id: id, user_id: user_id }, async (err, data) => {
        if (err)
            res.json({
                code: 9999,
                message: err
            });
        else {
            if (data === null) {
                await Post.findOne({ id: id }, async (err, data) => {
                    if (err) {
                        res.json({
                            code: 9999,
                            message: err
                        });
                    }
                    else {
                        if (data.author.id === user_id) {
                            data.is_liked = true;
                        }
                        else {
                            let user = await User.findOne({ id: req.jwtDecoded.data.id }).exec();
                            let notify = new Notify({
                                info_user: {
                                    user_id: user.id,
                                    username: user.name,
                                    avatar: user.avatar,
                                },
                                user_id: data.author.id,
                                post_id: id,
                                type: 'like'
                            })
                            await notify.save();
                        }

                        data.like += 1;
                        let updated_post = new Post(data);

                        await updated_post.save(async (err) => {
                            if (err) {
                                res.json({
                                    code: 9999,
                                    message: err
                                });
                            }
                            else {
                                let like = new Like({
                                    user_id: req.jwtDecoded.data.id,
                                    id: id
                                });
                                like.save(async (err) => {
                                    if (err) {
                                        res.json({
                                            code: 9999,
                                            message: err
                                        });
                                    }
                                    else {
                                        res.json({
                                            code: 1000,
                                            message: "OK",
                                            count: data.like
                                        });
                                    }
                                });
                            }
                        })
                    }
                })
            }
            else {
                await Post.findOne({ id: id }, (err, data) => {
                    if (err)
                        res.json({
                            code: 9999,
                            message: err
                        });
                    else {
                        if (data.author.id === user_id) {
                            data.is_liked = false;
                        }
                        data.like -= 1;
                        let updated_post = new Post(data);
                        updated_post.save(async (err) => {
                            if (err) {
                                res.json({
                                    code: 9999,
                                    message: err
                                });
                            }
                            else {
                                await Like.deleteOne({ id: id }, async (err) => {
                                    if (err) {
                                        res.json({
                                            code: 9999,
                                            message: err
                                        });
                                    }
                                    else {
                                        res.json({
                                            code: 1000,
                                            message: "OK",
                                            count: data.like
                                        });
                                    }
                                });
                            }
                        })
                    }
                })
            }
        }
    })
}

exports.get_list_posts_is_liked = async (req, res) => {
    let count = parseInt(req.query.count);
    let index = parseInt(req.query.index);
    let user_id = req.jwtDecoded.data.id;
    let list_user_id = [];
    let list_friends = await Friend.find({ user_id: user_id });
    if (list_friends) {
        for (let i = 0; i < list_friends.length; i++) {
            list_user_id.push(list_friends[i].info.user_id)
        }
    }
    list_user_id.push(user_id);

    await Post.find({ "author.id": { $in: list_user_id } })
        .sort({ created_at: -1 })
        .limit(count)
        .skip(index)
        .then(function (data) {
            var jobQueries = [];
            data.forEach(function (u) {
                jobQueries.push(Like.find({ "user_id": req.jwtDecoded.data.id, "id": u.id }));
            });
            return Promise.all(jobQueries);
        }).then(function (listOfJobs) {
            for (let i = 0; i < listOfJobs.length; i++) {
                if (listOfJobs[i].length === 0)
                    listOfJobs[i] = false;
                else
                    listOfJobs[i] = true;
            }
            return res.json({
                code: 1000,
                message: 'OK',
                is_liked: listOfJobs
            });
        }).catch(function (err) {
            res.json({
                code: 9999,
                message: err
            });
        });
}

exports.get_list_posts = async (req, res) => {
    let count = parseInt(req.query.count);
    let index = parseInt(req.query.index);
    let user_id = req.jwtDecoded.data.id;
    let list_user_id = [];
    let list_friends = await Friend.find({ user_id: user_id });

    if (list_friends) {
        for (let i = 0; i < list_friends.length; i++) {
            list_user_id.push(list_friends[i].info.user_id)
        }
    }

    list_user_id.push(user_id)

    await Post.find({ "author.id": { $in: list_user_id } })
        .sort({ created_at: -1 })
        .limit(count)
        .skip(index)
        .exec(function (err, data) {
            if (err)
                return res.json({
                    code: 9999,
                    message: err
                });
            else {
                if (data) {
                    debugger
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

exports.get_my_list_posts_is_liked = async (req, res) => {
    let count = parseInt(req.query.count);
    let index = parseInt(req.query.index);
    let user_id = req.jwtDecoded.data.id;

    await Post.find({ "author.id": user_id })
        .sort({ created_at: -1 })
        .limit(count)
        .skip(index)
        .then(function (data) {
            var jobQueries = [];
            data.forEach(function (u) {
                jobQueries.push(Like.find({ "user_id": req.jwtDecoded.data.id, "id": u.id }));
            });
            return Promise.all(jobQueries);
        }).then(function (listOfJobs) {
            for (let i = 0; i < listOfJobs.length; i++) {
                if (listOfJobs[i].length === 0)
                    listOfJobs[i] = false;
                else
                    listOfJobs[i] = true;
            }
            return res.json({
                code: 1000,
                message: 'OK',
                is_liked: listOfJobs
            });
        }).catch(function (err) {
            res.json({
                code: 9999,
                message: err
            });
        });
}

exports.get_my_list_posts = async (req, res) => {
    let count = parseInt(req.query.count);
    let index = parseInt(req.query.index);
    let user_id = req.query.user_id == null ? req.jwtDecoded.data.id : parseInt(req.query.user_id);
    // let user_id = req.jwtDecoded.data.id;

    await Post.find({ "author.id": user_id })
        .sort({ created_at: -1 })
        .limit(count)
        .skip(index)
        .exec(function (err, data) {
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

exports.check_new_item = (req, res) => {
}

exports.get_comment = (req, res) => {
    let count = parseInt(req.query.count);
    let index = parseInt(req.query.index);
    let id = parseInt(req.query.id);

    Comment.find({ id: id })
        .sort({ created_at: 1 })
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

exports.set_comment = async (req, res) => {
    let cmt = req.body.comment;
    let count = req.body.count;
    let index = req.body.index;
    let id = req.body.id;

    let user = await User.findOne({
        id: req.jwtDecoded.data.id,
    }).exec();

    let post = await Post.findOne({
        id: id,
    }).exec();

    post.comment += 1;
    await post.save();

    let comment = new Comment({
        comment: cmt,
        id: id,
        author: user,
    });

    comment.save(async (err, data) => {
        if (err)
            res.json({
                code: 9999,
                message: err
            });
        else {
            let notify = new Notify({
                info_user: {
                    user_id: req.jwtDecoded.data.id,
                    username: user.name,
                    avatar: user.avatar,
                },
                post_id: id,
                user_id: post.author.id,
                type: 'comment'
            })
            await notify.save();
            await Comment.find({ id: id })
                .sort({ created_at: -1 })
                .limit(count)
                .skip(index)
                .exec((err, d) => {
                    if (err)
                        res.json({
                            code: 9999,
                            message: err
                        });
                    else {
                        if (d) {
                            res.json({
                                code: 1000,
                                message: 'OK',
                                data: d
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
    });
}

exports.get_id_post_commented = (req, res) => {
    let user_id = req.jwtDecoded.data.id;
    let list_id = [];
    Comment.find({ "author.id": user_id }, (err, data) => {
        if (err) {
            res.json({
                code: 9999,
                message: err
            });
        }
        else {
            if (data) {
                for (let i = 0; i < data.length; i++) {
                    if (list_id.length === 0) {
                        list_id.push(data[i].id);
                    }
                    for (let j = 0; j < list_id.length; j++) {
                        if (list_id[j] !== data[i].id) {
                            list_id.push(data[i].id);
                        }
                    }
                }
                res.json({
                    code: 1000,
                    message: 'OK',
                    data: list_id
                })
            }
            else {
                res.json({
                    code: 1000,
                    message: 'No data'
                });
            }
        }
    })
}

exports.get_id_user_in_post = (req, res) => {
    let id = parseInt(req.query.id);
    Comment.find({ "id": id }, (err, data) => {
        if (err) {
            res.json({
                code: 9999,
                message: err
            });
        }
        else {
            if (data) {
                res.json({
                    code: 1000,
                    message: 'OK',
                    data: data
                })
            }
            else {
                res.json({
                    code: 1000,
                    message: 'No data'
                });
            }
        }
    })
}

exports.get_all_id_post = (req, res) => {
    Post.find({}, (err, data) => {
        if (err) {
            res.json({
                code: 9999,
                message: err
            });
        }
        else {
            if (data) {
                let list_id = []
                for (let i = 1; i < data.length; i++) {
                    list_id.push(data[i].id)
                }
                res.json({
                    code: 1000,
                    message: 'OK',
                    data: list_id
                })
            }
            else {
                res.json({
                    code: 1000,
                    message: 'No data'
                });
            }
        }
    })
}

exports.get_list_notify = (req, res) => {
    let count = parseInt(req.query.count);
    let index = parseInt(req.query.index);
    let user_id = req.jwtDecoded.data.id;

    Notify.find({ "user_id": user_id })
        .sort({ created_at: -1 })
        .limit(count)
        .skip(index)
        .exec(function (err, data) {
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

exports.get_list_videos = (req, res) => {
    let index = parseInt(req.query.index);
    let count = parseInt(req.query.count);
    let user_id = req.jwtDecoded.data.id;

    Post.find({ "video": { $exists: true, $not: { $size: 0 } } })
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

let storageData = multer.diskStorage({
    destination: (req, file, callback) => { callback(null, './data'); },
    filename: (req, file, callback) => {
        callback(null, path.parse(file.originalname).name + '-' + Date.now() + path.extname(file.originalname));
    }
});
let uploadData = multer({ storage: storageData }).single('data');

exports.upload_data = (req, res) => {
    uploadData(req, res, async (err) => {
        if (err) {
            return res.json({
                code: 9999,
                message: err
            });
        } else {
            let link = 'data/' + req.file.filename;
            res.json({
                code: 1000,
                message: "OK",
                link: link
            })
        }
    });
}

exports.delete_notify = (req, res) => {
    let conditions = {
        "notify_id": req.body.id,
        "user_id": req.jwtDecoded.data.id,
    };
    Notify.deleteOne(conditions, function (err, data) {
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

exports.seen_notify = async (req, res) => {
    let seen = req.body.seen;
    let notify_id = req.body.notify_id;

    let notify = await Notify.findOne({ "user_id": req.jwtDecoded.data.id, "notify_id": notify_id }).exec();
    notify.seen = seen;
    notify.save((err, data) => {
        if (err)
            return res.json({
                code: 9999,
                message: err
            });
        else
            return res.json({
                code: 1000,
                message: 'OK'
            });
    })
}