CREATE TABLE groups (
  id                  MEDIUMINT NOT NULL AUTO_INCREMENT               COMMENT 'ID записи',
  vk_id               MEDIUMINT NOT NULL                              COMMENT 'ID группы ВК',
  vk_description      TEXT NOT NULL                                   COMMENT 'описание группы',
  last_checked        int(11)  NOT NULL DEFAULT UNIX_TIMESTAMP()      COMMENT 'время последней проверки',
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci, COMMENT='Группы вк';
