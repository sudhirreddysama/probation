-- MySQL dump 10.13  Distrib 5.7.29, for Linux (x86_64)
--
-- Host: localhost    Database: probation_inventory
-- ------------------------------------------------------
-- Server version	5.7.28-0ubuntu0.18.04.4

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `agents`
--

DROP TABLE IF EXISTS `agents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `agents` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `first_name` varchar(255) DEFAULT NULL,
  `last_name` varchar(255) DEFAULT NULL,
  `badge_number` varchar(255) DEFAULT NULL,
  `last_4ssn` varchar(255) DEFAULT NULL,
  `division_unit` varchar(255) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `location` varchar(255) DEFAULT NULL,
  `room` varchar(255) DEFAULT NULL,
  `office_phone` varchar(255) DEFAULT NULL,
  `pager_phone` varchar(255) DEFAULT NULL,
  `cell_phone` varchar(255) DEFAULT NULL,
  `supervisor` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `agents`
--

LOCK TABLES `agents` WRITE;
/*!40000 ALTER TABLE `agents` DISABLE KEYS */;
/*!40000 ALTER TABLE `agents` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ar_internal_metadata`
--

DROP TABLE IF EXISTS `ar_internal_metadata`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ar_internal_metadata` (
  `key` varchar(255) NOT NULL,
  `value` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ar_internal_metadata`
--

