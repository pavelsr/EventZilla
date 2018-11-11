CREATE TABLE subscriptions (
  id                  INT NOT NULL AUTO_INCREMENT PRIMARY KEY   COMMENT 'Кэш ID подписки',
  user_id             INT NOT NULL                              COMMENT 'ID пользователя ВК',
  group_id            INT NOT NULL                              COMMENT 'ID группы ВК',
  hash                VARCHAR(64) NOT NULL DEFAULT SHA2(CONCAT(`user_id`,`group_id`),256)       COMMENT 'хеш',
  FOREIGN KEY (user_id) REFERENCES users(vk_id),
  FOREIGN KEY (group_id) REFERENCES groups(vk_id),
  INDEX `user_id` (`user_id`),
  INDEX `group_id` (`group_id`),
  UNIQUE KEY (hash)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci, COMMENT='Подписки пользователей на группы';
