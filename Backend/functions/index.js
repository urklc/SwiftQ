/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

// The Cloud Functions for Firebase SDK to create Cloud Functions and triggers.
const functions = require('firebase-functions');
const {onCall, HttpsError} = require("firebase-functions/v2/https");

// The Firebase Admin SDK to access Firestore.
const admin = require("firebase-admin");
const {initializeApp} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");

initializeApp();

exports.getUnansweredQuestions = onCall({ region: 'europe-west3', enforceAppCheck: true, }, async(request) => {
  if (!request.auth?.token.uid) {
    throw new HttpsError("failed-precondition", "The function must be " +
            "called while authenticated.");
  }
  
  const level = parseInt(request.data.level, 0);
  const responsesQuery = await getFirestore().collection("responses").where("userID", "==", request.auth.token.uid).get();
  const questionIDs = new Set(responsesQuery.docs.map((doc) => doc.data().questionID));

  var questionsData;
  if (level != 3) {
    const questionsQuery = await getFirestore().collection("questions").where("level", "==", level).get();
    questionsData = questionsQuery.docs.map((doc) => doc.data());
  } else {
    const questionsQuery = await getFirestore().collection("questions").get();
    questionsData = questionsQuery.docs.map((doc) => doc.data());
  }

  questionsData.sort(() => Math.random() - 0.5);

  const allQuestions = [];
  for (const question of questionsData) {
    if (!questionIDs.has(question.questionID)) {
      allQuestions.push(question);
    }
    if (allQuestions.length === 10) {
      break;
    }
  }

  if (allQuestions.length === 0) {
    const responseData = {
      questions: []
    };
    return responseData;  
  } else {
    const responseData = {
      questions: allQuestions
    };
    return responseData;
  }
});

exports.syncAnswers = onCall({ region: 'europe-west3', enforceAppCheck: true, }, async(request) => {
  if (!request.auth?.token.uid) {
    throw new HttpsError("failed-precondition", "The function must be " +
            "called while authenticated.");
  }

  const answers = request.data.answers;
  if (answers.length === 0) {
    return {
      status: 204,
      body: ''
    };
  }

  // update responses
  const batch = getFirestore().batch();
  for (const answer of answers) {
    const isCorrect = answer.isCorrect;
    const questionID = answer.questionID;
    const userID = request.auth.token.uid;

    const responseObj = {
      isCorrect: isCorrect,
      questionID: questionID,
      userID: userID
    };

    const docRef = getFirestore().collection("responses").doc();
    batch.set(docRef, responseObj);
  }
  await batch.commit();

  // update stats
  const statsQuery = await getFirestore().collection("stats").where("userID", "==", request.auth.token.uid).get();
  const statsData = statsQuery.docs.map((doc) => doc.data());
  if (statsData.length === 0) {
    // create new stats object
    const correctMap = {0: 0, 1: 0, 2: 0};
    const wrongMap = {0: 0, 1: 0, 2: 0};
    for (const answer of answers) {
      if (answer.isCorrect) {
        correctMap[answer.level] = correctMap[answer.level] + 1;
      } else {
        wrongMap[answer.level] = wrongMap[answer.level] + 1;
      }
    }
    const statsObj = {
      userID: request.auth.token.uid,
      correctMap: correctMap,
      wrongMap: wrongMap
    };
    const docRef = getFirestore().collection("stats").doc();
    await docRef.set(statsObj);
  } else {
    // update stats object with new values
    const statsObj = statsData[0];
    const correctMap = statsObj.correctMap;
    const wrongMap = statsObj.wrongMap;
    for (const answer of answers) {
      if (answer.isCorrect) {
        correctMap[answer.level] = correctMap[answer.level] + 1;
      } else {
        wrongMap[answer.level] = wrongMap[answer.level] + 1;
      }
    }
    const docRef = statsQuery.docs[0].ref
    await docRef.update({
      correctMap: correctMap,
      wrongMap: wrongMap
    });
  }
  
  return {
    status: 204,
    body: ''
  };
});

exports.retrieveStats = onCall({ region: 'europe-west3', enforceAppCheck: true, }, async(request) => {
  if (!request.auth?.token.uid) {
    throw new HttpsError("failed-precondition", "The function must be " +
            "called while authenticated.");
  }

  // query and return stats per user
  const statsQuery = await getFirestore().collection("stats").where("userID", "==", request.auth.token.uid).get();
  const statsData = statsQuery.docs.map((doc) => doc.data());

  if (statsData.length === 1) {
    const responseData = {
      "stats": statsData,
    };
    return responseData;
  } else {
    const responseData = {
      "stats": []
    };
    return responseData;
  }
});