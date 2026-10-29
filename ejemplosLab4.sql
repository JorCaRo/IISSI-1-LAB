# Ejemplos Lab4

#----------------------------------------------------------------------------------------------------------------------------------

# Variables y parámetros en SQL

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

