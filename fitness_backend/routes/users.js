const express = require('express');
const router = express.Router();
const {
  getUserFavorites,
  getFavoriteListDetail,
  createFavoriteList,
  addFullListToFavorites,
  addExerciseToFavoriteList,
  toggleFavoriteList,

  // ✅ Balanced favori işlemleri
  toggleFavoriteBalancedList,
  getFavoriteBalancedLists,
} = require('../controllers/userController');

// 🔹 Klasik favori listeler
router.get('/:userId/favorites', getUserFavorites);
router.get('/:userId/favorites/:listId', getFavoriteListDetail);
router.post('/:userId/favorites', createFavoriteList);
router.post('/:userId/favorites/full-list', addFullListToFavorites);
router.patch('/:userId/favorites/:listId/exercises', addExerciseToFavoriteList);
router.patch('/:userId/favorites/:listId', toggleFavoriteList);

// 🔹 Balanced favori listeler
router.get('/:userId/balanced-favorites', getFavoriteBalancedLists); // ✅ listeyi getir
router.patch('/:userId/balanced-favorites/:listId', toggleFavoriteBalancedList); // ✅ toggle işlemi

module.exports = router;
