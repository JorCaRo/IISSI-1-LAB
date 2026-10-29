
// Archivo de consultas para lab3
USE grados;

#-------------------------------------------------------------------------------------------------------------------------------------------

# SELECT: Consulta básica

# Consulta 1: Todas las asignaturas
SELECT * 
FROM subjects;

# Consulta 2: Asignatura con acrónimo específico
SELECT * 
FROM subjects s
WHERE s.acronym = 'IISSI-1';

# Consulta 3: Consultas específicas
# Nombres y acrónimos de todas las asignaturas
SELECT s.subject_name, s.acronym 
FROM subjects s;

# Consulta 4: Filtrado por tipo
# Asignaturas de formación básica
SELECT s.subject_name, s.acronym, s.subject_type
FROM subjects s
WHERE s.subject_type = 'Formación Básica';

#-------------------------------------------------------------------------------------------------------------------------------------------
