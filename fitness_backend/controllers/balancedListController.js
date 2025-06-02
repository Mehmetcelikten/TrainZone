const BalancedList = require('../models/BalancedList');
const Exercise = require('../models/Exercise');


const getMetaByName = async (req, res) => {
  try {
    const name = decodeURIComponent(req.query.name);
    const list = await BalancedList.findOne({ name });

    if (!list) {
      return res.status(404).json({ error: 'Liste bulunamadı.' });
    }

    return res.status(200).json([
      {
        _id: list._id,
        name: list.name,
        color: list.color || '#FF2196F3',
      },
    ]);
  } catch (err) {
    res.status(500).json({ error: 'Meta verisi alınamadı.', detail: err.message });
  }
};

const getByName = async (req, res) => {
  try {
    const listName = decodeURIComponent(req.query.name);
    console.log('GELEN LİSTE ADI:', listName);

    const list = await BalancedList.findOne({ name: listName });

    if (!list) {
      return res.status(404).json({ error: `Liste bulunamadı: ${listName}` });
    }

    const exerciseIds = list.exercises.map(e => e.exerciseId);
    const exercises = await Exercise.find({ _id: { $in: exerciseIds } });

    return res.status(200).json({
      id: list._id, // 🔥 BURASI ÖNEMLİ!
      name: list.name,
      color: list.color || '#FF2196F3',
      exercises,
    });
  } catch (err) {
    res.status(500).json({ error: 'Liste alınamadı', detail: err.message });
  }
};

module.exports = {
  getByName,
  getMetaByName,
};