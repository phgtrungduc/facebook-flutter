'use strict';

module.exports = (app) => {
    let searchCtr = require('../controllers/searchController');

    app.route('/search').get(searchCtr.search);
    app.route('/get_saved_search').get(searchCtr.get_saved_search);
    app.route('/del_saved_search').post(searchCtr.del_saved_search);
    
    app.route('/search_user').get(searchCtr.search_user);
    app.route('/search_post').get(searchCtr.search_post);
    app.route('/search_user_home').get(searchCtr.search_user_home);
    app.route('/search_post_home').get(searchCtr.search_post_home);
}