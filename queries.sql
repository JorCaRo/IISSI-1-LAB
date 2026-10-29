
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

#-------------------------------------------------------------------------------------------------------------------------------------------

# Patrones con LIKE: El operador LIKE permite buscar patrones de texto usando comodines
// % representa cualquier secuencia de caracteres (incluyendo ninguno).
// _ representa exactamente un carácter.

# Consulta 23: Terminación de cadena
# Personas con DNI terminado en 'A'
SELECT p.first_name, p.last_name, p.dni
FROM people p
WHERE p.dni LIKE '%A';

# Consulta 24: Inicio de cadena
# Asignaturas cuyo nombre empieza por 'Fundamentos'
SELECT s.subject_name
FROM subjects s
WHERE s.subject_name LIKE 'Fundamentos%';

# Consulta 25: Longitud exacta
# Personas con nombres de 5 letras (usar 5 guiones bajos)
SELECT p.first_name, p.last_name
FROM people p
WHERE p.first_name LIKE '_____';

#-------------------------------------------------------------------------------------------------------------------------------------------

# Filtrado por fechas y años: Las consultas pueden filtrar valores numéricos que representan años o trabajar con fechas

# Consulta 26: Filtro por año
# Grupos del año 2024
SELECT g.group_name, g.activity, g.academic_year
FROM groups g
WHERE g.academic_year = 2024;

# Consulta 27: Rango de años
# Grupos entre 2020 y 2023
SELECT g.group_name, g.activity, g.academic_year
FROM groups g
WHERE g.academic_year BETWEEN 2020 AND 2023
ORDER BY g.academic_year;

#-------------------------------------------------------------------------------------------------------------------------------------------

# Vistas complejas: vistas que combinan información de múltiples tablas

# Vista v_grades_with_honors
# Notas con matrícula de honor
CREATE OR REPLACE VIEW v_grades_with_honors AS
SELECT g.grade_id, g.student_id, g.group_id, g.grade_value, g.exam_call
FROM grades g
WHERE g.with_honors = 1;

# Vista v_student_grades
# Notas de todos los estudiantes con información completa
CREATE OR REPLACE VIEW v_student_grades AS
SELECT 
    p.person_id,
    p.first_name,
    p.last_name,
    p.dni,
    g.grade_value,
    g.exam_call,
    g.with_honors,
    gr.group_name,
    gr.activity,
    gr.academic_year,
    s.subject_name,
    s.acronym,
    s.credits
FROM people p
JOIN students st ON p.person_id = st.student_id
JOIN grades g ON st.student_id = g.student_id
JOIN groups gr ON g.group_id = gr.group_id
JOIN subjects s ON gr.subject_id = s.subject_id;

# Vista v_professors_loads
# Información de profesores con sus cargas docentes
CREATE OR REPLACE VIEW v_professor_loads AS
SELECT
    p.person_id,
    p.first_name,
    p.last_name,
    pr.category,
    tl.credits AS teaching_credits,
    gr.group_name,
    gr.activity,
    gr.academic_year,
    s.subject_name,
    s.acronym
FROM people p
JOIN professors pr ON p.person_id = pr.professor_id
JOIN teaching_loads tl ON pr.professor_id = tl.professor_id
JOIN groups gr ON tl.group_id = gr.group_id
JOIN subjects s ON gr.subject_id = s.subject_id;

# Vista v_degree_students
# Estudiantes por grado
CREATE OR REPLACE VIEW v_degree_students AS
SELECT DISTINCT
    d.degree_id,
    d.degree_name,
    p.person_id,
    p.first_name,
    p.last_name,
    st.access_method,
    gr.academic_year
FROM degrees d
JOIN subjects s ON d.degree_id = s.degree_id
JOIN groups gr ON s.subject_id = gr.subject_id
JOIN students_groups ge ON gr.group_id = ge.group_id
JOIN students st ON ge.student_id = st.student_id
JOIN people p ON st.student_id = p.person_id;

# Consulta 28: Uso de vistas
# Total de matrículas de honor
SELECT COUNT(*) AS total_honors
FROM v_grades_with_honors;

# Consulta 29: Agregación sobre vistas
# Nota media de cada estudiante
SELECT v.first_name, v.last_name, AVG(v.grade_value) AS average_grade
FROM v_student_grades v
GROUP BY v.person_id, v.first_name, v.last_name;

#-------------------------------------------------------------------------------------------------------------------------------------------

# ORDER BY, LIMIT y OFFSET: Control de resultados: Controlan el orden y paginación de los resultados

