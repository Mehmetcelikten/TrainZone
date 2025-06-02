const User = require('../models/User');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

// Kullanıcı kaydı (register)
const registerUser = async (req, res) => {
  try {
    const { userName, gender, password, height } = req.body;

    if (!userName || !password || !gender || !height) {
      return res.status(400).json({ error: 'Tüm alanlar zorunludur.' });
    }

    const existing = await User.findOne({ userName });
    if (existing) {
      return res.status(409).json({ error: 'Bu isim zaten kullanımda.' });
    }

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    const newUser = new User({
      userName,
      gender,
      height,
      passwordHash: hashedPassword,
    });

    await newUser.save();

    const token = jwt.sign({ userId: newUser._id }, 'fitness_secret_key');
    res.status(201).json({ userId: newUser._id, token });
  } catch (err) {
    console.error('Kullanıcı kayıt hatası:', err);
    res.status(500).json({ error: 'Kullanıcı kaydı başarısız.' });
  }
};

// Kullanıcı girişi (login)
const loginUser = async (req, res) => {
  try {
    const { userName, password } = req.body;

    const user = await User.findOne({ userName });
    if (!user) {
      return res.status(404).json({ error: 'Kullanıcı bulunamadı.' });
    }

    const isMatch = await bcrypt.compare(password, user.passwordHash);
    if (!isMatch) {
      return res.status(401).json({ error: 'Geçersiz şifre.' });
    }

    const token = jwt.sign({ userId: user._id }, 'fitness_secret_key');
    res.status(200).json({ userId: user._id, token });
  } catch (err) {
    console.error('Giriş hatası:', err);
    res.status(500).json({ error: 'Giriş işlemi başarısız.' });
  }
};

module.exports = {
  registerUser,
  loginUser,
};
