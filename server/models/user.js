// Calling Dependencies
let mongoose = require('mongoose');

// Creating a schema model

const { Schema } = mongoose;

const UserSchema = new Schema({
    user_id  :{ String },
    first_name  :{ String },
    last_name   :{ String },
    has_taken_a_ride    :{ Boolean }

});

module.exports = mongoose.model('User', UserSchema);
