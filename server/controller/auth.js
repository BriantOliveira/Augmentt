module.exports = function (app) {


// AUTH

    const jtw = require('jsonwebtoken');

// Import User model
    const User = require('./../models/user');

    module.exports = (app) => {
        //Secret environment
        process.env.SECRET = 'ThisIsASecret';

        // User Route

        app.post('/new-user', function (req, res, next) {

            var user = new User(req.body);

            user.save(function (err) {
                console.log("Save user");
                // ERROR 404
                if (err) {
                    return res.status(400).send({err: err})
                }

                console.log(user.username);

                //Jwt and setting token
                var token = jwt.sign({_id: user._id}, process.env.SECRET, {expireIn: "30 days"});
                res.cookie('nToken', token, {maxAge: 100, httpOnly: true});
            });
        });
    };

};