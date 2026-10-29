
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

# Vistas: Simplificando vistas complejas

# Vista v_professors
# Profesores con información completa
CREATE OR REPLACE VIEW v_professors AS
SELECT 
    pr.professor_id,
    pr.category,
    p.person_id,
    p.dni,
    p.first_name,
    p.last_name,
    p.age,
    p.email
FROM professors pr
JOIN people p ON pr.professor_id = p.person_id;

# Vista v_students
# Estudiantes con información completa
CREATE OR REPLACE VIEW v_students AS
SELECT 
    st.student_id,
    st.access_method,
    p.person_id,
    p.dni,
    p.first_name,
    p.last_name,
    p.age,
    p.email
FROM students st
JOIN people p ON st.student_id = p.person_id;

#-------------------------------------------------------------------------------------------------------------------------------------------

# Funciones agregadas: Calcular valores sobre conjuntos de filas

# Consulta 7: Media de notas
# Media de las notas del grupo con ID 1
SELECT AVG(g.grade_value) AS average_grade
FROM grades g
WHERE g.group_id = 1;

# Consulta 8: Suma de créditos
# Total de créditos de las asignaturas del grado con ID 3
SELECT SUM(s.credits) AS total_credits
FROM subjects s 
WHERE s.degree_id = 3;

# Consulta 9: Contar registros
# Número total de estudiantes
SELECT COUNT(*) AS total_students
FROM students;

# Consulta 10: Contar con agrupación básica
# Número de grupos por tipo de actividad
SELECT activity, COUNT(*) AS total_groups
FROM groups
GROUP BY activity;

# Consulta 11: Valor máximo
# Máxima nota obtenida
SELECT MAX(g.grade_value) AS max_grade
FROM grades g;

# Consulta 12: Valor mínimo
# Mínima nota obtenida
SELECT MIN(g.grade_value) AS min_grade
FROM grades g;

#-------------------------------------------------------------------------------------------------------------------------------------------

# Condiciones múltiples
# Las cláusulas WHERE pueden combinar múltiples condiciones con operadores lógicos (AND, OR) y operadores de rango (BETWEEN, IN).

# Consulta 13: OR lógico
# Notas con valor menor que 5 o mayor que 9
SELECT g.grade_id, g.grade_value, g.exam_call
FROM grades g
WHERE g.grade_value < 5 OR g.grade_value > 9;

# Consulta 14: BETWEEN
# Notas entre 5 y 7 (inclusive)
SELECT g.grade_id, g.grade_value, g.exam_call
FROM grades g
WHERE g.grade_value BETWEEN 5 AND 7;

# Consulta 15: IN
# Asignaturas de 6 o 12 créditos
SELECT s.subject_name, s.credits
FROM subjects s
WHERE s.credits IN (6, 12);

# Consulta 16: Rango de edad
# Personas con edad entre 20 y 30 años
SELECT p.first_name, p.last_name, p.age
FROM people p
WHERE p.age BETWEEN 20 AND 30;

#-------------------------------------------------------------------------------------------------------------------------------------------

# DISTINCT: Eliminación de duplicados

# Consulta 17: Nombres únicos de grupos
# Nombres de grupos diferentes
SELECT DISTINCT g.group_name 
FROM groups g;

# Consulta 18: Tipos de asignaturas
# Tipos de asignatura diferentes
SELECT DISTINCT s.subject_type
FROM subjects s;

# Consulta 19: Años académicos
# Años académicos registrados
SELECT DISTINCT g.academic_year
FROM groups g
ORDER BY g.academic_year DESC;

#-------------------------------------------------------------------------------------------------------------------------------------------

# Subconsulta: Consulta dentro de una consulta.

# Consulta 20: Agregado filtrado
# Máxima nota del estudiante con ID 6
SELECT MAX(g.grade_value) AS max_grade
FROM grades g
WHERE g.student_id = 6;

# Consulta 21: IN con subconsulta
# IDs de estudiantes del año académico 2024
SELECT DISTINCT ge.student_id
FROM students_groups ge
WHERE ge.group_id IN (
    SELECT g.group_id 
    FROM groups g 
    WHERE g.academic_year = 2024
);

# Consulta 22: Comparación con agregado
# Asignaturas con más créditos que la media
SELECT s.subject_name, s.credits
FROM subjects s
WHERE s.credits > (SELECT AVG(credits) FROM subjects);
