const express = require('express');
const fs = require('fs');
const app = express();
const port = 3000;

app.get('/', (req, res) => {
    fs.readFile('index.html', 'utf8' , (err, data) => {
        if (err) {
            console.error(err);
            return res.status(500).send('An error occurred while trying to load the page');
        }
        res.send(data);
    });
});

app.listen(port, () => {
    console.log(`Server running at http://localhost:${port}/`);
});