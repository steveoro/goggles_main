/*M!999999\- enable the sandbox mode */ 

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
DROP TABLE IF EXISTS `achievement_rows`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `achievement_rows` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) DEFAULT 0,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `part_order` mediumint(9) DEFAULT 0,
  `achievement_value` varchar(10) DEFAULT NULL,
  `is_bracket_open` tinyint(1) DEFAULT 0,
  `is_or_operator` tinyint(1) DEFAULT 0,
  `is_not_operator` tinyint(1) DEFAULT 0,
  `is_bracket_closed` tinyint(1) DEFAULT 0,
  `achievement_id` int(11) DEFAULT NULL,
  `achievement_type_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_achievement_rows_achievement` (`achievement_id`),
  KEY `idx_achievement_rows_achievement_type` (`achievement_type_id`)
) ENGINE=InnoDB AUTO_INCREMENT=57 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `achievement_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `achievement_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) DEFAULT 0,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `code` varchar(5) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_achievement_types_on_code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `achievements`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `achievements` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) DEFAULT 0,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `code` varchar(10) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_achievements_on_code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `active_storage_attachments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `active_storage_attachments` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `record_type` varchar(255) NOT NULL,
  `record_id` bigint(20) NOT NULL,
  `blob_id` bigint(20) NOT NULL,
  `created_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_active_storage_attachments_uniqueness` (`record_type`,`record_id`,`name`,`blob_id`),
  KEY `index_active_storage_attachments_on_blob_id` (`blob_id`),
  CONSTRAINT `fk_rails_c3b3935057` FOREIGN KEY (`blob_id`) REFERENCES `active_storage_blobs` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5084 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `active_storage_blobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `active_storage_blobs` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `key` varchar(255) NOT NULL,
  `filename` varchar(255) NOT NULL,
  `content_type` varchar(255) DEFAULT NULL,
  `metadata` text DEFAULT NULL,
  `byte_size` bigint(20) NOT NULL,
  `checksum` varchar(255) NOT NULL,
  `created_at` datetime NOT NULL,
  `service_name` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_active_storage_blobs_on_key` (`key`)
) ENGINE=InnoDB AUTO_INCREMENT=5084 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `active_storage_variant_records`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `active_storage_variant_records` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `blob_id` bigint(20) NOT NULL,
  `variation_digest` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_active_storage_variant_records_uniqueness` (`blob_id`,`variation_digest`),
  CONSTRAINT `fk_rails_993965df05` FOREIGN KEY (`blob_id`) REFERENCES `active_storage_blobs` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `admin_grants`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `admin_grants` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) DEFAULT 0,
  `entity` varchar(150) DEFAULT NULL,
  `user_id` bigint(20) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_admin_grants_on_user_id_and_entity` (`user_id`,`entity`),
  KEY `index_admin_grants_on_user_id` (`user_id`),
  KEY `index_admin_grants_on_entity` (`entity`)
) ENGINE=InnoDB AUTO_INCREMENT=125489 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `api_daily_use_agents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `api_daily_use_agents` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) DEFAULT 0,
  `user_agent` varchar(255) NOT NULL,
  `day` date NOT NULL,
  `count` bigint(20) DEFAULT 0,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_api_daily_use_agents_on_day_and_user_agent` (`day`,`user_agent`)
) ENGINE=InnoDB AUTO_INCREMENT=7135 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `api_daily_uses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `api_daily_uses` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) DEFAULT 0,
  `route` varchar(255) NOT NULL,
  `day` date NOT NULL,
  `count` bigint(20) DEFAULT 0,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_api_daily_uses_on_route_and_day` (`route`,`day`),
  KEY `index_api_daily_uses_on_route` (`route`)
) ENGINE=InnoDB AUTO_INCREMENT=136213 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `app_parameters`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `app_parameters` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) DEFAULT 0,
  `code` int(11) DEFAULT NULL,
  `controller_name` varchar(255) DEFAULT NULL,
  `action_name` varchar(255) DEFAULT NULL,
  `is_a_post` tinyint(1) DEFAULT 0,
  `confirmation_text` varchar(255) DEFAULT NULL,
  `a_string` varchar(255) DEFAULT NULL,
  `a_bool` tinyint(1) DEFAULT NULL,
  `a_integer` int(11) DEFAULT NULL,
  `a_date` datetime DEFAULT NULL,
  `a_decimal` decimal(10,2) DEFAULT NULL,
  `a_decimal_2` decimal(10,2) DEFAULT NULL,
  `a_decimal_3` decimal(10,2) DEFAULT NULL,
  `a_decimal_4` decimal(10,2) DEFAULT NULL,
  `range_x` bigint(20) DEFAULT NULL,
  `range_y` bigint(20) DEFAULT NULL,
  `a_name` varchar(255) DEFAULT NULL,
  `a_filename` varchar(255) DEFAULT NULL,
  `tooltip_text` varchar(255) DEFAULT NULL,
  `view_height` int(11) DEFAULT 0,
  `code_type_1` bigint(20) DEFAULT NULL,
  `code_type_2` bigint(20) DEFAULT NULL,
  `code_type_3` bigint(20) DEFAULT NULL,
  `code_type_4` bigint(20) DEFAULT NULL,
  `free_text_1` text DEFAULT NULL,
  `free_text_2` text DEFAULT NULL,
  `free_text_3` text DEFAULT NULL,
  `free_text_4` text DEFAULT NULL,
  `free_bool_1` tinyint(1) DEFAULT NULL,
  `free_bool_2` tinyint(1) DEFAULT NULL,
  `free_bool_3` tinyint(1) DEFAULT NULL,
  `free_bool_4` tinyint(1) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_app_parameters_on_code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=1403 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `ar_internal_metadata`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `ar_internal_metadata` (
  `key` varchar(255) NOT NULL,
  `value` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `aux_arms_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `aux_arms_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) DEFAULT 0,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `code` varchar(5) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_aux_arms_types_on_code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `aux_body_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `aux_body_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) DEFAULT 0,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `code` varchar(5) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_aux_body_types_on_code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `aux_breath_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `aux_breath_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) DEFAULT 0,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `code` varchar(5) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_aux_breath_types_on_code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `aux_kicks_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `aux_kicks_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) DEFAULT 0,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `code` varchar(5) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_aux_kicks_types_on_code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `badge_payments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `badge_payments` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) DEFAULT 0,
  `amount` decimal(10,2) DEFAULT NULL,
  `payment_date` date DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `manual` tinyint(1) NOT NULL DEFAULT 0,
  `badge_id` bigint(20) DEFAULT NULL,
  `user_id` bigint(20) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_badge_payments_on_badge_id` (`badge_id`),
  KEY `index_badge_payments_on_user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=8788 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `badges`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `badges` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) DEFAULT 0,
  `number` varchar(40) DEFAULT NULL,
  `season_id` int(11) DEFAULT NULL,
  `swimmer_id` int(11) DEFAULT NULL,
  `team_id` int(11) DEFAULT NULL,
  `category_type_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `entry_time_type_id` int(11) DEFAULT NULL,
  `team_affiliation_id` int(11) DEFAULT NULL,
  `final_rank` int(11) DEFAULT NULL,
  `off_gogglecup` tinyint(1) DEFAULT 0,
  `fees_due` tinyint(1) NOT NULL DEFAULT 0,
  `badge_due` tinyint(1) NOT NULL DEFAULT 0,
  `relays_due` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `index_badges_on_number` (`number`),
  KEY `fk_badges_seasons` (`season_id`),
  KEY `fk_badges_swimmers` (`swimmer_id`),
  KEY `fk_badges_teams` (`team_id`),
  KEY `fk_badges_category_types` (`category_type_id`),
  KEY `fk_badges_entry_time_types` (`entry_time_type_id`),
  KEY `fk_badges_team_affiliations` (`team_affiliation_id`)
) ENGINE=InnoDB AUTO_INCREMENT=309444 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `base_movements`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `base_movements` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) DEFAULT 0,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `code` varchar(6) DEFAULT NULL,
  `aux_arms_ok` tinyint(1) DEFAULT 0,
  `aux_kicks_ok` tinyint(1) DEFAULT 0,
  `aux_body_ok` tinyint(1) DEFAULT 0,
  `aux_breath_ok` tinyint(1) DEFAULT 0,
  `movement_type_id` int(11) DEFAULT NULL,
  `stroke_type_id` int(11) DEFAULT NULL,
  `movement_scope_type_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_base_movements_on_code` (`code`),
  KEY `fk_base_movements_movement_types` (`movement_type_id`),
  KEY `fk_base_movements_stroke_types` (`stroke_type_id`),
  KEY `fk_base_movements_movement_scope_types` (`movement_scope_type_id`)
) ENGINE=InnoDB AUTO_INCREMENT=147 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `best_50_and_100_results`;
/*!50001 DROP VIEW IF EXISTS `best_50_and_100_results`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8mb4;
/*!50001 CREATE VIEW `best_50_and_100_results` AS SELECT
 1 AS `swimmer_id`,
  1 AS `swimmer_name`,
  1 AS `swimmer_year_of_birth`,
  1 AS `gender_type_id`,
  1 AS `event_type_id`,
  1 AS `event_type_code`,
  1 AS `pool_type_id`,
  1 AS `pool_type_code`,
  1 AS `season_id`,
  1 AS `season_header_year`,
  1 AS `meeting_individual_result_id`,
  1 AS `minutes`,
  1 AS `seconds`,
  1 AS `hundredths`,
  1 AS `total_hundredths`,
  1 AS `meeting_id`,
  1 AS `meeting_date`,
  1 AS `meeting_name`,
  1 AS `team_id`,
  1 AS `team_name` */;
SET character_set_client = @saved_cs_client;
DROP TABLE IF EXISTS `best_50_and_100_results5y`;
/*!50001 DROP VIEW IF EXISTS `best_50_and_100_results5y`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8mb4;
/*!50001 CREATE VIEW `best_50_and_100_results5y` AS SELECT
 1 AS `swimmer_id`,
  1 AS `swimmer_name`,
  1 AS `swimmer_year_of_birth`,
  1 AS `gender_type_id`,
  1 AS `event_type_id`,
  1 AS `event_type_code`,
  1 AS `pool_type_id`,
  1 AS `pool_type_code`,
  1 AS `season_id`,
  1 AS `season_header_year`,
  1 AS `meeting_individual_result_id`,
  1 AS `minutes`,
  1 AS `seconds`,
  1 AS `hundredths`,
  1 AS `total_hundredths`,
  1 AS `meeting_id`,
  1 AS `meeting_date`,
  1 AS `meeting_name`,
  1 AS `team_id`,
  1 AS `team_name` */;
SET character_set_client = @saved_cs_client;
DROP TABLE IF EXISTS `best_50m_results`;
/*!50001 DROP VIEW IF EXISTS `best_50m_results`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8mb4;
/*!50001 CREATE VIEW `best_50m_results` AS SELECT
 1 AS `swimmer_id`,
  1 AS `swimmer_name`,
  1 AS `swimmer_year_of_birth`,
  1 AS `gender_type_id`,
  1 AS `event_type_id`,
  1 AS `event_type_code`,
  1 AS `pool_type_id`,
  1 AS `pool_type_code`,
  1 AS `season_id`,
  1 AS `season_header_year`,
  1 AS `meeting_individual_result_id`,
  1 AS `minutes`,
  1 AS `seconds`,
  1 AS `hundredths`,
  1 AS `total_hundredths`,
  1 AS `meeting_id`,
  1 AS `meeting_date`,
  1 AS `meeting_name`,
  1 AS `team_id`,
  1 AS `team_name` */;
SET character_set_client = @saved_cs_client;
DROP TABLE IF EXISTS `best_swimmer3y_results`;
/*!50001 DROP VIEW IF EXISTS `best_swimmer3y_results`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8mb4;
/*!50001 CREATE VIEW `best_swimmer3y_results` AS SELECT
 1 AS `swimmer_id`,
  1 AS `swimmer_name`,
  1 AS `swimmer_year_of_birth`,
  1 AS `gender_type_id`,
  1 AS `event_type_id`,
  1 AS `event_type_code`,
  1 AS `pool_type_id`,
  1 AS `pool_type_code`,
  1 AS `season_id`,
  1 AS `season_header_year`,
  1 AS `meeting_individual_result_id`,
  1 AS `minutes`,
  1 AS `seconds`,
  1 AS `hundredths`,
  1 AS `total_hundredths`,
  1 AS `meeting_id`,
  1 AS `meeting_date`,
  1 AS `meeting_name`,
  1 AS `team_id`,
  1 AS `team_name` */;
SET character_set_client = @saved_cs_client;
DROP TABLE IF EXISTS `best_swimmer5y_results`;
/*!50001 DROP VIEW IF EXISTS `best_swimmer5y_results`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8mb4;
/*!50001 CREATE VIEW `best_swimmer5y_results` AS SELECT
 1 AS `swimmer_id`,
  1 AS `swimmer_name`,
  1 AS `swimmer_year_of_birth`,
  1 AS `gender_type_id`,
  1 AS `event_type_id`,
  1 AS `event_type_code`,
  1 AS `pool_type_id`,
  1 AS `pool_type_code`,
  1 AS `season_id`,
  1 AS `season_header_year`,
  1 AS `meeting_individual_result_id`,
  1 AS `minutes`,
  1 AS `seconds`,
  1 AS `hundredths`,
  1 AS `total_hundredths`,
  1 AS `meeting_id`,
  1 AS `meeting_date`,
  1 AS `meeting_name`,
  1 AS `team_id`,
  1 AS `team_name` */;
SET character_set_client = @saved_cs_client;
DROP TABLE IF EXISTS `best_swimmer_all_time_results`;
/*!50001 DROP VIEW IF EXISTS `best_swimmer_all_time_results`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8mb4;
/*!50001 CREATE VIEW `best_swimmer_all_time_results` AS SELECT
 1 AS `swimmer_id`,
  1 AS `swimmer_name`,
  1 AS `swimmer_year_of_birth`,
  1 AS `gender_type_id`,
  1 AS `event_type_id`,
  1 AS `event_type_code`,
  1 AS `pool_type_id`,
  1 AS `pool_type_code`,
  1 AS `season_id`,
  1 AS `season_header_year`,
  1 AS `meeting_individual_result_id`,
  1 AS `minutes`,
  1 AS `seconds`,
  1 AS `hundredths`,
  1 AS `total_hundredths`,
  1 AS `meeting_id`,
  1 AS `meeting_date`,
  1 AS `meeting_name`,
  1 AS `team_id`,
  1 AS `team_name` */;
SET character_set_client = @saved_cs_client;
DROP TABLE IF EXISTS `best_swimmer_current_vs_previous_results`;
/*!50001 DROP VIEW IF EXISTS `best_swimmer_current_vs_previous_results`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8mb4;
/*!50001 CREATE VIEW `best_swimmer_current_vs_previous_results` AS SELECT
 1 AS `swimmer_id`,
  1 AS `swimmer_name`,
  1 AS `swimmer_year_of_birth`,
  1 AS `gender_type_id`,
  1 AS `event_type_id`,
  1 AS `event_type_code`,
  1 AS `pool_type_id`,
  1 AS `pool_type_code`,
  1 AS `season_id`,
  1 AS `season_header_year`,
  1 AS `meeting_individual_result_id`,
  1 AS `minutes`,
  1 AS `seconds`,
  1 AS `hundredths`,
  1 AS `total_hundredths`,
  1 AS `meeting_id`,
  1 AS `meeting_date`,
  1 AS `meeting_name`,
  1 AS `team_id`,
  1 AS `team_name`,
  1 AS `old_meeting_individual_result_id`,
  1 AS `old_meeting_id`,
  1 AS `old_meeting_date`,
  1 AS `old_meeting_name`,
  1 AS `old_total_hundredths`,
  1 AS `old_minutes`,
  1 AS `old_seconds`,
  1 AS `old_hundredths` */;
SET character_set_client = @saved_cs_client;
DROP TABLE IF EXISTS `best_team_results_for_season`;
/*!50001 DROP VIEW IF EXISTS `best_team_results_for_season`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8mb4;
/*!50001 CREATE VIEW `best_team_results_for_season` AS SELECT
 1 AS `swimmer_id`,
  1 AS `swimmer_name`,
  1 AS `swimmer_year_of_birth`,
  1 AS `gender_type_id`,
  1 AS `gender_type_code`,
  1 AS `event_type_id`,
  1 AS `event_type_code`,
  1 AS `category_type_id`,
  1 AS `category_type_code`,
  1 AS `category_type_short_name`,
  1 AS `pool_type_id`,
  1 AS `pool_type_code`,
  1 AS `season_id`,
  1 AS `season_header_year`,
  1 AS `federation_type_id`,
  1 AS `meeting_individual_result_id`,
  1 AS `minutes`,
  1 AS `seconds`,
  1 AS `hundredths`,
  1 AS `total_hundredths`,
  1 AS `meeting_id`,
  1 AS `meeting_date`,
  1 AS `meeting_name`,
  1 AS `team_id`,
  1 AS `team_name` */;
SET character_set_client = @saved_cs_client;
DROP TABLE IF EXISTS `calendars`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `calendars` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) DEFAULT 0,
  `scheduled_date` varchar(255) DEFAULT NULL,
  `meeting_name` varchar(255) DEFAULT NULL,
  `meeting_place` varchar(255) DEFAULT NULL,
  `manifest_code` varchar(255) DEFAULT NULL,
  `startlist_code` varchar(255) DEFAULT NULL,
  `results_code` varchar(255) DEFAULT NULL,
  `meeting_code` varchar(255) DEFAULT NULL,
  `season_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `year` varchar(4) DEFAULT NULL,
  `month` varchar(20) DEFAULT NULL,
  `results_link` varchar(255) DEFAULT NULL,
  `startlist_link` varchar(255) DEFAULT NULL,
  `manifest_link` varchar(255) DEFAULT NULL,
  `manifest` text DEFAULT NULL,
  `name_import_text` text DEFAULT NULL,
  `organization_import_text` text DEFAULT NULL,
  `place_import_text` text DEFAULT NULL,
  `dates_import_text` text DEFAULT NULL,
  `program_import_text` text DEFAULT NULL,
  `meeting_id` int(11) DEFAULT NULL,
  `read_only` tinyint(1) NOT NULL DEFAULT 0,
  `cancelled` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `index_calendars_on_season_id` (`season_id`),
  KEY `index_calendars_on_meeting_id` (`meeting_id`),
  KEY `index_calendars_on_meeting_code` (`meeting_code`),
  KEY `index_calendars_on_cancelled` (`cancelled`)
) ENGINE=InnoDB AUTO_INCREMENT=9131 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `category_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `category_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) DEFAULT 0,
  `code` varchar(7) DEFAULT NULL,
  `federation_code` varchar(2) DEFAULT NULL,
  `description` varchar(100) DEFAULT NULL,
  `short_name` varchar(50) DEFAULT NULL,
  `group_name` varchar(50) DEFAULT NULL,
  `age_begin` mediumint(9) DEFAULT NULL,
  `age_end` mediumint(9) DEFAULT NULL,
  `relay` tinyint(1) DEFAULT 0,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `season_id` int(11) DEFAULT NULL,
  `out_of_race` tinyint(1) DEFAULT 0,
  `undivided` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `season_and_code` (`season_id`,`relay`,`code`),
  KEY `federation_code` (`federation_code`,`relay`)
) ENGINE=InnoDB AUTO_INCREMENT=200318 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `cities`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `cities` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) DEFAULT 0,
  `name` varchar(50) DEFAULT NULL,
  `zip` varchar(6) DEFAULT NULL,
  `area` varchar(50) DEFAULT NULL,
  `country` varchar(50) DEFAULT NULL,
  `country_code` varchar(10) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `latitude` varchar(50) DEFAULT NULL,
  `longitude` varchar(50) DEFAULT NULL,
  `plus_code` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_cities_on_country_code_and_area_and_name` (`country_code`,`area`,`name`),
  KEY `index_cities_on_name` (`name`),
  FULLTEXT KEY `city_name` (`name`,`area`)
) ENGINE=InnoDB AUTO_INCREMENT=478454 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `coach_level_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `coach_level_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) DEFAULT 0,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `code` varchar(5) DEFAULT NULL,
  `level` mediumint(9) DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_coach_level_types_on_code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `comments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `comments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) DEFAULT 0,
  `entry_text` varchar(255) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `swimming_pool_review_id` int(11) DEFAULT NULL,
  `comment_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_comments_swimming_pool_reviews` (`swimming_pool_review_id`),
  KEY `fk_comments_comments` (`comment_id`),
  KEY `idx_comments_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `computed_season_rankings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `computed_season_rankings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) DEFAULT 0,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `rank` int(11) DEFAULT 0,
  `total_points` decimal(10,2) DEFAULT 0.00,
  `team_id` int(11) DEFAULT NULL,
  `season_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `rank_x_season` (`season_id`,`rank`),
  KEY `teams_x_season` (`season_id`,`team_id`),
  KEY `fk_computed_season_rankings_teams` (`team_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4272 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `data_import_laps`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `data_import_laps` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `import_key` varchar(500) NOT NULL COMMENT 'Unique composite key for this lap',
  `parent_import_key` varchar(500) NOT NULL COMMENT 'Parent MIR import_key',
  `phase_file_path` varchar(500) DEFAULT NULL COMMENT 'Path to phase file source',
  `meeting_individual_result_id` int(11) DEFAULT NULL COMMENT 'Parent MIR DB ID',
  `lap_id` int(11) DEFAULT NULL COMMENT 'Existing Lap ID if matched',
  `length_in_meters` int(11) NOT NULL COMMENT 'Lap distance (50, 100, 150, etc.)',
  `minutes` mediumint(9) DEFAULT 0,
  `seconds` smallint(6) DEFAULT 0,
  `hundredths` smallint(6) DEFAULT 0,
  `reaction_time` decimal(5,2) DEFAULT 0.00,
  `stroke_cycles` int(11) DEFAULT 0,
  `underwater_kicks` int(11) DEFAULT 0,
  `underwater_seconds` int(11) DEFAULT 0,
  `breath_cycles` int(11) DEFAULT 0,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `minutes_from_start` mediumint(9) DEFAULT 0 COMMENT 'Minutes from race start',
  `seconds_from_start` smallint(6) DEFAULT 0 COMMENT 'Seconds from race start',
  `hundredths_from_start` smallint(6) DEFAULT 0 COMMENT 'Hundredths from race start',
  `meeting_individual_result_key` varchar(500) DEFAULT NULL COMMENT 'Parent MIR import_key reference',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_di_laps_import_key` (`import_key`),
  KEY `idx_di_laps_parent_key` (`parent_import_key`),
  KEY `idx_di_laps_mir_id` (`meeting_individual_result_id`),
  KEY `idx_di_laps_phase_file` (`phase_file_path`),
  KEY `idx_di_lap_mir_key` (`meeting_individual_result_key`)
) ENGINE=InnoDB AUTO_INCREMENT=147 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `data_import_meeting_individual_results`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `data_import_meeting_individual_results` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `import_key` varchar(500) NOT NULL COMMENT 'Unique composite key for this result',
  `phase_file_path` varchar(500) DEFAULT NULL COMMENT 'Path to phase file source',
  `meeting_program_id` int(11) DEFAULT NULL COMMENT 'DB ID if matched, null if new',
  `swimmer_id` int(11) DEFAULT NULL COMMENT 'DB ID from phase 3',
  `team_id` int(11) DEFAULT NULL COMMENT 'DB ID from phase 2',
  `badge_id` int(11) DEFAULT NULL COMMENT 'DB ID (calculated in phase 6)',
  `meeting_individual_result_id` int(11) DEFAULT NULL COMMENT 'Existing MIR ID if matched',
  `rank` int(11) NOT NULL DEFAULT 0,
  `minutes` mediumint(9) DEFAULT 0,
  `seconds` smallint(6) DEFAULT 0,
  `hundredths` smallint(6) DEFAULT 0,
  `disqualified` tinyint(1) NOT NULL DEFAULT 0,
  `disqualification_code_type_id` varchar(5) DEFAULT NULL,
  `standard_points` decimal(10,2) DEFAULT 0.00,
  `meeting_points` decimal(10,2) DEFAULT 0.00,
  `goggle_cup_points` decimal(10,2) DEFAULT 0.00,
  `reaction_time` decimal(5,2) DEFAULT 0.00,
  `team_points` int(11) DEFAULT 0,
  `out_of_race` tinyint(1) NOT NULL DEFAULT 0,
  `notes` varchar(500) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `swimmer_key` varchar(500) DEFAULT NULL COMMENT 'Swimmer key from phase3 (e.g., "ROSSI|Mario|1990")',
  `team_key` varchar(500) DEFAULT NULL COMMENT 'Team key from phase2 (e.g., "ASD Team Name")',
  `meeting_program_key` varchar(500) DEFAULT NULL COMMENT 'Program key (e.g., "1-100SL-M25-M")',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_di_mir_import_key` (`import_key`),
  KEY `idx_di_mir_program_id` (`meeting_program_id`),
  KEY `idx_di_mir_swimmer_id` (`swimmer_id`),
  KEY `idx_di_mir_team_id` (`team_id`),
  KEY `idx_di_mir_phase_file` (`phase_file_path`),
  KEY `idx_di_mir_swimmer_key` (`swimmer_key`),
  KEY `idx_di_mir_team_key` (`team_key`),
  KEY `idx_di_mir_program_key` (`meeting_program_key`)
) ENGINE=InnoDB AUTO_INCREMENT=1013 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `data_import_meeting_relay_results`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `data_import_meeting_relay_results` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `import_key` varchar(500) NOT NULL COMMENT 'Unique composite key for this relay result',
  `phase_file_path` varchar(500) DEFAULT NULL COMMENT 'Path to phase file source',
  `meeting_program_id` int(11) DEFAULT NULL COMMENT 'DB ID if matched, null if new',
  `team_id` int(11) DEFAULT NULL COMMENT 'DB ID from phase 2',
  `team_affiliation_id` int(11) DEFAULT NULL COMMENT 'DB ID (calculated in phase 6)',
  `meeting_relay_result_id` int(11) DEFAULT NULL COMMENT 'Existing MRR ID if matched',
  `rank` int(11) NOT NULL DEFAULT 0,
  `minutes` mediumint(9) DEFAULT 0,
  `seconds` smallint(6) DEFAULT 0,
  `hundredths` smallint(6) DEFAULT 0,
  `relay_code` varchar(60) DEFAULT '' COMMENT 'Relay team code/name',
  `disqualified` tinyint(1) NOT NULL DEFAULT 0,
  `disqualification_code_type_id` varchar(5) DEFAULT NULL,
  `standard_points` decimal(10,2) DEFAULT 0.00,
  `meeting_points` decimal(10,2) DEFAULT 0.00,
  `reaction_time` decimal(5,2) DEFAULT 0.00,
  `team_points` int(11) DEFAULT 0,
  `out_of_race` tinyint(1) NOT NULL DEFAULT 0,
  `notes` varchar(500) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `team_key` varchar(500) DEFAULT NULL COMMENT 'Team key from phase2',
  `meeting_program_key` varchar(500) DEFAULT NULL COMMENT 'Program key (e.g., "1-4X50SL-M100-F")',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_di_mrr_import_key` (`import_key`),
  KEY `idx_di_mrr_program_id` (`meeting_program_id`),
  KEY `idx_di_mrr_team_id` (`team_id`),
  KEY `idx_di_mrr_phase_file` (`phase_file_path`),
  KEY `idx_di_mrr_team_key` (`team_key`),
  KEY `idx_di_mrr_program_key` (`meeting_program_key`)
) ENGINE=InnoDB AUTO_INCREMENT=2801 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `data_import_meeting_relay_swimmers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `data_import_meeting_relay_swimmers` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `import_key` varchar(500) NOT NULL COMMENT 'Unique composite key for this relay swimmer',
  `parent_import_key` varchar(500) NOT NULL COMMENT 'Parent MRR import_key',
  `phase_file_path` varchar(500) DEFAULT NULL COMMENT 'Path to phase file source',
  `meeting_relay_result_id` int(11) DEFAULT NULL COMMENT 'Parent MRR DB ID',
  `swimmer_id` int(11) DEFAULT NULL COMMENT 'DB ID from phase 3',
  `badge_id` int(11) DEFAULT NULL COMMENT 'DB ID (calculated in phase 6)',
  `meeting_relay_swimmer_id` int(11) DEFAULT NULL COMMENT 'Existing MRS ID if matched',
  `relay_order` int(11) NOT NULL DEFAULT 0 COMMENT 'Order within relay (1-4)',
  `minutes` mediumint(9) DEFAULT 0,
  `seconds` smallint(6) DEFAULT 0,
  `hundredths` smallint(6) DEFAULT 0,
  `length_in_meters` int(11) DEFAULT 0,
  `reaction_time` decimal(5,2) DEFAULT 0.00,
  `stroke_cycles` int(11) DEFAULT 0,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `minutes_from_start` mediumint(9) DEFAULT 0 COMMENT 'Minutes from race start',
  `seconds_from_start` smallint(6) DEFAULT 0 COMMENT 'Seconds from race start',
  `hundredths_from_start` smallint(6) DEFAULT 0 COMMENT 'Hundredths from race start',
  `swimmer_key` varchar(500) DEFAULT NULL COMMENT 'Swimmer key from phase3 (e.g., "GRAZIANI|Fabio|1958")',
  `meeting_relay_result_key` varchar(500) DEFAULT NULL COMMENT 'Parent MRR import_key reference',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_di_mrs_import_key` (`import_key`),
  KEY `idx_di_mrs_parent_key` (`parent_import_key`),
  KEY `idx_di_mrs_mrr_id` (`meeting_relay_result_id`),
  KEY `idx_di_mrs_swimmer_id` (`swimmer_id`),
  KEY `idx_di_mrs_phase_file` (`phase_file_path`),
  KEY `idx_di_mrs_swimmer_key` (`swimmer_key`),
  KEY `idx_di_mrs_mrr_key` (`meeting_relay_result_key`)
) ENGINE=InnoDB AUTO_INCREMENT=8677 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `data_import_relay_laps`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `data_import_relay_laps` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `import_key` varchar(500) NOT NULL COMMENT 'Unique composite key for this relay lap',
  `parent_import_key` varchar(500) NOT NULL COMMENT 'Parent MRR import_key',
  `phase_file_path` varchar(500) DEFAULT NULL COMMENT 'Path to phase file source',
  `meeting_relay_result_id` int(11) DEFAULT NULL COMMENT 'Parent MRR DB ID',
  `relay_lap_id` int(11) DEFAULT NULL COMMENT 'Existing RelayLap ID if matched',
  `length_in_meters` int(11) NOT NULL COMMENT 'Lap distance (50, 100, 150, etc.)',
  `minutes` mediumint(9) DEFAULT 0,
  `seconds` smallint(6) DEFAULT 0,
  `hundredths` smallint(6) DEFAULT 0,
  `reaction_time` decimal(5,2) DEFAULT 0.00,
  `stroke_cycles` int(11) DEFAULT 0,
  `underwater_kicks` int(11) DEFAULT 0,
  `underwater_seconds` int(11) DEFAULT 0,
  `breath_cycles` int(11) DEFAULT 0,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `minutes_from_start` mediumint(9) DEFAULT 0 COMMENT 'Minutes from race start',
  `seconds_from_start` smallint(6) DEFAULT 0 COMMENT 'Seconds from race start',
  `hundredths_from_start` smallint(6) DEFAULT 0 COMMENT 'Hundredths from race start',
  `meeting_relay_swimmer_key` varchar(500) DEFAULT NULL COMMENT 'Parent MRS import_key reference',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_di_rel_laps_import_key` (`import_key`),
  KEY `idx_di_rel_laps_parent_key` (`parent_import_key`),
  KEY `idx_di_rel_laps_mrr_id` (`meeting_relay_result_id`),
  KEY `idx_di_rel_laps_phase_file` (`phase_file_path`),
  KEY `idx_di_rlap_mrs_key` (`meeting_relay_swimmer_key`)
) ENGINE=InnoDB AUTO_INCREMENT=7591 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `day_part_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `day_part_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) DEFAULT 0,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `code` varchar(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_day_part_types_on_code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `day_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `day_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) DEFAULT 0,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `code` varchar(6) DEFAULT NULL,
  `week_order` mediumint(9) DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_day_types_on_code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `disqualification_code_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `disqualification_code_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) DEFAULT 0,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `code` varchar(4) DEFAULT NULL,
  `relay` tinyint(1) DEFAULT 0,
  `stroke_type_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`relay`,`code`),
  KEY `idx_disqualification_code_types_stroke_type` (`stroke_type_id`),
  KEY `index_disqualification_code_types_on_relay` (`relay`)
) ENGINE=InnoDB AUTO_INCREMENT=61 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `edition_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `edition_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) DEFAULT 0,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `code` varchar(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_edition_types_on_code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `entry_time_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `entry_time_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) DEFAULT 0,
  `code` varchar(1) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_entry_time_types_code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `event_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `event_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) DEFAULT 0,
  `code` varchar(10) DEFAULT NULL,
  `length_in_meters` bigint(20) DEFAULT NULL,
  `relay` tinyint(1) DEFAULT 0,
  `stroke_type_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `style_order` smallint(6) DEFAULT 0,
  `mixed_gender` tinyint(1) DEFAULT 0,
  `partecipants` smallint(6) DEFAULT 4,
  `phases` smallint(6) DEFAULT 4,
  `phase_length_in_meters` mediumint(9) DEFAULT 50,
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`relay`,`code`),
  KEY `fk_event_types_stroke_types` (`stroke_type_id`),
  KEY `index_event_types_on_style_order` (`style_order`),
  KEY `index_event_types_on_relay` (`relay`)
) ENGINE=InnoDB AUTO_INCREMENT=42 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `events_by_pool_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `events_by_pool_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) DEFAULT 0,
  `pool_type_id` int(11) DEFAULT NULL,
  `event_type_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_events_by_pool_types_pool_types` (`pool_type_id`),
  KEY `fk_events_by_pool_types_event_types` (`event_type_id`)
) ENGINE=InnoDB AUTO_INCREMENT=68 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `execution_note_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `execution_note_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) DEFAULT 0,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `code` varchar(3) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_execution_note_types_on_code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `exercise_rows`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `exercise_rows` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) DEFAULT 0,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `part_order` mediumint(9) DEFAULT 0,
  `percentage` mediumint(9) DEFAULT 0,
  `start_and_rest` int(11) DEFAULT 0,
  `pause` int(11) DEFAULT 0,
  `exercise_id` int(11) DEFAULT NULL,
  `base_movement_id` int(11) DEFAULT NULL,
  `training_mode_type_id` int(11) DEFAULT NULL,
  `execution_note_type_id` int(11) DEFAULT NULL,
  `length_in_meters` int(11) DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_exercise_rows_part_order` (`exercise_id`,`part_order`),
  KEY `fk_exercise_rows_base_movements` (`base_movement_id`),
  KEY `fk_exercise_rows_training_mode_types` (`training_mode_type_id`),
  KEY `fk_exercise_rows_execution_note_types` (`execution_note_type_id`)
) ENGINE=InnoDB AUTO_INCREMENT=427 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `exercises`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `exercises` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) DEFAULT 0,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `code` varchar(6) DEFAULT NULL,
  `training_step_type_codes` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_exercises_on_code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=312 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `federation_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `federation_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) DEFAULT 0,
  `code` varchar(4) DEFAULT NULL,
  `description` varchar(100) DEFAULT NULL,
  `short_name` varchar(10) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_federation_types_on_code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=187 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `friendships`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `friendships` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `friendable_id` int(11) DEFAULT NULL,
  `friend_id` int(11) DEFAULT NULL,
  `blocker_id` int(11) DEFAULT NULL,
  `pending` tinyint(1) DEFAULT 1,
  `shares_passages` tinyint(1) DEFAULT 0,
  `shares_trainings` tinyint(1) DEFAULT 0,
  `shares_calendars` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_friendships_on_friendable_id_and_friend_id` (`friendable_id`,`friend_id`)
) ENGINE=InnoDB AUTO_INCREMENT=634 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `gender_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `gender_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) DEFAULT 0,
  `code` varchar(1) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_gender_types_on_code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `goggle_cup_definitions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `goggle_cup_definitions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) DEFAULT 0,
  `goggle_cup_id` int(11) DEFAULT NULL,
  `season_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_goggle_cup_definitions_goggle_cups` (`goggle_cup_id`),
  KEY `fk_goggle_cup_definitions_seasons` (`season_id`)
) ENGINE=InnoDB AUTO_INCREMENT=40 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `goggle_cup_standards`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `goggle_cup_standards` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) DEFAULT 0,
  `minutes` mediumint(9) DEFAULT 0,
  `seconds` smallint(6) DEFAULT 0,
  `hundredths` smallint(6) DEFAULT 0,
  `event_type_id` int(11) DEFAULT NULL,
  `pool_type_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `reaction_time` decimal(5,2) DEFAULT 0.00,
  `goggle_cup_id` int(11) DEFAULT NULL,
  `swimmer_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_goggle_cup_standards_goggle_cup_swimmer_pool_event` (`goggle_cup_id`,`swimmer_id`,`pool_type_id`,`event_type_id`),
  KEY `fk_goggle_cup_standards_goggle_cups` (`goggle_cup_id`),
  KEY `fk_goggle_cup_standards_event_types` (`event_type_id`),
  KEY `fk_goggle_cup_standards_pool_types` (`pool_type_id`),
  KEY `fk_goggle_cup_standards_swimmers` (`swimmer_id`)
) ENGINE=InnoDB AUTO_INCREMENT=14535 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `goggle_cups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `goggle_cups` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) DEFAULT 0,
  `description` varchar(60) DEFAULT NULL,
  `season_year` int(11) DEFAULT 2010,
  `max_points` int(11) DEFAULT 1000,
  `team_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `max_performance` smallint(6) DEFAULT 5,
  `limited_to_existing_season_types` tinyint(1) NOT NULL DEFAULT 0,
  `end_date` date DEFAULT NULL,
  `age_for_negative_modifier` int(11) DEFAULT 20,
  `negative_modifier` decimal(10,2) DEFAULT -10.00,
  `age_for_positive_modifier` int(11) DEFAULT 60,
  `positive_modifier` decimal(10,2) DEFAULT 5.00,
  `create_standards` tinyint(1) DEFAULT 1,
  `update_standards` tinyint(1) DEFAULT 0,
  `pre_calculation_sql` text DEFAULT NULL,
  `post_calculation_sql` text DEFAULT NULL,
  `team_constrained` tinyint(1) DEFAULT 1,
  `career_step` int(11) DEFAULT 100,
  `career_bonus` decimal(10,2) DEFAULT 0.00,
  `swimmers_ids` text DEFAULT NULL,
  `ranking_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`ranking_data`)),
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_goggle_cups_team_year_desc` (`team_id`,`season_year`,`description`),
  KEY `idx_season_year` (`season_year`),
  KEY `fk_goggle_cups_teams` (`team_id`),
  CONSTRAINT `fk_goggle_cups_teams` FOREIGN KEY (`team_id`) REFERENCES `teams` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1301 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `goggles_cup_3y_base_timings`;
/*!50001 DROP VIEW IF EXISTS `goggles_cup_3y_base_timings`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8mb4;
/*!50001 CREATE VIEW `goggles_cup_3y_base_timings` AS SELECT
 1 AS `swimmer_id`,
  1 AS `swimmer_name`,
  1 AS `swimmer_year_of_birth`,
  1 AS `gender_type_id`,
  1 AS `event_type_id`,
  1 AS `event_type_code`,
  1 AS `pool_type_id`,
  1 AS `pool_type_code`,
  1 AS `season_id`,
  1 AS `season_header_year`,
  1 AS `meeting_individual_result_id`,
  1 AS `minutes`,
  1 AS `seconds`,
  1 AS `hundredths`,
  1 AS `total_hundredths`,
  1 AS `meeting_id`,
  1 AS `meeting_date`,
  1 AS `meeting_name`,
  1 AS `team_id`,
  1 AS `team_name` */;
SET character_set_client = @saved_cs_client;
DROP TABLE IF EXISTS `hair_dryer_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `hair_dryer_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) DEFAULT 0,
  `code` varchar(3) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_hair_dryer_types_on_code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `heat_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `heat_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) DEFAULT 0,
  `code` varchar(10) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `default` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_heat_types_code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `import_queues`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `import_queues` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) DEFAULT 0,
  `user_id` bigint(20) NOT NULL,
  `process_runs` int(11) DEFAULT 0,
  `request_data` text NOT NULL,
  `solved_data` text NOT NULL,
  `done` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `uid` varchar(255) DEFAULT NULL,
  `bindings_left_count` int(11) NOT NULL DEFAULT 0,
  `bindings_left_list` varchar(255) DEFAULT NULL,
  `error_messages` text DEFAULT NULL,
  `import_queue_id` int(11) DEFAULT NULL,
  `batch_sql` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `index_import_queues_on_user_id` (`user_id`),
  KEY `index_import_queues_on_done` (`done`),
  KEY `index_import_queues_on_user_id_and_uid` (`user_id`,`uid`),
  KEY `index_import_queues_on_import_queue_id` (`import_queue_id`),
  KEY `index_import_queues_on_batch_sql` (`batch_sql`)
) ENGINE=InnoDB AUTO_INCREMENT=62025 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `individual_records`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `individual_records` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) DEFAULT 0,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `pool_type_id` int(11) DEFAULT NULL,
  `event_type_id` int(11) DEFAULT NULL,
  `category_type_id` int(11) DEFAULT NULL,
  `gender_type_id` int(11) DEFAULT NULL,
  `minutes` mediumint(9) DEFAULT 0,
  `seconds` smallint(6) DEFAULT 0,
  `hundredths` smallint(6) DEFAULT 0,
  `team_record` tinyint(1) DEFAULT 0,
  `swimmer_id` int(11) DEFAULT NULL,
  `team_id` int(11) DEFAULT NULL,
  `season_id` int(11) DEFAULT NULL,
  `federation_type_id` int(11) DEFAULT NULL,
  `meeting_individual_result_id` int(11) DEFAULT NULL,
  `record_type_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_individual_records_record_types` (`record_type_id`),
  KEY `idx_individual_records_pool_type` (`pool_type_id`),
  KEY `idx_individual_records_event_type` (`event_type_id`),
  KEY `idx_individual_records_category_type` (`category_type_id`),
  KEY `idx_individual_records_gender_type` (`gender_type_id`),
  KEY `idx_individual_records_swimmer` (`swimmer_id`),
  KEY `idx_individual_records_team` (`team_id`),
  KEY `idx_individual_records_season` (`season_id`),
  KEY `idx_individual_records_federation_type` (`federation_type_id`),
  KEY `idx_individual_records_meeting_individual_result` (`meeting_individual_result_id`)
) ENGINE=InnoDB AUTO_INCREMENT=267346 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `issues`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `issues` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `code` varchar(3) NOT NULL,
  `req` text NOT NULL,
  `priority` tinyint(4) DEFAULT 0,
  `status` tinyint(4) DEFAULT 0,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_issues_on_user_id` (`user_id`),
  KEY `index_issues_on_code` (`code`),
  KEY `index_issues_on_priority` (`priority`),
  KEY `index_issues_on_status` (`status`),
  CONSTRAINT `fk_rails_f8f1052133` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=105508 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `laps`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `laps` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) DEFAULT 0,
  `minutes` mediumint(9) DEFAULT 0,
  `seconds` smallint(6) DEFAULT 0,
  `hundredths` smallint(6) DEFAULT 0,
  `meeting_program_id` int(11) DEFAULT NULL,
  `length_in_meters` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `reaction_time` decimal(5,2) DEFAULT NULL,
  `stroke_cycles` mediumint(9) DEFAULT NULL,
  `underwater_seconds` smallint(6) DEFAULT NULL,
  `underwater_hundredths` smallint(6) DEFAULT NULL,
  `underwater_kicks` smallint(6) DEFAULT NULL,
  `breath_cycles` mediumint(9) DEFAULT NULL,
  `position` mediumint(9) DEFAULT NULL,
  `minutes_from_start` mediumint(9) DEFAULT NULL,
  `seconds_from_start` smallint(6) DEFAULT NULL,
  `hundredths_from_start` smallint(6) DEFAULT NULL,
  `meeting_individual_result_id` int(11) DEFAULT NULL,
  `swimmer_id` int(11) DEFAULT NULL,
  `team_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `passages_x_badges` (`meeting_program_id`),
  KEY `idx_passages_meeting_individual_result` (`meeting_individual_result_id`),
  KEY `idx_passages_swimmer` (`swimmer_id`),
  KEY `idx_passages_team` (`team_id`),
  KEY `index_laps_on_length_in_meters` (`length_in_meters`),
  CONSTRAINT `fk_rails_a33a36dd83` FOREIGN KEY (`swimmer_id`) REFERENCES `swimmers` (`id`),
  CONSTRAINT `fk_rails_c073154702` FOREIGN KEY (`team_id`) REFERENCES `teams` (`id`),
  CONSTRAINT `fk_rails_d2251ad180` FOREIGN KEY (`meeting_individual_result_id`) REFERENCES `meeting_individual_results` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=32349 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `last_seasons_ids`;
/*!50001 DROP VIEW IF EXISTS `last_seasons_ids`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8mb4;
/*!50001 CREATE VIEW `last_seasons_ids` AS SELECT
 1 AS `id` */;
SET character_set_client = @saved_cs_client;
DROP TABLE IF EXISTS `locker_cabinet_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `locker_cabinet_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) DEFAULT 0,
  `code` varchar(3) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_locker_cabinet_types_on_code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `managed_affiliations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `managed_affiliations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) DEFAULT 0,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `team_affiliation_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `team_manager_with_affiliation` (`team_affiliation_id`,`user_id`),
  KEY `index_managed_affiliations_on_team_affiliation_id` (`team_affiliation_id`),
  KEY `index_managed_affiliations_on_user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=18489 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `medal_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `medal_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) DEFAULT 0,
  `code` varchar(1) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `rank` int(11) DEFAULT 0,
  `weigth` int(11) DEFAULT 0,
  `image_uri` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_medal_types_on_code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `meeting_entries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `meeting_entries` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) DEFAULT 0,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `start_list_number` int(11) DEFAULT NULL,
  `lane_number` smallint(6) DEFAULT NULL,
  `heat_number` int(11) DEFAULT NULL,
  `heat_arrival_order` smallint(6) DEFAULT NULL,
  `meeting_program_id` int(11) DEFAULT NULL,
  `swimmer_id` int(11) DEFAULT NULL,
  `team_id` int(11) DEFAULT NULL,
  `team_affiliation_id` int(11) DEFAULT NULL,
  `badge_id` int(11) DEFAULT NULL,
  `entry_time_type_id` int(11) DEFAULT NULL,
  `minutes` mediumint(9) DEFAULT NULL,
  `seconds` smallint(6) DEFAULT NULL,
  `hundredths` smallint(6) DEFAULT NULL,
  `no_time` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_meeting_entries_meeting_program` (`meeting_program_id`),
  KEY `idx_meeting_entries_swimmer` (`swimmer_id`),
  KEY `idx_meeting_entries_team` (`team_id`),
  KEY `idx_meeting_entries_team_affiliation` (`team_affiliation_id`),
  KEY `idx_meeting_entries_badge` (`badge_id`),
  KEY `idx_meeting_entries_entry_time_type` (`entry_time_type_id`)
) ENGINE=InnoDB AUTO_INCREMENT=34408 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `meeting_event_reservations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `meeting_event_reservations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `meeting_id` int(11) DEFAULT NULL,
  `team_id` int(11) DEFAULT NULL,
  `swimmer_id` int(11) DEFAULT NULL,
  `badge_id` int(11) DEFAULT NULL,
  `meeting_event_id` int(11) DEFAULT NULL,
  `minutes` mediumint(9) DEFAULT NULL,
  `seconds` smallint(6) DEFAULT NULL,
  `hundredths` smallint(6) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `accepted` tinyint(1) NOT NULL DEFAULT 0,
  `meeting_reservation_id` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_unique_event_reservation` (`meeting_id`,`badge_id`,`team_id`,`swimmer_id`,`meeting_event_id`),
  KEY `index_meeting_event_reservations_on_meeting_id` (`meeting_id`),
  KEY `index_meeting_event_reservations_on_team_id` (`team_id`),
  KEY `index_meeting_event_reservations_on_swimmer_id` (`swimmer_id`),
  KEY `index_meeting_event_reservations_on_badge_id` (`badge_id`),
  KEY `index_meeting_event_reservations_on_meeting_event_id` (`meeting_event_id`),
  KEY `index_meeting_event_reservations_on_meeting_reservation_id` (`meeting_reservation_id`),
  CONSTRAINT `fk_rails_0af8d54bdb` FOREIGN KEY (`badge_id`) REFERENCES `badges` (`id`),
  CONSTRAINT `fk_rails_322431943b` FOREIGN KEY (`swimmer_id`) REFERENCES `swimmers` (`id`),
  CONSTRAINT `fk_rails_6cc7a28bdd` FOREIGN KEY (`meeting_id`) REFERENCES `meetings` (`id`),
  CONSTRAINT `fk_rails_e8541cd824` FOREIGN KEY (`meeting_event_id`) REFERENCES `meeting_events` (`id`),
  CONSTRAINT `fk_rails_f9b61694b4` FOREIGN KEY (`team_id`) REFERENCES `teams` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=36579 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `meeting_events`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `meeting_events` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) DEFAULT 0,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `event_order` mediumint(9) DEFAULT 0,
  `begin_time` time DEFAULT NULL,
  `out_of_race` tinyint(1) DEFAULT 0,
  `autofilled` tinyint(1) DEFAULT 0,
  `notes` text DEFAULT NULL,
  `meeting_session_id` int(11) DEFAULT NULL,
  `event_type_id` int(11) DEFAULT NULL,
  `heat_type_id` int(11) DEFAULT NULL,
  `split_gender_start_list` tinyint(1) DEFAULT 1,
  `split_category_start_list` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `fk_meeting_events_meeting_sessions` (`meeting_session_id`),
  KEY `fk_meeting_events_event_types` (`event_type_id`),
  KEY `fk_meeting_events_heat_types` (`heat_type_id`)
) ENGINE=InnoDB AUTO_INCREMENT=192809 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `meeting_individual_result_rows`;
/*!50001 DROP VIEW IF EXISTS `meeting_individual_result_rows`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8mb4;
/*!50001 CREATE VIEW `meeting_individual_result_rows` AS SELECT
 1 AS `meeting_individual_result_id`,
  1 AS `meeting_id`,
  1 AS `meeting_session_id`,
  1 AS `session_order`,
  1 AS `meeting_event_id`,
  1 AS `event_order`,
  1 AS `event_type_id`,
  1 AS `event_type_code`,
  1 AS `meeting_program_id`,
  1 AS `pool_type_id`,
  1 AS `category_type_id`,
  1 AS `category_code`,
  1 AS `category_age_begin`,
  1 AS `gender_type_id`,
  1 AS `gender_type_code`,
  1 AS `season_id`,
  1 AS `season_type_id`,
  1 AS `season_header_year`,
  1 AS `rank`,
  1 AS `minutes`,
  1 AS `seconds`,
  1 AS `hundredths`,
  1 AS `total_hundredths`,
  1 AS `reaction_time`,
  1 AS `standard_points`,
  1 AS `meeting_points`,
  1 AS `goggle_cup_points`,
  1 AS `out_of_race`,
  1 AS `disqualified`,
  1 AS `disqualification_notes`,
  1 AS `swimmer_id`,
  1 AS `swimmer_complete_name`,
  1 AS `swimmer_year_of_birth`,
  1 AS `swimmer_gender_type_id`,
  1 AS `team_id`,
  1 AS `team_name`,
  1 AS `team_editable_name`,
  1 AS `badge_id`,
  1 AS `updated_at`,
  1 AS `laps_count`,
  1 AS `laps_json` */;
