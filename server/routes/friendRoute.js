'use strict';

module.exports = (app) => {
    let friendCtr = require('../controllers/friendController');

    app.route('/get_requested_friends').get(friendCtr.get_requested_friends);
    app.route('/get_user_friends').get(friendCtr.get_user_friends);
    
    app.route('/set_accept_friend').post(friendCtr.set_accept_friend);
    app.route('/set_request_friend').post(friendCtr.set_request_friend);
    app.route('/get_list_blocks').get(friendCtr.get_list_blocks);
    
    app.route('/set_block').post(friendCtr.set_block);
    app.route('/set_unblock').post(friendCtr.set_unblock);

    app.route('/get_list_suggested_friends').get(friendCtr.get_list_suggested_friends);
    app.route('/unfriend').get(friendCtr.unfriend);
    app.route('/del_request_friend').get(friendCtr.del_request_friend);
}