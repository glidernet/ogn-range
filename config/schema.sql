-- MySQL dump 10.13  Distrib 5.6.38, for FreeBSD10.3 (amd64)


-- Copyright (c) 2014-2018, Melissa Jenkins
-- All rights reserved.

-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions are met:
--     * Redistributions of source code must retain the above copyright
--       notice, this list of conditions and the following disclaimer.
--     * Redistributions in binary form must reproduce the above copyright
--       notice, this list of conditions and the following disclaimer in the
--       documentation and/or other materials provided with the distribution.
--     * The names of its contributors may not be used to endorse or promote products
--       derived from this software without specific prior written permission.

-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
-- ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
-- WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
-- DISCLAIMED. IN NO EVENT SHALL MELISSA JENKINS BE LIABLE FOR ANY
-- DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
-- (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
-- LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
-- ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
-- (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
-- SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


--
-- Host: localhost    Database: flarmrange2
-- ------------------------------------------------------
-- Server version	5.6.38

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
-- Table structure for table `availability`
--

DROP TABLE IF EXISTS `availability`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `availability` (
  `station_id` smallint(5) unsigned NOT NULL,
  `time` int(10) unsigned DEFAULT NULL,
  `status` char(1) DEFAULT NULL,
  PRIMARY KEY (`station_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `availability_log`
--

DROP TABLE IF EXISTS `availability_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `availability_log` (
  `station_id` smallint(5) unsigned DEFAULT NULL,
  `time` int(10) unsigned DEFAULT NULL,
  `status` char(1) DEFAULT NULL,
  KEY `a_s` (`station_id`,`time`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `estimatedcoverage`
--

DROP TABLE IF EXISTS `estimatedcoverage`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `estimatedcoverage` (
  `station` smallint(5) unsigned NOT NULL,
  `ref` char(9) NOT NULL,
  `strength` smallint(5) unsigned NOT NULL,
  `count` int(11) DEFAULT NULL,
  UNIQUE KEY `posmgrs_uniq` (`station`,`ref`),
  KEY `posmgrs_ref` (`ref`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `history`
--

DROP TABLE IF EXISTS `history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `history` (
  `time` datetime NOT NULL,
  `station` int(11) NOT NULL,
  `type` enum('new','move','purged','noppm') DEFAULT NULL,
  `details` text
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `positions_mgrs`
--

DROP TABLE IF EXISTS `positions_mgrs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `positions_mgrs` (
  `time` char(10) NOT NULL,
  `station` smallint(5) unsigned NOT NULL,
  `ref` char(9) NOT NULL,
  `strength` smallint(5) unsigned NOT NULL,
  `lowest` smallint(5) NOT NULL,
  `highest` smallint(5) NOT NULL,
  `count` int(10) unsigned NOT NULL,
  PRIMARY KEY (`ref`,`station`,`time`),
  KEY `rt` (`ref`,`time`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 DELAY_KEY_WRITE=1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `roughcoverage`
--

DROP TABLE IF EXISTS `roughcoverage`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `roughcoverage` (
  `station` smallint(5) unsigned NOT NULL,
  `ref` char(9) NOT NULL,
  `strength` smallint(5) unsigned NOT NULL,
  `count` int(11) DEFAULT NULL,
  UNIQUE KEY `posmgrs_uniq` (`station`,`ref`),
  KEY `posmgrs_ref` (`ref`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `stationlocation`
--

DROP TABLE IF EXISTS `stationlocation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `stationlocation` (
  `time` char(10) DEFAULT NULL,
  `station` smallint(5) unsigned DEFAULT NULL,
  `lt` decimal(7,4) DEFAULT NULL,
  `lg` decimal(7,4) DEFAULT NULL,
  `height` smallint(6) DEFAULT NULL,
  `country` char(50) DEFAULT 'Unknown',
  `version` char(16) DEFAULT NULL,
  UNIQUE KEY `s1` (`station`,`time`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `stations`
--

DROP TABLE IF EXISTS `stations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `stations` (
  `id` smallint(6) NOT NULL AUTO_INCREMENT,
  `station` char(11) DEFAULT NULL,
  `country` char(2) DEFAULT NULL,
  `active` char(1) DEFAULT 'Y',
  PRIMARY KEY (`id`),
  UNIQUE KEY `station` (`station`),
  KEY `sup` (`active`,`station`)
) ENGINE=InnoDB AUTO_INCREMENT=3154 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `stats`
--

DROP TABLE IF EXISTS `stats`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `stats` (
  `time` datetime NOT NULL,
  `station` smallint(5) unsigned NOT NULL,
  `positions` int(10) unsigned NOT NULL,
  `gliders` smallint(5) unsigned NOT NULL,
  `crc` smallint(5) unsigned NOT NULL,
  `ignoredpositions` smallint(5) unsigned NOT NULL,
  `cpu` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `temp` tinyint(3) unsigned DEFAULT '0',
  UNIQUE KEY `st` (`station`,`time`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `statssummary`
--

DROP TABLE IF EXISTS `statssummary`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `statssummary` (
  `station` smallint(5) unsigned NOT NULL,
  `time` datetime NOT NULL,
  `positions` int(10) unsigned NOT NULL,
  `gliders` smallint(5) unsigned NOT NULL,
  `crc` smallint(5) unsigned NOT NULL,
  `ignoredpositions` smallint(5) unsigned NOT NULL,
  `cpu` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `temp` tinyint(3) unsigned DEFAULT '0',
  UNIQUE KEY `st` (`station`)
) ENGINE=MEMORY DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2017-12-31 23:29:31
