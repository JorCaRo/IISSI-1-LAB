# Ejemplos Lab4

#----------------------------------------------------------------------------------------------------------------------------------

# Variables y parámetros en SQL (Los pongo en este archivo para tener las estructuras en algún lado)

# Variables locales (DECLARE)
# Las variables locales se declaran dentro de procedimientos, funciones o bloques BEGIN…END mediante la palabra clave DECLARE
DELIMITER //
CREATE OR REPLACE PROCEDURE ejemplo_variables_locales()
BEGIN
    DECLARE v_contador INT DEFAULT 0;
    DECLARE v_nombre VARCHAR(100);
    DECLARE v_promedio DECIMAL(4,2);
    
    -- Asignar valores
    SET v_contador = 10;
    SELECT first_name INTO v_nombre FROM people WHERE person_id = 1;
    
    SELECT v_contador, v_nombre;
END //
DELIMITER ;

# Variables del usuario (@variable)
# Las variables de usuario se identifican con el prefijo @ y las hay de distintos tipos:

-- Asignar valor directamente
SET @resultado = 100;

-- Asignar desde una consulta
SELECT AVG(grade_value) INTO @promedio_general FROM grades;

-- Usar en procedimientos
CALL p_student_average(6, @promedio_estudiante);

-- Consultar el valor
SELECT @promedio_estudiante;

# Parámetros de procedimientos
# Los procedimientos pueden recibir parámetros de tres tipos:

# IN(entrada). Valores que se pasan al procedimiento
CREATE OR REPLACE PROCEDURE ejemplo_in(
    IN p_student_id INT
)
BEGIN
    SELECT * FROM students WHERE student_id = p_student_id;
END;

# OUT(salida). Variables que el procedimiento usa para devolver valores.
CREATE OR REPLACE PROCEDURE ejemplo_out(
    IN p_student_id INT,
    OUT p_average DECIMAL(4,2)
)
BEGIN
    SELECT AVG(grade_value) INTO p_average
    FROM grades
    WHERE student_id = p_student_id;
END;

# INOUT(entrada/salida). Combinación de ambos
CREATE OR REPLACE PROCEDURE ejemplo_inout(
    INOUT p_contador INT
)
BEGIN
    SET p_contador = p_contador + 1;
END;

# Convenciones de nomenclatura
# Variables locales: v_
# Variables de usuario: @
# Parámetros: p_

# EJEMPLO: Aplicando convenciones
DELIMITER //
CREATE OR REPLACE PROCEDURE p_calculate_and_store(
    IN p_student_id INT,          -- Parámetro de entrada
    OUT p_result DECIMAL(4,2)     -- Parámetro de salida
)
BEGIN
    DECLARE v_count INT;           -- Variable local
    DECLARE v_sum DECIMAL(6,2);    -- Variable local
    
    -- Contar notas del estudiante
    SELECT COUNT(*), SUM(grade_value) 
    INTO v_count, v_sum
    FROM grades
    WHERE student_id = p_student_id;
    
    -- Calcular promedio
    IF v_count > 0 THEN
        SET p_result = v_sum / v_count;
    ELSE
        SET p_result = 0;
    END IF;
    
    -- Guardar en variable de usuario para uso posterior
    SET @last_calculation = p_result;
END //
DELIMITER ;

-- Uso del procedimiento
CALL p_calculate_and_store(6, @average);
SELECT @average AS 'Promedio', @last_calculation AS 'Última calculada';

#----------------------------------------------------------------------------------------------------------------------------------

# Procedimientos almacenados: conceptos básicos
# Conjunto de instrucciones SQL que se almacenan en el servidor de base de datos
# Se pueden llamar mediante la instrucción CALL


