// Calling dependencies
const express = require('express');

const querystring = require('querystring');
const app = express();

const http = require('http');

const path = require('path');

const routes = express.Router();

const exphbs = require('express-handlebars');

const bodyParser = require('body-parser');

const favicon = require('serve-favicon');

const request = require('request');

const mailgun = require('mailgun-js');

const server = require('http').Server(app);

const popper = require('popper.js');

const io = require('socket.io')(server);

const jwt = require('jsonwebtoken');

const auth = require('./config.json');

const mongoose = require('mongoose');

// Calling Lyft API
const lyft = require('node-lyft');

// Creating server connection
const port = process.env.PORT || 3000;



// Connecting to the database

mongoose.Promise = global.Promise;


mongoose.connect('mongodb://localhost/augment', {useMongoClient: true});
console.log("You are connected to the Augment database...");

let db = mongoose.connection;
db.on('error', console.error.bind(console, 'connection error:'));
db.once('open', function () {

});

//Middleware
//app.use(cookieParser());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({extended: true}));
//app.use(cookieParser());
app.use(express.static('public'));
app.use(express.static(path.join(__dirname, 'public')));


//Setting up engine template
app.engine('handlebars', exphbs({defaultLayout: 'main'}));
app.set('view engine', 'handlebars');

// Defaul test to the server
app.all('/ping', function (req, res) {
    res.send(`I'm awake!`);
});

// INDEX
app.get('/', function (req, res) {
    res.render('index', {});
});

function post(path, params, method) {
    method = method || "post"; // Set method to post by default if not specified.

    // The rest of this code assumes you are not using a library.
    // It can be made less wordy if you use one.
    var form = document.createElement("form");
    form.setAttribute("method", method);
    form.setAttribute("action", path);

    for(var key in params) {
        if(params.hasOwnProperty(key)) {
            var hiddenField = document.createElement("input");
            hiddenField.setAttribute("type", "hidden");
            hiddenField.setAttribute("name", key);
            hiddenField.setAttribute("value", params[key]);

            form.appendChild(hiddenField);
        }
    }

    document.body.appendChild(form);
    form.submit();
}

app.post('/contact', (req, res) => {
    let data;
    let api_key = 'key-3273c083adaa1be404154301aede0594';
    let domain = 'sandbox1777a7c2af484cbc8b5c4a70966e242c.mailgun.org';
    let mailgun = require('mailgun-js')({apiKey: api_key, domain: domain});


    data = {
        from: 'Augment Team <postmaster@sandbox1777a7c2af484cbc8b5c4a70966e242c.mailgun.org>',
        to: 'team@augmentapp.io',
        subject: req.body.subject,
        text: 'From: ' + req.body.first_name + ' ' + req.body.last_name + ' (' + req.body.email + ')\n' + req.body.body
    };

    mailgun.messages().send(data, function (err, body) {
        if (err) {
            // res.render('index', {error: err});
            console.log("got an error: ", err);
        } else {
            res.redirect('index', {email: req.params.email});
            console.log(body);

        }
    });
});
// process.on('unhandledRejection', up => { throw up });

//LogOut
app.get('/logout', function (req, res, next) {
    res.clearCookie('nToken');
    res.redirect('/');
});

// LOGIN FORM
app.get('/admin/login', function (req, res, next) {
    res.render('login');
});

app.post('/login/now', function (req, res, next) {
    User.findOne({username: req.body.username}, "+password", function (err, user) {
        if (!user) {
            return res.status(401).send({message: 'Wrong username or password'})
        }
        user.comparePassword(req.body.password, function (err, isMatch) {
            if (!isMatch) {
                return res.status(401).send({message: 'Wrong username or password'});
            }

            var token = jwt.sign({_id: user._id}, process.env.SECRET, {expiresIn: "60 days"});
            res.cookie('nToken', token, {maxAge: 900000, httpOnly: true});

            res.redirect('index');
        });
    })
});

// SIGN UP ROUTE
require('./controller/userController')(app);


let sockets = {};

//Websocket *connection to the mobile app*
io.on('connection', function(socket) {
    console.log("User tried to connect to socket");

    if (typeof socket.request.headers.user_id == "undefined"){
        console.log("Socket was disconnect because of lack of headers");
        socket.disconnect();
        return;
    }

    sockets[socket.request.headers.user_id] = socket;
    console.log('User successfully connected to socket');

    socket.on('disconnect', (message) => {
        delete sockets[socket.request.headers.user_id];
        console.log('User has been disconnected');
    });

    socket.on('test', function(){
        console.log("TEST")
    })
});

// Webhook that Lyft server will hit
app.post('/webhook', function (req, res) {
    // Token Verification
    function createWebhookDigest(verToken, payloadBody) {
        var verificationToken = verToken.toString('ascii');
        var stringToSign = payloadBody.toString('utf8');
        var digest = crypto.createHmac('SHA256', verificationToken).update(new Buffer(req.body, 'utf8')).digest('base64');
        return digest;
    }

    let ride_info = req.body;
    // sockets[ride_info.user_id].emit('Ride information', ride_info);

    let id = ride_info.event.ride_id; // The ID of the ride

    let apiInstance = new lyft.UserApi();

    apiInstance.getRide(id).then((data) => {
        console.log('API called successfully. Returned data: ' + data);
    }, (error) => {
        console.error(error);
    });

    console.log('HEADERS ', req.headers);
    console.log('BODY ', req.body);

    res.send('Info recieved');
});


// Calling API for ride details

// let defaultClient = lyft.ApiClient.instance;
//
// // Configure OAuth2 access token for authorization: User Authentication
// let userAuth = defaultClient.authentications['user_id'];
// userAuth.accessToken = 'access_token';
//
//


app.listen(port);
console.log('You are connected to ' + port);

server.listen(3001, function(){
    console.log("SOCKET IS SKERTING")
});