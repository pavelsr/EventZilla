CREATE TABLE groups (
  id                  INT NOT NULL AUTO_INCREMENT PRIMARY KEY   COMMENT 'Кэш ID записи',
  vk_id               INT NOT NULL                              COMMENT 'ID группы ВК',
  city                TEXT                                            COMMENT 'город',
  vk_name             TEXT NOT NULL                                   COMMENT 'название группы',
  vk_description      TEXT NOT NULL                                   COMMENT 'описание группы',
  last_checked        INT(11)  NOT NULL DEFAULT UNIX_TIMESTAMP()      COMMENT 'время последней проверки',
  UNIQUE KEY (vk_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci, COMMENT='Группы вк';
