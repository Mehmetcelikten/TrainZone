const { MongoClient } = require('mongodb');

const uri = 'mongodb://localhost:27017';
const dbName = 'fitnessDB';
const collectionName = 'exercises';

async function deleteWithoutMuscleField() {
  const client = new MongoClient(uri);

  try {
    await client.connect();
    const db = client.db(dbName);
    const collection = db.collection(collectionName);

    const result = await collection.deleteMany({ muscle: { $exists: false } });

    console.log(`Silinen egzersiz sayısı: ${result.deletedCount}`);
  } catch (err) {
    console.error('Hata:', err);
  } finally {
    await client.close();
  }
}

deleteWithoutMuscleField();