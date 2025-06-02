const mongoose = require('mongoose');

const BalancedListSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
    unique: true,
    trim: true,
  },
  exercises: [
    {
      exerciseId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Exercise',
        required: true,
      },
    },
  ],
}, {
  timestamps: true,
});

module.exports = mongoose.model('BalancedList', BalancedListSchema);
