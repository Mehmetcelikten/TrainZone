const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

// 🔹 Klasik favori listeler (birden fazla egzersiz içeren yapı)
const customFavoriteListSchema = new mongoose.Schema({
  _id: {
    type: mongoose.Schema.Types.ObjectId,
    default: () => new mongoose.Types.ObjectId()
  },
  name: {
    type: String,
    required: true,
    trim: true,
  },
  color: {
    type: String,
    default: '#FFFFFF',
  },
  exercises: [
    {
      exerciseId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Exercise',
        required: true
      }
    }
  ]
}, { _id: false });

// 🔹 BalancedList favorileri (hazır listeler için)
const balancedFavoriteRefSchema = new mongoose.Schema({
  listId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'BalancedList',
    required: true,
  },
}, { _id: false });

// 🔹 Kullanıcı şeması
const userSchema = new mongoose.Schema({
  userName: {
    type: String,
    required: true,
    unique: true,
    trim: true,
  },
  email: {
    type: String,
    unique: true,
    sparse: true,
    trim: true,
    lowercase: true,
  },
  gender: {
    type: String,
    enum: ['Erkek', 'Kadın', 'Diğer'],
    required: true,
  },
  height: {
    type: Number,
    required: true,
    min: 100,
    max: 250,
  },
  passwordHash: {
    type: String,
    required: true,
  },

  // ✅ Klasik favori listeler (manuel oluşturulanlar)
  favoriteLists: {
    type: [customFavoriteListSchema],
    default: [],
  },

  // ✅ Hazır favori Balanced listeler
  favoriteBalanced: {
    type: [balancedFavoriteRefSchema],
    default: [],
  }

}, { timestamps: true });

// 🔐 Şifreyi kaydetmeden önce hashle
userSchema.pre('save', async function (next) {
  if (!this.isModified('passwordHash')) return next();
  try {
    const salt = await bcrypt.genSalt(10);
    this.passwordHash = await bcrypt.hash(this.passwordHash, salt);
    next();
  } catch (err) {
    console.error('Şifre hashleme hatası:', err);
    next(err);
  }
});

// ✅ Şifre doğrulama fonksiyonu
userSchema.methods.isValidPassword = async function (password) {
  try {
    return await bcrypt.compare(password, this.passwordHash);
  } catch (err) {
    console.error('Şifre doğrulama hatası:', err);
    throw err;
  }
};

module.exports = mongoose.model('User', userSchema);
