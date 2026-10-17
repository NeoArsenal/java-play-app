/**
 * ⚠️ ADVERTENCIA: SCRIPT OBSOLETO / LEGACY GENERATOR ⚠️
 * 
 * Este generador está OBSOLETO. Produce únicamente entre 6 y 7 ejercicios por lección,
 * mientras que la versión canónica actual en assets/data/curriculum.json cuenta con
 * 10 ejercicios por lección (1050 ejercicios de lección + 58 de bosses = 1108 ejercicios).
 * 
 * assets/data/curriculum.json es la FUENTE DE VERDAD del currículum de JavaPlay.
 * 
 * Sobrescribir assets/data/curriculum.json con este script destruiría los 10 ejercicios
 * por lección y la diversidad de preguntas auditada.
 * 
 * Por seguridad, este script aborta de inmediato a menos que se invoque explícitamente con --force.
 */

const fs = require('fs');
const path = require('path');

// Comprobación de seguridad: abortar salvo que se proporcione el flag --force
const isForce = process.argv.includes('--force');
if (!isForce) {
  console.error('\n❌ ERROR: backend/legacy_curriculum_generator.js está OBSOLETO.');
  console.error('   assets/data/curriculum.json es la FUENTE DE VERDAD (10 ejercicios por lección).');
  console.error('   Ejecutar este script sobrescribiría el archivo con una versión incompleta (6-7 ejercicios).');
  console.error('   Si realmente deseas ejecutarlo bajo tu propio riesgo, pasa el flag: --force\n');
  process.exit(1);
}

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
