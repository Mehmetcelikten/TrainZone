const mongoose = require('mongoose');
const User = require('../models/User');
const Exercise = require('../models/Exercise');
const BalancedList = require('../models/BalancedList');
// userController.js
const getUserFavorites = async (req, res) => {
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
          exercises: exercises.map(e => ({ exerciseId: e })), // ⚠️ Flutter burayı bekliyor
        };
      })
    );

    console.log('🧪 Dönen veri örneği:', JSON.stringify(populatedLists[0], null, 2));
    res.status(200).json(populatedLists);
  } catch (err) {
    console.error('❌ Favori listeleri alınamadı:', err.message);
    res.status(500).json({ error: 'Sistem hatası.' });
  }
};



// 🔁 Kullanıcının Balanced favori listelerini getir
const getFavoriteBalancedLists = async (req, res) => {
  try {
    const { userId } = req.params;
    const user = await User.findById(userId).populate('favoriteBalanced.listId');
    if (!user) return res.status(404).json({ error: 'Kullanıcı bulunamadı' });
    res.status(200).json(user.favoriteBalanced);
  } catch (err) {
    console.error('❌ Balanced favoriler alınamadı:', err);
    res.status(500).json({ error: 'Balanced favoriler alınamadı' });
  }
};

// ✅ Balanced favori toggle (ekle/çıkar)
const toggleFavoriteBalancedList = async (req, res) => {
  try {
    const { userId, listId } = req.params;
    const user = await User.findById(userId);
    if (!user) return res.status(404).json({ error: 'Kullanıcı bulunamadı' });

    const index = user.favoriteBalanced.findIndex(entry => entry.listId.toString() === listId);

    if (index >= 0) {
      user.favoriteBalanced.splice(index, 1); // çıkar
    } else {
      user.favoriteBalanced.push({ listId }); // ekle
    }

    await user.save();
    await user.populate('favoriteBalanced.listId');

    res.status(200).json({
      message: index >= 0 ? 'Favoriden çıkarıldı' : 'Favorilere eklendi',
      favoriteBalanced: user.favoriteBalanced
    });
  } catch (err) {
    console.error('❌ Balanced toggle hatası:', err);
    res.status(500).json({ error: 'Balanced toggle hatası', detail: err.message });
  }
};

// ✅ Belirli bir klasik favori listeyi ID ile getir
const getFavoriteListDetail = async (req, res) => {
  try {
    const { userId, listId } = req.params;
    const user = await User.findById(userId).populate('favoriteLists.listId');
    if (!user) return res.status(404).json({ error: 'Kullanıcı bulunamadı' });
    const list = user.favoriteLists.find((item) => item.listId._id.toString() === listId);
    if (!list) return res.status(404).json({ error: 'Liste bulunamadı' });
    res.status(200).json(list);
  } catch (err) {
    console.error('❌ Liste detayı alınamadı:', err);
    res.status(500).json({ error: 'Liste detayı alınamadı' });
  }
};

// ✅ Yeni kullanıcı oluştur (profil)
const createUser = async (req, res) => {
  try {
    const { userName, gender } = req.body;
    if (!userName || !gender) {
      return res.status(400).json({ error: 'userName ve gender zorunludur' });
    }
    const newUser = new User({ userName, gender });
    await newUser.save();
    res.status(201).json({ userId: newUser._id });
  } catch (err) {
    console.error('❌ Kullanıcı oluşturulamadı:', err);
    res.status(500).json({ error: 'Kullanıcı oluşturulamadı' });
  }
};

// ➕ Yeni klasik favori listesi oluştur
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

// 🏋️‍♀️ Klasik favori listeye egzersiz ekle
const addExerciseToFavoriteList = async (req, res) => {
  try {
    const { userId, listId } = req.params;
    const { exerciseId } = req.body;
    if (!exerciseId) {
      return res.status(400).json({ error: 'exerciseId gerekli' });
    }
    const user = await User.findById(userId);
    if (!user) return res.status(404).json({ error: 'Kullanıcı bulunamadı' });
    const list = user.favoriteLists.id(listId);
    if (!list) return res.status(404).json({ error: 'Liste bulunamadı' });
    const alreadyExists = list.exercises.some(
      (item) => item.exerciseId.toString() === exerciseId
    );
    if (alreadyExists) {
      return res.status(409).json({ error: 'Egzersiz zaten listede' });
    }
    const exercise = await Exercise.findById(exerciseId);
    if (!exercise) return res.status(404).json({ error: 'Egzersiz bulunamadı' });
    list.exercises.push({ exerciseId: new mongoose.Types.ObjectId(exerciseId) });
    await user.save();
    await user.populate('favoriteLists.exercises.exerciseId');
    res.status(200).json({
      message: 'Egzersiz başarıyla eklendi',
      updatedList: user.favoriteLists.id(listId),
    });
  } catch (err) {
    console.error('❌ Egzersiz ekleme hatası:', err);
    res.status(500).json({ error: 'Egzersiz eklenemedi' });
  }
};

// ✅ BalancedList üzerinden klasik favori oluştur
const addFullListToFavorites = async (req, res) => {
  const { userId } = req.params;
  const { name, exerciseIds } = req.body;
  if (!name || !Array.isArray(exerciseIds) || exerciseIds.length === 0) {
    return res.status(400).json({ error: 'Liste adı ve egzersizler gereklidir.' });
  }
  try {
    const user = await User.findById(userId);
    if (!user) return res.status(404).json({ error: 'Kullanıcı bulunamadı.' });
    let balancedList = await BalancedList.findOne({ name });
    if (!balancedList) {
      balancedList = new BalancedList({
        name,
        exerciseIds,
      });
      await balancedList.save();
    }
    const alreadyAdded = user.favoriteLists.some(
      (fav) => fav.listId && fav.listId.toString() === balancedList._id.toString()
    );
    if (alreadyAdded) {
      return res.status(200).json({ message: 'Zaten favorilerde var' });
    }
    user.favoriteLists.push({ listId: balancedList._id });
    await user.save();
    res.status(201).json({ addedListId: balancedList._id });
  } catch (err) {
    console.error('❌ Liste eklenemedi:', err.message);
    res.status(500).json({ error: 'Favori listesi eklenemedi.' });
  }
};

// ✅ Klasik favori toggle
const toggleFavoriteList = async (req, res) => {
  try {
    const { userId, listId } = req.params;
    const user = await User.findById(userId);
    if (!user) return res.status(404).json({ error: 'Kullanıcı bulunamadı' });
    const list = await BalancedList.findById(listId);
    if (!list) return res.status(404).json({ error: 'Liste bulunamadı' });
    const alreadyFavorited = user.favoriteLists.some(
      (fav) => fav.listId.toString() === listId
    );
    if (alreadyFavorited) {
      user.favoriteLists = user.favoriteLists.filter(
        (fav) => fav.listId.toString() !== listId
      );
    } else {
      user.favoriteLists.push({ listId });
    }
    await user.save();
    res.status(200).json({
      message: alreadyFavorited ? 'Favoriden çıkarıldı' : 'Favorilere eklendi',
      updatedFavorites: user.favoriteLists,
    });
  } catch (err) {
    console.error('❌ Favori liste toggle hatası:', err);
    res.status(500).json({ error: 'Favori liste güncellenemedi', detail: err.message });
  }
};

module.exports = {
  getUserFavorites,
  getFavoriteBalancedLists,
  getFavoriteListDetail,
  createFavoriteList,
  addExerciseToFavoriteList,
  toggleFavoriteList,
  toggleFavoriteBalancedList,
  addFullListToFavorites,
  createUser,
};
