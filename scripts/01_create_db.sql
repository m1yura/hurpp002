-- Создание базы данных (выполнить отдельно, если нужно)
-- CREATE DATABASE food_industry_db;

-- Подключение к БД (для psql)
-- \c food_industry_db

-- ------------------------------------------------------------
-- 1. Справочники
-- ------------------------------------------------------------
CREATE TABLE Сырье (
    id SERIAL PRIMARY KEY,
    наименование VARCHAR(200) NOT NULL,
    ед_изм VARCHAR(10) NOT NULL,
    тип VARCHAR(50),
    опасно_просрочка BOOLEAN DEFAULT TRUE
);

CREATE TABLE Поставщики (
    id SERIAL PRIMARY KEY,
    наименование VARCHAR(200) NOT NULL,
    ИНН VARCHAR(12) UNIQUE NOT NULL,
    контактное_лицо VARCHAR(100),
    телефон VARCHAR(20),
    email VARCHAR(100)
);

-- ------------------------------------------------------------
-- 2. Рецептуры и спецификации
-- ------------------------------------------------------------
CREATE TABLE Рецептуры (
    id SERIAL PRIMARY KEY,
    код_ТУ VARCHAR(50) UNIQUE,
    наименование_продукта VARCHAR(200) NOT NULL,
    выход_продукта_кг DECIMAL(10,3) NOT NULL,
    дата_утверждения DATE DEFAULT CURRENT_DATE,
    версия INT DEFAULT 1
);

CREATE TABLE СоставРецептуры (
    id SERIAL PRIMARY KEY,
    рецептура_id INT REFERENCES Рецептуры(id) ON DELETE CASCADE,
    сырье_id INT REFERENCES Сырье(id),
    норма_расхода_кг DECIMAL(10,3) NOT NULL,
    потери_процент DECIMAL(5,2) DEFAULT 0
);

-- ------------------------------------------------------------
-- 3. Склад сырья (партионный учет)
-- ------------------------------------------------------------
CREATE TABLE ПартииСырья (
    id SERIAL PRIMARY KEY,
    сырье_id INT REFERENCES Сырье(id),
    поставщик_id INT REFERENCES Поставщики(id),
    номер_партии VARCHAR(50) NOT NULL,
    дата_поступления DATE NOT NULL,
    срок_годности DATE NOT NULL,
    количество DECIMAL(12,3) NOT NULL,
    цена_за_ед DECIMAL(10,2) NOT NULL,
    статус VARCHAR(20) DEFAULT 'На карантине'
);

-- ------------------------------------------------------------
-- 4. Производство
-- ------------------------------------------------------------
CREATE TABLE ПроизводственныеЗаказы (
    id SERIAL PRIMARY KEY,
    номер_заказа VARCHAR(50) UNIQUE NOT NULL,
    рецептура_id INT REFERENCES Рецептуры(id),
    плановый_объем_кг DECIMAL(12,3) NOT NULL,
    дата_создания DATE DEFAULT CURRENT_DATE,
    статус VARCHAR(30) DEFAULT 'Создан'
);

CREATE TABLE ВыпускПродукции (
    id SERIAL PRIMARY KEY,
    партия_номер VARCHAR(50) UNIQUE NOT NULL,
    заказ_id INT REFERENCES ПроизводственныеЗаказы(id),
    рецептура_id INT REFERENCES Рецептуры(id),
    дата_производства DATE NOT NULL,
    срок_годности DATE NOT NULL,
    количество_кг DECIMAL(12,3) NOT NULL,
    статус VARCHAR(20) DEFAULT 'Оприходован'
);

CREATE TABLE СписаниеСырья (
    id SERIAL PRIMARY KEY,
    партия_сырья_id INT REFERENCES ПартииСырья(id),
    заказ_id INT REFERENCES ПроизводственныеЗаказы(id),
    выпуск_id INT REFERENCES ВыпускПродукции(id),
    количество_списано DECIMAL(12,3) NOT NULL,
    дата_списания TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ------------------------------------------------------------
-- 5. Отгрузка
-- ------------------------------------------------------------
CREATE TABLE Отгрузки (
    id SERIAL PRIMARY KEY,
    номер_ТТН VARCHAR(50) UNIQUE NOT NULL,
    дата_отгрузки DATE NOT NULL,
    покупатель VARCHAR(200),
    статус VARCHAR(20) DEFAULT 'Отгружен'
);

CREATE TABLE СоставОтгрузки (
    id SERIAL PRIMARY KEY,
    отгрузка_id INT REFERENCES Отгрузки(id),
    партия_продукции_id INT REFERENCES ВыпускПродукции(id),
    количество_кг DECIMAL(12,3) NOT NULL
);