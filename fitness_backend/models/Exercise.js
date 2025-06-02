const mongoose = require('mongoose');

const ExerciseSchema = new mongoose.Schema({
  name: { type: String, required: true },
  level: { type: String, required: true },
  equipment: { type: String, required: true },
  sets: { type: Number, default: 3 },
  reps: { type: Number, default: 10 },
  description: { type: String },

  rating: { type: Number, default: 0 }, // Ortalama puan

  ratings: [ // Her kullanıcının verdiği puan
    {
      userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
      value: { type: Number } // 1.0 - 5.0 arası puan
    }
  ],

  images: [String], // 3 Cloudinary görseli olacak: başlangıç, orta, bitiş
  muscle: { type: String, required: true }
}, {
  timestamps: true // createdAt, updatedAt otomatik oluşur
});

const Exercise = mongoose.model('Exercise', ExerciseSchema);
module.exports = Exercise;
