let express = require('express');
const user = require('./../models/user');

module.exports = function (app) {

    app.get('/admin/signup', function (req, res) {
        // res.send('It`s working!');
        res.render('signup', {});
    });

    app.post('/signup/new', function (req, res) {
        User.create(req.body, function (err, user) {
            console.log(req.body);
            res.render('index', {user: user})
        });
    });
};


