const User = require('../models/User');
const Exercise = require('../models/Exercise');
const mongoose = require('mongoose');

// ✅ Favori liste oluştur
const createFavoriteList = async (req, res) => {
  try {
    const { userId } = req.params;
    const { name } = req.body;

    if (!name || name.trim() === '') {
      return res.status(400).json({ error: 'Liste adı zorunludur' });
    }

    const user = await User.findById(userId);
    if (!user) return res.status(404).json({ error: 'Kullanıcı bulunamadı' });

    const newList = {
      _id: new mongoose.Types.ObjectId(),
      name: name.trim(),
      exercises: [],
    };

    user.favoriteLists.push(newList);
    await user.save();

    res.status(201).json({ createdList: newList });
  } catch (err) {
    console.error('❌ Liste oluşturma hatası:', err);
    res.status(500).json({ error: 'Favori listesi oluşturulamadı' });
  }
};

// ✅ Tüm favori listeleri getir (egzersizleri populate eder)
const getUserFavoriteLists = async (req, res) => {
  const { userId } = req.params;

  try {
    const user = await User.findById(userId);
    if (!user) return res.status(404).json({ error: 'Kullanıcı bulunamadı.' });

    const populatedLists = await Promise.all(
      user.favoriteLists.map(async (list) => {
        const exerciseIds = list.exercises.map(e => e.exerciseId);
        const exercises = await Exercise.find({ _id: { $in: exerciseIds } });

        return {
          _id: list._id,
          name: list.name,
          color: list.color || '#FFFFFF',
          exercises: exercises.map(e => ({ exerciseId: e })), // ✅ burada doğru
        };
      })
    );

    // ✅ Log önce
    console.log('🧪 Dönen veri örneği:', JSON.stringify(populatedLists[0], null, 2));

    // ✅ Sonra yanıt
    res.status(200).json(populatedLists);
  } catch (err) {
    console.error('❌ Favori listeleri alınamadı:', err.message);
    res.status(500).json({ error: 'Sistem hatası.' });
  }
};

const getFavoriteListDetail = async (req, res) => {
  const { userId, listId } = req.params;

  try {
    const user = await User.findById(userId);
    if (!user) return res.status(404).json({ error: 'Kullanıcı bulunamadı.' });

    const list = user.favoriteLists.find(
      (l) => l._id.toString() === listId
    );
    if (!list) return res.status(404).json({ error: 'Liste bulunamadı.' });

    const exerciseIds = list.exercises.map(e => e.exerciseId);
    const exercises = await Exercise.find({ _id: { $in: exerciseIds } });

    res.status(200).json({
      _id: list._id,
      name: list.name,
      color: list.color || '#FFFFFF',
      exercises: exercises,
    });
  } catch (err) {
    console.error('❌ Liste detayı alınamadı:', err.message);
    res.status(500).json({ error: 'Liste detayı alınamadı.' });
  }
};


// ✅ Egzersizi favori listeye ekle
const addExerciseToFavoriteList = async (req, res) => {
  const { userId, listId } = req.params;
  const { exerciseId } = req.body;

  try {
    const user = await User.findById(userId);
    if (!user) return res.status(404).json({ error: 'Kullanıcı bulunamadı.' });

    const list = user.favoriteLists.id(listId);
    if (!list) return res.status(404).json({ error: 'Favori liste bulunamadı.' });

    const alreadyExists = list.exercises.some(e => e.exerciseId.toString() === exerciseId);
    if (alreadyExists) {
      return res.status(409).json({ error: 'Egzersiz zaten listede.' });
    }

    list.exercises.push({ exerciseId: mongoose.Types.ObjectId(exerciseId) });
    await user.save();

    res.status(200).json({ success: true, updatedList: list });
  } catch (err) {
    console.error('❌ Egzersiz eklenemedi:', err.message);
    res.status(500).json({ error: 'Egzersiz eklenemedi.' });
  }
};
const renameFavoriteList = async (req, res) => {
  const { userId, listId } = req.params;
  const { newName } = req.body;

  try {
    const user = await User.findById(userId);
    if (!user) return res.status(404).json({ error: 'Kullanıcı bulunamadı.' });

    const list = user.favoriteLists.find(
      (l) => l._id.toString() === listId
    );
    if (!list) return res.status(404).json({ error: 'Liste bulunamadı.' });

    list.name = newName;
    await user.save();

    res.status(200).json({ success: true, updatedList: list });
  } catch (err) {
    console.error('❌ İsim güncellenemedi:', err.message);
    res.status(500).json({ error: 'Liste adı güncellenemedi.' });
  }
};

const updateFavoriteListColor = async (req, res) => {
  const { userId, listId } = req.params;
  const { newColor } = req.body;

  try {
    const user = await User.findById(userId);
    if (!user) return res.status(404).json({ error: 'Kullanıcı bulunamadı.' });

    const list = user.favoriteLists.find(
      (l) => l._id.toString() === listId
    );
    if (!list) return res.status(404).json({ error: 'Liste bulunamadı.' });

    list.color = newColor;
    await user.save();

    res.status(200).json({ success: true, updatedList: list });
  } catch (err) {
    console.error('❌ Renk güncellenemedi:', err.message);
    res.status(500).json({ error: 'Liste rengi güncellenemedi.' });
  }
};
const deleteFavoriteList = async (req, res) => {
  const { userId, listId } = req.params;

  try {
    const user = await User.findById(userId);
    if (!user) return res.status(404).json({ error: 'Kullanıcı bulunamadı.' });

    const index = user.favoriteLists.findIndex(
      (l) => l._id.toString() === listId
    );
    if (index === -1) return res.status(404).json({ error: 'Liste bulunamadı.' });

    user.favoriteLists.splice(index, 1);
    await user.save();

    res.status(200).json({ success: true, message: 'Liste silindi.' });
  } catch (err) {
    console.error('❌ Liste silinemedi:', err.message);
    res.status(500).json({ error: 'Liste silinemedi.' });
  }
};


module.exports = {
  createFavoriteList,
  getUserFavoriteLists,
  getFavoriteListDetail,
  addExerciseToFavoriteList,
  renameFavoriteList,
  deleteFavoriteList,

  updateFavoriteListColor,
};
