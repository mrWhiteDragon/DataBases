/* Курсовая работа. База данных для сервиса: Социальная сеть - Планировщик личных задач "Лайфменеджер". Автор - Сергей Солодянников. Январь, 2020 год. 
Приложение помогает планировать задачи и отмечать их осуществление, делать записи, общаться, совместно работать над проектами, продавать продукты хэндмейда, организовывать мероприятия, обучаться и получать предложения по интересам, объявлять свои компетениции, предлагать и откликаться на вакансии. Приложение создает связи между занесенными пользователем объектами в виде графа для удобства создания, анализа и хранения этих объектов.

Близкий по функционалу(но далеко не полностью) сервис - Smartprogress - https://smartprogress.do/?lang=ru
*/


DROP DATABASE IF EXISTS lifemanager;
CREATE DATABASE lifemanager;

USE lifemanager;


-- 1)Таблицы сущностей:
-- Таблица пользователей

DROP TABLE IF EXISTS users;
CREATE TABLE users (
  id INT(10) UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY, 
  first_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL,
  email VARCHAR(120) NOT NULL UNIQUE,
  phone VARCHAR(120) NOT NULL UNIQUE,
  created_at DATETIME DEFAULT NOW(),
  updated_at DATETIME DEFAULT NOW() ON UPDATE NOW(),

  INDEX(first_name, last_name, phone)
);

-- Таблица профилей
DROP TABLE IF EXISTS profiles;
CREATE TABLE profiles (
  user_id INT(10) UNSIGNED NOT NULL PRIMARY KEY,
  sex CHAR(1) NOT NULL,
  birthday DATE,
  hometown VARCHAR(100),
  photo_id INT(10) UNSIGNED NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users (id)
  ON UPDATE CASCADE
);