SET character_set_client = @saved_cs_client;
DROP TABLE IF EXISTS `meeting_individual_results`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `meeting_individual_results` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) DEFAULT 0,
  `rank` int(11) DEFAULT 0,
  `play_off` tinyint(1) DEFAULT 0,
  `out_of_race` tinyint(1) DEFAULT 0,
  `disqualified` tinyint(1) DEFAULT 0,
  `standard_points` decimal(10,2) DEFAULT 0.00,
  `meeting_points` decimal(10,2) DEFAULT 0.00,
  `minutes` mediumint(9) DEFAULT 0,
  `seconds` smallint(6) DEFAULT 0,
  `hundredths` smallint(6) DEFAULT 0,
  `meeting_program_id` int(11) DEFAULT NULL,
  `swimmer_id` int(11) DEFAULT NULL,
  `team_id` int(11) DEFAULT NULL,
  `badge_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `disqualification_code_type_id` int(11) DEFAULT NULL,
  `goggle_cup_points` decimal(10,2) DEFAULT 0.00,
  `reaction_time` decimal(5,2) DEFAULT 0.00,
  `team_points` decimal(10,2) DEFAULT 0.00,
  `team_affiliation_id` int(11) DEFAULT NULL,
  `personal_best` tinyint(1) NOT NULL DEFAULT 0,
  `season_type_best` tinyint(1) NOT NULL DEFAULT 0,
  `disqualification_notes` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_meeting_individual_results_meeting_programs` (`meeting_program_id`),
  KEY `fk_meeting_individual_results_swimmers` (`swimmer_id`),
  KEY `fk_meeting_individual_results_teams` (`team_id`),
  KEY `fk_meeting_individual_results_badges` (`badge_id`),
  KEY `fk_meeting_individual_results_team_affiliations` (`team_affiliation_id`),
  KEY `idx_mir_disqualification_code_type` (`disqualification_code_type_id`),
  KEY `idx_meeting_individual_results_updated_at` (`updated_at`),
  KEY `index_meeting_individual_results_on_out_of_race` (`out_of_race`),
  KEY `index_meeting_individual_results_on_disqualified` (`disqualified`),
  KEY `index_meeting_individual_results_on_personal_best` (`personal_best`),
  KEY `index_meeting_individual_results_on_season_type_best` (`season_type_best`)
) ENGINE=InnoDB AUTO_INCREMENT=889718 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `meeting_programs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `meeting_programs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) DEFAULT 0,
  `event_order` mediumint(9) DEFAULT 0,
  `category_type_id` int(11) DEFAULT NULL,
  `gender_type_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `autofilled` tinyint(1) DEFAULT 0,
  `out_of_race` tinyint(1) DEFAULT 0,
  `begin_time` time DEFAULT NULL,
  `meeting_event_id` int(11) DEFAULT NULL,
  `pool_type_id` int(11) DEFAULT NULL,
  `standard_timing_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `meeting_category_type` (`category_type_id`),
  KEY `meeting_gender_type` (`gender_type_id`),
  KEY `meeting_order` (`event_order`),
  KEY `fk_meeting_programs_meeting_events` (`meeting_event_id`),
  KEY `fk_meeting_programs_pool_types` (`pool_type_id`),
  KEY `fk_meeting_programs_time_standards` (`standard_timing_id`)
) ENGINE=InnoDB AUTO_INCREMENT=384629 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `meeting_relay_reservations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `meeting_relay_reservations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `meeting_id` int(11) DEFAULT NULL,
  `team_id` int(11) DEFAULT NULL,
  `swimmer_id` int(11) DEFAULT NULL,
  `badge_id` int(11) DEFAULT NULL,
  `meeting_event_id` int(11) DEFAULT NULL,
  `notes` varchar(50) DEFAULT NULL,
  `accepted` tinyint(1) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `meeting_reservation_id` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_unique_relay_reservation` (`meeting_id`,`badge_id`,`team_id`,`swimmer_id`,`meeting_event_id`),
  KEY `index_meeting_relay_reservations_on_meeting_id` (`meeting_id`),
  KEY `index_meeting_relay_reservations_on_team_id` (`team_id`),
  KEY `index_meeting_relay_reservations_on_swimmer_id` (`swimmer_id`),
  KEY `index_meeting_relay_reservations_on_badge_id` (`badge_id`),
  KEY `index_meeting_relay_reservations_on_meeting_event_id` (`meeting_event_id`),
  KEY `index_meeting_relay_reservations_on_meeting_reservation_id` (`meeting_reservation_id`),
  CONSTRAINT `fk_rails_04ccf0080e` FOREIGN KEY (`team_id`) REFERENCES `teams` (`id`),
  CONSTRAINT `fk_rails_2d3860ae23` FOREIGN KEY (`meeting_id`) REFERENCES `meetings` (`id`),
  CONSTRAINT `fk_rails_a15976fb75` FOREIGN KEY (`badge_id`) REFERENCES `badges` (`id`),
  CONSTRAINT `fk_rails_adf945379a` FOREIGN KEY (`swimmer_id`) REFERENCES `swimmers` (`id`),
  CONSTRAINT `fk_rails_bd2a0aa40d` FOREIGN KEY (`meeting_event_id`) REFERENCES `meeting_events` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10295 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `meeting_relay_result_rows`;
/*!50001 DROP VIEW IF EXISTS `meeting_relay_result_rows`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8mb4;
/*!50001 CREATE VIEW `meeting_relay_result_rows` AS SELECT
 1 AS `meeting_relay_result_id`,
  1 AS `meeting_id`,
  1 AS `meeting_session_id`,
  1 AS `session_order`,
  1 AS `meeting_event_id`,
  1 AS `event_order`,
  1 AS `event_type_id`,
  1 AS `event_type_code`,
  1 AS `meeting_program_id`,
  1 AS `pool_type_id`,
  1 AS `category_type_id`,
  1 AS `category_code`,
  1 AS `category_age_begin`,
  1 AS `gender_type_id`,
  1 AS `gender_type_code`,
  1 AS `season_id`,
  1 AS `season_type_id`,
  1 AS `season_header_year`,
  1 AS `rank`,
  1 AS `minutes`,
  1 AS `seconds`,
  1 AS `hundredths`,
  1 AS `total_hundredths`,
  1 AS `reaction_time`,
  1 AS `standard_points`,
  1 AS `meeting_points`,
  1 AS `out_of_race`,
  1 AS `disqualified`,
  1 AS `disqualification_notes`,
  1 AS `relay_code`,
  1 AS `team_id`,
  1 AS `team_name`,
  1 AS `team_editable_name`,
  1 AS `updated_at`,
  1 AS `meeting_relay_swimmers_count`,
  1 AS `relay_swimmers_json`,
  1 AS `relay_laps_json` */;
SET character_set_client = @saved_cs_client;
DROP TABLE IF EXISTS `meeting_relay_results`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `meeting_relay_results` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) DEFAULT 0,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `rank` int(11) DEFAULT 0,
  `play_off` tinyint(1) DEFAULT 0,
  `out_of_race` tinyint(1) DEFAULT 0,
  `disqualified` tinyint(1) DEFAULT 0,
  `standard_points` decimal(10,2) DEFAULT 0.00,
  `meeting_points` decimal(10,2) DEFAULT 0.00,
  `minutes` mediumint(9) DEFAULT 0,
  `seconds` smallint(6) DEFAULT 0,
  `hundredths` smallint(6) DEFAULT 0,
  `team_id` int(11) DEFAULT NULL,
  `meeting_program_id` int(11) DEFAULT NULL,
  `disqualification_code_type_id` int(11) DEFAULT NULL,
  `relay_code` varchar(60) DEFAULT '',
  `reaction_time` decimal(5,2) DEFAULT 0.00,
  `entry_minutes` mediumint(9) DEFAULT NULL,
  `entry_seconds` smallint(6) DEFAULT NULL,
  `entry_hundredths` smallint(6) DEFAULT NULL,
  `team_affiliation_id` int(11) DEFAULT NULL,
  `entry_time_type_id` int(11) DEFAULT NULL,
  `disqualification_notes` varchar(255) DEFAULT NULL,
  `meeting_relay_swimmers_count` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `fk_meeting_relay_results_teams` (`team_id`),
  KEY `results_x_relay` (`meeting_program_id`,`rank`),
  KEY `fk_meeting_relay_results_team_affiliations` (`team_affiliation_id`),
  KEY `fk_meeting_relay_results_entry_time_types` (`entry_time_type_id`),
  KEY `idx_mrr_disqualification_code_type` (`disqualification_code_type_id`)
) ENGINE=InnoDB AUTO_INCREMENT=69670 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `meeting_relay_swimmers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `meeting_relay_swimmers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) DEFAULT 0,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `relay_order` mediumint(9) DEFAULT 0,
  `swimmer_id` int(11) DEFAULT NULL,
  `badge_id` int(11) DEFAULT NULL,
  `stroke_type_id` int(11) DEFAULT NULL,
  `reaction_time` decimal(5,2) DEFAULT 0.00,
  `minutes` mediumint(9) DEFAULT 0,
  `seconds` smallint(6) DEFAULT 0,
  `hundredths` smallint(6) DEFAULT 0,
  `meeting_relay_result_id` int(11) DEFAULT NULL,
  `length_in_meters` int(11) DEFAULT 0,
  `minutes_from_start` mediumint(9) DEFAULT 0,
  `seconds_from_start` smallint(6) DEFAULT 0,
  `hundredths_from_start` smallint(6) DEFAULT 0,
  `relay_laps_count` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `fk_meeting_relay_swimmers_swimmers` (`swimmer_id`),
  KEY `fk_meeting_relay_swimmers_badges` (`badge_id`),
  KEY `fk_meeting_relay_swimmers_stroke_types` (`stroke_type_id`),
  KEY `relay_order` (`relay_order`),
  KEY `fk_meeting_relay_swimmers_meeting_relay_results` (`meeting_relay_result_id`)
) ENGINE=InnoDB AUTO_INCREMENT=33465 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `meeting_reservations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `meeting_reservations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `meeting_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `team_id` int(11) DEFAULT NULL,
  `swimmer_id` int(11) DEFAULT NULL,
  `badge_id` int(11) DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `not_coming` tinyint(1) DEFAULT NULL,
  `confirmed` tinyint(1) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `payed` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_unique_reservation` (`meeting_id`,`badge_id`),
  KEY `index_meeting_reservations_on_meeting_id` (`meeting_id`),
  KEY `index_meeting_reservations_on_user_id` (`user_id`),
  KEY `index_meeting_reservations_on_team_id` (`team_id`),
  KEY `index_meeting_reservations_on_swimmer_id` (`swimmer_id`),
  KEY `index_meeting_reservations_on_badge_id` (`badge_id`),
  KEY `index_meeting_reservations_on_payed` (`payed`),
  CONSTRAINT `fk_rails_3ad1c5f3de` FOREIGN KEY (`team_id`) REFERENCES `teams` (`id`),
  CONSTRAINT `fk_rails_4082a84a07` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_rails_449dc9078e` FOREIGN KEY (`badge_id`) REFERENCES `badges` (`id`),
  CONSTRAINT `fk_rails_54be3a08b1` FOREIGN KEY (`swimmer_id`) REFERENCES `swimmers` (`id`),
  CONSTRAINT `fk_rails_bc62b0fc13` FOREIGN KEY (`meeting_id`) REFERENCES `meetings` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=25285 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `meeting_sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `meeting_sessions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) DEFAULT 0,
  `session_order` smallint(6) DEFAULT 0,
  `scheduled_date` date DEFAULT NULL,
  `warm_up_time` time DEFAULT NULL,
  `begin_time` time DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `meeting_id` int(11) DEFAULT NULL,
  `swimming_pool_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `description` varchar(100) DEFAULT NULL,
  `autofilled` tinyint(1) DEFAULT 0,
  `day_part_type_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_meeting_sessions_on_scheduled_date` (`scheduled_date`),
  KEY `fk_meeting_sessions_meetings` (`meeting_id`),
  KEY `fk_meeting_sessions_swimming_pools` (`swimming_pool_id`),
  KEY `fk_meeting_sessions_day_part_types` (`day_part_type_id`)
) ENGINE=InnoDB AUTO_INCREMENT=166913 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `meeting_team_scores`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `meeting_team_scores` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) DEFAULT 0,
  `sum_individual_points` decimal(10,2) DEFAULT 0.00,
  `sum_relay_points` decimal(10,2) DEFAULT 0.00,
  `team_id` int(11) DEFAULT NULL,
  `meeting_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `rank` int(11) DEFAULT 0,
  `sum_team_points` decimal(10,2) DEFAULT 0.00,
  `meeting_points` decimal(10,2) DEFAULT 0.00,
  `meeting_relay_points` decimal(10,2) DEFAULT 0.00,
  `meeting_team_points` decimal(10,2) DEFAULT 0.00,
  `season_points` decimal(10,2) DEFAULT 0.00,
  `season_relay_points` decimal(10,2) DEFAULT 0.00,
  `season_team_points` decimal(10,2) DEFAULT 0.00,
  `season_id` int(11) DEFAULT NULL,
  `team_affiliation_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `teams_x_meeting` (`meeting_id`,`team_id`),
  KEY `fk_meeting_team_scores_teams` (`team_id`),
  KEY `fk_meeting_team_scores_seasons` (`season_id`),
  KEY `fk_meeting_team_scores_team_affiliations` (`team_affiliation_id`)
) ENGINE=InnoDB AUTO_INCREMENT=41892 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `meetings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `meetings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) DEFAULT 0,
  `description` varchar(100) DEFAULT NULL,
  `entry_deadline` date DEFAULT NULL,
  `warm_up_pool` tinyint(1) DEFAULT 0,
  `allows_under25` tinyint(1) DEFAULT 0,
  `reference_phone` varchar(40) DEFAULT NULL,
  `reference_e_mail` varchar(50) DEFAULT NULL,
  `reference_name` varchar(50) DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `manifest` tinyint(1) DEFAULT 0,
  `startlist` tinyint(1) DEFAULT 0,
  `results_acquired` tinyint(1) DEFAULT 0,
  `max_individual_events` tinyint(4) DEFAULT 2,
  `configuration_file` varchar(255) DEFAULT NULL,
  `edition` mediumint(9) DEFAULT 0,
  `season_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `autofilled` tinyint(1) DEFAULT 0,
  `header_date` date DEFAULT NULL,
  `code` varchar(50) DEFAULT NULL,
  `header_year` varchar(9) DEFAULT NULL,
  `max_individual_events_per_session` smallint(6) DEFAULT 2,
  `off_season` tinyint(1) DEFAULT 0,
  `edition_type_id` int(11) DEFAULT NULL,
  `timing_type_id` int(11) DEFAULT NULL,
  `individual_score_computation_type_id` int(11) DEFAULT NULL,
  `relay_score_computation_type_id` int(11) DEFAULT NULL,
  `team_score_computation_type_id` int(11) DEFAULT NULL,
  `meeting_score_computation_type_id` int(11) DEFAULT NULL,
  `manifest_body` mediumtext DEFAULT NULL,
  `confirmed` tinyint(1) NOT NULL DEFAULT 0,
  `tweeted` tinyint(1) DEFAULT 0,
  `posted` tinyint(1) DEFAULT 0,
  `cancelled` tinyint(1) DEFAULT 0,
  `pb_acquired` tinyint(1) DEFAULT 0,
  `home_team_id` bigint(20) DEFAULT NULL,
  `read_only` tinyint(1) NOT NULL DEFAULT 0,
  `meeting_fee` decimal(10,2) DEFAULT NULL,
  `event_fee` decimal(10,2) DEFAULT NULL,
  `relay_fee` decimal(10,2) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_meetings_on_entry_deadline` (`entry_deadline`),
  KEY `fk_meetings_seasons` (`season_id`),
  KEY `idx_meetings_header_date` (`header_date`),
  KEY `idx_meetings_code` (`code`,`edition`),
  KEY `fk_meetings_edition_types` (`edition_type_id`),
  KEY `fk_meetings_timing_types` (`timing_type_id`),
  KEY `fk_meetings_score_individual_score_computation_types` (`individual_score_computation_type_id`),
  KEY `fk_meetings_score_relay_score_computation_types` (`relay_score_computation_type_id`),
  KEY `fk_meetings_score_team_score_computation_types` (`team_score_computation_type_id`),
  KEY `fk_meetings_score_meeting_score_computation_types` (`meeting_score_computation_type_id`),
  KEY `index_meetings_on_home_team_id` (`home_team_id`),
  FULLTEXT KEY `meeting_name` (`description`,`code`),
  FULLTEXT KEY `meeting_code` (`code`),
  FULLTEXT KEY `meeting_desc` (`description`)
) ENGINE=InnoDB AUTO_INCREMENT=234340 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `movement_scope_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `movement_scope_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) DEFAULT 0,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `code` varchar(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_movement_scope_types_on_code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `movement_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `movement_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) DEFAULT 0,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `code` varchar(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_movement_types_on_code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `pool_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `pool_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) DEFAULT 0,
  `code` varchar(3) DEFAULT NULL,
  `length_in_meters` mediumint(9) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `eventable` tinyint(1) DEFAULT 1,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_pool_types_on_code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `posts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `posts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) DEFAULT 0,
  `title` varchar(80) DEFAULT NULL,
  `body` text DEFAULT NULL,
  `pinned` tinyint(1) DEFAULT 0,
  `user_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_articles_user` (`user_id`),
  KEY `index_posts_on_title` (`title`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `presence_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `presence_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) DEFAULT 0,
  `code` varchar(1) DEFAULT NULL,
  `value` mediumint(9) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_presence_types_on_code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `rails_admin_histories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `rails_admin_histories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `message` text DEFAULT NULL,
  `username` varchar(255) DEFAULT NULL,
  `item` int(11) DEFAULT NULL,
  `table` varchar(255) DEFAULT NULL,
  `month` smallint(6) DEFAULT NULL,
  `year` bigint(20) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_rails_admin_histories` (`item`,`table`,`month`,`year`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `record_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `record_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) DEFAULT 0,
  `code` varchar(3) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `swimmer` tinyint(1) DEFAULT 0,
  `team` tinyint(1) DEFAULT 0,
  `season` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_record_types_on_code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `relay_laps`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `relay_laps` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `minutes` mediumint(9) DEFAULT 0,
  `seconds` smallint(6) DEFAULT 0,
  `hundredths` smallint(6) DEFAULT 0,
  `minutes_from_start` mediumint(9) DEFAULT 0,
  `seconds_from_start` smallint(6) DEFAULT 0,
  `hundredths_from_start` smallint(6) DEFAULT 0,
  `reaction_time` decimal(5,2) DEFAULT 0.00,
  `length_in_meters` int(11) DEFAULT 0,
  `position` mediumint(9) DEFAULT NULL,
  `stroke_cycles` int(11) DEFAULT NULL,
  `breath_cycles` int(11) DEFAULT NULL,
  `swimmer_id` int(11) NOT NULL,
  `team_id` int(11) NOT NULL,
  `meeting_relay_result_id` int(11) NOT NULL,
  `meeting_relay_swimmer_id` int(11) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_relay_laps_on_swimmer_id` (`swimmer_id`),
  KEY `index_relay_laps_on_team_id` (`team_id`),
  KEY `index_relay_laps_on_meeting_relay_result_id` (`meeting_relay_result_id`),
  KEY `index_relay_laps_on_meeting_relay_swimmer_id` (`meeting_relay_swimmer_id`),
  CONSTRAINT `fk_rails_53cb030570` FOREIGN KEY (`meeting_relay_result_id`) REFERENCES `meeting_relay_results` (`id`),
  CONSTRAINT `fk_rails_96252ccdc9` FOREIGN KEY (`meeting_relay_swimmer_id`) REFERENCES `meeting_relay_swimmers` (`id`),
  CONSTRAINT `fk_rails_a75b7d8484` FOREIGN KEY (`swimmer_id`) REFERENCES `swimmers` (`id`),
  CONSTRAINT `fk_rails_c42747b923` FOREIGN KEY (`team_id`) REFERENCES `teams` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8293 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `schema_migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `schema_migrations` (
  `version` varchar(255) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `score_computation_type_rows`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `score_computation_type_rows` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) DEFAULT 0,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `class_name` varchar(100) DEFAULT NULL,
  `method_name` varchar(100) DEFAULT NULL,
  `default_score` decimal(10,2) DEFAULT 0.00,
  `score_computation_type_id` int(11) DEFAULT NULL,
  `score_mapping_type_id` int(11) DEFAULT NULL,
  `computation_order` bigint(20) DEFAULT 0,
  `position_limit` int(11) DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `fk_score_computation_type_rows_score_computation_types` (`score_computation_type_id`),
  KEY `idx_score_computation_type_rows_computation_order` (`computation_order`),
  KEY `idx_score_computation_type_rows_score_mapping_type` (`score_mapping_type_id`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `score_computation_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `score_computation_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) DEFAULT 0,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `code` varchar(6) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_score_computation_types_on_code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `score_mapping_type_rows`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `score_mapping_type_rows` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) DEFAULT 0,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `position` bigint(20) DEFAULT 0,
  `score` decimal(10,2) DEFAULT 0.00,
  `score_mapping_type_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_score_mapping_type_rows_score_mapping_type` (`score_mapping_type_id`)
) ENGINE=InnoDB AUTO_INCREMENT=94 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `score_mapping_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `score_mapping_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) DEFAULT 0,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `code` varchar(6) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_score_mapping_types_on_code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `season_personal_standards`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `season_personal_standards` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) DEFAULT 0,
  `minutes` mediumint(9) NOT NULL DEFAULT 0,
  `seconds` smallint(6) NOT NULL DEFAULT 0,
  `hundredths` smallint(6) NOT NULL DEFAULT 0,
  `season_id` int(11) DEFAULT NULL,
  `swimmer_id` int(11) DEFAULT NULL,
  `event_type_id` int(11) DEFAULT NULL,
  `pool_type_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_season_personal_standards_season_swimmer_event_pool` (`season_id`,`swimmer_id`,`pool_type_id`,`event_type_id`),
  KEY `idx_season_personal_standards_season_id` (`season_id`),
  KEY `idx_season_personal_standards_swimmer_id` (`swimmer_id`)
) ENGINE=InnoDB AUTO_INCREMENT=18839 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `season_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `season_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) DEFAULT 0,
  `code` varchar(10) DEFAULT NULL,
  `description` varchar(100) DEFAULT NULL,
  `short_name` varchar(40) DEFAULT NULL,
  `federation_type_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_season_types_on_code` (`code`),
  KEY `fk_season_types_federation_types` (`federation_type_id`)
) ENGINE=InnoDB AUTO_INCREMENT=57 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `seasons`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `seasons` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) DEFAULT 0,
  `description` varchar(100) DEFAULT NULL,
  `begin_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `season_type_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `header_year` varchar(9) DEFAULT NULL,
  `edition` mediumint(9) DEFAULT 0,
  `edition_type_id` int(11) DEFAULT NULL,
  `timing_type_id` int(11) DEFAULT NULL,
  `rules` mediumtext DEFAULT NULL,
  `individual_rank` tinyint(1) DEFAULT 1,
  `badge_fee` decimal(10,2) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_seasons_on_begin_date` (`begin_date`),
  KEY `fk_seasons_season_types` (`season_type_id`),
  KEY `fk_seasons_edition_types` (`edition_type_id`),
  KEY `fk_seasons_timing_types` (`timing_type_id`)
) ENGINE=InnoDB AUTO_INCREMENT=503362 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `sessions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `session_id` varchar(255) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
  `data` text DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_sessions_on_session_id` (`session_id`),
  KEY `index_sessions_on_updated_at` (`updated_at`)
) ENGINE=InnoDB AUTO_INCREMENT=7591 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `settings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `var` varchar(255) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `value` text DEFAULT NULL,
  `target_type` varchar(255) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `target_id` int(11) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_settings_on_target_type_and_target_id_and_var` (`target_type`,`target_id`,`var`),
  KEY `index_settings_on_target_type_and_target_id` (`target_type`,`target_id`)
) ENGINE=InnoDB AUTO_INCREMENT=108 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `shower_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `shower_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) DEFAULT 0,
  `code` varchar(3) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_shower_types_on_code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `social_news`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `social_news` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(150) DEFAULT NULL,
  `body` text DEFAULT NULL,
  `old` tinyint(1) DEFAULT 0,
  `friend_activity` tinyint(1) DEFAULT 0,
  `achievement` tinyint(1) DEFAULT 0,
  `user_id` int(11) DEFAULT NULL,
  `friend_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_news_feeds_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=99 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `standard_timings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `standard_timings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) DEFAULT 0,
  `minutes` mediumint(9) DEFAULT 0,
  `seconds` smallint(6) DEFAULT 0,
  `hundredths` smallint(6) DEFAULT 0,
  `season_id` int(11) DEFAULT NULL,
  `gender_type_id` int(11) DEFAULT NULL,
  `pool_type_id` int(11) DEFAULT NULL,
  `event_type_id` int(11) DEFAULT NULL,
  `category_type_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_time_standards_seasons` (`season_id`),
  KEY `fk_time_standards_gender_types` (`gender_type_id`),
  KEY `fk_time_standards_pool_types` (`pool_type_id`),
  KEY `fk_time_standards_event_types` (`event_type_id`),
  KEY `fk_time_standards_category_types` (`category_type_id`)
) ENGINE=InnoDB AUTO_INCREMENT=21014 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `stroke_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `stroke_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) DEFAULT 0,
  `code` varchar(2) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `eventable` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_stroke_types_on_code` (`code`),
  KEY `idx_is_eventable` (`eventable`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `swimmer_aliases`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `swimmer_aliases` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) DEFAULT 0,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `complete_name` varchar(100) DEFAULT NULL,
  `swimmer_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_swimmer_id_complete_name` (`swimmer_id`,`complete_name`)
) ENGINE=InnoDB AUTO_INCREMENT=2025 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `swimmer_level_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `swimmer_level_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) DEFAULT 0,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `code` varchar(5) DEFAULT NULL,
  `level` mediumint(9) DEFAULT 0,
  `achievement_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_swimmer_level_types_on_code` (`code`),
  KEY `idx_swimmer_level_types_achievement` (`achievement_id`)
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `swimmer_season_scores`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `swimmer_season_scores` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) DEFAULT 0,
  `score` decimal(10,2) DEFAULT NULL,
  `badge_id` int(11) DEFAULT NULL,
  `meeting_individual_result_id` int(11) DEFAULT NULL,
  `event_type_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_swimmer_season_scores_on_badge_id` (`badge_id`),
  KEY `index_swimmer_season_scores_on_meeting_individual_result_id` (`meeting_individual_result_id`),
  KEY `index_swimmer_season_scores_on_event_type_id` (`event_type_id`),
  KEY `swimmer_season_scores_badge_event` (`badge_id`,`event_type_id`),
  KEY `swimmer_season_scores_badge_score` (`badge_id`,`score`),
  CONSTRAINT `fk_rails_1432a7d1c3` FOREIGN KEY (`event_type_id`) REFERENCES `event_types` (`id`),
  CONSTRAINT `fk_rails_a56323b1df` FOREIGN KEY (`badge_id`) REFERENCES `badges` (`id`),
  CONSTRAINT `fk_rails_da93d4e994` FOREIGN KEY (`meeting_individual_result_id`) REFERENCES `meeting_individual_results` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `swimmers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `swimmers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) DEFAULT 0,
  `last_name` varchar(50) DEFAULT NULL,
  `first_name` varchar(50) DEFAULT NULL,
  `year_of_birth` int(11) DEFAULT 1900,
  `phone_mobile` varchar(40) DEFAULT NULL,
  `phone_number` varchar(40) DEFAULT NULL,
  `e_mail` varchar(100) DEFAULT NULL,
  `nickname` varchar(25) DEFAULT '',
  `associated_user_id` bigint(20) DEFAULT NULL,
  `gender_type_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `complete_name` varchar(100) DEFAULT NULL,
  `year_guessed` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name_and_year` (`complete_name`,`year_of_birth`),
  KEY `full_name` (`last_name`,`first_name`),
  KEY `index_swimmers_on_nickname` (`nickname`),
  KEY `index_swimmers_on_associated_user_id` (`associated_user_id`),
  KEY `fk_swimmers_gender_types` (`gender_type_id`),
  KEY `index_swimmers_on_complete_name` (`complete_name`),
  FULLTEXT KEY `swimmer_name` (`last_name`,`first_name`,`complete_name`),
  FULLTEXT KEY `swimmer_first_name` (`first_name`),
  FULLTEXT KEY `swimmer_last_name` (`last_name`),
  FULLTEXT KEY `swimmer_complete_name` (`complete_name`)
) ENGINE=InnoDB AUTO_INCREMENT=275806 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `swimming_pool_reviews`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `swimming_pool_reviews` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) DEFAULT 0,
  `title` varchar(100) DEFAULT NULL,
  `entry_text` text DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `swimming_pool_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_swimming_pool_reviews_on_title` (`title`),
  KEY `fk_swimming_pool_reviews_swimming_pools` (`swimming_pool_id`),
  KEY `idx_swimming_pool_reviews_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `swimming_pools`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `swimming_pools` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) DEFAULT 0,
  `name` varchar(100) DEFAULT NULL,
  `address` varchar(100) DEFAULT NULL,
  `zip` varchar(6) DEFAULT NULL,
  `nick_name` varchar(50) DEFAULT NULL,
  `phone_number` varchar(40) DEFAULT NULL,
  `fax_number` varchar(40) DEFAULT NULL,
  `e_mail` varchar(100) DEFAULT NULL,
  `contact_name` varchar(100) DEFAULT NULL,
  `maps_uri` varchar(255) DEFAULT NULL,
  `lanes_number` smallint(6) DEFAULT 8,
  `multiple_pools` tinyint(1) DEFAULT 0,
  `garden` tinyint(1) DEFAULT 0,
  `bar` tinyint(1) DEFAULT 0,
  `restaurant` tinyint(1) DEFAULT 0,
  `gym` tinyint(1) DEFAULT 0,
  `child_area` tinyint(1) DEFAULT 0,
  `notes` text DEFAULT NULL,
  `city_id` int(11) DEFAULT NULL,
  `pool_type_id` int(11) DEFAULT NULL,
  `shower_type_id` int(11) DEFAULT NULL,
  `hair_dryer_type_id` int(11) DEFAULT NULL,
  `locker_cabinet_type_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `read_only` tinyint(1) NOT NULL DEFAULT 0,
  `latitude` varchar(50) DEFAULT NULL,
  `longitude` varchar(50) DEFAULT NULL,
  `plus_code` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_swimming_pools_on_nick_name` (`nick_name`),
  KEY `index_swimming_pools_on_name` (`name`),
  KEY `fk_swimming_pools_cities` (`city_id`),
  KEY `fk_swimming_pools_pool_types` (`pool_type_id`),
  KEY `fk_swimming_pools_shower_types` (`shower_type_id`),
  KEY `fk_swimming_pools_hair_dryer_types` (`hair_dryer_type_id`),
  KEY `fk_swimming_pools_locker_cabinet_types` (`locker_cabinet_type_id`),
  FULLTEXT KEY `swimming_pool_name` (`name`,`nick_name`)
) ENGINE=InnoDB AUTO_INCREMENT=193944 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `taggings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `taggings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `tag_id` int(11) DEFAULT NULL,
  `taggable_id` int(11) DEFAULT NULL,
  `taggable_type` varchar(255) DEFAULT NULL,
  `tagger_id` int(11) DEFAULT NULL,
  `tagger_type` varchar(255) DEFAULT NULL,
  `context` varchar(128) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `taggings_idx` (`tag_id`,`taggable_id`,`taggable_type`,`context`,`tagger_id`,`tagger_type`),
  KEY `index_taggings_on_taggable_id_and_taggable_type_and_context` (`taggable_id`,`taggable_type`,`context`),
  KEY `index_taggings_on_tag_id` (`tag_id`),
  KEY `index_taggings_on_taggable_id` (`taggable_id`),
  KEY `index_taggings_on_taggable_type` (`taggable_type`),
  KEY `index_taggings_on_tagger_id` (`tagger_id`),
  KEY `index_taggings_on_context` (`context`),
  KEY `index_taggings_on_tagger_id_and_tagger_type` (`tagger_id`,`tagger_type`),
  KEY `taggings_idy` (`taggable_id`,`taggable_type`,`tagger_id`,`context`)
) ENGINE=InnoDB AUTO_INCREMENT=1829 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tags`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tags` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `taggings_count` int(11) DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_tags_on_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=1261 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `team_affiliations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `team_affiliations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) DEFAULT 0,
  `number` varchar(20) DEFAULT NULL,
  `name` varchar(100) DEFAULT NULL,
  `compute_gogglecup` tinyint(1) DEFAULT 0,
  `team_id` int(11) DEFAULT NULL,
  `season_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `autofilled` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_team_affiliations_seasons_teams` (`season_id`,`team_id`),
  KEY `index_team_affiliations_on_name` (`name`),
  KEY `fk_team_affiliations_teams` (`team_id`),
  KEY `index_team_affiliations_on_number` (`number`),
  FULLTEXT KEY `team_affiliation_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=238768 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `team_aliases`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `team_aliases` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) DEFAULT 0,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `name` varchar(60) DEFAULT NULL,
  `team_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_team_id_name` (`team_id`,`name`)
) ENGINE=InnoDB AUTO_INCREMENT=1854 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `team_lap_templates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `team_lap_templates` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) DEFAULT 0,
  `part_order` mediumint(9) DEFAULT 0,
  `subtotal` tinyint(1) DEFAULT 0,
  `cycle_count` tinyint(1) DEFAULT 0,
  `breath_count` tinyint(1) DEFAULT 0,
  `underwater_part` tinyint(1) DEFAULT 0,
  `underwater_kicks` tinyint(1) DEFAULT 0,
  `lap_position` tinyint(1) DEFAULT 0,
  `team_id` int(11) DEFAULT NULL,
  `event_type_id` int(11) DEFAULT NULL,
  `pool_type_id` int(11) DEFAULT NULL,
  `length_in_meters` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_team_passage_templates_team` (`team_id`),
  KEY `idx_team_passage_templates_event_type` (`event_type_id`),
  KEY `idx_team_passage_templates_pool_type` (`pool_type_id`),
  KEY `index_team_lap_templates_on_length_in_meters` (`length_in_meters`)
) ENGINE=InnoDB AUTO_INCREMENT=2488 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `teams`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `teams` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) DEFAULT 0,
  `name` varchar(60) DEFAULT NULL,
  `editable_name` varchar(60) DEFAULT NULL,
  `address` varchar(100) DEFAULT NULL,
  `zip` varchar(6) DEFAULT NULL,
  `phone_mobile` varchar(40) DEFAULT NULL,
  `phone_number` varchar(40) DEFAULT NULL,
  `fax_number` varchar(40) DEFAULT NULL,
  `e_mail` varchar(100) DEFAULT NULL,
  `contact_name` varchar(100) DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `name_variations` text DEFAULT NULL,
  `city_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `home_page_url` varchar(150) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_teams_on_name` (`name`),
  KEY `index_teams_on_editable_name` (`editable_name`),
  KEY `fk_teams_cities` (`city_id`),
  FULLTEXT KEY `team_name` (`name`,`editable_name`,`name_variations`),
  FULLTEXT KEY `team_only_name` (`name`),
  FULLTEXT KEY `team_editable_name` (`editable_name`),
  FULLTEXT KEY `team_name_variations` (`name_variations`)
) ENGINE=InnoDB AUTO_INCREMENT=287774 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `timing_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `timing_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) DEFAULT 0,
  `code` varchar(1) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_timing_types_on_code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `training_mode_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `training_mode_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) DEFAULT 0,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `code` varchar(5) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_training_mode_types_on_code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `training_rows`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `training_rows` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) DEFAULT 0,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `part_order` mediumint(9) DEFAULT 0,
  `times` mediumint(9) DEFAULT 0,
  `distance` int(11) DEFAULT 0,
  `start_and_rest` int(11) DEFAULT 0,
  `pause` int(11) DEFAULT 0,
  `training_id` int(11) DEFAULT NULL,
  `exercise_id` int(11) DEFAULT NULL,
  `training_step_type_id` int(11) DEFAULT NULL,
  `group_id` mediumint(9) DEFAULT 0,
  `group_times` mediumint(9) DEFAULT 0,
  `group_start_and_rest` int(11) DEFAULT 0,
  `group_pause` int(11) DEFAULT 0,
  `aux_arms_type_id` int(11) DEFAULT NULL,
  `aux_kicks_type_id` int(11) DEFAULT NULL,
  `aux_body_type_id` int(11) DEFAULT NULL,
  `aux_breath_type_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_training_rows_part_order` (`training_id`,`part_order`),
  KEY `fk_training_exercises` (`exercise_id`),
  KEY `fk_training_rows_training_step_types` (`training_step_type_id`),
  KEY `index_training_rows_on_group_id_and_part_order` (`group_id`,`part_order`),
  KEY `fk_training_rows_arm_aux_types` (`aux_arms_type_id`),
  KEY `fk_training_rows_kick_aux_types` (`aux_kicks_type_id`),
  KEY `fk_training_rows_body_aux_types` (`aux_body_type_id`),
  KEY `fk_training_rows_breath_aux_types` (`aux_breath_type_id`)
) ENGINE=InnoDB AUTO_INCREMENT=36 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `training_step_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `training_step_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) DEFAULT 0,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `code` varchar(1) DEFAULT NULL,
  `step_order` mediumint(9) DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_training_step_types_on_code` (`code`),
  KEY `index_training_step_types_on_step_order` (`step_order`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `trainings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `trainings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) DEFAULT 0,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `title` varchar(100) DEFAULT '',
  `training_date` datetime DEFAULT NULL,
  `training_by` varchar(100) DEFAULT NULL,
  `created_by` varchar(100) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `min_swimmer_level` mediumint(9) DEFAULT 0,
  `max_swimmer_level` mediumint(9) DEFAULT 0,
  `swimmer_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_trainings_on_title` (`title`),
  KEY `index_trainings_on_training_date` (`training_date`),
  KEY `index_trainings_on_swimmer_id` (`swimmer_id`),
  CONSTRAINT `fk_rails_4b1eac6ed8` FOREIGN KEY (`swimmer_id`) REFERENCES `swimmers` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=214 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `user_achievements`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_achievements` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) DEFAULT 0,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `achievement_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_user_achievements_on_user_id_and_achievement_id` (`user_id`,`achievement_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `user_laps`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_laps` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_result_id` int(11) NOT NULL,
  `swimmer_id` int(11) NOT NULL,
  `reaction_time` decimal(5,2) DEFAULT NULL,
  `minutes` mediumint(9) DEFAULT NULL,
  `seconds` smallint(6) DEFAULT NULL,
  `hundredths` smallint(6) DEFAULT NULL,
  `length_in_meters` int(11) DEFAULT NULL,
  `position` mediumint(9) DEFAULT NULL,
  `minutes_from_start` mediumint(9) DEFAULT NULL,
  `seconds_from_start` smallint(6) DEFAULT NULL,
  `hundredths_from_start` smallint(6) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_user_laps_on_user_result_id` (`user_result_id`),
  KEY `index_user_laps_on_swimmer_id` (`swimmer_id`),
  CONSTRAINT `fk_rails_3a8ef09ce9` FOREIGN KEY (`user_result_id`) REFERENCES `user_results` (`id`),
  CONSTRAINT `fk_rails_51835bd9c8` FOREIGN KEY (`swimmer_id`) REFERENCES `swimmers` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=15150 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `user_results`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_results` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) DEFAULT 0,
  `standard_points` decimal(10,2) DEFAULT 0.00,
  `meeting_points` decimal(10,2) DEFAULT 0.00,
  `rank` bigint(20) DEFAULT 0,
  `disqualified` tinyint(1) DEFAULT 0,
  `minutes` mediumint(9) DEFAULT 0,
  `seconds` smallint(6) DEFAULT 0,
  `hundredths` smallint(6) DEFAULT 0,
  `swimmer_id` int(11) DEFAULT NULL,
  `category_type_id` int(11) DEFAULT NULL,
  `pool_type_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `disqualification_code_type_id` int(11) DEFAULT NULL,
  `description` varchar(60) DEFAULT '',
  `event_date` date DEFAULT NULL,
  `reaction_time` decimal(10,2) DEFAULT 0.00,
  `event_type_id` int(11) DEFAULT NULL,
  `user_workshop_id` bigint(20) NOT NULL,
  `swimming_pool_id` bigint(20) DEFAULT NULL,
  `standard_timing_id` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_user_results_swimmers` (`swimmer_id`),
  KEY `fk_user_results_category_types` (`category_type_id`),
  KEY `fk_user_results_pool_types` (`pool_type_id`),
  KEY `fk_user_results_event_types` (`event_type_id`),
  KEY `idx_user_results_disqualification_code_type` (`disqualification_code_type_id`),
  KEY `fk_rails_e406f4db18` (`user_id`),
  KEY `index_user_results_on_user_workshop_id` (`user_workshop_id`),
  KEY `index_user_results_on_swimming_pool_id` (`swimming_pool_id`),
  KEY `index_user_results_on_standard_timing_id` (`standard_timing_id`),
  CONSTRAINT `fk_rails_6ac8587baa` FOREIGN KEY (`user_workshop_id`) REFERENCES `user_workshops` (`id`),
  CONSTRAINT `fk_rails_e406f4db18` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=25606 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `user_swimmer_confirmations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_swimmer_confirmations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) DEFAULT 0,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `swimmer_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `confirmator_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_swimmer_confirmator` (`user_id`,`swimmer_id`,`confirmator_id`),
  KEY `index_user_swimmer_confirmations_on_confirmator_id` (`confirmator_id`)
) ENGINE=InnoDB AUTO_INCREMENT=56 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `user_training_rows`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_training_rows` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) DEFAULT 0,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `part_order` mediumint(9) DEFAULT 0,
  `times` mediumint(9) DEFAULT 0,
  `distance` int(11) DEFAULT 0,
  `start_and_rest` int(11) DEFAULT 0,
  `pause` int(11) DEFAULT 0,
  `group_id` mediumint(9) DEFAULT 0,
  `group_times` mediumint(9) DEFAULT 0,
  `group_start_and_rest` int(11) DEFAULT 0,
  `group_pause` int(11) DEFAULT 0,
  `user_training_id` int(11) DEFAULT NULL,
  `exercise_id` int(11) DEFAULT NULL,
  `training_step_type_id` int(11) DEFAULT NULL,
  `aux_arms_type_id` int(11) DEFAULT NULL,
  `aux_kicks_type_id` int(11) DEFAULT NULL,
  `aux_body_type_id` int(11) DEFAULT NULL,
  `aux_breath_type_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_user_training_rows_part_order` (`user_training_id`,`part_order`),
  KEY `index_user_training_rows_on_group_id_and_part_order` (`group_id`,`part_order`),
  KEY `idx_user_training_rows_exercise` (`exercise_id`),
  KEY `idx_user_training_rows_training_step_type` (`training_step_type_id`),
  KEY `idx_user_training_rows_arm_aux_type` (`aux_arms_type_id`),
  KEY `idx_user_training_rows_kick_aux_type` (`aux_kicks_type_id`),
  KEY `idx_user_training_rows_body_aux_type` (`aux_body_type_id`),
  KEY `idx_user_training_rows_breath_aux_type` (`aux_breath_type_id`)
) ENGINE=InnoDB AUTO_INCREMENT=714 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `user_training_stories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_training_stories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) DEFAULT 0,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `swam_date` date DEFAULT NULL,
  `total_training_time` mediumint(9) DEFAULT 0,
  `notes` text DEFAULT NULL,
  `user_training_id` int(11) DEFAULT NULL,
  `swimming_pool_id` int(11) DEFAULT NULL,
  `swimmer_level_type_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_user_training_stories_on_user_training_id_and_swam_date` (`user_training_id`,`swam_date`),
  KEY `idx_user_training_stories_swimming_pool` (`swimming_pool_id`),
  KEY `idx_user_training_stories_swimmer_level_type` (`swimmer_level_type_id`),
  KEY `idx_user_training_stories_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=43 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `user_trainings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_trainings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) DEFAULT 0,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `description` varchar(250) DEFAULT '',
  `user_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_user_trainings_on_user_id_and_description` (`user_id`,`description`)
) ENGINE=InnoDB AUTO_INCREMENT=46 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `user_workshops`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_workshops` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) DEFAULT 0,
  `header_date` date DEFAULT NULL,
  `header_year` varchar(10) DEFAULT NULL,
  `code` varchar(80) DEFAULT NULL,
  `description` varchar(100) DEFAULT NULL,
  `edition` int(11) DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `user_id` int(11) NOT NULL,
  `team_id` int(11) NOT NULL,
  `season_id` int(11) NOT NULL,
  `edition_type_id` int(11) NOT NULL DEFAULT 3,
  `timing_type_id` int(11) NOT NULL DEFAULT 1,
  `swimming_pool_id` int(11) DEFAULT NULL,
  `autofilled` tinyint(1) NOT NULL DEFAULT 0,
  `off_season` tinyint(1) NOT NULL DEFAULT 0,
  `confirmed` tinyint(1) NOT NULL DEFAULT 0,
  `cancelled` tinyint(1) NOT NULL DEFAULT 0,
  `pb_acquired` tinyint(1) NOT NULL DEFAULT 0,
  `read_only` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_user_workshops_on_user_id` (`user_id`),
  KEY `index_user_workshops_on_team_id` (`team_id`),
  KEY `index_user_workshops_on_season_id` (`season_id`),
  KEY `index_user_workshops_on_edition_type_id` (`edition_type_id`),
  KEY `index_user_workshops_on_timing_type_id` (`timing_type_id`),
  KEY `index_user_workshops_on_swimming_pool_id` (`swimming_pool_id`),
  KEY `index_user_workshops_on_header_date` (`header_date`),
  KEY `index_user_workshops_on_header_year` (`header_year`),
  KEY `index_user_workshops_on_code` (`code`),
  FULLTEXT KEY `workshop_name` (`description`,`code`),
  FULLTEXT KEY `workshop_code` (`code`),
  FULLTEXT KEY `workshop_desc` (`description`),
  CONSTRAINT `fk_rails_1da8cf3948` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_rails_491714ee3b` FOREIGN KEY (`season_id`) REFERENCES `seasons` (`id`),
  CONSTRAINT `fk_rails_68db6bc5bc` FOREIGN KEY (`edition_type_id`) REFERENCES `edition_types` (`id`),
  CONSTRAINT `fk_rails_aa39033a10` FOREIGN KEY (`team_id`) REFERENCES `teams` (`id`),
  CONSTRAINT `fk_rails_ebe7a00465` FOREIGN KEY (`timing_type_id`) REFERENCES `timing_types` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=33230 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lock_version` int(11) DEFAULT 0,
  `name` varchar(190) NOT NULL,
  `description` varchar(100) DEFAULT NULL,
  `swimmer_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `email` varchar(190) NOT NULL,
  `encrypted_password` varchar(255) DEFAULT '',
  `reset_password_token` varchar(255) DEFAULT NULL,
  `reset_password_sent_at` datetime DEFAULT NULL,
  `remember_created_at` datetime DEFAULT NULL,
  `sign_in_count` int(11) DEFAULT 0,
  `current_sign_in_at` datetime DEFAULT NULL,
  `last_sign_in_at` datetime DEFAULT NULL,
  `current_sign_in_ip` varchar(255) DEFAULT NULL,
  `last_sign_in_ip` varchar(255) DEFAULT NULL,
  `confirmation_token` varchar(255) DEFAULT NULL,
  `confirmed_at` datetime DEFAULT NULL,
  `confirmation_sent_at` datetime DEFAULT NULL,
  `unconfirmed_email` varchar(255) DEFAULT NULL,
  `failed_attempts` int(11) DEFAULT 0,
  `unlock_token` varchar(255) DEFAULT NULL,
  `locked_at` datetime DEFAULT NULL,
  `avatar_url` text DEFAULT NULL,
  `swimmer_level_type_id` int(11) DEFAULT NULL,
  `coach_level_type_id` int(11) DEFAULT NULL,
  `jwt` varchar(255) DEFAULT NULL,
  `outstanding_goggle_score_bias` int(11) DEFAULT 800,
  `outstanding_standard_score_bias` int(11) DEFAULT 800,
  `last_name` varchar(50) DEFAULT NULL,
  `first_name` varchar(50) DEFAULT NULL,
  `year_of_birth` int(11) DEFAULT 1900,
  `provider` varchar(255) DEFAULT NULL,
  `uid` varchar(255) DEFAULT NULL,
  `active` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_users_on_name` (`name`),
  UNIQUE KEY `index_users_on_email` (`email`),
  UNIQUE KEY `index_users_on_reset_password_token` (`reset_password_token`),
  UNIQUE KEY `index_users_on_confirmation_token` (`confirmation_token`),
  UNIQUE KEY `index_users_on_unlock_token` (`unlock_token`),
  UNIQUE KEY `index_users_on_jwt` (`jwt`),
  KEY `full_name` (`last_name`,`first_name`,`year_of_birth`),
  KEY `idx_users_swimmer` (`swimmer_id`),
  KEY `idx_users_swimmer_level_type` (`swimmer_level_type_id`),
  KEY `idx_users_coach_level_type` (`coach_level_type_id`),
  KEY `index_users_on_active` (`active`)
) ENGINE=InnoDB AUTO_INCREMENT=487520 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `votes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `votes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `votable_id` int(11) DEFAULT NULL,
  `votable_type` varchar(255) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
  `voter_id` int(11) DEFAULT NULL,
  `voter_type` varchar(255) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
  `vote_flag` tinyint(1) DEFAULT NULL,
  `vote_scope` varchar(255) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
  `vote_weight` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_votes_on_votable_id_and_votable_type` (`votable_id`,`votable_type`),
  KEY `index_votes_on_voter_id_and_voter_type` (`voter_id`,`voter_type`),
  KEY `index_votes_on_voter_id_and_voter_type_and_vote_scope` (`voter_id`,`voter_type`,`vote_scope`),
  KEY `index_votes_on_votable_id_and_votable_type_and_vote_scope` (`votable_id`,`votable_type`,`vote_scope`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO,STRICT_TRANS_TABLES,STRICT_ALL_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP FUNCTION IF EXISTS `goggles_db_base_year` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` FUNCTION `goggles_db_base_year`() RETURNS int(11)
    READS SQL DATA
