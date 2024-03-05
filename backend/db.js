const mysql = require('mysql2');
require('dotenv').config(); 

const connection = mysql.createConnection({
  host: process.env.DB_HOST,
  user: process.env.DB_USER ,
  password: process.env.DB_PASSWORD ,
  database: process.env.DB_DATABASE,
  port: 3306
});

console.log('dbg '+process.env.DB_HOST);

connection.connect((err) => {
  if (err) {
    console.error('Error connecting to database:', err);
    process.exit(1);
  } else {
    console.log('Connected to database');
  }
});

module.exports = connection;
