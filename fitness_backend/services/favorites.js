const User = require('../models/User');
const mongoose = require('mongoose');

// 🔧 Yeni favori listesi oluştur
const createFavoriteList = async (req, res) => {
  const { userId } = req.params;
  const { name } = req.body;

  if (!name) {
    return res.status(400).json({ error: 'Liste adı gerekli.' });
  }

  try {
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ error: 'Kullanıcı bulunamadı.' });
    }

    const newList = {
      _id: new mongoose.Types.ObjectId(),
      name,
      exercises: [], // ObjectId yerine nesne olarak tutulacak
    };

    user.favoriteLists.push(newList);
    await user.save();

    const createdList = user.favoriteLists[user.favoriteLists.length - 1];
    res.status(201).json({ success: true, createdList });
  } catch (err) {
    console.error('Favori listesi oluşturulamadı:', err.message);
    res.status(500).json({ error: 'Sistem hatası.' });
  }
};

// 📥 Kullanıcının favori listelerini getir
const getUserFavoriteLists = async (req, res) => {
  const { userId } = req.params;

  try {
    const user = await User.findById(userId).populate('favoriteLists.exercises.exerciseId');
    if (!user) {
      return res.status(404).json({ error: 'Kullanıcı bulunamadı.' });
    }

    res.status(200).json(user.favoriteLists || []);
  } catch (err) {
    console.error('Favori listeleri getirilemedi:', err.message);
    res.status(500).json({ error: 'Sistem hatası.' });
  }
};

// ➕ Egzersizi listeye ekle
const addExerciseToFavoriteList = async (req, res) => {
  const { userId, listId } = req.params;
  const { exerciseId } = req.body;

  try {
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ error: 'Kullanıcı bulunamadı.' });
    }

    const list = user.favoriteLists.id(listId);
    if (!list) {
      return res.status(404).json({ error: 'Liste bulunamadı.' });
    }

    const alreadyExists = list.exercises.some(e =>
      e.exerciseId.toString() === exerciseId
    );
    if (alreadyExists) {
      return res.status(400).json({ error: 'Bu egzersiz zaten listede.' });
    }

    list.exercises.push({ exerciseId: mongoose.Types.ObjectId(exerciseId) });
    await user.save();

    res.status(200).json({ success: true, updatedList: list });
  } catch (err) {
    console.error('Egzersiz eklenemedi:', err.message);
    res.status(500).json({ error: 'Egzersiz eklenemedi.' });
  }
};

// 🔄 Liste adını güncelle
const renameFavoriteList = async (req, res) => {
  const { userId, listId } = req.params;
  const { newName } = req.body;

  try {
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ error: 'Kullanıcı bulunamadı.' });
    }

    const list = user.favoriteLists.id(listId);
    if (!list) {
      return res.status(404).json({ error: 'Liste bulunamadı.' });
    }

    list.name = newName;
    await user.save();

    res.status(200).json({ success: true, updatedList: list });
  } catch (err) {
    console.error('İsim güncellenemedi:', err.message);
    res.status(500).json({ error: 'Liste adı güncellenemedi.' });
  }
};

// 🎨 Liste rengini güncelle
const updateFavoriteListColor = async (req, res) => {
  const { userId, listId } = req.params;
  const { newColor } = req.body;

  try {
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ error: 'Kullanıcı bulunamadı.' });
    }

    const list = user.favoriteLists.id(listId);
    if (!list) {
      return res.status(404).json({ error: 'Liste bulunamadı.' });
    }

    list.color = newColor;
    await user.save();

    res.status(200).json({ success: true, updatedList: list });
  } catch (err) {
    console.error('Renk güncellenemedi:', err.message);
    res.status(500).json({ error: 'Liste rengi güncellenemedi.' });
  }
};

module.exports = {
  createFavoriteList,
  getUserFavoriteLists,
  addExerciseToFavoriteList,
  renameFavoriteList,
  updateFavoriteListColor,
};
