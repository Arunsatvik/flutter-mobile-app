const express = require('express');
const router = express.Router();
const bcrypt = require('bcrypt');
const connection = require('../db.js'); // Import the database connection

router.post('/login', async (req, res) => {
  if (connection){
    const { email, password,disclaimerChecked, latitude, longitude } = req.body;
    console.log(req.body);
    const truncatedLatitude = String(latitude).split('.')[0] + '.' + String(latitude).split('.')[1].substring(0, 3);
    const truncatedLongitude = String(longitude).split('.')[0] + '.' + String(longitude).split('.')[1].substring(0, 3);
    connection.query(
      'SELECT * FROM students_profile WHERE email = ?',
      [email],
      async (error, results) => {
        if (error) {
          console.error('Error querying user:', error);
          res.status(500).json({ error: 'Internal Server Error' });
        } else {
          if (results.length > 0) {
            const user = results[0];

            const passwordMatch = password === user.Password;
            const latitudeMatch = truncatedLatitude === user.Latitude;
            const longitudeMatch = truncatedLongitude === user.Longitude;
            if (passwordMatch) {
              // if(latitudeMatch && longitudeMatch){
                // res.status(200).json({ message: 'Login successful' });
                connection.query(
                  'INSERT INTO checked_in (student_id, Email, Checkout_DateTime, stayForDinner, disclaimerChecked) VALUES (?, ?, NULL, Null, ?)',
                  [user.student_id, email, disclaimerChecked],
                  (checkInInsertError) => {
                    if (checkInInsertError) {
                      console.error('Error checking in student:', checkInInsertError);
                      res.status(500).json({ error: 'Internal Server Error' });
                    } else {
                      res.status(200).json({ message: 'Student checked in successfully' });
                    }
                  }
                );
              // }
              // else{
              //   res.status(401).json({ error: 'Please Try to login at the premisis' });
              // }
            } else {
              res.status(402).json({ error: 'Password does not match.' });
            }
          } else {
            res.status(404).json({ error: 'User not found' });
          }
        }
      }
    );
    
  }
  else{
    res.status(502).json({ error: '502: Database connection error' });
  }
});

module.exports = router;
