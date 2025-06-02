const express = require('express');
const router = express.Router();
const {
  getAllExercises,
  getPopularExercises,
  getExercisesByNames,
  updateExerciseRating,
  getExerciseById, // ✅ Detay sayfa için egzersizi ID ile çekme eklendi
} = require('../controllers/exerciseController');

// 🔁 Tüm egzersizleri getir (filtreli)
router.get('/', getAllExercises);

// 🌟 Popüler egzersizleri getir
router.get('/popular', getPopularExercises);

// 🧾 İsim listesine göre egzersizleri getir
router.post('/by-names', getExercisesByNames);

// ⭐ Rating güncelleme
router.patch('/:id/rating', updateExerciseRating);

// 🔍 Belirli bir egzersizi ID ile getir (detay sayfa için)
router.get('/:id', getExerciseById); // ✅ yeni

module.exports = router;
