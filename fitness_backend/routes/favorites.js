const express = require('express');
const router = express.Router();
const {
  createFavoriteList,
  getUserFavoriteLists,
  addExerciseToFavoriteList,
  renameFavoriteList,
  updateFavoriteListColor,
  getFavoriteListDetail, // ✅ Detay sayfası için eklendi
} = require('../controllers/favoriteController');

// 🔧 Yeni favori listesi oluştur
router.post('/:userId/favorites', async (req, res) => {
  try {
    await createFavoriteList(req, res);
  } catch (error) {
    res.status(500).json({ error: 'Favori listesi oluşturulurken bir hata oluştu.' });
  }
});

// 📥 Kullanıcının favori listelerini getir
router.get('/:userId/favorites', async (req, res) => {
  try {
    await getUserFavoriteLists(req, res);
  } catch (error) {
    res.status(500).json({ error: 'Favori listeleri alınırken bir hata oluştu.' });
  }
});

// ➕ Egzersizi favori listeye ekle
router.patch('/:userId/lists/:listId/exercises', async (req, res) => {
  try {
    await addExerciseToFavoriteList(req, res);
  } catch (error) {
    res.status(500).json({ error: 'Egzersiz eklenirken bir hata oluştu.' });
  }
});

// 🔍 Belirli bir favori listeyi ID ile detaylı getir (populate ile)
router.get('/:userId/favorites/:listId', async (req, res) => {
  try {
    await getFavoriteListDetail(req, res);
  } catch (error) {
    res.status(500).json({ error: 'Favori listesi detayları alınırken hata oluştu.' });
  }
});

// 🔄 Favori listenin adını güncelle
router.put('/:userId/favorites/:listId/rename', async (req, res) => {
  try {
    await renameFavoriteList(req, res);
  } catch (error) {
    res.status(500).json({ error: 'Favori listesi adı güncellenirken bir hata oluştu.' });
  }
});

// 🎨 Favori listenin rengini güncelle
router.put('/:userId/favorites/:listId/color', async (req, res) => {
  try {
    await updateFavoriteListColor(req, res);
  } catch (error) {
    res.status(500).json({ error: 'Favori listesi rengi güncellenirken bir hata oluştu.' });
  }
});

module.exports = router;
