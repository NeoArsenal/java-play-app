// Generator for the complete 11-World JavaPlay Curriculum with 100% Unique, Non-Repeating Questions & Boss Battles
const fs = require('fs');
const path = require('path');

// Import dedicated world data definitions
const { worldsData, getWorldLevelExercises, getWorldBossExercises } = require('./curriculum_data');

function generateCurriculum() {
  const totalL = worldsData.reduce((acc, w) => acc + w.levels.length, 0);
  const result = {
    totalWorlds: worldsData.length,
    totalLevels: totalL,
    worlds: []
  };

  worldsData.forEach((wData) => {
    const bossExercises = getWorldBossExercises(wData.id);
    const bossChallenge = {
      ...wData.bossChallenge,
      exercises: bossExercises
    };

    const worldObj = {
      id: wData.id,
      level: wData.level,
      title: wData.title,
      badge: wData.badge,
      description: wData.description,
      color: wData.color,
      bossChallenge: bossChallenge,
      lessons: []
    };

    wData.levels.forEach((lvl, lvlIdx) => {
      const lessonNumber = lvlIdx + 1;
      const lessonObj = {
        id: `${wData.id}_l${lessonNumber}`,
        levelNumber: lessonNumber,
        title: lvl.title,
        xpReward: 20 + lessonNumber * 2,
        exercises: getWorldLevelExercises(wData, lvl, lessonNumber)
      };
      worldObj.lessons.push(lessonObj);
    });

    result.worlds.push(worldObj);
  });

  return result;
}

// Generate curriculum and write to assets/data/curriculum.json
const fullCurriculum = generateCurriculum();
const outputPath = path.join(__dirname, '../assets/data/curriculum.json');
fs.writeFileSync(outputPath, JSON.stringify(fullCurriculum, null, 2), 'utf8');

console.log(`✅ Curriculum completo de ${fullCurriculum.worlds.length} Mundos generado exitosamente.`);
console.log(`   Ruta: ${outputPath}`);
console.log(`   Total de niveles: ${fullCurriculum.worlds.reduce((acc, w) => acc + w.lessons.length, 0)}`);
console.log(`   Desafíos Finales con preguntas creados: ${fullCurriculum.worlds.filter(w => w.bossChallenge && w.bossChallenge.exercises.length > 0).length}`);
