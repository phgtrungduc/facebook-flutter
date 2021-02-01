const express = require("express");
const bodyParser = require('body-parser');
const cors = require('cors');
const app = express();
const server = require("http").Server(app);
const io = require("socket.io")(server);

app.use(cors());
app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());
server.listen(3002);

const Post = require('./models/post/postModel');
io.on("connection", (socket) => {
    socket.on("post");
    Post.find({}, (err, data) => {
        if (data) {
            for (let i = 1; i < data.length; i++) {
                socket.to(data[i].id).on("post", function (msg) {
                    io.emit("chat message", msg);
                });
            }
        } else {
            console.log(err);
        }
    });
});


console.log('Socket server started on: 3002');

// "start": "concurrently \"node server.js\" \"node socket.js\""
