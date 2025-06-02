const User = require('../models/User');
const bcrypt = require('bcryptjs');

// Kullanıcıyı ID'ye göre bul
const getUserById = async (userId) => {
  const user = await User.findById(userId);
  if (!user) {
    throw new Error('Kullanıcı bulunamadı');
  }
  return user;
};

// Yeni kullanıcı oluştur (şifre hash'lenerek)
const createUser = async (userName, gender, password) => {
  const existingUser = await User.findOne({ userName });
  if (existingUser) {
    throw new Error('Bu kullanıcı adı zaten kayıtlı');
  }

  const salt = await bcrypt.genSalt(10);
  const hashedPassword = await bcrypt.hash(password, salt);

  const newUser = new User({
    userName,
    gender,
    passwordHash: hashedPassword,
  });

  await newUser.save();
  return newUser;
};

// Şifreyi doğrula
const validatePassword = async (user, plainPassword) => {
  return await bcrypt.compare(plainPassword, user.passwordHash);
};

module.exports = {
  getUserById,
  createUser,
  validatePassword,
};