# Ejemplo 1: Procedimiento para borrar notas de un alumno (RF02)
# Borra todas las notas del alumno con el DNI indicado (CUIDADO A LA HORA DE EJECUTAR ESTE ARCHIVO)
CREATE OR REPLACE PROCEDURE p_delete_student_grades(
    IN p_student_dni CHAR(9)
)
BEGIN
    DECLARE v_student_id INT;

    SELECT student_id INTO v_student_id
    FROM people p
    JOIN students s ON s.student_id = p.person_id
    WHERE p.dni = p_student_dni;

    DELETE FROM grades WHERE student_id = v_student_id;
END //

# Para ejecutar el ejemplo anterior tenemos que usar CALL
CALL p_delete_student_grades('10000006F');

# Con el siguiente SELECT chequeamos que se ha borrado bien
SELECT * FROM grades g
JOIN students s ON s.student_id = g.student_id
JOIN people p ON p.person_id = s.student_id
WHERE p.dni = '10000006F';


# Ejemplo 2: Procedimiento para borrar todos los datos
# Borra los datos de la base de datos respetando las relaciones de dependencia
# IMPORTANTE: no borra las tablas
CREATE OR REPLACE PROCEDURE p_delete_all_data()
BEGIN
    DELETE FROM grades;
    DELETE FROM teaching_loads;
    DELETE FROM students_groups;
    DELETE FROM students_subjects;
    DELETE FROM groups;
    DELETE FROM subjects;
    DELETE FROM students;
    DELETE FROM professors;
    DELETE FROM degrees;
    DELETE FROM people;
END //

# Ejecutamos el procedimiento anterior con CALL (CUIDADO, BORRA TODOS LOS DATOS)
CALL p_delete_all_data();

# Para revisar que se haya realizado bien el procedimiento lo revisamos con el SELECT COUNT en un par de tablas
SELECT COUNT(*) AS total_grades FROM grades;
SELECT COUNT(*) AS total_students FROM students;
SELECT COUNT(*) AS total_people FROM people;


# Ejemplo 3: Procedimiento para calcular el promedio de notas con parámetro OUT
# Sirve para calcular la nota media de un estudiante y devolverla mediante una salida (OUT)
# Se devuelve en el parámetro de salida p_average la nota media del alumno
# (Si no tiene notas devolverá NULL). Se puede comparar con la función f_student_average (L5)
CREATE OR REPLACE PROCEDURE p_student_average(
    IN p_student_id INT,
    OUT p_average DECIMAL(4,2)
)
BEGIN
    SELECT AVG(grade_value) INTO p_average
    FROM grades
    WHERE student_id = p_student_id;
END //

# Para ejecutar el anterior procedimiento debemos utilizar CALL y para revisar usamos SELECT
# Podemos probarlo con un sólo estudiante (ID 6)
CALL p_student_average(6, @avg_student_6);
SELECT @avg_student_6 AS 'Promedio del estudiante 6';
# También podemos probarlo con más de un estudiante a la vez (El de ID 7 y ID 8)
CALL p_student_average(7, @avg_student_7);
CALL p_student_average(8, @avg_student_8);
SELECT @avg_student_6, @avg_student_7, @avg_student_8;


# Ejemplo 4: Procedimiento para subir las notas de un grupo
# Subirá las notas un 15% de los examinados de una convocatoria y un grupo específicos con notas entre 4.5 y 8 (No subirá más del 10)
# Para ello usaremos UPDATE dentro del procedimiento
CREATE OR REPLACE PROCEDURE p_boost_group_grades(
    IN p_group_id INT,
    IN p_exam_call VARCHAR(20)
)
BEGIN
    DECLARE v_affected_rows INT;
    DECLARE v_group_name VARCHAR(40);

    SELECT group_name INTO v_group_name
    FROM groups
    WHERE group_id = p_group_id;

    UPDATE grades

    SET grade_value = LEAST(grade_value * 1.15, 10.0)
    WHERE group_id = p_group_id
      AND exam_call = p_exam_call
      AND grade_value BETWEEN 4.5 AND 8.0;

    
    SET v_affected_rows = ROW_COUNT();

    SELECT v_group_name AS group_name,
           v_affected_rows AS updated_grades;
