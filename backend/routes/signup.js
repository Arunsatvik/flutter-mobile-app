const express = require('express');
const router = express.Router();
const connection = require('../db.js'); // Import the database connection


//check if email exists
router.post('/userexists', (req, res) => {
  const {
    Email,
    Password,
    Zip_code,
    phonenumber,
    disclaimerChecked
  } = req.body;
  console.log(req.body)

  // Check if the student profile already exists
  connection.query(
    'SELECT * FROM students_profile WHERE Email = ?',
    [Email],

    (error, results) => {
      if (error) {
        console.error('Error checking student profile:', error);
        res.status(500).json({ error: 'Internal Server Error' });
      } else {
        if (results.length > 0) {
          // Student profile already exists
          const user = results[0];

          if(user.Password != null){
            res.status(409).json({ success: 'Student already Signed up' });
          }
          else{
              const zipcodeMatch = Zip_code === user.Zip_code;
              const phonenumberMatch = phonenumber === user.phonenumber;
    
              if (zipcodeMatch && phonenumberMatch) {
                const student_id = user.student_id;
    
                // Update the password attribute in students_profile table.
                connection.query(
                    'UPDATE students_profile SET Password = ? WHERE student_id = ?',
                    [Password, student_id],
                    (updateError, updateResults) => {
                      if (updateError) {
                        console.error('Error updating password:', updateError);
                        res.status(500).json({ error: 'Internal Server Error' });
                      } else {
                        res.status(201).json({ success: 'Check-in successful!' });
                      }
                    }
                  );
              } else {
                let errorMessage = '';
                if (!zipcodeMatch) {
                  errorMessage += 'Zip code does not match. ';
                }
            
                if (!phonenumberMatch) {
                  errorMessage += 'Phone number does not match. ';
                }
                res.status(401).json({ error: errorMessage.trim() });
            }
          }
        } else {
          // Student profile not found, create a new one
          res.status(404).json({ error: 'Student Profile Not found' });
        }
      }
    }
  );
});



// API endpoint for student profile creation or update
router.post('/createStudentProfile', (req, res) => {
  const {
    student_First_Name,
    student_Last_Name,
    Age,
    Email,
    Password,
    Alternate_Email,
    Address_line_1,
    Address_line_2,
    Zip_code,
    parent_guardian,
    secondary_parent_guardian,
    phonenumber,
    sign_up_date = new Date().toISOString().split('T')[0],
    expire_date = null,
  } = req.body;
  console.log(req.body)

  connection.query(
    'INSERT INTO students_profile SET ?',
    {
      student_First_Name,
      student_Last_Name,
      Age,
      Email,
      Password,
      Alternate_Email,
      Address_line_1,
      Address_line_2,
      Zip_code,
      parent_guardian,
      secondary_parent_guardian,
      phonenumber,
      sign_up_date,
      expire_date,
       // Set to current timestamp
    },
    (error) => {
      if (error) {
        console.error('Error creating student profile:', error);
        res.status(500).json({ error: 'Internal Server Error' });
      } else {
        res.status(201).json({ message: 'Student profile created successfully' });
      }
    }
  );
});
  
  // API endpoint for student check-in
  router.post('/checkIn', (req, res) => {
    const { Email, stayForDinner, disclaimerChecked} = req.body;
    console.log(req.body)

  
    // Retrieve student_id from students_profile table based on the provided Email
    connection.query(
      'SELECT student_id FROM students_profile WHERE Email = ?',
      [Email],
      (error, results) => {
        
        if (error) {
          console.error('Error retrieving student_id:', error);
          res.status(500).json({ error: 'Internal Server Error' });
        } else {
          if (results.length > 0) {
            const student_id = results[0].student_id;
  
            // Add check-in details to checked_in table
            connection.query(
              'INSERT INTO checked_in (student_id, Email, Checkout_DateTime, stayForDinner, disclaimerChecked) VALUES (?, ?, NULL, ?, ?)',
              [student_id, Email, stayForDinner, disclaimerChecked],
              (error) => {
                if (error) {
                  console.error('Error checking in student:', error);
                  res.status(500).json({ error: 'Internal Server Error' });
                } else {
                  res.status(201).json({ message: 'Student checked in successfully' });
                }
              }
            );
          } else {
            res.status(404).json({ error: 'Student not found with the provided Email' });
          }
        }
      }
    );
  });
  
  
  module.exports = router;