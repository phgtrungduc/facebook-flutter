'use strict';

module.exports = (app) => {
    let authCtr = require('../controllers/authController');
    let userCtr = require('../controllers/userController');
    let authMid = require('../middleware/auth');
    let postCtr = require('../controllers/postController');

    app.route('/info_user').post(userCtr.info_user);
    app.route('/login').post(authCtr.login);
    app.route('/signup').post(authCtr.signup);

    app.route('/get_comment').get(postCtr.get_comment);
    app.route('/get_post').get(postCtr.get_post);
    app.route('/get_id_post_commented').get(postCtr.get_id_post_commented);
    app.route('/get_id_user_in_post').get(postCtr.get_id_user_in_post);
    app.route('/get_all_id_post').get(postCtr.get_all_id_post);

    app.use(authMid.isAuth);
    
    app.route('/refresh_token').post(authCtr.refreshToken);
    app.route('/logout').post(authCtr.logout);
    app.route('/get_user_info').get(userCtr.get_user_info);
    app.route('/change_info_after_signup').post(userCtr.change_info_after_signup);
    app.route('/change_password').post(userCtr.change_password);
    app.route('/set_user_info').post(userCtr.set_user_info);
    
    app.route('/set_avatar').post(userCtr.set_avatar);
    app.route('/set_cover').post(userCtr.set_cover);
    app.route('/edit_name').post(userCtr.edit_name);
    app.route('/edit_address').post(userCtr.edit_address);
}
