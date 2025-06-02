const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;
const mongoURI = process.env.MONGO_URI || 'mongodb+srv://fitnessuser:fitnessuser123@fitness-app.p8myzz0.mongodb.net/fitnessDB?retryWrites=true&w=majority&appName=fitness-app';

// 📦 Route dosyaları
const exercisesRoutes = require('./routes/exercises');
const balancedListRoutes = require('./routes/balancedLists');
const usersRoutes = require('./routes/users');
const authRoutes = require('./routes/auth'); // ✅ Auth eklendi

// 🌐 Middleware
app.use(cors({
  origin: process.env.CORS_ORIGIN || '*',
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}));
app.use(express.json());

// 🔗 Route bağlantıları
app.use('/api/exercises', exercisesRoutes);           // /api/exercises/*
app.use('/api/balanced-lists', balancedListRoutes);   // /api/balanced-lists/*
app.use('/api/users', usersRoutes);                   // /api/users/:userId/favorites/*
app.use('/api/auth', authRoutes);                     // ✅ /api/auth/register, /login

// 🛢️ MongoDB bağlantısı ve sunucu başlatma
mongoose.connect(mongoURI)
  .then(() => {
    console.log('✅ MongoDB bağlantısı başarılı!');
    app.listen(PORT, '0.0.0.0', () => {
      console.log(`🚀 Sunucu ${PORT} portunda çalışıyor.`);
    });
  })
  .catch((err) => {
    console.error('❌ MongoDB bağlantı hatası:', err.message);
    process.exit(1);
  });
