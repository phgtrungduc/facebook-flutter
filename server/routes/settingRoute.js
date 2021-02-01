'use strict';

module.exports = (app) => {
    let settingCtr = require('../controllers/settingController');

    app.route('/get_push_settings').get(settingCtr.get_push_settings);
    app.route('/set_push_settings').post(settingCtr.set_push_settings);

    //chua lam
    // app.route('/check_new_version').get(settingCtr.check_new_version);
}
