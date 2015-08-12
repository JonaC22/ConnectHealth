CREATE TABLE `heroku_7c99704f99bd301`.`users` (
  `id` BIGINT NOT NULL,
  `username` VARCHAR(45) NOT NULL,
  `password` VARCHAR(45) NOT NULL,
  `active` TINYINT(1) NOT NULL,
  PRIMARY KEY (`id`));

CREATE TABLE `heroku_7c99704f99bd301`.`roles` (
  `id` BIGINT NOT NULL,
  `description` VARCHAR(45) NOT NULL,
  `active` TINYINT NOT NULL,
  PRIMARY KEY (`id`));

CREATE TABLE `heroku_7c99704f99bd301`.`functions` (
  `id` BIGINT NOT NULL,
  `description` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`id`));

CREATE TABLE `heroku_7c99704f99bd301`.`user_roles` (
  `id_user` BIGINT NOT NULL,
  `id_role` BIGINT NOT NULL,
  PRIMARY KEY (`id_user`, `id_role`),
  INDEX `fk_user_roles_role_idx` (`id_role` ASC),
  CONSTRAINT `fk_user_roles_user`
  FOREIGN KEY (`id_user`)
  REFERENCES `heroku_7c99704f99bd301`.`users` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_user_roles_role`
  FOREIGN KEY (`id_role`)
  REFERENCES `heroku_7c99704f99bd301`.`roles` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);

CREATE TABLE `heroku_7c99704f99bd301`.`role_functions` (
  `id_role` BIGINT NOT NULL,
  `id_function` BIGINT NOT NULL,
  PRIMARY KEY (`id_role`, `id_function`),
  INDEX `fk_role_functions_function_idx` (`id_function` ASC),
  CONSTRAINT `fk_role_functions_role`
  FOREIGN KEY (`id_role`)
  REFERENCES `heroku_7c99704f99bd301`.`roles` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_role_functions_function`
  FOREIGN KEY (`id_function`)
  REFERENCES `heroku_7c99704f99bd301`.`functions` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);

CREATE TABLE `heroku_7c99704f99bd301`.`statistical_reports` (
  `id` BIGINT NOT NULL,
  `create_date` DATE NOT NULL,
  `query` VARCHAR(1000) NOT NULL,
  `description` VARCHAR(45) NOT NULL,
  `result` VARCHAR(1000) NOT NULL,
  `made_by` BIGINT NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_statistical_reports_idx` (`made_by` ASC),
  CONSTRAINT `fk_statistical_reports`
  FOREIGN KEY (`made_by`)
  REFERENCES `heroku_7c99704f99bd301`.`users` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);

CREATE TABLE `heroku_7c99704f99bd301`.`patients` (
  `id` BIGINT NOT NULL,
  `name` VARCHAR(45) NOT NULL,
  `lastname` VARCHAR(45) NOT NULL,
  `document_type` VARCHAR(10) NOT NULL,
  `document_number` BIGINT NOT NULL,
  `active` TINYINT NOT NULL,
  PRIMARY KEY (`id`));

CREATE TABLE `heroku_7c99704f99bd301`.`pedigrees` (
  `id` BIGINT NOT NULL,
  `id_patient` BIGINT NOT NULL,
  `create_date` DATE NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_pedigrees_patient_idx` (`id_patient` ASC),
  CONSTRAINT `fk_pedigrees_patient`
  FOREIGN KEY (`id_patient`)
  REFERENCES `heroku_7c99704f99bd301`.`patients` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);

CREATE TABLE `heroku_7c99704f99bd301`.`queries` (
  `id` BIGINT NOT NULL,
  `create_date` DATE NOT NULL,
  `query` VARCHAR(1000) NOT NULL,
  `description` VARCHAR(45) NOT NULL,
  `result` VARCHAR(1000) NOT NULL,
  `made_by` BIGINT NOT NULL,
  `id_pedigree` BIGINT NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_queries_user_idx` (`made_by` ASC),
  INDEX `fk_queries_pedigree_idx` (`id_pedigree` ASC),
  CONSTRAINT `fk_queries_user`
  FOREIGN KEY (`made_by`)
  REFERENCES `heroku_7c99704f99bd301`.`users` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_queries_pedigree`
  FOREIGN KEY (`id_pedigree`)
  REFERENCES `heroku_7c99704f99bd301`.`pedigrees` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);

CREATE TABLE `heroku_7c99704f99bd301`.`medical_history` (
  `id` BIGINT NOT NULL,
  `id_patient` BIGINT NOT NULL,
  `json_text` VARCHAR(10000) NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_medical_history_patient_idx` (`id_patient` ASC),
  CONSTRAINT `fk_medical_history_patient`
  FOREIGN KEY (`id_patient`)
  REFERENCES `heroku_7c99704f99bd301`.`patients` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);

CREATE TABLE `heroku_7c99704f99bd301`.`annotations` (
  `id` BIGINT NOT NULL,
  `id_pedigree` BIGINT NOT NULL,
  `pos_x` VARCHAR(45) NOT NULL,
  `pos_y` VARCHAR(45) NOT NULL,
  `text` VARCHAR(1000) NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_annotations_pedigree_idx` (`id_pedigree` ASC),
  CONSTRAINT `fk_annotations_pedigree`
  FOREIGN KEY (`id_pedigree`)
  REFERENCES `heroku_7c99704f99bd301`.`pedigrees` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);

