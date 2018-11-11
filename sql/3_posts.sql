CREATE TABLE posts (
  id                  INT NOT NULL AUTO_INCREMENT PRIMARY KEY   COMMENT 'Кэш ID поста',
  owner_id            INT NOT NULL                              COMMENT 'ID владельца',
  vk_post_id          INT NOT NULL                              COMMENT 'Уникальный ID поста VK в пределах группы',
  created             INT(11)  NOT NULL                               COMMENT 'Дата создания поста',
  hash                VARCHAR(64) NOT NULL DEFAULT SHA2(CONCAT(`owner_id`,`vk_post_id`),256)       COMMENT 'хеш',
  text                TEXT                                            COMMENT 'Содержимое поста',
  checked_by_tomita   TINYINT(1)                                      COMMENT 'Проверен ли Томита парсером',
  location            TEXT                                            COMMENT 'Адрес',
  lat                 DECIMAL(9, 7)                                   COMMENT 'широта',
  lon                 DECIMAL(9, 7)                                   COMMENT 'долгота',
  start_date          int(11)                                         COMMENT 'время начала',
  end_date            int(11)                                         COMMENT 'время конца',
  KEY `owner_id` (`owner_id`),
  KEY `created` (`created`),
  UNIQUE KEY (hash)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci, COMMENT='Группы вк';
