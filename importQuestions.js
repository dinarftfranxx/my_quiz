const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json'); // Pastikan nama file ini benar
const questionsData = require('./quiz_questions.json'); // Pastikan nama file ini benar

// Inisialisasi Firebase Admin SDK
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function importData() {
  console.log("Memulai import data ke Firestore...");
  let successCount = 0;
  let errorCount = 0;

  for (const question of questionsData) {
    try {
      await db.collection('questions').add(question);
      successCount++;
      console.log(`Berhasil menambahkan soal: ${question.questionText}`);
    } catch (error) {
      errorCount++;
      console.error(`Gagal menambahkan soal: ${question.questionText}, Error:`, error);
    }
  }

  console.log(`\nImport selesai.`);
  console.log(`Berhasil: ${successCount} soal.`);
  console.log(`Gagal: ${errorCount} soal.`);
  process.exit(); // Keluar dari script
}

importData();