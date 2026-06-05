-- Create database
CREATE DATABASE IF NOT EXISTS taskmanagerdb;
USE taskmanagerdb;

-- Users table
CREATE TABLE IF NOT EXISTS users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(150) NOT NULL UNIQUE, -- UNIQUE already acts as index for login queries
  password VARCHAR(255) NOT NULL
);

-- Tasks table
CREATE TABLE IF NOT EXISTS tasks (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  title VARCHAR(255) NOT NULL,
  priority ENUM('High','Medium','Low') DEFAULT 'Medium',
  category VARCHAR(100) DEFAULT 'General',
  due_date DATE NOT NULL,
  is_completed TINYINT(1) DEFAULT 0,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,

  INDEX idx_tasks_user_id (user_id),
  INDEX idx_tasks_is_completed (is_completed),
  INDEX idx_tasks_priority (priority),
  INDEX idx_tasks_category (category),
  INDEX idx_tasks_due_date (due_date),
  INDEX idx_tasks_user_completed (user_id, is_completed),
  INDEX idx_tasks_user_due_date (user_id, due_date)
);

-- Categories table
CREATE TABLE IF NOT EXISTS categories (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  name VARCHAR(100) NOT NULL,
  UNIQUE KEY unique_user_category (user_id, name),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,

  INDEX idx_categories_user_id (user_id)
);

-- Notifications table
CREATE TABLE IF NOT EXISTS notifications (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  title VARCHAR(255) NOT NULL,
  message TEXT,
  is_read TINYINT(1) DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,

  INDEX idx_notifications_user_id (user_id),
  INDEX idx_notifications_user_read (user_id, is_read),
  INDEX idx_notifications_created_at (created_at)
);