RETURN IFNULL( CAST(@base_year AS SIGNED), (SELECT CASE WHEN MONTH(s.begin_date) >= 9 THEN YEAR(s.begin_date) WHEN MONTH(s.begin_date) <= 5 THEN YEAR(s.begin_date) - 1 ELSE YEAR(s.end_date) END AS championship_year FROM seasons s WHERE s.end_date >= CURRENT_DATE() ORDER BY s.begin_date DESC, s.id DESC LIMIT 1) ) ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50001 DROP VIEW IF EXISTS `best_50_and_100_results`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `best_50_and_100_results` AS with RecentSeasons as (select `seasons`.`id` AS `id` from `seasons` where `seasons`.`end_date` >= curdate() - interval 3 year order by `seasons`.`end_date` desc), RankedResults as (select `mir`.`swimmer_id` AS `swimmer_id`,`s`.`complete_name` AS `swimmer_name`,`s`.`year_of_birth` AS `swimmer_year_of_birth`,`s`.`gender_type_id` AS `gender_type_id`,`me`.`event_type_id` AS `event_type_id`,`et`.`code` AS `event_type_code`,`mp`.`pool_type_id` AS `pool_type_id`,`pt`.`code` AS `pool_type_code`,`m`.`season_id` AS `season_id`,`se`.`header_year` AS `season_header_year`,`mir`.`id` AS `meeting_individual_result_id`,`mir`.`minutes` AS `minutes`,`mir`.`seconds` AS `seconds`,`mir`.`hundredths` AS `hundredths`,`mir`.`minutes` * 6000 + `mir`.`seconds` * 100 + `mir`.`hundredths` AS `total_hundredths`,`m`.`id` AS `meeting_id`,`m`.`header_date` AS `meeting_date`,`m`.`description` AS `meeting_name`,`t`.`id` AS `team_id`,`t`.`name` AS `team_name`,row_number() over ( partition by `mir`.`swimmer_id`,`me`.`event_type_id`,`mp`.`pool_type_id` order by `mir`.`minutes` * 6000 + `mir`.`seconds` * 100 + `mir`.`hundredths`,`m`.`header_date` desc) AS `rn` from ((((((((((`meeting_individual_results` `mir` join `meeting_programs` `mp` on(`mp`.`id` = `mir`.`meeting_program_id`)) join `meeting_events` `me` on(`me`.`id` = `mp`.`meeting_event_id`)) join `meeting_sessions` `ms` on(`ms`.`id` = `me`.`meeting_session_id`)) join `meetings` `m` on(`m`.`id` = `ms`.`meeting_id`)) join `seasons` `se` on(`se`.`id` = `m`.`season_id`)) join `event_types` `et` on(`et`.`id` = `me`.`event_type_id`)) join `pool_types` `pt` on(`pt`.`id` = `mp`.`pool_type_id`)) join `swimmers` `s` on(`s`.`id` = `mir`.`swimmer_id`)) join `teams` `t` on(`t`.`id` = `mir`.`team_id`)) join `RecentSeasons` `rs` on(`m`.`season_id` = `rs`.`id`)) where `mir`.`disqualified` = 0 and `mir`.`minutes` * 6000 + `mir`.`seconds` * 100 + `mir`.`hundredths` > 0 and `me`.`event_type_id` in (2,3,11,12,15,16,19,20,22) and `mp`.`pool_type_id` in (1,2))select `RankedResults`.`swimmer_id` AS `swimmer_id`,`RankedResults`.`swimmer_name` AS `swimmer_name`,`RankedResults`.`swimmer_year_of_birth` AS `swimmer_year_of_birth`,`RankedResults`.`gender_type_id` AS `gender_type_id`,`RankedResults`.`event_type_id` AS `event_type_id`,`RankedResults`.`event_type_code` AS `event_type_code`,`RankedResults`.`pool_type_id` AS `pool_type_id`,`RankedResults`.`pool_type_code` AS `pool_type_code`,`RankedResults`.`season_id` AS `season_id`,`RankedResults`.`season_header_year` AS `season_header_year`,`RankedResults`.`meeting_individual_result_id` AS `meeting_individual_result_id`,`RankedResults`.`minutes` AS `minutes`,`RankedResults`.`seconds` AS `seconds`,`RankedResults`.`hundredths` AS `hundredths`,`RankedResults`.`total_hundredths` AS `total_hundredths`,`RankedResults`.`meeting_id` AS `meeting_id`,`RankedResults`.`meeting_date` AS `meeting_date`,`RankedResults`.`meeting_name` AS `meeting_name`,`RankedResults`.`team_id` AS `team_id`,`RankedResults`.`team_name` AS `team_name` from `RankedResults` where `RankedResults`.`rn` = 1 */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!50001 DROP VIEW IF EXISTS `best_50_and_100_results5y`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `best_50_and_100_results5y` AS with RecentSeasons as (select `seasons`.`id` AS `id` from `seasons` where `seasons`.`end_date` >= curdate() - interval 5 year order by `seasons`.`end_date` desc), RankedResults as (select `mir`.`swimmer_id` AS `swimmer_id`,`s`.`complete_name` AS `swimmer_name`,`s`.`year_of_birth` AS `swimmer_year_of_birth`,`s`.`gender_type_id` AS `gender_type_id`,`me`.`event_type_id` AS `event_type_id`,`et`.`code` AS `event_type_code`,`mp`.`pool_type_id` AS `pool_type_id`,`pt`.`code` AS `pool_type_code`,`m`.`season_id` AS `season_id`,`se`.`header_year` AS `season_header_year`,`mir`.`id` AS `meeting_individual_result_id`,`mir`.`minutes` AS `minutes`,`mir`.`seconds` AS `seconds`,`mir`.`hundredths` AS `hundredths`,`mir`.`minutes` * 6000 + `mir`.`seconds` * 100 + `mir`.`hundredths` AS `total_hundredths`,`m`.`id` AS `meeting_id`,`m`.`header_date` AS `meeting_date`,`m`.`description` AS `meeting_name`,`t`.`id` AS `team_id`,`t`.`name` AS `team_name`,row_number() over ( partition by `mir`.`swimmer_id`,`me`.`event_type_id`,`mp`.`pool_type_id` order by `mir`.`minutes` * 6000 + `mir`.`seconds` * 100 + `mir`.`hundredths`,`m`.`header_date` desc) AS `rn` from ((((((((((`meeting_individual_results` `mir` join `meeting_programs` `mp` on(`mp`.`id` = `mir`.`meeting_program_id`)) join `meeting_events` `me` on(`me`.`id` = `mp`.`meeting_event_id`)) join `meeting_sessions` `ms` on(`ms`.`id` = `me`.`meeting_session_id`)) join `meetings` `m` on(`m`.`id` = `ms`.`meeting_id`)) join `seasons` `se` on(`se`.`id` = `m`.`season_id`)) join `event_types` `et` on(`et`.`id` = `me`.`event_type_id`)) join `pool_types` `pt` on(`pt`.`id` = `mp`.`pool_type_id`)) join `swimmers` `s` on(`s`.`id` = `mir`.`swimmer_id`)) join `teams` `t` on(`t`.`id` = `mir`.`team_id`)) join `RecentSeasons` `rs` on(`m`.`season_id` = `rs`.`id`)) where `mir`.`disqualified` = 0 and `mir`.`minutes` * 6000 + `mir`.`seconds` * 100 + `mir`.`hundredths` > 0 and `me`.`event_type_id` in (2,3,11,12,15,16,19,20,22) and `mp`.`pool_type_id` in (1,2))select `RankedResults`.`swimmer_id` AS `swimmer_id`,`RankedResults`.`swimmer_name` AS `swimmer_name`,`RankedResults`.`swimmer_year_of_birth` AS `swimmer_year_of_birth`,`RankedResults`.`gender_type_id` AS `gender_type_id`,`RankedResults`.`event_type_id` AS `event_type_id`,`RankedResults`.`event_type_code` AS `event_type_code`,`RankedResults`.`pool_type_id` AS `pool_type_id`,`RankedResults`.`pool_type_code` AS `pool_type_code`,`RankedResults`.`season_id` AS `season_id`,`RankedResults`.`season_header_year` AS `season_header_year`,`RankedResults`.`meeting_individual_result_id` AS `meeting_individual_result_id`,`RankedResults`.`minutes` AS `minutes`,`RankedResults`.`seconds` AS `seconds`,`RankedResults`.`hundredths` AS `hundredths`,`RankedResults`.`total_hundredths` AS `total_hundredths`,`RankedResults`.`meeting_id` AS `meeting_id`,`RankedResults`.`meeting_date` AS `meeting_date`,`RankedResults`.`meeting_name` AS `meeting_name`,`RankedResults`.`team_id` AS `team_id`,`RankedResults`.`team_name` AS `team_name` from `RankedResults` where `RankedResults`.`rn` = 1 */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!50001 DROP VIEW IF EXISTS `best_50m_results`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `best_50m_results` AS with RecentSeasons as (select `seasons`.`id` AS `id` from `seasons` where `seasons`.`end_date` >= curdate() - interval 3 year order by `seasons`.`end_date` desc), RankedResults as (select `mir`.`swimmer_id` AS `swimmer_id`,`s`.`complete_name` AS `swimmer_name`,`s`.`year_of_birth` AS `swimmer_year_of_birth`,`s`.`gender_type_id` AS `gender_type_id`,`me`.`event_type_id` AS `event_type_id`,`et`.`code` AS `event_type_code`,`mp`.`pool_type_id` AS `pool_type_id`,`pt`.`code` AS `pool_type_code`,`m`.`season_id` AS `season_id`,`se`.`header_year` AS `season_header_year`,`mir`.`id` AS `meeting_individual_result_id`,`mir`.`minutes` AS `minutes`,`mir`.`seconds` AS `seconds`,`mir`.`hundredths` AS `hundredths`,`mir`.`minutes` * 6000 + `mir`.`seconds` * 100 + `mir`.`hundredths` AS `total_hundredths`,`m`.`id` AS `meeting_id`,`m`.`header_date` AS `meeting_date`,`m`.`description` AS `meeting_name`,`t`.`id` AS `team_id`,`t`.`name` AS `team_name`,row_number() over ( partition by `mir`.`swimmer_id`,`me`.`event_type_id`,`mp`.`pool_type_id` order by `mir`.`minutes` * 6000 + `mir`.`seconds` * 100 + `mir`.`hundredths`,`m`.`header_date` desc) AS `rn` from ((((((((((`meeting_individual_results` `mir` join `meeting_programs` `mp` on(`mp`.`id` = `mir`.`meeting_program_id`)) join `meeting_events` `me` on(`me`.`id` = `mp`.`meeting_event_id`)) join `meeting_sessions` `ms` on(`ms`.`id` = `me`.`meeting_session_id`)) join `meetings` `m` on(`m`.`id` = `ms`.`meeting_id`)) join `seasons` `se` on(`se`.`id` = `m`.`season_id`)) join `event_types` `et` on(`et`.`id` = `me`.`event_type_id`)) join `pool_types` `pt` on(`pt`.`id` = `mp`.`pool_type_id`)) join `swimmers` `s` on(`s`.`id` = `mir`.`swimmer_id`)) join `teams` `t` on(`t`.`id` = `mir`.`team_id`)) join `RecentSeasons` `rs` on(`m`.`season_id` = `rs`.`id`)) where `mir`.`disqualified` = 0 and `mir`.`minutes` * 6000 + `mir`.`seconds` * 100 + `mir`.`hundredths` > 0 and `me`.`event_type_id` in (2,11,15,19) and `mp`.`pool_type_id` in (1,2))select `RankedResults`.`swimmer_id` AS `swimmer_id`,`RankedResults`.`swimmer_name` AS `swimmer_name`,`RankedResults`.`swimmer_year_of_birth` AS `swimmer_year_of_birth`,`RankedResults`.`gender_type_id` AS `gender_type_id`,`RankedResults`.`event_type_id` AS `event_type_id`,`RankedResults`.`event_type_code` AS `event_type_code`,`RankedResults`.`pool_type_id` AS `pool_type_id`,`RankedResults`.`pool_type_code` AS `pool_type_code`,`RankedResults`.`season_id` AS `season_id`,`RankedResults`.`season_header_year` AS `season_header_year`,`RankedResults`.`meeting_individual_result_id` AS `meeting_individual_result_id`,`RankedResults`.`minutes` AS `minutes`,`RankedResults`.`seconds` AS `seconds`,`RankedResults`.`hundredths` AS `hundredths`,`RankedResults`.`total_hundredths` AS `total_hundredths`,`RankedResults`.`meeting_id` AS `meeting_id`,`RankedResults`.`meeting_date` AS `meeting_date`,`RankedResults`.`meeting_name` AS `meeting_name`,`RankedResults`.`team_id` AS `team_id`,`RankedResults`.`team_name` AS `team_name` from `RankedResults` where `RankedResults`.`rn` = 1 */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!50001 DROP VIEW IF EXISTS `best_swimmer3y_results`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `best_swimmer3y_results` AS with RecentSeasons as (select `seasons`.`id` AS `id` from `seasons` where `seasons`.`end_date` >= curdate() - interval 3 year order by `seasons`.`end_date` desc), RankedResults as (select `mir`.`swimmer_id` AS `swimmer_id`,`s`.`complete_name` AS `swimmer_name`,`s`.`year_of_birth` AS `swimmer_year_of_birth`,`s`.`gender_type_id` AS `gender_type_id`,`me`.`event_type_id` AS `event_type_id`,`et`.`code` AS `event_type_code`,`mp`.`pool_type_id` AS `pool_type_id`,`pt`.`code` AS `pool_type_code`,`m`.`season_id` AS `season_id`,`se`.`header_year` AS `season_header_year`,`mir`.`id` AS `meeting_individual_result_id`,`mir`.`minutes` AS `minutes`,`mir`.`seconds` AS `seconds`,`mir`.`hundredths` AS `hundredths`,`mir`.`minutes` * 6000 + `mir`.`seconds` * 100 + `mir`.`hundredths` AS `total_hundredths`,`m`.`id` AS `meeting_id`,`m`.`header_date` AS `meeting_date`,`m`.`description` AS `meeting_name`,`t`.`id` AS `team_id`,`t`.`name` AS `team_name`,row_number() over ( partition by `mir`.`swimmer_id`,`me`.`event_type_id`,`mp`.`pool_type_id` order by `mir`.`minutes` * 6000 + `mir`.`seconds` * 100 + `mir`.`hundredths`,`m`.`header_date` desc) AS `rn` from ((((((((((`meeting_individual_results` `mir` join `meeting_programs` `mp` on(`mp`.`id` = `mir`.`meeting_program_id`)) join `meeting_events` `me` on(`me`.`id` = `mp`.`meeting_event_id`)) join `meeting_sessions` `ms` on(`ms`.`id` = `me`.`meeting_session_id`)) join `meetings` `m` on(`m`.`id` = `ms`.`meeting_id`)) join `seasons` `se` on(`se`.`id` = `m`.`season_id`)) join `event_types` `et` on(`et`.`id` = `me`.`event_type_id`)) join `pool_types` `pt` on(`pt`.`id` = `mp`.`pool_type_id`)) join `swimmers` `s` on(`s`.`id` = `mir`.`swimmer_id`)) join `teams` `t` on(`t`.`id` = `mir`.`team_id`)) join `RecentSeasons` `rs` on(`m`.`season_id` = `rs`.`id`)) where `mir`.`disqualified` = 0 and `mir`.`minutes` * 6000 + `mir`.`seconds` * 100 + `mir`.`hundredths` > 0 and `me`.`event_type_id` in (2,3,4,5,6,7,11,12,13,15,16,17,19,20,21,22,23,24) and `mp`.`pool_type_id` in (1,2))select `RankedResults`.`swimmer_id` AS `swimmer_id`,`RankedResults`.`swimmer_name` AS `swimmer_name`,`RankedResults`.`swimmer_year_of_birth` AS `swimmer_year_of_birth`,`RankedResults`.`gender_type_id` AS `gender_type_id`,`RankedResults`.`event_type_id` AS `event_type_id`,`RankedResults`.`event_type_code` AS `event_type_code`,`RankedResults`.`pool_type_id` AS `pool_type_id`,`RankedResults`.`pool_type_code` AS `pool_type_code`,`RankedResults`.`season_id` AS `season_id`,`RankedResults`.`season_header_year` AS `season_header_year`,`RankedResults`.`meeting_individual_result_id` AS `meeting_individual_result_id`,`RankedResults`.`minutes` AS `minutes`,`RankedResults`.`seconds` AS `seconds`,`RankedResults`.`hundredths` AS `hundredths`,`RankedResults`.`total_hundredths` AS `total_hundredths`,`RankedResults`.`meeting_id` AS `meeting_id`,`RankedResults`.`meeting_date` AS `meeting_date`,`RankedResults`.`meeting_name` AS `meeting_name`,`RankedResults`.`team_id` AS `team_id`,`RankedResults`.`team_name` AS `team_name` from `RankedResults` where `RankedResults`.`rn` = 1 */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!50001 DROP VIEW IF EXISTS `best_swimmer5y_results`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `best_swimmer5y_results` AS with RecentSeasons as (select `seasons`.`id` AS `id` from `seasons` where `seasons`.`end_date` >= curdate() - interval 5 year order by `seasons`.`end_date` desc), RankedResults as (select `mir`.`swimmer_id` AS `swimmer_id`,`s`.`complete_name` AS `swimmer_name`,`s`.`year_of_birth` AS `swimmer_year_of_birth`,`s`.`gender_type_id` AS `gender_type_id`,`me`.`event_type_id` AS `event_type_id`,`et`.`code` AS `event_type_code`,`mp`.`pool_type_id` AS `pool_type_id`,`pt`.`code` AS `pool_type_code`,`m`.`season_id` AS `season_id`,`se`.`header_year` AS `season_header_year`,`mir`.`id` AS `meeting_individual_result_id`,`mir`.`minutes` AS `minutes`,`mir`.`seconds` AS `seconds`,`mir`.`hundredths` AS `hundredths`,`mir`.`minutes` * 6000 + `mir`.`seconds` * 100 + `mir`.`hundredths` AS `total_hundredths`,`m`.`id` AS `meeting_id`,`m`.`header_date` AS `meeting_date`,`m`.`description` AS `meeting_name`,`t`.`id` AS `team_id`,`t`.`name` AS `team_name`,row_number() over ( partition by `mir`.`swimmer_id`,`me`.`event_type_id`,`mp`.`pool_type_id` order by `mir`.`minutes` * 6000 + `mir`.`seconds` * 100 + `mir`.`hundredths`,`m`.`header_date` desc) AS `rn` from ((((((((((`meeting_individual_results` `mir` join `meeting_programs` `mp` on(`mp`.`id` = `mir`.`meeting_program_id`)) join `meeting_events` `me` on(`me`.`id` = `mp`.`meeting_event_id`)) join `meeting_sessions` `ms` on(`ms`.`id` = `me`.`meeting_session_id`)) join `meetings` `m` on(`m`.`id` = `ms`.`meeting_id`)) join `seasons` `se` on(`se`.`id` = `m`.`season_id`)) join `event_types` `et` on(`et`.`id` = `me`.`event_type_id`)) join `pool_types` `pt` on(`pt`.`id` = `mp`.`pool_type_id`)) join `swimmers` `s` on(`s`.`id` = `mir`.`swimmer_id`)) join `teams` `t` on(`t`.`id` = `mir`.`team_id`)) join `RecentSeasons` `rs` on(`m`.`season_id` = `rs`.`id`)) where `mir`.`disqualified` = 0 and `mir`.`minutes` * 6000 + `mir`.`seconds` * 100 + `mir`.`hundredths` > 0 and `me`.`event_type_id` in (2,3,4,5,6,7,11,12,13,15,16,17,19,20,21,22,23,24) and `mp`.`pool_type_id` in (1,2))select `RankedResults`.`swimmer_id` AS `swimmer_id`,`RankedResults`.`swimmer_name` AS `swimmer_name`,`RankedResults`.`swimmer_year_of_birth` AS `swimmer_year_of_birth`,`RankedResults`.`gender_type_id` AS `gender_type_id`,`RankedResults`.`event_type_id` AS `event_type_id`,`RankedResults`.`event_type_code` AS `event_type_code`,`RankedResults`.`pool_type_id` AS `pool_type_id`,`RankedResults`.`pool_type_code` AS `pool_type_code`,`RankedResults`.`season_id` AS `season_id`,`RankedResults`.`season_header_year` AS `season_header_year`,`RankedResults`.`meeting_individual_result_id` AS `meeting_individual_result_id`,`RankedResults`.`minutes` AS `minutes`,`RankedResults`.`seconds` AS `seconds`,`RankedResults`.`hundredths` AS `hundredths`,`RankedResults`.`total_hundredths` AS `total_hundredths`,`RankedResults`.`meeting_id` AS `meeting_id`,`RankedResults`.`meeting_date` AS `meeting_date`,`RankedResults`.`meeting_name` AS `meeting_name`,`RankedResults`.`team_id` AS `team_id`,`RankedResults`.`team_name` AS `team_name` from `RankedResults` where `RankedResults`.`rn` = 1 */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!50001 DROP VIEW IF EXISTS `best_swimmer_all_time_results`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `best_swimmer_all_time_results` AS with RankedResults as (select `mir`.`swimmer_id` AS `swimmer_id`,`s`.`complete_name` AS `swimmer_name`,`s`.`year_of_birth` AS `swimmer_year_of_birth`,`s`.`gender_type_id` AS `gender_type_id`,`me`.`event_type_id` AS `event_type_id`,`et`.`code` AS `event_type_code`,`mp`.`pool_type_id` AS `pool_type_id`,`pt`.`code` AS `pool_type_code`,`m`.`season_id` AS `season_id`,`se`.`header_year` AS `season_header_year`,`mir`.`id` AS `meeting_individual_result_id`,`mir`.`minutes` AS `minutes`,`mir`.`seconds` AS `seconds`,`mir`.`hundredths` AS `hundredths`,`mir`.`minutes` * 6000 + `mir`.`seconds` * 100 + `mir`.`hundredths` AS `total_hundredths`,`m`.`id` AS `meeting_id`,`m`.`header_date` AS `meeting_date`,`m`.`description` AS `meeting_name`,`t`.`id` AS `team_id`,`t`.`name` AS `team_name`,row_number() over ( partition by `mir`.`swimmer_id`,`me`.`event_type_id`,`mp`.`pool_type_id` order by `mir`.`minutes` * 6000 + `mir`.`seconds` * 100 + `mir`.`hundredths`,`m`.`header_date` desc) AS `rn` from (((((((((`meeting_individual_results` `mir` join `meeting_programs` `mp` on(`mp`.`id` = `mir`.`meeting_program_id`)) join `meeting_events` `me` on(`me`.`id` = `mp`.`meeting_event_id`)) join `meeting_sessions` `ms` on(`ms`.`id` = `me`.`meeting_session_id`)) join `meetings` `m` on(`m`.`id` = `ms`.`meeting_id`)) join `seasons` `se` on(`se`.`id` = `m`.`season_id`)) join `event_types` `et` on(`et`.`id` = `me`.`event_type_id`)) join `pool_types` `pt` on(`pt`.`id` = `mp`.`pool_type_id`)) join `swimmers` `s` on(`s`.`id` = `mir`.`swimmer_id`)) join `teams` `t` on(`t`.`id` = `mir`.`team_id`)) where `mir`.`disqualified` = 0 and `mir`.`minutes` * 6000 + `mir`.`seconds` * 100 + `mir`.`hundredths` > 0 and `me`.`event_type_id` in (2,3,4,5,6,7,11,12,13,15,16,17,19,20,21,22,23,24) and `mp`.`pool_type_id` in (1,2))select `RankedResults`.`swimmer_id` AS `swimmer_id`,`RankedResults`.`swimmer_name` AS `swimmer_name`,`RankedResults`.`swimmer_year_of_birth` AS `swimmer_year_of_birth`,`RankedResults`.`gender_type_id` AS `gender_type_id`,`RankedResults`.`event_type_id` AS `event_type_id`,`RankedResults`.`event_type_code` AS `event_type_code`,`RankedResults`.`pool_type_id` AS `pool_type_id`,`RankedResults`.`pool_type_code` AS `pool_type_code`,`RankedResults`.`season_id` AS `season_id`,`RankedResults`.`season_header_year` AS `season_header_year`,`RankedResults`.`meeting_individual_result_id` AS `meeting_individual_result_id`,`RankedResults`.`minutes` AS `minutes`,`RankedResults`.`seconds` AS `seconds`,`RankedResults`.`hundredths` AS `hundredths`,`RankedResults`.`total_hundredths` AS `total_hundredths`,`RankedResults`.`meeting_id` AS `meeting_id`,`RankedResults`.`meeting_date` AS `meeting_date`,`RankedResults`.`meeting_name` AS `meeting_name`,`RankedResults`.`team_id` AS `team_id`,`RankedResults`.`team_name` AS `team_name` from `RankedResults` where `RankedResults`.`rn` = 1 */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!50001 DROP VIEW IF EXISTS `best_swimmer_current_vs_previous_results`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `best_swimmer_current_vs_previous_results` AS with SeasonWithChampionship as (select `s`.`id` AS `id`,`s`.`begin_date` AS `begin_date`,`s`.`end_date` AS `end_date`,case when month(`s`.`begin_date`) >= 9 then year(`s`.`begin_date`) when month(`s`.`begin_date`) <= 5 then year(`s`.`begin_date`) - 1 else year(`s`.`end_date`) end AS `championship_year` from `seasons` `s`), BaseYear as (select `goggles_db_base_year`() AS `base_year`), CurrentSeasons as (select `swc`.`id` AS `id`,`swc`.`championship_year` AS `championship_year` from (`SeasonWithChampionship` `swc` join `BaseYear` `byr` on(`swc`.`championship_year` = `byr`.`base_year`))), ValidResults as (select `mir`.`swimmer_id` AS `swimmer_id`,`s`.`complete_name` AS `swimmer_name`,`s`.`year_of_birth` AS `swimmer_year_of_birth`,`s`.`gender_type_id` AS `gender_type_id`,`me`.`event_type_id` AS `event_type_id`,`et`.`code` AS `event_type_code`,`mp`.`pool_type_id` AS `pool_type_id`,`pt`.`code` AS `pool_type_code`,`m`.`season_id` AS `season_id`,`se`.`header_year` AS `season_header_year`,`mir`.`id` AS `meeting_individual_result_id`,`mir`.`minutes` AS `minutes`,`mir`.`seconds` AS `seconds`,`mir`.`hundredths` AS `hundredths`,`mir`.`minutes` * 6000 + `mir`.`seconds` * 100 + `mir`.`hundredths` AS `total_hundredths`,`m`.`id` AS `meeting_id`,`m`.`header_date` AS `meeting_date`,`m`.`description` AS `meeting_name`,`t`.`id` AS `team_id`,`t`.`name` AS `team_name` from (((((((((`meeting_individual_results` `mir` join `meeting_programs` `mp` on(`mp`.`id` = `mir`.`meeting_program_id`)) join `meeting_events` `me` on(`me`.`id` = `mp`.`meeting_event_id`)) join `meeting_sessions` `ms` on(`ms`.`id` = `me`.`meeting_session_id`)) join `meetings` `m` on(`m`.`id` = `ms`.`meeting_id`)) join `seasons` `se` on(`se`.`id` = `m`.`season_id`)) join `event_types` `et` on(`et`.`id` = `me`.`event_type_id`)) join `pool_types` `pt` on(`pt`.`id` = `mp`.`pool_type_id`)) join `swimmers` `s` on(`s`.`id` = `mir`.`swimmer_id`)) join `teams` `t` on(`t`.`id` = `mir`.`team_id`)) where `mir`.`disqualified` = 0 and `mir`.`minutes` * 6000 + `mir`.`seconds` * 100 + `mir`.`hundredths` > 0 and `me`.`event_type_id` in (2,3,4,5,6,7,11,12,13,15,16,17,19,20,21,22,23,24) and `mp`.`pool_type_id` in (1,2)), CurrentSeasonRanked as (select `vr`.`swimmer_id` AS `swimmer_id`,`vr`.`swimmer_name` AS `swimmer_name`,`vr`.`swimmer_year_of_birth` AS `swimmer_year_of_birth`,`vr`.`gender_type_id` AS `gender_type_id`,`vr`.`event_type_id` AS `event_type_id`,`vr`.`event_type_code` AS `event_type_code`,`vr`.`pool_type_id` AS `pool_type_id`,`vr`.`pool_type_code` AS `pool_type_code`,`vr`.`season_id` AS `season_id`,`vr`.`season_header_year` AS `season_header_year`,`vr`.`meeting_individual_result_id` AS `meeting_individual_result_id`,`vr`.`minutes` AS `minutes`,`vr`.`seconds` AS `seconds`,`vr`.`hundredths` AS `hundredths`,`vr`.`total_hundredths` AS `total_hundredths`,`vr`.`meeting_id` AS `meeting_id`,`vr`.`meeting_date` AS `meeting_date`,`vr`.`meeting_name` AS `meeting_name`,`vr`.`team_id` AS `team_id`,`vr`.`team_name` AS `team_name`,row_number() over ( partition by `vr`.`swimmer_id`,`vr`.`event_type_id`,`vr`.`pool_type_id` order by `vr`.`total_hundredths`,`vr`.`meeting_date` desc,`vr`.`meeting_id` desc) AS `rn` from (`ValidResults` `vr` join `CurrentSeasons` `cs` on(`cs`.`id` = `vr`.`season_id`))), CurrentBest as (select `CurrentSeasonRanked`.`swimmer_id` AS `swimmer_id`,`CurrentSeasonRanked`.`swimmer_name` AS `swimmer_name`,`CurrentSeasonRanked`.`swimmer_year_of_birth` AS `swimmer_year_of_birth`,`CurrentSeasonRanked`.`gender_type_id` AS `gender_type_id`,`CurrentSeasonRanked`.`event_type_id` AS `event_type_id`,`CurrentSeasonRanked`.`event_type_code` AS `event_type_code`,`CurrentSeasonRanked`.`pool_type_id` AS `pool_type_id`,`CurrentSeasonRanked`.`pool_type_code` AS `pool_type_code`,`CurrentSeasonRanked`.`season_id` AS `season_id`,`CurrentSeasonRanked`.`season_header_year` AS `season_header_year`,`CurrentSeasonRanked`.`meeting_individual_result_id` AS `meeting_individual_result_id`,`CurrentSeasonRanked`.`minutes` AS `minutes`,`CurrentSeasonRanked`.`seconds` AS `seconds`,`CurrentSeasonRanked`.`hundredths` AS `hundredths`,`CurrentSeasonRanked`.`total_hundredths` AS `total_hundredths`,`CurrentSeasonRanked`.`meeting_id` AS `meeting_id`,`CurrentSeasonRanked`.`meeting_date` AS `meeting_date`,`CurrentSeasonRanked`.`meeting_name` AS `meeting_name`,`CurrentSeasonRanked`.`team_id` AS `team_id`,`CurrentSeasonRanked`.`team_name` AS `team_name`,`CurrentSeasonRanked`.`rn` AS `rn` from `CurrentSeasonRanked` where `CurrentSeasonRanked`.`rn` = 1)select `cb`.`swimmer_id` AS `swimmer_id`,`cb`.`swimmer_name` AS `swimmer_name`,`cb`.`swimmer_year_of_birth` AS `swimmer_year_of_birth`,`cb`.`gender_type_id` AS `gender_type_id`,`cb`.`event_type_id` AS `event_type_id`,`cb`.`event_type_code` AS `event_type_code`,`cb`.`pool_type_id` AS `pool_type_id`,`cb`.`pool_type_code` AS `pool_type_code`,`cb`.`season_id` AS `season_id`,`cb`.`season_header_year` AS `season_header_year`,`cb`.`meeting_individual_result_id` AS `meeting_individual_result_id`,`cb`.`minutes` AS `minutes`,`cb`.`seconds` AS `seconds`,`cb`.`hundredths` AS `hundredths`,`cb`.`total_hundredths` AS `total_hundredths`,`cb`.`meeting_id` AS `meeting_id`,`cb`.`meeting_date` AS `meeting_date`,`cb`.`meeting_name` AS `meeting_name`,`cb`.`team_id` AS `team_id`,`cb`.`team_name` AS `team_name`,`bt`.`old_meeting_individual_result_id` AS `old_meeting_individual_result_id`,`bt`.`old_meeting_id` AS `old_meeting_id`,`bt`.`old_meeting_date` AS `old_meeting_date`,`bt`.`old_meeting_name` AS `old_meeting_name`,`bt`.`old_total_hundredths` AS `old_total_hundredths`,`bt`.`old_minutes` AS `old_minutes`,`bt`.`old_seconds` AS `old_seconds`,`bt`.`old_hundredths` AS `old_hundredths` from (`CurrentBest` `cb` left join (select `goggles_cup_3y_base_timings`.`swimmer_id` AS `swimmer_id`,`goggles_cup_3y_base_timings`.`event_type_id` AS `event_type_id`,`goggles_cup_3y_base_timings`.`pool_type_id` AS `pool_type_id`,`goggles_cup_3y_base_timings`.`meeting_individual_result_id` AS `old_meeting_individual_result_id`,`goggles_cup_3y_base_timings`.`meeting_id` AS `old_meeting_id`,`goggles_cup_3y_base_timings`.`meeting_date` AS `old_meeting_date`,`goggles_cup_3y_base_timings`.`meeting_name` AS `old_meeting_name`,`goggles_cup_3y_base_timings`.`total_hundredths` AS `old_total_hundredths`,`goggles_cup_3y_base_timings`.`minutes` AS `old_minutes`,`goggles_cup_3y_base_timings`.`seconds` AS `old_seconds`,`goggles_cup_3y_base_timings`.`hundredths` AS `old_hundredths` from `goggles_cup_3y_base_timings`) `bt` on(`bt`.`swimmer_id` = `cb`.`swimmer_id` and `bt`.`event_type_id` = `cb`.`event_type_id` and `bt`.`pool_type_id` = `cb`.`pool_type_id`)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!50001 DROP VIEW IF EXISTS `best_team_results_for_season`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_uca1400_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `best_team_results_for_season` AS with RankedResults as (select `mir`.`swimmer_id` AS `swimmer_id`,`s`.`complete_name` AS `swimmer_name`,`s`.`year_of_birth` AS `swimmer_year_of_birth`,`mp`.`gender_type_id` AS `gender_type_id`,`gt`.`code` AS `gender_type_code`,`me`.`event_type_id` AS `event_type_id`,`et`.`code` AS `event_type_code`,`mp`.`category_type_id` AS `category_type_id`,`ct`.`code` AS `category_type_code`,`ct`.`short_name` AS `category_type_short_name`,`mp`.`pool_type_id` AS `pool_type_id`,`pt`.`code` AS `pool_type_code`,`m`.`season_id` AS `season_id`,`se`.`header_year` AS `season_header_year`,`st`.`federation_type_id` AS `federation_type_id`,`mir`.`id` AS `meeting_individual_result_id`,`mir`.`minutes` AS `minutes`,`mir`.`seconds` AS `seconds`,`mir`.`hundredths` AS `hundredths`,`mir`.`minutes` * 6000 + `mir`.`seconds` * 100 + `mir`.`hundredths` AS `total_hundredths`,`m`.`id` AS `meeting_id`,`m`.`header_date` AS `meeting_date`,`m`.`description` AS `meeting_name`,`b`.`team_id` AS `team_id`,`t`.`name` AS `team_name`,row_number() over ( partition by `b`.`team_id`,`m`.`season_id`,`me`.`event_type_id`,`mp`.`category_type_id`,`mp`.`gender_type_id`,`mp`.`pool_type_id` order by `mir`.`minutes` * 6000 + `mir`.`seconds` * 100 + `mir`.`hundredths`,`m`.`header_date` desc,`m`.`id` desc) AS `rn` from (((((((((((((`meeting_individual_results` `mir` join `badges` `b` on(`b`.`id` = `mir`.`badge_id`)) join `meeting_programs` `mp` on(`mp`.`id` = `mir`.`meeting_program_id`)) join `meeting_events` `me` on(`me`.`id` = `mp`.`meeting_event_id`)) join `meeting_sessions` `ms` on(`ms`.`id` = `me`.`meeting_session_id`)) join `meetings` `m` on(`m`.`id` = `ms`.`meeting_id`)) join `seasons` `se` on(`se`.`id` = `m`.`season_id`)) join `season_types` `st` on(`st`.`id` = `se`.`season_type_id`)) join `event_types` `et` on(`et`.`id` = `me`.`event_type_id`)) join `category_types` `ct` on(`ct`.`id` = `mp`.`category_type_id`)) join `gender_types` `gt` on(`gt`.`id` = `mp`.`gender_type_id`)) join `pool_types` `pt` on(`pt`.`id` = `mp`.`pool_type_id`)) join `swimmers` `s` on(`s`.`id` = `mir`.`swimmer_id`)) join `teams` `t` on(`t`.`id` = `b`.`team_id`)) where `mir`.`disqualified` = 0 and `mir`.`minutes` * 6000 + `mir`.`seconds` * 100 + `mir`.`hundredths` > 0 and `me`.`event_type_id` in (2,3,4,5,6,7,11,12,13,15,16,17,19,20,21,22,23,24) and `mp`.`pool_type_id` in (1,2) and `mp`.`gender_type_id` in (1,2) and `b`.`season_id` = `m`.`season_id`)select `RankedResults`.`swimmer_id` AS `swimmer_id`,`RankedResults`.`swimmer_name` AS `swimmer_name`,`RankedResults`.`swimmer_year_of_birth` AS `swimmer_year_of_birth`,`RankedResults`.`gender_type_id` AS `gender_type_id`,`RankedResults`.`gender_type_code` AS `gender_type_code`,`RankedResults`.`event_type_id` AS `event_type_id`,`RankedResults`.`event_type_code` AS `event_type_code`,`RankedResults`.`category_type_id` AS `category_type_id`,`RankedResults`.`category_type_code` AS `category_type_code`,`RankedResults`.`category_type_short_name` AS `category_type_short_name`,`RankedResults`.`pool_type_id` AS `pool_type_id`,`RankedResults`.`pool_type_code` AS `pool_type_code`,`RankedResults`.`season_id` AS `season_id`,`RankedResults`.`season_header_year` AS `season_header_year`,`RankedResults`.`federation_type_id` AS `federation_type_id`,`RankedResults`.`meeting_individual_result_id` AS `meeting_individual_result_id`,`RankedResults`.`minutes` AS `minutes`,`RankedResults`.`seconds` AS `seconds`,`RankedResults`.`hundredths` AS `hundredths`,`RankedResults`.`total_hundredths` AS `total_hundredths`,`RankedResults`.`meeting_id` AS `meeting_id`,`RankedResults`.`meeting_date` AS `meeting_date`,`RankedResults`.`meeting_name` AS `meeting_name`,`RankedResults`.`team_id` AS `team_id`,`RankedResults`.`team_name` AS `team_name` from `RankedResults` where `RankedResults`.`rn` = 1 */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!50001 DROP VIEW IF EXISTS `goggles_cup_3y_base_timings`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `goggles_cup_3y_base_timings` AS with SeasonWithChampionship as (select `s`.`id` AS `id`,`s`.`begin_date` AS `begin_date`,`s`.`end_date` AS `end_date`,case when month(`s`.`begin_date`) >= 9 then year(`s`.`begin_date`) when month(`s`.`begin_date`) <= 5 then year(`s`.`begin_date`) - 1 else year(`s`.`end_date`) end AS `championship_year` from `seasons` `s`), BaseYear as (select `goggles_db_base_year`() AS `base_year`), Previous3ySeasons as (select `swc`.`id` AS `id` from (`SeasonWithChampionship` `swc` join `BaseYear` `byr` on(`swc`.`championship_year` between `byr`.`base_year` - 3 and `byr`.`base_year` - 1))), ValidResults as (select `mir`.`swimmer_id` AS `swimmer_id`,`s`.`complete_name` AS `swimmer_name`,`s`.`year_of_birth` AS `swimmer_year_of_birth`,`s`.`gender_type_id` AS `gender_type_id`,`me`.`event_type_id` AS `event_type_id`,`et`.`code` AS `event_type_code`,`mp`.`pool_type_id` AS `pool_type_id`,`pt`.`code` AS `pool_type_code`,`m`.`season_id` AS `season_id`,`se`.`header_year` AS `season_header_year`,`mir`.`id` AS `meeting_individual_result_id`,`mir`.`minutes` AS `minutes`,`mir`.`seconds` AS `seconds`,`mir`.`hundredths` AS `hundredths`,`mir`.`minutes` * 6000 + `mir`.`seconds` * 100 + `mir`.`hundredths` AS `total_hundredths`,`m`.`id` AS `meeting_id`,`m`.`header_date` AS `meeting_date`,`m`.`description` AS `meeting_name`,`t`.`id` AS `team_id`,`t`.`name` AS `team_name` from (((((((((`meeting_individual_results` `mir` join `meeting_programs` `mp` on(`mp`.`id` = `mir`.`meeting_program_id`)) join `meeting_events` `me` on(`me`.`id` = `mp`.`meeting_event_id`)) join `meeting_sessions` `ms` on(`ms`.`id` = `me`.`meeting_session_id`)) join `meetings` `m` on(`m`.`id` = `ms`.`meeting_id`)) join `seasons` `se` on(`se`.`id` = `m`.`season_id`)) join `event_types` `et` on(`et`.`id` = `me`.`event_type_id`)) join `pool_types` `pt` on(`pt`.`id` = `mp`.`pool_type_id`)) join `swimmers` `s` on(`s`.`id` = `mir`.`swimmer_id`)) join `teams` `t` on(`t`.`id` = `mir`.`team_id`)) where `mir`.`disqualified` = 0 and `mir`.`minutes` * 6000 + `mir`.`seconds` * 100 + `mir`.`hundredths` > 0 and `me`.`event_type_id` in (2,3,4,5,6,7,11,12,13,15,16,17,19,20,21,22,23,24) and `mp`.`pool_type_id` in (1,2)), RankedResults as (select `vr`.`swimmer_id` AS `swimmer_id`,`vr`.`swimmer_name` AS `swimmer_name`,`vr`.`swimmer_year_of_birth` AS `swimmer_year_of_birth`,`vr`.`gender_type_id` AS `gender_type_id`,`vr`.`event_type_id` AS `event_type_id`,`vr`.`event_type_code` AS `event_type_code`,`vr`.`pool_type_id` AS `pool_type_id`,`vr`.`pool_type_code` AS `pool_type_code`,`vr`.`season_id` AS `season_id`,`vr`.`season_header_year` AS `season_header_year`,`vr`.`meeting_individual_result_id` AS `meeting_individual_result_id`,`vr`.`minutes` AS `minutes`,`vr`.`seconds` AS `seconds`,`vr`.`hundredths` AS `hundredths`,`vr`.`total_hundredths` AS `total_hundredths`,`vr`.`meeting_id` AS `meeting_id`,`vr`.`meeting_date` AS `meeting_date`,`vr`.`meeting_name` AS `meeting_name`,`vr`.`team_id` AS `team_id`,`vr`.`team_name` AS `team_name`,row_number() over ( partition by `vr`.`swimmer_id`,`vr`.`event_type_id`,`vr`.`pool_type_id` order by `vr`.`total_hundredths`,`vr`.`meeting_date` desc,`vr`.`meeting_id` desc) AS `rn` from (`ValidResults` `vr` join `Previous3ySeasons` `ps` on(`ps`.`id` = `vr`.`season_id`)))select `RankedResults`.`swimmer_id` AS `swimmer_id`,`RankedResults`.`swimmer_name` AS `swimmer_name`,`RankedResults`.`swimmer_year_of_birth` AS `swimmer_year_of_birth`,`RankedResults`.`gender_type_id` AS `gender_type_id`,`RankedResults`.`event_type_id` AS `event_type_id`,`RankedResults`.`event_type_code` AS `event_type_code`,`RankedResults`.`pool_type_id` AS `pool_type_id`,`RankedResults`.`pool_type_code` AS `pool_type_code`,`RankedResults`.`season_id` AS `season_id`,`RankedResults`.`season_header_year` AS `season_header_year`,`RankedResults`.`meeting_individual_result_id` AS `meeting_individual_result_id`,`RankedResults`.`minutes` AS `minutes`,`RankedResults`.`seconds` AS `seconds`,`RankedResults`.`hundredths` AS `hundredths`,`RankedResults`.`total_hundredths` AS `total_hundredths`,`RankedResults`.`meeting_id` AS `meeting_id`,`RankedResults`.`meeting_date` AS `meeting_date`,`RankedResults`.`meeting_name` AS `meeting_name`,`RankedResults`.`team_id` AS `team_id`,`RankedResults`.`team_name` AS `team_name` from `RankedResults` where `RankedResults`.`rn` = 1 */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!50001 DROP VIEW IF EXISTS `last_seasons_ids`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `last_seasons_ids` AS select `s1`.`id` AS `id` from (select `seasons`.`id` AS `id` from `seasons` where `seasons`.`season_type_id` = 1 order by `seasons`.`begin_date` desc limit 1) `s1` union select `s1_1`.`id` AS `id` from (select `seasons`.`id` AS `id` from (((((`seasons` join `meetings` on(`meetings`.`season_id` = `seasons`.`id`)) join `meeting_sessions` on(`meeting_sessions`.`meeting_id` = `meetings`.`id`)) join `meeting_events` on(`meeting_events`.`meeting_session_id` = `meeting_sessions`.`id`)) join `meeting_programs` on(`meeting_programs`.`meeting_event_id` = `meeting_events`.`id`)) join `meeting_individual_results` on(`meeting_individual_results`.`meeting_program_id` = `meeting_programs`.`id`)) where `seasons`.`season_type_id` = 1 order by `seasons`.`begin_date` desc limit 1) `s1_1` union select `s1_2`.`id` AS `id` from (select `seasons`.`id` AS `id` from (`seasons` join `user_workshops` on(`user_workshops`.`season_id` = `seasons`.`id`)) where `seasons`.`season_type_id` = 1 order by `seasons`.`begin_date` desc limit 1) `s1_2` union select `s1_3`.`id` AS `id` from (select `seasons`.`id` AS `id` from ((`seasons` join `user_workshops` on(`user_workshops`.`season_id` = `seasons`.`id`)) join `user_results` on(`user_results`.`user_workshop_id` = `user_workshops`.`id`)) where `seasons`.`season_type_id` = 1 order by `seasons`.`begin_date` desc limit 1) `s1_3` union select `s2`.`id` AS `id` from (select `seasons`.`id` AS `id` from `seasons` where `seasons`.`season_type_id` = 7 order by `seasons`.`begin_date` desc limit 1) `s2` union select `s2_1`.`id` AS `id` from (select `seasons`.`id` AS `id` from (((((`seasons` join `meetings` on(`meetings`.`season_id` = `seasons`.`id`)) join `meeting_sessions` on(`meeting_sessions`.`meeting_id` = `meetings`.`id`)) join `meeting_events` on(`meeting_events`.`meeting_session_id` = `meeting_sessions`.`id`)) join `meeting_programs` on(`meeting_programs`.`meeting_event_id` = `meeting_events`.`id`)) join `meeting_individual_results` on(`meeting_individual_results`.`meeting_program_id` = `meeting_programs`.`id`)) where `seasons`.`season_type_id` = 7 order by `seasons`.`begin_date` desc limit 1) `s2_1` union select `s2_2`.`id` AS `id` from (select `seasons`.`id` AS `id` from (`seasons` join `user_workshops` on(`user_workshops`.`season_id` = `seasons`.`id`)) where `seasons`.`season_type_id` = 7 order by `seasons`.`begin_date` desc limit 1) `s2_2` union select `s2_3`.`id` AS `id` from (select `seasons`.`id` AS `id` from ((`seasons` join `user_workshops` on(`user_workshops`.`season_id` = `seasons`.`id`)) join `user_results` on(`user_results`.`user_workshop_id` = `user_workshops`.`id`)) where `seasons`.`season_type_id` = 7 order by `seasons`.`begin_date` desc limit 1) `s2_3` union select `s3`.`id` AS `id` from (select `seasons`.`id` AS `id` from `seasons` where `seasons`.`season_type_id` = 8 order by `seasons`.`begin_date` desc limit 1) `s3` union select `s3_1`.`id` AS `id` from (select `seasons`.`id` AS `id` from (((((`seasons` join `meetings` on(`meetings`.`season_id` = `seasons`.`id`)) join `meeting_sessions` on(`meeting_sessions`.`meeting_id` = `meetings`.`id`)) join `meeting_events` on(`meeting_events`.`meeting_session_id` = `meeting_sessions`.`id`)) join `meeting_programs` on(`meeting_programs`.`meeting_event_id` = `meeting_events`.`id`)) join `meeting_individual_results` on(`meeting_individual_results`.`meeting_program_id` = `meeting_programs`.`id`)) where `seasons`.`season_type_id` = 8 order by `seasons`.`begin_date` desc limit 1) `s3_1` union select `s2_2`.`id` AS `id` from (select `seasons`.`id` AS `id` from (`seasons` join `user_workshops` on(`user_workshops`.`season_id` = `seasons`.`id`)) where `seasons`.`season_type_id` = 8 order by `seasons`.`begin_date` desc limit 1) `s2_2` union select `s2_3`.`id` AS `id` from (select `seasons`.`id` AS `id` from ((`seasons` join `user_workshops` on(`user_workshops`.`season_id` = `seasons`.`id`)) join `user_results` on(`user_results`.`user_workshop_id` = `user_workshops`.`id`)) where `seasons`.`season_type_id` = 8 order by `seasons`.`begin_date` desc limit 1) `s2_3` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!50001 DROP VIEW IF EXISTS `meeting_individual_result_rows`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_uca1400_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `meeting_individual_result_rows` AS select `mir`.`id` AS `meeting_individual_result_id`,`m`.`id` AS `meeting_id`,`ms`.`id` AS `meeting_session_id`,`ms`.`session_order` AS `session_order`,`me`.`id` AS `meeting_event_id`,`me`.`event_order` AS `event_order`,`et`.`id` AS `event_type_id`,`et`.`code` AS `event_type_code`,`mp`.`id` AS `meeting_program_id`,`mp`.`pool_type_id` AS `pool_type_id`,`ct`.`id` AS `category_type_id`,`ct`.`code` AS `category_code`,`ct`.`age_begin` AS `category_age_begin`,`mp`.`gender_type_id` AS `gender_type_id`,`gt`.`code` AS `gender_type_code`,`m`.`season_id` AS `season_id`,`se`.`season_type_id` AS `season_type_id`,`se`.`header_year` AS `season_header_year`,`mir`.`rank` AS `rank`,`mir`.`minutes` AS `minutes`,`mir`.`seconds` AS `seconds`,`mir`.`hundredths` AS `hundredths`,`mir`.`minutes` * 6000 + `mir`.`seconds` * 100 + `mir`.`hundredths` AS `total_hundredths`,`mir`.`reaction_time` AS `reaction_time`,`mir`.`standard_points` AS `standard_points`,`mir`.`meeting_points` AS `meeting_points`,`mir`.`goggle_cup_points` AS `goggle_cup_points`,`mir`.`out_of_race` AS `out_of_race`,`mir`.`disqualified` AS `disqualified`,`mir`.`disqualification_notes` AS `disqualification_notes`,`mir`.`swimmer_id` AS `swimmer_id`,`sw`.`complete_name` AS `swimmer_complete_name`,`sw`.`year_of_birth` AS `swimmer_year_of_birth`,`sw`.`gender_type_id` AS `swimmer_gender_type_id`,`mir`.`team_id` AS `team_id`,`t`.`name` AS `team_name`,`t`.`editable_name` AS `team_editable_name`,`mir`.`badge_id` AS `badge_id`,`mir`.`updated_at` AS `updated_at`,(select count(`l`.`id`) from `laps` `l` where `l`.`meeting_individual_result_id` = `mir`.`id`) AS `laps_count`,(select json_arrayagg(json_object('id',`l`.`id`,'length_in_meters',`l`.`length_in_meters`,'minutes',`l`.`minutes`,'seconds',`l`.`seconds`,'hundredths',`l`.`hundredths`,'minutes_from_start',`l`.`minutes_from_start`,'seconds_from_start',`l`.`seconds_from_start`,'hundredths_from_start',`l`.`hundredths_from_start`,'reaction_time',`l`.`reaction_time`,'position',`l`.`position`) order by `l`.`length_in_meters` ASC) from `laps` `l` where `l`.`meeting_individual_result_id` = `mir`.`id`) AS `laps_json` from ((((((((((`meeting_individual_results` `mir` join `meeting_programs` `mp` on(`mp`.`id` = `mir`.`meeting_program_id`)) join `meeting_events` `me` on(`me`.`id` = `mp`.`meeting_event_id`)) join `meeting_sessions` `ms` on(`ms`.`id` = `me`.`meeting_session_id`)) join `meetings` `m` on(`m`.`id` = `ms`.`meeting_id`)) join `seasons` `se` on(`se`.`id` = `m`.`season_id`)) join `event_types` `et` on(`et`.`id` = `me`.`event_type_id`)) join `category_types` `ct` on(`ct`.`id` = `mp`.`category_type_id`)) join `gender_types` `gt` on(`gt`.`id` = `mp`.`gender_type_id`)) join `swimmers` `sw` on(`sw`.`id` = `mir`.`swimmer_id`)) left join `teams` `t` on(`t`.`id` = `mir`.`team_id`)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!50001 DROP VIEW IF EXISTS `meeting_relay_result_rows`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_uca1400_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `meeting_relay_result_rows` AS select `mrr`.`id` AS `meeting_relay_result_id`,`m`.`id` AS `meeting_id`,`ms`.`id` AS `meeting_session_id`,`ms`.`session_order` AS `session_order`,`me`.`id` AS `meeting_event_id`,`me`.`event_order` AS `event_order`,`et`.`id` AS `event_type_id`,`et`.`code` AS `event_type_code`,`mp`.`id` AS `meeting_program_id`,`mp`.`pool_type_id` AS `pool_type_id`,`ct`.`id` AS `category_type_id`,`ct`.`code` AS `category_code`,`ct`.`age_begin` AS `category_age_begin`,`mp`.`gender_type_id` AS `gender_type_id`,`gt`.`code` AS `gender_type_code`,`m`.`season_id` AS `season_id`,`se`.`season_type_id` AS `season_type_id`,`se`.`header_year` AS `season_header_year`,`mrr`.`rank` AS `rank`,`mrr`.`minutes` AS `minutes`,`mrr`.`seconds` AS `seconds`,`mrr`.`hundredths` AS `hundredths`,`mrr`.`minutes` * 6000 + `mrr`.`seconds` * 100 + `mrr`.`hundredths` AS `total_hundredths`,`mrr`.`reaction_time` AS `reaction_time`,`mrr`.`standard_points` AS `standard_points`,`mrr`.`meeting_points` AS `meeting_points`,`mrr`.`out_of_race` AS `out_of_race`,`mrr`.`disqualified` AS `disqualified`,`mrr`.`disqualification_notes` AS `disqualification_notes`,`mrr`.`relay_code` AS `relay_code`,`mrr`.`team_id` AS `team_id`,`t`.`name` AS `team_name`,`t`.`editable_name` AS `team_editable_name`,`mrr`.`updated_at` AS `updated_at`,`mrr`.`meeting_relay_swimmers_count` AS `meeting_relay_swimmers_count`,(select json_arrayagg(json_object('id',`mrs`.`id`,'relay_order',`mrs`.`relay_order`,'swimmer_id',`mrs`.`swimmer_id`,'swimmer_complete_name',`sw`.`complete_name`,'swimmer_year_of_birth',`sw`.`year_of_birth`,'badge_id',`mrs`.`badge_id`,'stroke_type_id',`mrs`.`stroke_type_id`,'length_in_meters',`mrs`.`length_in_meters`,'reaction_time',`mrs`.`reaction_time`,'minutes',`mrs`.`minutes`,'seconds',`mrs`.`seconds`,'hundredths',`mrs`.`hundredths`,'minutes_from_start',`mrs`.`minutes_from_start`,'seconds_from_start',`mrs`.`seconds_from_start`,'hundredths_from_start',`mrs`.`hundredths_from_start`,'relay_laps_count',`mrs`.`relay_laps_count`) order by `mrs`.`relay_order` ASC) from (`meeting_relay_swimmers` `mrs` join `swimmers` `sw` on(`sw`.`id` = `mrs`.`swimmer_id`)) where `mrs`.`meeting_relay_result_id` = `mrr`.`id`) AS `relay_swimmers_json`,(select json_arrayagg(json_object('id',`rl`.`id`,'meeting_relay_swimmer_id',`rl`.`meeting_relay_swimmer_id`,'swimmer_id',`rl`.`swimmer_id`,'length_in_meters',`rl`.`length_in_meters`,'minutes',`rl`.`minutes`,'seconds',`rl`.`seconds`,'hundredths',`rl`.`hundredths`,'minutes_from_start',`rl`.`minutes_from_start`,'seconds_from_start',`rl`.`seconds_from_start`,'hundredths_from_start',`rl`.`hundredths_from_start`,'reaction_time',`rl`.`reaction_time`,'position',`rl`.`position`) order by `rl`.`length_in_meters` ASC) from `relay_laps` `rl` where `rl`.`meeting_relay_result_id` = `mrr`.`id`) AS `relay_laps_json` from (((((((((`meeting_relay_results` `mrr` join `meeting_programs` `mp` on(`mp`.`id` = `mrr`.`meeting_program_id`)) join `meeting_events` `me` on(`me`.`id` = `mp`.`meeting_event_id`)) join `meeting_sessions` `ms` on(`ms`.`id` = `me`.`meeting_session_id`)) join `meetings` `m` on(`m`.`id` = `ms`.`meeting_id`)) join `seasons` `se` on(`se`.`id` = `m`.`season_id`)) join `event_types` `et` on(`et`.`id` = `me`.`event_type_id`)) join `category_types` `ct` on(`ct`.`id` = `mp`.`category_type_id`)) join `gender_types` `gt` on(`gt`.`id` = `mp`.`gender_type_id`)) join `teams` `t` on(`t`.`id` = `mrr`.`team_id`)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

INSERT INTO `schema_migrations` (version) VALUES
('20261004120100'),
('20261004120000'),
('20260923170100'),
('20260923170000'),
('20260921170005'),
('20260921170001'),
('20260921170000'),
('20260828110000'),
('20260826190000'),
('20260817170100'),
('20260817170000'),
('20260813110100'),
('20260813110000'),
('20260813105500'),
('20260805000000'),
('20260803210000'),
('20260727183000'),
('20260727180000'),
('20260727170000'),
('20260727160000'),
('20260706230300'),
('20260706153000'),
('20260706150500'),
('20260625164500'),
('20260625163300'),
('20260625121000'),
('20260625110505'),
('20260625110500'),
('20260430121138'),
('20251117095111'),
('20251102154400'),
('20251027210157'),
('20251027210152'),
('20251027210125'),
('20251027210057'),
('20251027210004'),
('20251012170005'),
('20251012170001'),
('20251012170000'),
('20250505204900'),
('20250505204600'),
('20250505204500'),
('20250505204400'),
('20250504190000'),
('20250504180000'),
('20250503231700'),
('20250503170000'),
('20250502210518'),
('20250502210502'),
('20250502210440'),
('20250428145207'),
('20250427170000'),
('20250427145207'),
('20250427145120'),
('20240918190000'),
('20240918170001'),
('20240918170000'),
('20240716115552'),
('20240708194400'),
('20240415111509'),
('20240415092625'),
('20240301123811'),
('20240301123810'),
('20240219180559'),
('20240219173422'),
('20240212111345'),
('20240212110612'),
('20240212110504'),
('20240204165000'),
('20231217193904'),
('20231217184225'),
('20231217170455'),
('20231217170445'),
('20231217170435'),
('20231214123448'),
('20231214114230'),
('20231214113536'),
('20230608153109'),
('20230530165750'),
('20230528181441'),
('20230424140046'),
('20230424112946'),
('20230420171019'),
('20230323185031'),
('20220823131256'),
('20220808140700'),
('20220808120347'),
('20220808114135'),
('20220801132800'),
('20220801110842'),
('20220801103836'),
('20220228161427'),
('20220228141224'),
('20220228114607'),
('20220228101325'),
('20220228100056'),
('20220221114745'),
('20220221104613'),
('20211026101919'),
('20211026094021'),
('20211026082636'),
('20211026075239'),
('20210728183111'),
('20210728163508'),
('20210728082943'),
('20210726121625'),
('20210726110423'),
('20210709090644'),
('20210709083517'),
('20210702171931'),
('20210630154722'),
('20210614132647'),
('20210614074635'),
('20210611120440'),
('20210515172357'),
('20210514131355'),
('20210514082612'),
('20210513170055'),
('20210513170020'),
('20210513155157'),
('20210513113601'),
('20210429155847'),
('20210315110522'),
('20210302170844'),
('20210302125701'),
('20210225130846'),
('20210225122838'),
('20210225084758'),
('20210224170621'),
('20210224155119'),
('20210224152208'),
('20210130164719'),
('20210130163013'),
('20210125123953'),
('20210125112038'),
('20210125103953'),
('20210125102743'),
('20210125100402'),
('20210125094839'),
('20210125092624'),
('20210125091539'),
('20210125091507'),
('20210125091407'),
('20210107181622'),
('20210104183700'),
('20210104165001'),
('20210104165000'),
('20210104113305'),
('20201217114100'),
('20201217101006'),
('20201216172430'),
('20201216134025'),
('20201216133048'),
('20201216124312'),
('20201211174336'),
('20201203180147'),
('20201203174057'),
('20201203173509'),
('20201127184636'),
('20201127124922'),
('20201126180504'),
('20201126172240'),
('20201126160623'),
('20201124125446'),
('20201121182012'),
('20201121173221'),
('20201121161226'),
('20201121160433'),
('20201121154118'),
('20201116111107'),
('20201114190213'),
('20201114190206'),
('20201114190122'),
('20201114185202'),
('20201114182035'),
('20201114153405'),
('20201109160354'),
('20201109160026'),
('20201109160005'),
('20201109122544'),
('20201105094646'),
('20201104174729'),
('20200918172329'),
('20190213194658'),
('20190213194322'),
('20190112092856'),
('20190112092730'),
('20181215104937'),
('20181215103212'),
('20181215094412'),
('20180606133037'),
('20180606132934'),
('20180606132645'),
('20180106195500'),
('20180106195157'),
('20170324110129'),
('20170324094603'),
('20170322122633'),
('20170322120700'),
('20170322105927'),
('20170209000000'),
('20170207222924'),
('20170207182200'),
('20170205162132'),
('20170205140932'),
('20170205123022'),
('20170205110347'),
('20170205105918'),
('20170205105100'),
('20170205104912'),
('20161206101453'),
('20161206101432'),
('20161206101349'),
('20161206100650'),
('20161206100533'),
('20161126164243'),
('20161126162008'),
('20161126161939'),
('20160205143425'),
('20160205142705'),
('20151206195420'),
('20151206195126'),
('20151206194922'),
('20151202094913'),
('20151202094546'),
('20151107165010'),
('20151107164914'),
('20151106182310'),
('20151106182014'),
('20151104133100'),
('20151104124225'),
('20151104123005'),
('20151104123004'),
('20151104123003'),
('20151104123002'),
('20151104123001'),
('20151104123000'),
('20151104110820'),
('20151023171631'),
('20151023171131'),
('20150824184152'),
('20150824183432'),
('20150623154850'),
('20150623125543'),
('20150623125443'),
('20150623125355'),
('20150205184853'),
('20150205135706'),
('20150122234436'),
('20150122234130'),
('20150104212756'),
('20141212190100'),
('20141212180254'),
('20141212180209'),
('20141129180100'),
('20141129180000'),
('20141127151003'),
('20141127150848'),
('20141105150001'),
('20141105143032'),
('20141105143031'),
('20141018160236'),
('20141018155522'),
('20141018153900'),
('20141009084432'),
('20140909161617'),
('20140909161231'),
('20140909133849'),
('20140909133726'),
('20140906173627'),
('20140906173122'),
('20140826081547'),
('20140826081231'),
('20140825195959'),
('20140825195946'),
('20140825195738'),
('20140825195535'),
('20140825195157'),
('20140825193626'),
('20140825190846'),
('20140819142216'),
('20140819142050'),
('20140819141523'),
('20140807154318'),
('20140807154051'),
('20140731184807'),
('20140731184057'),
('20140709162307'),
('20140709162146'),
('20140709151837'),
('20140709150857'),
('20140604102837'),
('20140604102731'),
('20140604102620'),
('20140530173953'),
('20140506113232'),
('20140423141510'),
('20140423120000'),
('20140423113704'),
('20140407120828'),
('20140407120709'),
('20140407105013'),
('20140320223319'),
('20140320220944'),
('20140320130153'),
('20140320113029'),
('20140228230153'),
('20140228225657'),
('20140228150553'),
('20140228150157'),
('20140228131031'),
('20140228131030'),
('20140228131000'),
('20140228095953'),
('20140228095907'),
('20140226130430'),
('20140226130129'),
('20140221221530'),
('20140221221412'),
('20140221221232'),
('20140221221012'),
('20140221220705'),
('20140221214229'),
('20140220191030'),
('20140220191029'),
('20140220175333'),
('20140219164000'),
('20140219161530'),
('20140219150000'),
('20140218191040'),
('20140218191035'),
('20140218191030'),
('20140218191029'),
('20140218191028'),
('20140217161531'),
('20140217161530'),
('20140214110638'),
('20140214100303'),
('20140214095636'),
('20140214090816'),
('20140203174739'),
('20140203174708'),
('20140203174630'),
('20140127181613'),
('20140127181535'),
('20140127181423'),
('20140124190256'),
('20140124170257'),
('20140124150005'),
('20140122102927'),
('20140122101501'),
('20140114114307'),
('20140114114155'),
('20140110161451'),
('20140110161132'),
('20140110161023'),
('20131110230401'),
('20131110230256'),
('20131108233944'),
('20131105120845'),
('20131105120800'),
('20131105120755'),
('20131104093426'),
('20131104093129'),
('20131030164819'),
('20131029113102'),
('20131029103736'),
('20131029094806'),
('20131029092913'),
('20131028164201'),
('20131028164136'),
('20131028164025'),
('20131028163803'),
('20131027173631'),
('20131027173431'),
('20131027173203'),
('20131027172439'),
('20131025120658'),
('20131025120639'),
('20131025120618'),
('20131025080603'),
('20131025075700'),
('20131025062053'),
('20131025061949'),
('20131024123906'),
('20131024123846'),
('20131024122320'),
('20131024105521'),
('20131023165931'),
('20131023120652'),
('20131023120515'),
('20131023120322'),
('20131023120311'),
('20131023120254'),
('20131023113447'),
('20131023103343'),
('20131022160235'),
('20131021094620'),
('20131021094558'),
('20131021094536'),
('20131021094522'),
('20131021094503'),
('20131021094445'),
('20131021094426'),
('20131021094400'),
('20131021094344'),
('20131021094305'),
('20131021094222'),
('20131021094209'),
('20131021094150'),
('20131021094137'),
('20131021094130'),
('20131021094125'),
('20131021094120'),
('20131021094110'),
('20131021094101'),
('20131021094051'),
('20131021094032'),
('20131021080212'),
('20131021080109'),
('20131021070020'),
('20131021070000'),
('20131018163642'),
('20131018163540'),
('20131018163530'),
('20131018163520'),
('20131018163507'),
('20131018163414'),
('20131018163330'),
('20131018163237'),
('20131016235422'),
('20131008175822'),
('20131008175652'),
('20131008175532'),
('20131008175427'),
('20131008175226'),
('20131008175159'),
('20131008175041'),
('20131008174846'),
('20131008174752'),
('20131007183125'),
('20131007183110'),
('20131007163307'),
('20131007163201'),
('20131003092554'),
('20131003092512'),
('20131003092401'),
('20131003092305'),
('20130930084322'),
('20130928003801'),
('20130928003148'),
('20130925104237'),
('20130925094202'),
('20130919084912'),
('20130919084832'),
('20130919084800'),
('20130919084757'),
('20130919084741'),
('20130919084716'),
('20130919084655'),
('20130726134627'),
('20130716104131'),
('20130716090949'),
('20130716090917'),
('20130715123011'),
('20130709111920'),
('20130708095719'),
('20130708095645'),
('20130708095544'),
('20130708095528'),
('20130708095500'),
('20130708095358'),
('20130708095240'),
('20130708095118'),
('20130227172834'),
('20130227172825'),
('20130227172815'),
('20130227172733'),
('20130227172720'),
('20130227172702'),
('20130227101357'),
('20130227101346'),
('20130226135205'),
('20130226135131'),
('20130226104439'),
('20130225192148'),
('20130225192114'),
('20130225192043'),
('20130225191851'),
('20130225191837'),
('20130225191828'),
('20130225191818'),
('20130225191754'),
('20130225191742'),
('20130225191641'),
('20130225191634'),
('20130225191625'),
('20130225191016'),
('20130225190617'),
('20130225190534'),
('20130225190052');

