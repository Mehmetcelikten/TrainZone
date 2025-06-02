const express = require('express');
const router = express.Router();
const balancedListController = require('../controllers/balancedListController');

// 🔸 Liste adına göre sadece meta verileri getir
router.get('/meta', balancedListController.getMetaByName);

// 🔹 Liste adına göre egzersizlerle birlikte tam liste
router.get('/', balancedListController.getByName);

module.exports = router;
