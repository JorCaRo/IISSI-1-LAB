# Tuve un problema con los repositorios de GitHub, ya que sobrescribí los archivos con duplicados, lo que eliminó mis commits previos

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS people;
DROP TABLE IF EXISTS professors;
DROP TABLE IF EXISTS students;
SET FOREIGN_KEY_CHECKS = 1;


# Tabla PEOPLE

CREATE TABLE people (
    person_id INT AUTO_INCREMENT,
    dni CHAR(9) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(150) NOT NULL,
    age TINYINT NOT NULL,
    email VARCHAR(255) NOT NULL,
    PRIMARY KEY (person_id)
);


# Tabla PROFESSORS

CREATE TABLE professors (
    professor_id INT,
    category VARCHAR(30) NOT NULL,
    PRIMARY KEY (professor_id),
    FOREIGN KEY (professor_id) REFERENCES people(person_id)
);


# Tabla STUDENTS

CREATE TABLE students (
    student_id INT,
    access_method VARCHAR(20) NOT NULL,
    PRIMARY KEY (student_id),
    FOREIGN KEY (student_id) REFERENCES people(person_id)
);
