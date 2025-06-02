const mongoose = require('mongoose');
const Exercise = require('../models/Exercise');

// Tüm egzersizleri filtreli getir
const getAllExercises = async (req, res) => {
  try {
    const query = {};

    if (req.query.muscle) {
      query.muscle = req.query.muscle;
    }
    if (req.query.level) {
      query.level = req.query.level;
    }
    if (req.query.equipment) {
      query.equipment = req.query.equipment;
    }

    const exercises = await Exercise.find(query);
    res.json(exercises);
  } catch (err) {
    res.status(500).json({ error: 'Egzersizler alınırken hata oluştu' });
  }
};

// ✅ Popüler egzersizleri getir
const getPopularExercises = async (req, res) => {
  try {
    const exercises = await Exercise.find().sort({ rating: -1 }).limit(10);
    res.json(exercises);
  } catch (err) {
    res.status(500).json({ error: 'Popüler egzersizler alınamadı' });
  }
};

// ✅ İsim listesine göre egzersizleri getir
const getExercisesByNames = async (req, res) => {
  try {
    const { names } = req.body;
    const exercises = await Exercise.find({ name: { $in: names } });
    res.json(exercises);
  } catch (err) {
    res.status(500).json({ error: 'İsimlere göre egzersizler alınamadı' });
  }
};

// ⭐ Egzersize rating güncelle (kullanıcı başına tek oy + yuvarlama)
const updateExerciseRating = async (req, res) => {
  try {
    const { id } = req.params;
    const { rating, userId } = req.body;

    if (!userId || typeof rating !== 'number') {
      return res.status(400).json({ error: 'Geçersiz veri.' });
    }

    const allowedRatings = [1, 1.5, 2, 2.5, 3, 3.5, 4, 4.5, 5];
    if (!allowedRatings.includes(rating)) {
      return res.status(400).json({ error: 'Sadece 0.5 aralıklı değerler geçerlidir.' });
    }

    const exercise = await Exercise.findById(id);
    if (!exercise) {
      return res.status(404).json({ error: 'Egzersiz bulunamadı.' });
    }

    const userObjectId = new mongoose.Types.ObjectId(userId);
    const existingIndex = exercise.ratings.findIndex(r => r.userId.equals(userObjectId));

    if (existingIndex !== -1) {
      exercise.ratings[existingIndex].value = rating;
    } else {
      exercise.ratings.push({ userId: userObjectId, value: rating });
    }

    const total = exercise.ratings.reduce((sum, r) => sum + r.value, 0);
    const average = total / exercise.ratings.length;
    const rounded = Math.round(average * 2) / 2;

    exercise.rating = rounded;

    await exercise.save();
    res.json({ success: true, newRating: rounded });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Rating güncellenemedi' });
  }
};

// ✅ Detay sayfa için egzersizi ID ile getir
const getExerciseById = async (req, res) => {
  try {
    const exercise = await Exercise.findById(req.params.id);
    if (!exercise) {
      return res.status(404).json({ error: 'Egzersiz bulunamadı.' });
    }
    res.status(200).json(exercise);
  } catch (err) {
    res.status(500).json({ error: 'Egzersiz alınamadı.' });
  }
};

module.exports = {
  getAllExercises,
  getPopularExercises,
  getExercisesByNames,
  updateExerciseRating,
  getExerciseById, // ✅ eklendi
};
