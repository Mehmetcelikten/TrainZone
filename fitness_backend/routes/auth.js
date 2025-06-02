const express = require('express');
const router = express.Router();
const { registerUser, loginUser } = require('../controllers/authcontroller'); // ✅ dosya adında 'C' büyük mü küçük mü? dikkat et!

// ✅ Kullanıcı kayıt (POST /api/auth/register)
router.post('/register', registerUser);

// ✅ Kullanıcı giriş (POST /api/auth/login)
router.post('/login', loginUser);

module.exports = router;