LOCK TABLES `ar_internal_metadata` WRITE;
/*!40000 ALTER TABLE `ar_internal_metadata` DISABLE KEYS */;
INSERT INTO `ar_internal_metadata` VALUES ('environment','development','2019-12-18 21:40:58','2019-12-18 21:40:58');
/*!40000 ALTER TABLE `ar_internal_metadata` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `inventories`
--

DROP TABLE IF EXISTS `inventories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `inventories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `item_dec` varchar(255) DEFAULT NULL,
  `serial_num` varchar(255) DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  `status_date` date DEFAULT NULL,
  `agent_rec` varchar(255) DEFAULT NULL,
  `incident_rep` varchar(255) DEFAULT NULL,
  `nsn_in_inventory` varchar(255) DEFAULT NULL,
  `notes` text,
  `expendable` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `inc_rep_date` date DEFAULT NULL,
  `inc_rep` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inventories`
--

LOCK TABLES `inventories` WRITE;
/*!40000 ALTER TABLE `inventories` DISABLE KEYS */;
/*!40000 ALTER TABLE `inventories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `schema_migrations`
--

DROP TABLE IF EXISTS `schema_migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `schema_migrations` (
  `version` varchar(255) NOT NULL,
  PRIMARY KEY (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `schema_migrations`
--

LOCK TABLES `schema_migrations` WRITE;
/*!40000 ALTER TABLE `schema_migrations` DISABLE KEYS */;
INSERT INTO `schema_migrations` VALUES ('20191212022836'),('20191216022836'),('20191216022838'),('20200106'),('20200114163624'),('20200114175435'),('20200225165617');
/*!40000 ALTER TABLE `schema_migrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sessions`
--

DROP TABLE IF EXISTS `sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sessions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `session_id` varchar(255) DEFAULT NULL,
  `data` text,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sessions`
--

LOCK TABLES `sessions` WRITE;
/*!40000 ALTER TABLE `sessions` DISABLE KEYS */;
INSERT INTO `sessions` VALUES (1,'20ea3b560205ddf2a7ec333ea407e16e','BAh7CEkiEF9jc3JmX3Rva2VuBjoGRUZJIjF4ZkJvVlRYRllCeTBaMDVzeHhG\nVjdMN2Q4MkhwMWtjNVc5QlgwL0FEV2JJPQY7AEZJIhRjdXJyZW50X3VzZXJf\naWQGOwBGaQtJIgxjb250ZXh0BjsARkkiGWludmVudG9yeV9ub25fc2VyaWFs\nBjsAVA==\n','2020-02-25 22:27:47','2020-02-25 22:30:05');
/*!40000 ALTER TABLE `sessions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `status`
--

DROP TABLE IF EXISTS `status`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `status` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `status` varchar(255) DEFAULT NULL,
  `status_description` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `status`
--

LOCK TABLES `status` WRITE;
/*!40000 ALTER TABLE `status` DISABLE KEYS */;
/*!40000 ALTER TABLE `status` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `summaries`
--

DROP TABLE IF EXISTS `summaries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `summaries` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `item_summary_name` varchar(255) DEFAULT NULL,
  `item_description` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `summaries`
--

LOCK TABLES `summaries` WRITE;
/*!40000 ALTER TABLE `summaries` DISABLE KEYS */;
/*!40000 ALTER TABLE `summaries` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `supervisors`
--

DROP TABLE IF EXISTS `supervisors`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `supervisors` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `first_name` varchar(255) DEFAULT NULL,
  `last_name` varchar(255) DEFAULT NULL,
  `first_phone` varchar(255) DEFAULT NULL,
  `second_phone` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `supervisors`
--

LOCK TABLES `supervisors` WRITE;
/*!40000 ALTER TABLE `supervisors` DISABLE KEYS */;
/*!40000 ALTER TABLE `supervisors` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `password_digest` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `first_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `last_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `level` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `active` tinyint(1) unsigned NOT NULL DEFAULT '1',
  `activation_key` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `last_login_at` datetime DEFAULT NULL,
  `password_set_at` datetime DEFAULT NULL,
  `auth_ldap` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `qb_level` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ve_level` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `valid_until` date DEFAULT NULL,
  `deliver_from_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `deliver_from_email` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=82 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (6,'isadmin','$2a$10$69GUdyN.RYR6hnQQ2WHqV.5NpwCZxtZ1t2feHlh3xjr4eThJcVzwa','jessesternberg@monroecounty.gov','IS','Admin','Programmer','585-753-1822','admin',1,'1843734726','2020-02-25 22:29:42','2019-12-06 06:55:06',0,'admin','admin',NULL,NULL,NULL),(7,'silkworw',NULL,'wadesilkworth@monroecounty.gov','Wade','Silkworth','Manager of Environmental Health','585-753-5470','admin',1,NULL,'2019-06-27 08:09:51',NULL,1,NULL,NULL,NULL,NULL,NULL),(8,'piedmond',NULL,'dpiedmont@monroecounty.gov','Drey','Piedmont','Sr Data Manager','585-753-5350','admin',1,NULL,'2018-06-28 11:53:27',NULL,1,NULL,NULL,NULL,NULL,NULL),(9,'sternbej',NULL,'jessesternberg@monroecounty.gov','Jesse','Sternberg','Programmer Analyst','585-753-1822','user',1,NULL,'2018-01-18 14:11:14',NULL,1,NULL,NULL,NULL,NULL,NULL),(10,'GierJ',NULL,'jgier@monroecounty.gov','Jennifer','Gier','Business Analyst','585-753-1857','admin',1,NULL,NULL,NULL,1,NULL,NULL,NULL,NULL,NULL),(11,'FrazerJ',NULL,'jfrazer@monroecounty.gov','John','Frazer','Sr Public Health Engineer','585-753-5476','admin',1,'3747047818','2019-06-28 10:42:43',NULL,1,NULL,NULL,NULL,NULL,NULL),(12,'HoustonL',NULL,'lhouston@monroecounty.gov','Lee','Houston','Assoc Public Health Sanitarian','585-753-5571','admin',1,NULL,'2019-03-25 11:33:29',NULL,1,NULL,NULL,NULL,NULL,NULL),(13,'AmmermaE',NULL,'eammerman@monroecounty.gov','Eric','Ammerman','Sr Public Health Sanitarian','585-753-5058','admin',0,NULL,'2018-10-11 15:43:39',NULL,1,NULL,NULL,NULL,NULL,NULL),(14,'HuntP',NULL,'phunt@monroecounty.gov','Paul','Hunt','Sr Public Health Sanitarian','585-753-5067','admin',1,NULL,'2019-05-07 09:39:38',NULL,1,NULL,NULL,NULL,NULL,NULL),(15,'PaintinS',NULL,'spainting@monroecounty.gov','Susan','Painting','Sr Public Health Sanitarian','585-753-5464','admin',1,NULL,'2019-06-28 17:14:02',NULL,1,NULL,NULL,NULL,NULL,NULL),(16,'SchellJ',NULL,'jschell@monroecounty.gov','Jeanne','Schell','Sr Public Health Sanitarian','585-753-5051','admin',0,NULL,'2019-01-15 15:43:53',NULL,1,NULL,NULL,NULL,NULL,NULL),(17,'StichE',NULL,'estich@monroecounty.gov','Earl','Stich','retired Sr Public Health Sanitarian','','user',0,NULL,'2018-01-25 13:54:16',NULL,1,NULL,NULL,NULL,NULL,NULL),(18,'HallockS',NULL,'shallock@monroecounty.gov','Scott','Hallock','Associate Public Health Sanitarian','585-753-5579','admin',1,'4566602106','2019-06-05 12:52:45',NULL,1,NULL,NULL,NULL,NULL,NULL),(19,'KassmanC',NULL,'ckassmann@monroecounty.gov','Chris','Kassmann','Public Health Sanitarian','585-753-5459','user',1,NULL,'2019-06-27 08:53:02',NULL,1,NULL,NULL,NULL,NULL,NULL),(20,'RightmyG',NULL,'grightmyer@monroecounty.gov','Gerry','Rightmyer','Public Health Sanitarian','585-753-5075','user',1,'8034781475','2019-06-25 13:44:54',NULL,1,NULL,NULL,NULL,NULL,NULL),(21,'RightmyP',NULL,'prightmyer@monroecounty.gov','Peter','Rightmyer','Public Health Sanitarian','585-753-5480','user',1,NULL,'2019-06-28 10:58:01',NULL,1,NULL,NULL,NULL,NULL,NULL),(22,'MayS',NULL,'smay@monroecounty.gov','Sabrina','May','Clerk 2','585-753-5057','user',1,NULL,NULL,NULL,1,NULL,NULL,NULL,NULL,NULL),(23,'FinferaA',NULL,'afinfera@monroecounty.gov','Amy','Finfera','Public Health Sanitarian','585-753-5474','user',1,NULL,'2019-06-28 08:03:25',NULL,1,NULL,NULL,NULL,NULL,NULL),(24,'McCallK',NULL,'kmccall@monroecounty.gov','Kurt','McCall','Public Health Sanitarian','585-753-5466','user',1,'5560014348','2019-06-28 09:13:48',NULL,1,NULL,NULL,NULL,NULL,NULL),(25,'CecereC',NULL,'ccecere@monroecounty.gov','Chris','Cecere','Public Health Sanitarian','585-753-5457','user',1,NULL,'2019-06-24 09:05:11',NULL,1,NULL,NULL,NULL,NULL,NULL),(26,'RobsonJ',NULL,'judyrobson@monroecounty.gov','Judy','Robson','Public Health Sanitarian','585-753-5463','user',1,NULL,'2019-06-28 09:37:14',NULL,1,NULL,NULL,NULL,NULL,NULL),(27,'VoellinM',NULL,'mvoellinger@monroecounty.gov','Meghan','Voellinger','Public Health Sanitarian','585-753-5475','user',1,NULL,'2019-06-19 08:35:43',NULL,1,NULL,NULL,NULL,NULL,NULL),(28,'JohnsonR',NULL,'racheljohnson@monroecounty.gov','Rachel','Johnson','Public Health Sanitarian','585-753-5563','user',1,NULL,'2019-06-28 10:41:14',NULL,1,NULL,NULL,NULL,NULL,NULL),(29,'MadisonS',NULL,'saramadison@monroecounty.gov','Sara','Madison','Public Health Sanitarian','585-753-5462','user',1,'0746125471','2019-06-28 09:55:11',NULL,1,NULL,NULL,NULL,NULL,NULL),(30,'GrantJ',NULL,'jgrant@monroecounty.gov','Jody','Grant','Public Health Sanitarian','585-753-5541','user',1,NULL,'2019-06-28 15:36:13',NULL,1,NULL,NULL,NULL,NULL,NULL),(31,'GallifoG',NULL,'ggalliford@monroecounty.gov','Greg','Galliford','Public Health Sanitarian','585-753-5041','user',1,NULL,'2019-06-07 08:58:07',NULL,1,NULL,NULL,NULL,NULL,NULL),(32,'CadeE',NULL,'elisecade@monroecounty.gov','Elise','Cade','Public Health Sanitarian','585-753-5048','user',1,NULL,'2019-06-27 10:01:58',NULL,1,NULL,NULL,NULL,NULL,NULL),(33,'CreightJ',NULL,'jcreighton@monroecounty.gov','James','Creighton','Public Health Sanitarian','585-753-5043','user',1,NULL,'2018-01-11 08:48:05',NULL,1,NULL,NULL,NULL,NULL,NULL),(34,'MortensL',NULL,'lmortensen@monroecounty.gov','Lance','Mortensen','Public Health Sanitarian','585-753-5066','user',1,'6037848278','2019-06-28 11:55:30',NULL,1,NULL,NULL,NULL,NULL,NULL),(35,'kasperr',NULL,'ronaldkasper@monroecounty.gov','Ronald','Kasper','Senior Public Health Sanitarian','585-753-5052','admin',1,NULL,'2019-06-19 08:15:00',NULL,1,NULL,NULL,NULL,NULL,NULL),(36,'AbramsJ',NULL,'jabrams@monroecounty.gov','Jim','Abrams','Public Health Sanitarian PT','585-754-5045','user',0,NULL,NULL,NULL,1,NULL,NULL,NULL,NULL,NULL),(37,'SteinS',NULL,'sstein@monroecounty.gov','Sandra','Stein','retired Office Clerk 2','','user',0,NULL,NULL,NULL,1,NULL,NULL,NULL,NULL,NULL),(38,'henryd',NULL,'davidhenry@monroecounty.gov','David','Henry','','585-753-5553','user',1,NULL,NULL,NULL,1,NULL,NULL,NULL,NULL,NULL),(39,'PalumboB',NULL,'bpalumbo@monroecounty.gov','Brian','Palumbo','Senior Public Health Sanitarian','585-753-5560','admin',1,NULL,'2019-06-26 09:23:09',NULL,1,NULL,NULL,NULL,NULL,NULL),(40,'BeylerG',NULL,'gbeyler@monroecounty.gov','Greg','Beyler','Public Health Sanitarian','585-753-5557','user',0,NULL,'2019-03-18 09:46:50',NULL,1,NULL,NULL,NULL,NULL,NULL),(41,'ZielinsJ',NULL,'jzielinski@monroecounty.gov','Joseph','Zielinski','Sr Public Health Sanitarian','585-753-5044','admin',1,NULL,'2019-04-03 15:17:01',NULL,1,NULL,NULL,NULL,NULL,NULL),(42,'BilenleA',NULL,'alpbilenler@monroecounty.gov','Alp','Bilenler','Public Health Sanitarian Trainee','585-753-5047','user',0,NULL,'2018-02-16 13:47:42',NULL,1,NULL,NULL,NULL,NULL,NULL),(43,'ThompsoN',NULL,'nthompson@monroecounty.gov','Nancy','Thompson','Clerk 2','585-753-5171','user',1,NULL,NULL,NULL,1,NULL,NULL,NULL,NULL,NULL),(44,'DiversT',NULL,'TDivers@monroecounty.gov','Tami','Divers','Community Health Worker','','user',1,NULL,'2019-06-28 13:14:07',NULL,1,NULL,NULL,NULL,NULL,NULL),(45,'WilliaLa',NULL,'lwilliams@monroecounty.gov','Latisha','Williams','','','user',0,NULL,NULL,NULL,1,NULL,NULL,NULL,NULL,NULL),(46,'RaymondM',NULL,'mraymond@monroecounty.gov','Marlene','Raymond','CHW/HFC','585-753-5575','user',1,NULL,'2018-07-10 16:34:47',NULL,1,NULL,NULL,NULL,NULL,NULL),(47,'ArmbrusS',NULL,'sarmbruster@monroecounty.gov','Sharon','Armbruster','','585-753-5087','user',1,NULL,NULL,NULL,1,NULL,NULL,NULL,NULL,NULL),(48,'DeuelD',NULL,'ddeuel@monroecounty.gov','Daniel','Deuel','Public Health Sanitarian','585-753-5068','user',1,'8033858430','2019-06-28 10:29:03',NULL,1,NULL,NULL,NULL,NULL,NULL),(49,'ReinschM',NULL,'mreinschmidt@monroecounty.gov','Michael ','Reinschmidt','Public Health Sanitarian','585-753-5072','user',1,NULL,'2019-04-15 09:57:34',NULL,1,NULL,NULL,NULL,NULL,NULL),(50,'ZieglerS',NULL,'sziegler@monroecounty.com','Stephanie','Ziegler','Public Health Sanitarian','585-753-5569','user',1,NULL,'2019-06-05 09:49:32',NULL,1,NULL,NULL,NULL,NULL,NULL),(51,'BegovicM',NULL,'mirzabegovic@monroecounty.gov','Mirza','Begovic','Public Health Sanitarian','585-753-5124','user',1,NULL,'2019-06-27 09:00:04',NULL,1,NULL,NULL,NULL,NULL,NULL),(52,'ParraR',NULL,'ryanparra-merrell@monroecounty.gov','Ryan','Parra-Merrell','Public Health Sanitarian','585-753-5465','user',1,NULL,'2019-06-27 15:22:42',NULL,1,NULL,NULL,NULL,NULL,NULL),(53,'SorensoL',NULL,'LauraSorenson@monroecounty.gov','Laura','Sorenson','Public Health Sanitarian','585-753-5854','user',1,'3806155501','2019-06-24 08:13:14',NULL,1,NULL,NULL,NULL,NULL,NULL),(54,'GobeB',NULL,'BrettGobe@monroecouty.gov','Brett','Gobe','Public Health Sanitarian','585-753-5330','user',1,NULL,'2019-06-28 15:29:33',NULL,1,NULL,NULL,NULL,NULL,NULL),(55,'SchiessL',NULL,'lindaschiess@monroecounty.gov','Linda','Schiess','','585-753-5077','user',1,NULL,'2019-06-28 16:08:00',NULL,1,NULL,NULL,NULL,NULL,NULL),(56,'LloydA',NULL,'antoinettelloyd@monroecounty.gov','Antoinette','Lloyd','','585-753-5062','user',0,NULL,NULL,NULL,1,NULL,NULL,NULL,NULL,NULL),(57,'KrebsAm',NULL,'AmyKrebs@monroecounty.gov','Amy','Krebs','','585-753-5060','user',1,NULL,NULL,NULL,1,NULL,NULL,NULL,NULL,NULL),(58,'testuser','$2a$10$6qmI6/cZ.tboITcWe3U9uuWPSfJ6T59ymJ3W7fuel89X2BipQ6xIi','nobody@example.com','Test','User','','','user',1,NULL,'2018-01-08 12:43:08','2017-12-14 16:39:03',0,NULL,NULL,NULL,NULL,NULL),(59,'LianosV',NULL,'vasilioslianos@monroecounty.gov','Vasilios','Lianos','Public Health Sanitarian','585-753-5550','user',1,'0635176508','2019-06-28 09:13:20',NULL,1,NULL,NULL,NULL,NULL,NULL),(60,'MinavioA',NULL,'alecminavio@monroecounty.gov','Alec','Minavio','Env Health Summer Worker','','user',0,NULL,'2018-08-20 08:23:48',NULL,1,NULL,NULL,NULL,NULL,NULL),(61,'MarcellG',NULL,'gabriellemarcello@monroecounty.gov','Gabrielle','Marcello','Community Health Worker','753-5070','user',1,NULL,'2019-06-28 09:34:37',NULL,1,NULL,NULL,NULL,NULL,NULL),(62,'roodj',NULL,'jamesrood@monroecounty.gov','James','Rood','Health Business Operations Analyst','585-753-5455','user',1,NULL,NULL,NULL,1,NULL,NULL,NULL,NULL,NULL),(63,'CalabreP',NULL,'paulettecalabrese@monroecounty.gov','Paulette','Calabrese','Clerk 2','585-753-5060','user',0,NULL,'2019-02-15 09:32:10',NULL,1,NULL,NULL,NULL,NULL,NULL),(64,'TereschL',NULL,'ltereschenko@monroecounty.gov','Ludmila','Tereschenko','HBOA','585-753-5554','user',0,NULL,NULL,NULL,1,NULL,NULL,NULL,NULL,NULL),(65,'BaskinD',NULL,'dbaskin@monroecounty.gov','Donna','Baskin','Senior Administrative Analyst','585-753-5209','user',0,NULL,NULL,NULL,1,NULL,NULL,NULL,NULL,NULL),(66,'BloomM',NULL,'MBloom@monroecounty.gov','Marie','Bloom','','','user',0,NULL,NULL,NULL,1,NULL,NULL,NULL,NULL,NULL),(67,'MirabelF',NULL,'fmirabella@monroecounty.gov','Frank','Mirabella','Principal Public Health Sanitarian','585-753-5563','user',0,NULL,NULL,NULL,1,NULL,NULL,NULL,NULL,NULL),(68,'CrouseM',NULL,'mcrouse@monroecounty.gov','Mary Ann','Crouse','','','user',0,NULL,NULL,NULL,1,NULL,NULL,NULL,NULL,NULL),(69,'SlaunwhM',NULL,'michaelslaunwhite@monroecounty.gov','Michael','Slaunwhite','','','user',0,NULL,NULL,NULL,1,NULL,NULL,NULL,NULL,NULL),(70,'DakinS',NULL,'sharondakin@monroecounty.gov','Sharon','Dakin','','274-6087','user',0,NULL,NULL,NULL,1,NULL,NULL,NULL,NULL,NULL),(71,'CavaluzZ','$2a$10$4q/QwpwXL9gI4ArN3igl/OoBivaWbAVzauoqSa9poKGBtNsuwj2JS','zacharycavaluzzi@monroecounty.gov','Zachary','Cavaluzzi','Public Health Sanitarian','585-753-5574','user',1,NULL,'2019-06-28 08:32:33','2019-03-25 15:05:03',0,NULL,NULL,NULL,NULL,NULL),(72,'KaltenbJ',NULL,'johnkaltenbach@monroecounty.gov','John','Kaltenbach','Public Health Sanitarian','','user',1,NULL,'2019-06-05 12:43:22',NULL,1,NULL,NULL,NULL,NULL,NULL),(73,'PadillaM',NULL,'marissapadilla@monroecounty.gov','Marissa','Padilla','Public Health Sanitarian','','user',1,NULL,'2019-06-28 08:40:03',NULL,1,NULL,NULL,NULL,NULL,NULL),(74,'pateb',NULL,'BenjaminPate@monroecounty.gov','Benjamin','Pate','','585-753-5449','user',1,NULL,NULL,NULL,1,'admin',NULL,NULL,NULL,NULL),(75,'benvenum',NULL,'MaureenBenvenuto@monroecounty.gov','Maureen','Benvenuto','Assistant Supervisor of Claims & Accounts','585-753-5053','user',1,NULL,NULL,NULL,1,'admin',NULL,NULL,NULL,NULL),(76,'shekar','$2a$10$M08ay.8FR3XcuXlJ/Hd1KOjEb6Nd7cJeZ6MVfysdFUc92fXf0FpyK','rajashekarguda@gmail.com','rajasheker','reddy',NULL,NULL,'manager',1,NULL,'2019-10-31 08:39:42','2019-10-31 06:52:27',0,NULL,NULL,NULL,NULL,NULL),(77,'shekar@1L','$2a$10$4EmGQmaV6pgaMFA2PHScm.F1oUWowBum4Pt0ZJ.XlRO5ruS4nhH.G','shekar@monroecounty.gov','sdfg','sdf',NULL,NULL,'admin',1,NULL,NULL,'2019-08-02 18:06:25',1,NULL,NULL,NULL,NULL,NULL),(78,'soujanya','$2a$10$uwoTodhlyzyXl1PgTSViXeb0Il5ll2rlnBmgQFLD5oR37hkG8N/6m','soujanyareddy@monroecounty.gov','Soujanya','Reddy',NULL,NULL,'user',1,NULL,'2019-08-23 22:49:00','2019-08-02 18:10:25',0,NULL,NULL,NULL,NULL,NULL),(79,'shek','$2a$10$KXmpXthxzOZNuZrHMxGO7O6L2qkS8RthT9Tysd0o7L104Av7LDVkW','shekarreddy1@monroecounty.gov','shekar','reddy',NULL,NULL,'admin',1,NULL,NULL,'2019-08-19 07:27:47',0,NULL,NULL,NULL,NULL,NULL),(80,'shekar123','$2a$10$ZJX2kRBXLzyZM98v6VJ5B.n6tccfN9fVMRe/Df9fPSWcdtr13cdzO','shekar123reddy@monroecounty.gov','shekar','reddy',NULL,NULL,'manager',1,NULL,'2019-08-20 09:35:55','2019-08-23 22:53:02',0,NULL,NULL,NULL,NULL,NULL),(81,'shekar1','$2a$10$AnVFHXvEgLhuXh1LLkGO/.2ukVfC.t4XZgRvynxgmKa.DqLOIsrsC','shekar1reddy@monroecounty.gov','shekar1','reddy',NULL,NULL,'manager',1,NULL,NULL,'2019-08-23 22:56:36',0,NULL,NULL,NULL,NULL,NULL);
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2020-02-25 22:48:11
