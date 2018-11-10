CREATE TABLE users (
  id                  MEDIUMINT NOT NULL AUTO_INCREMENT               COMMENT 'ID пользователя',
  registered          int(11)  NOT NULL DEFAULT UNIX_TIMESTAMP()      COMMENT 'current unix epoch timestamp in GMT+0 timezone',
  vk_id               MEDIUMINT NOT NULL                              COMMENT 'ID пользователя ВК',
  bdate               int(11)                                         COMMENT 'дата рождения (unix epoch)',
  age                 int(3)                                          COMMENT 'возраст',
  sex                 char(1)                                         COMMENT 'пол',
  city                TEXT NOT NULL                                   COMMENT 'текущий город',
  faculty             TEXT NOT NULL                                   COMMENT 'факультет',
  cathedra            TEXT NOT NULL                                   COMMENT 'кафедра',
  vk_interests        TEXT NOT NULL                                   COMMENT 'интересы согласно соотв полю профиля',
  vk_all_group_names  TEXT NOT NULL                                   COMMENT 'названия групп юзера в одну строчку',
  vk_all_posts        TEXT NOT NULL                                   COMMENT 'тексты всех постов юзера',
  vk_all_group_descr  TEXT NOT NULL                                   COMMENT 'названия групп юзера в одну строчку',
  status              TEXT NOT NULL                                   COMMENT 'текущий статус при наличии',
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci, COMMENT='Пользователи';
