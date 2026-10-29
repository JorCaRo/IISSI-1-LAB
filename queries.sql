
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

# JOIN: Relacionando tablas

# Consulta 5: Estudiantes con JOIN
# Estudiantes con método de acceso por Selectividad
SELECT p.first_name, p.last_name, st.access_method
FROM students st
JOIN people p ON st.student_id = p.person_id
WHERE st.access_method = 'Selectividad';

# Consulta 6: Profesores por categoría
# Profesores con categoría Catedrático
SELECT p.first_name, p.last_name, pr.category
FROM professors pr
JOIN people p ON pr.professor_id = p.person_id
WHERE pr.category = 'Catedrático';

#-------------------------------------------------------------------------------------------------------------------------------------------