# Consulta 30: Ordenación ascendente
# Notas ordenadas por valor (de menor a mayor)
SELECT g.grade_id, g.student_id, g.grade_value, g.exam_call
FROM grades g
ORDER BY g.grade_value ASC;

# Consulta 31: Ordenación descendente
# Notas ordenadas por valor descendente
SELECT g.grade_id, g.student_id, g.grade_value, g.exam_call
FROM grades g
ORDER BY g.grade_value DESC;

# Consulta 32: Limitación de resultados
# Las 5 mejores notas
SELECT g.grade_id, g.student_id, g.grade_value, g.exam_call
FROM grades g
ORDER BY g.grade_value DESC
LIMIT 5;

# Consulta 33: Ordenación múltiple
# Notas aprobadas ordenadas por estudiante
SELECT 
    st.first_name,
    st.last_name,
    g.grade_value,
    g.exam_call
FROM grades g
JOIN v_students st ON g.student_id = st.student_id
WHERE g.grade_value >= 5
ORDER BY st.last_name ASC, st.first_name ASC;

# Consulta 34: Paginación básica
# Paginación - Segunda página de 5 notas
SELECT g.grade_id, g.student_id, g.grade_value
FROM grades g
ORDER BY g.grade_value DESC
LIMIT 5 OFFSET 5;

# Consulta 35: Tercera página
# Tercera página de 5 notas
SELECT g.grade_id, g.student_id, g.grade_value
FROM grades g
ORDER BY g.grade_value DESC
LIMIT 5 OFFSET 10;

# Consulta 36: Ordenación con criterios mixtos
# Grupos ordenados por año académico descendente
SELECT g.group_name, g.activity, g.academic_year
FROM groups g
ORDER BY g.academic_year DESC, g.group_name ASC;

#-------------------------------------------------------------------------------------------------------------------------------------------

# JOIN: Consultas avanzadas con múltiples tablas
# combinar filas de diferentes tablas basándose en relaciones entre ellas.

# Consulta 37: JOIN con tabla intermedia
# Estudiantes con sus grupos (INNER JOIN)
SELECT 
    st.first_name,
    st.last_name,
    gr.group_name,
    gr.activity,
    gr.academic_year
FROM v_students st
JOIN students_groups ge ON st.student_id = ge.student_id
JOIN groups gr ON ge.group_id = gr.group_id;

# Consulta 38: JOIN uno a muchos
# Asignaturas con información del grado
SELECT 
    d.degree_name,
    s.subject_name,
    s.acronym,
    s.credits,
    s.course,
    s.subject_type
FROM degrees d
JOIN subjects s ON d.degree_id = s.degree_id
ORDER BY d.degree_name, s.course;

# Consulta 39: JOIN múltiple
# Notas con nombre del estudiante y asignatura
SELECT 
    st.first_name,
    st.last_name,
    s.subject_name,
    s.acronym,
    g.grade_value,
    g.exam_call,
    gr.academic_year
FROM grades g
JOIN v_students st ON g.student_id = st.student_id
JOIN groups gr ON g.group_id = gr.group_id
JOIN subjects s ON gr.subject_id = s.subject_id;

# Consulta 40: JOIN con agregación
# Profesores con grupos que imparten
SELECT 
    pr.first_name,
    pr.last_name,
    pr.category,
    s.subject_name,
    gr.group_name,
    gr.activity,
    tl.credits AS teaching_credits
FROM v_professors pr
JOIN teaching_loads tl ON pr.professor_id = tl.professor_id
JOIN groups gr ON tl.group_id = gr.group_id
JOIN subjects s ON gr.subject_id = s.subject_id;

# Consulta 41: DISTINCT con JOIN
# Estudiantes matriculados en asignaturas (a través de grupos)
SELECT DISTINCT
    st.first_name,
    st.last_name,
    s.subject_name,
    s.acronym,
    gr.academic_year
FROM v_students st
JOIN students_groups ge ON st.student_id = ge.student_id
JOIN groups gr ON ge.group_id = gr.group_id
JOIN subjects s ON gr.subject_id = s.subject_id
ORDER BY st.last_name, s.subject_name;

# Consulta 42: LEFT JOIN
# LEFT JOIN - Todos los estudiantes, con o sin notas
SELECT 
    st.first_name,
    st.last_name,
    g.grade_value,
    g.exam_call
FROM v_students st
LEFT JOIN grades g ON st.student_id = g.student_id;

#-------------------------------------------------------------------------------------------------------------------------------------------

