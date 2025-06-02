const { MongoClient } = require('mongodb');

const uri = 'mongodb+srv://fitnessuser:fitnessuser123@fitness-app.p8myzz0.mongodb.net/?retryWrites=true&w=majority&appName=fitness-app';
const client = new MongoClient(uri);

async function run() {
  try {
    await client.connect();
    console.log('MongoDB bağlantısı başarılı!');

    const database = client.db('fitnessDB'); // kendi DB adını seçebilirsin
    const collection = database.collection('exercises');

    // Örnek veri ekleme
    const result = await collection.insertOne({
      name: 'Squat',
      level: 'Orta',
      equipment: 'Barbell',
      sets: 3,
      reps: 12,
      images: [
        'https://cloudinary-link-1',
        'https://cloudinary-link-2',
        'https://cloudinary-link-3'
      ]
    });

    console.log(`Eklendi: ${result.insertedId}`);
  } finally {
    await client.close();
  }
}

run().catch(console.dir);
