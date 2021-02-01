'use strict';

module.exports = (app) => {
    let postCtr = require('../controllers/postController');

    app.route('/add_post').post(postCtr.add_post);
    app.route('/edit_post').post(postCtr.edit_post);
    app.route('/delete_post').post(postCtr.delete_post);
    app.route('/report_post').post(postCtr.report);
    app.route('/like').post(postCtr.like);
    app.route('/set_comment').post(postCtr.set_comment);
    
    app.route('/get_list_posts').get(postCtr.get_list_posts);
    app.route('/get_list_posts_is_liked').get(postCtr.get_list_posts_is_liked);

    app.route('/get_my_list_posts').get(postCtr.get_my_list_posts);
    app.route('/get_my_list_posts_is_liked').get(postCtr.get_my_list_posts_is_liked);

    app.route('/get_list_notify').get(postCtr.get_list_notify);
    app.route('/get_list_videos').get(postCtr.get_list_videos);

    app.route('/upload_data').post(postCtr.upload_data);
    app.route('/delete_notify').post(postCtr.delete_notify);
    app.route('/seen_notify').post(postCtr.seen_notify);
}