-- Таблица категорий постов
DROP TABLE IF EXISTS categories;
CREATE TABLE categories (
  id INT(10) UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id INT(10) UNSIGNED NOT NULL,
  title VARCHAR(150) NOT NULL,

  INDEX(title),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Таблица типов медиафайлов
DROP TABLE IF EXISTS media_types;
CREATE TABLE media_types (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL UNIQUE
);

-- Таблица медиафайлов
DROP TABLE IF EXISTS media;
CREATE TABLE media (
  id INT(10) UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  media_type_id INT(10) UNSIGNED NOT NULL,
  user_id INT(10) UNSIGNED NOT NULL,
  filename VARCHAR(255) NOT NULL,
  size INT NOT NULL,
  metadata JSON,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  INDEX(media_type_id, user_id, filename),
  FOREIGN KEY (media_type_id) REFERENCES media_types(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);



-- Таблица постов
DROP TABLE IF EXISTS posts;
CREATE TABLE posts (
  id INT(10) UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id INT(10) UNSIGNED NOT NULL,
  title VARCHAR(150) NOT NULL,
  text TEXT NOT NULL,
  media_id INT(10) UNSIGNED NOT NULL,
  category_id INT(10) UNSIGNED,
  created_at DATETIME DEFAULT NOW(),
  updated_at DATETIME DEFAULT NOW() ON UPDATE NOW(),

  INDEX(title),
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (media_id) REFERENCES media(id),
  FOREIGN KEY (category_id) REFERENCES categories(id)
);


-- Таблица ключевых слов в постах пользователей
DROP TABLE IF EXISTS keywords;
CREATE TABLE keywords (
  id INT(10) UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id INT(10) UNSIGNED NOT NULL,
  post_id INT(10) UNSIGNED NOT NULL,
  word VARCHAR(150) NOT NULL,

  INDEX(word),
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (post_id) REFERENCES posts(id)
);


-- Таблица статусов дружеских отношений
DROP TABLE IF EXISTS friendship_statuses;
CREATE TABLE friendship_statuses (
  id INT(10) UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(150) NOT NULL UNIQUE
);

-- Таблица дружбы
DROP TABLE IF EXISTS friendship;
CREATE TABLE friendship (
  user_id INT(10) UNSIGNED NOT NULL,
  friend_id INT(10) UNSIGNED NOT NULL,
  status_id INT(10) UNSIGNED NOT NULL,
  requested_at DATETIME DEFAULT NOW(),
  confirmed_at DATETIME,

  PRIMARY KEY (user_id, friend_id),
  INDEX(user_id),
  INDEX(friend_id),
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (friend_id) REFERENCES users(id),
  FOREIGN KEY (status_id) REFERENCES friendship_statuses(id)
);


-- Таблица сообщений
DROP TABLE IF EXISTS messages;
CREATE TABLE messages (
  id INT(10) UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY, 
  from_user_id INT(10) UNSIGNED NOT NULL,
  to_user_id INT(10) UNSIGNED NOT NULL,
  body TEXT NOT NULL,
  is_important BOOLEAN,
  is_delivered BOOLEAN,
  created_at DATETIME DEFAULT NOW(),

  INDEX(from_user_id),
  INDEX(to_user_id),
  FOREIGN KEY (from_user_id) REFERENCES users(id),
  FOREIGN KEY (to_user_id) REFERENCES users(id)
);

-- Таблица лайков
DROP TABLE IF EXISTS likes;
CREATE TABLE likes (
  id INT(10) UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id INT(10) UNSIGNED NOT NULL,
  post_id INT(10) UNSIGNED NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (post_id) REFERENCES posts(id)
);


-- Таблица комментариев
DROP TABLE IF EXISTS comments;
CREATE TABLE comments (
  id INT(10) UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id INT(10) UNSIGNED NOT NULL,
  post_id INT(10) UNSIGNED NOT NULL,
  body TEXT NOT NULL,
  created_at DATETIME DEFAULT NOW(),
  updated_at DATETIME DEFAULT NOW() ON UPDATE NOW(),


  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (post_id) REFERENCES posts(id)
);

-- Таблица проектов
DROP TABLE IF EXISTS projects;
CREATE TABLE projects (
  id INT(10) UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(150) NOT NULL UNIQUE,

  INDEX(name)
);

-- Таблица ролей в проекте
DROP TABLE IF EXISTS project_roles;
CREATE TABLE project_roles (
  id INT(10) UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL UNIQUE
);

-- Таблица связи пользователей и проектов
DROP TABLE IF EXISTS projects_users;
CREATE TABLE projects_users (
  project_id INT(10) UNSIGNED NOT NULL,
  user_id INT(10) UNSIGNED NOT NULL,
  role_in_project INT(10) UNSIGNED NOT NULL,

  PRIMARY KEY (project_id, user_id, role_in_project),
  FOREIGN KEY(project_id) REFERENCES projects(id),
  FOREIGN KEY(user_id) REFERENCES users(id),
  FOREIGN KEY(role_in_project) REFERENCES project_roles(id)  
);


-- Таблица каталогов для продуктов проекта
DROP TABLE IF EXISTS catalogs;
CREATE TABLE catalogs (
  id INT(10) UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Название раздела',
  UNIQUE unique_name(name(10))
) COMMENT = 'Разделы продуктов проекта';


-- Таблица продуктов проекта
DROP TABLE IF EXISTS products;
CREATE TABLE products (
  id INT(10) UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Название',
  description TEXT COMMENT 'Описание',
  price DECIMAL (11,2) COMMENT 'Цена',
  catalog_id INT(10) UNSIGNED,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY index_of_catalog_id (catalog_id),

  INDEX(name, price),
  FOREIGN KEY(catalog_id) REFERENCES catalogs(id)
) COMMENT = 'Товарные позиции проекта';


-- Таблица заказов для продуктов проекта
DROP TABLE IF EXISTS orders;
CREATE TABLE orders (
  id INT(10) UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id INT(10) UNSIGNED NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY index_of_user_id(user_id),
  
  FOREIGN KEY(user_id) REFERENCES users(id)
) COMMENT = 'Заказы';

-- Таблица для состава заказа
DROP TABLE IF EXISTS orders_products;
CREATE TABLE orders_products (
  id INT(10) UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  order_id INT(10) UNSIGNED,
  product_id INT(10) UNSIGNED,
  total INT(10) UNSIGNED DEFAULT 1 COMMENT 'Количество заказанных товарных позиций',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,


  FOREIGN KEY(order_id) REFERENCES orders(id),
  FOREIGN KEY(product_id) REFERENCES products(id)
) COMMENT = 'Состав заказа';


-- Таблица отзывов на проект(компанию) или продукт
DROP TABLE IF EXISTS reviews;
CREATE TABLE reviews (
  id INT(10) UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id INT(10) UNSIGNED NOT NULL,
  project_id INT(10) UNSIGNED NOT NULL,
  product_id INT(10) UNSIGNED NOT NULL,
  body TEXT NOT NULL,
  created_at DATETIME DEFAULT NOW(),
  updated_at DATETIME DEFAULT NOW() ON UPDATE NOW(),

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (project_id) REFERENCES projects(id),
  FOREIGN KEY (product_id) REFERENCES products(id)
);


-- Таблица типов системных оповещений
DROP TABLE IF EXISTS alert_types;
CREATE TABLE alert_types (
  id INT(10) UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(150) NOT NULL UNIQUE,
  message TEXT NOT NULL
);

-- Таблица системных оповещений
DROP TABLE IF EXISTS alerts;
CREATE TABLE alerts (
  user_id  INT(10) UNSIGNED NOT NULL,
  alert_type_id INT(10) UNSIGNED NOT NULL,
  is_delivered BOOLEAN,
  created_at DATETIME DEFAULT NOW(),

  FOREIGN KEY(user_id) REFERENCES users(id),
  FOREIGN KEY (alert_type_id) REFERENCES alert_types(id)  
);


-- Таблица интересов пользователей
DROP TABLE IF EXISTS interests;
CREATE TABLE interests (
  id INT(10) UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  added_by INT(10) UNSIGNED NOT NULL,
  name VARCHAR(150) NOT NULL,
  description TEXT NOT NULL,

  INDEX(name),
  FOREIGN KEY (added_by) REFERENCES users(id)
);


-- Таблица компетенций пользователей
DROP TABLE IF EXISTS skills;
CREATE TABLE skills (
  id INT(10) UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  added_by INT(10) UNSIGNED NOT NULL,
  name VARCHAR(150) NOT NULL,
  description TEXT NOT NULL,

  INDEX(name),
  FOREIGN KEY (added_by) REFERENCES users(id)
);

-- Таблица связи интересов и компетенций
DROP TABLE IF EXISTS interests_skills;
CREATE TABLE interests_skills (
  id INT(10) UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  interest_id INT(10) UNSIGNED NOT NULL,
  skill_id INT(10) UNSIGNED NOT NULL,

  FOREIGN KEY (interest_id) REFERENCES interests(id),
  FOREIGN KEY (skill_id) REFERENCES skills(id)
);

-- Таблица вакансий
DROP TABLE IF EXISTS vacancies;
CREATE TABLE vacancies (
  id INT(10) UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  project_id INT(10) UNSIGNED NOT NULL,
  name VARCHAR(150) NOT NULL,
  description TEXT NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  INDEX(name),
  FOREIGN KEY (project_id) REFERENCES projects(id)
);

-- Таблица связи интересов и вакансиий
DROP TABLE IF EXISTS interests_vacancies;
CREATE TABLE interests_vacancies (
  id  INT(10) UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  vacancy_id INT(10) UNSIGNED NOT NULL,
  interest_id INT(10) UNSIGNED NOT NULL,

  FOREIGN KEY (vacancy_id) REFERENCES vacancies(id),
  FOREIGN KEY (interest_id) REFERENCES interests(id)
);

-- Таблица связи компетенций и вакансий
DROP TABLE IF EXISTS skills_vacancies;
CREATE TABLE skills_vacancies (
  id  INT(10) UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  vacancy_id INT(10) UNSIGNED NOT NULL,
  skill_id INT(10) UNSIGNED NOT NULL,

  FOREIGN KEY (vacancy_id) REFERENCES vacancies(id),
  FOREIGN KEY (skill_id) REFERENCES skills(id)
);

-- Таблица откликов пользователей на вакансию
DROP TABLE IF EXISTS vacancy_responses;
CREATE TABLE vacancy_responses (
  id INT(10) UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  vacancy_id INT(10) UNSIGNED NOT NULL,
  user_id INT(10) UNSIGNED NOT NULL,
  message TEXT NOT NULL,

  FOREIGN KEY (vacancy_id) REFERENCES vacancies(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);


-- 2)Таблицы связей внутри сущностей, представленных в виде графа
-- Таблица связей между постами
DROP TABLE IF EXISTS post_bonds;
CREATE TABLE post_bonds (
  post_bond_id INT(10) UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  from_post INT(10) UNSIGNED,
  to_post INT(10) UNSIGNED NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,

  FOREIGN KEY(from_post) REFERENCES posts(id),
  FOREIGN KEY(to_post) REFERENCES posts(id)
);

-- Таблица связей между категориями
DROP TABLE IF EXISTS category_bonds;
CREATE TABLE category_bonds (
  category_bond_id INT(10) UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  from_category INT(10) UNSIGNED,
  to_category INT(10) UNSIGNED NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,

  FOREIGN KEY(from_category) REFERENCES categories(id),
  FOREIGN KEY(to_category) REFERENCES categories(id)
);

-- Таблица связей между интересами
DROP TABLE IF EXISTS interest_bonds;
CREATE TABLE interest_bonds (
  interest_bond_id INT(10) UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  from_interest INT(10) UNSIGNED,
  to_interest INT(10) UNSIGNED NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,

  FOREIGN KEY(from_interest) REFERENCES interests(id),
  FOREIGN KEY(to_interest) REFERENCES interests(id)
  );

-- Таблица связей между компетенциями
DROP TABLE IF EXISTS skill_bonds;
CREATE TABLE skill_bonds (
  skill_bond_id INT(10) UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  from_skill INT(10) UNSIGNED,
  to_skill INT(10) UNSIGNED NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,

  FOREIGN KEY(from_skill) REFERENCES skills(id),
  FOREIGN KEY(to_skill) REFERENCES skills(id)
  );

-- Таблица связей между ключевыми словами в записях пользователей
DROP TABLE IF EXISTS keyword_bonds;
CREATE TABLE keyword_bonds (
  keyword_bond_id INT(10) UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  from_keyword INT(10) UNSIGNED NOT NULL,
  to_keyword INT(10) UNSIGNED NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,

  FOREIGN KEY(from_keyword) REFERENCES keywords(id),
  FOREIGN KEY(to_keyword) REFERENCES keywords(id)
);



