const express = require('express');
const cors = require('cors');
const authRoutes = require('./routes/auth');
const signupRoutes = require('./routes/signup');
// const checkInRoutes = require('./routes/checkin');
// const checkOutRoutes = require('./routes/checkout');

const app = express();
const port = 3001;

app.use(cors());
app.use(express.json());

app.use('/auth', authRoutes);
app.use('/signup', signupRoutes);
// app.use('/checkin', checkInRoutes);
// app.use('/checkout', checkOutRoutes);

app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});