END //

# Para revisarlo, vemos primero las notas del grupo y convocatoria que vamos a modificar
SELECT g.grade_id, p.first_name, p.last_name, g.grade_value, g.exam_call
FROM grades g
JOIN students s ON s.student_id = g.student_id
JOIN people p ON p.person_id = s.student_id
WHERE g.group_id = 1 AND g.exam_call = 'Primera'
ORDER BY g.grade_value;

# Subimos las notas de ese grupo en la convocatoria elegida
CALL p_boost_group_grades(1, 'Primera');

# Después chequeamos que la modificación se haya realizado correctamente
SELECT g.grade_id, p.first_name, p.last_name, g.grade_value, g.exam_call
FROM grades g
JOIN students s ON s.student_id = g.student_id
JOIN people p ON p.person_id = s.student_id
WHERE g.group_id = 1 AND g.exam_call = 'Primera'
ORDER BY g.grade_value;


# Ejemplo 5: Procedimiento para asignar matrículas de honor
# Queremos que el top 5% de estudiantes de un grupo específico en una convocatoria, respetando que la nota tiene que ser >=9
# Realizaremos subconsultas, LIMIT y cálculos dentro de procedimientos
CREATE OR REPLACE PROCEDURE p_assign_honors(
    IN p_group_id INT,
    IN p_exam_call VARCHAR(20)
)
BEGIN
    DECLARE v_total_students INT;
    DECLARE v_max_honors INT;

    SELECT COUNT(*) INTO v_total_students
    FROM students_groups
    WHERE group_id = p_group_id;

    # FLOOR sirve para redondear hacia abajo, cumpliendo así la condición de que con menos de 20 alumnos no hay matrículas
    SET v_max_honors = FLOOR(v_total_students * 0.05);

    IF v_max_honors = 0 THEN
        SELECT CONCAT('No se pueden asignar matrículas de honor: ',
                      'el 5% de ', v_total_students,
                      ' estudiantes matriculados es 0') AS mensaje;
    ELSE
        # Hay que quitar las matrículas anteriores para volver a asignarlas
        UPDATE grades
        SET with_honors = 0
        WHERE group_id = p_group_id
          AND exam_call = p_exam_call;

        # MariaDB no admite LIMIT en una subconsulta con IN: por eso las notas
        # elegidas se calculan en una tabla derivada (selected_grades)
        UPDATE grades
        SET with_honors = 1
        WHERE grade_id IN (
            SELECT selected_grades.grade_id
            FROM (
                SELECT grade_id
                FROM grades
                WHERE group_id = p_group_id
                  AND exam_call = p_exam_call
                  AND grade_value >= 9.0
                ORDER BY grade_value DESC
                LIMIT v_max_honors
            ) AS selected_grades
        );
    END IF;
END //

# Vemos las notas del grupo antes de asignarle las matrículas de honor
SELECT g.grade_id, p.first_name, p.last_name, g.grade_value, 
       g.with_honors, g.exam_call
FROM grades g
JOIN students s ON s.student_id = g.student_id
JOIN people p ON p.person_id = s.student_id
WHERE g.group_id = 1 AND g.exam_call = 'Primera'
ORDER BY g.grade_value DESC;

# Asignamos matrículas de honor para un grupo en una convocatoria específicos (usando CALL)
CALL p_assign_honors(1, 'Primera');

# Chequeamos que se hayan entregado correctamente las matrículas de honor
SELECT g.grade_id, p.first_name, p.last_name, g.grade_value, 
       g.with_honors, g.exam_call
FROM grades g
JOIN students s ON s.student_id = g.student_id
JOIN people p ON p.person_id = s.student_id
WHERE g.group_id = 1 AND g.exam_call = 'Primera' AND g.with_honors = 1
ORDER BY g.grade_value DESC;

#----------------------------------------------------------------------------------------------------------------------------------