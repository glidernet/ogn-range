-- phpMyAdmin SQL Dump
-- version 4.8.4
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: May 17, 2019 at 06:40 PM
-- Server version: 5.7.26-0ubuntu0.18.04.1
-- PHP Version: 7.2.17-0ubuntu0.18.04.1

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `ognrange`
--

-- --------------------------------------------------------

--
-- Table structure for table `availability`
--

DROP TABLE IF EXISTS `availability`;
CREATE TABLE IF NOT EXISTS `availability` (
  `station_id` smallint(5) UNSIGNED NOT NULL,
  `time` int(10) UNSIGNED DEFAULT NULL,
  `status` char(1) DEFAULT NULL,
  PRIMARY KEY (`station_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `availability_log`
--

DROP TABLE IF EXISTS `availability_log`;
CREATE TABLE IF NOT EXISTS `availability_log` (
  `station_id` smallint(5) UNSIGNED DEFAULT NULL,
  `time` int(10) UNSIGNED DEFAULT NULL,
  `status` char(1) DEFAULT NULL,
  KEY `a_s` (`station_id`,`time`),
  KEY `sta` (`station_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `estimatedcoverage`
--

DROP TABLE IF EXISTS `estimatedcoverage`;
CREATE TABLE IF NOT EXISTS `estimatedcoverage` (
  `station` smallint(5) UNSIGNED NOT NULL,
  `ref` char(9) NOT NULL,
  `strength` smallint(5) UNSIGNED NOT NULL,
  `count` int(11) DEFAULT NULL,
  UNIQUE KEY `posmgrs_uniq` (`station`,`ref`),
  KEY `posmgrs_ref` (`ref`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `gliders`
--

DROP TABLE IF EXISTS `gliders`;
CREATE TABLE IF NOT EXISTS `gliders` (
  `glider_id` int(11) NOT NULL AUTO_INCREMENT,
  `callsign` char(32) NOT NULL,
  PRIMARY KEY (`glider_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `history`
--

DROP TABLE IF EXISTS `history`;
CREATE TABLE IF NOT EXISTS `history` (
  `time` datetime NOT NULL,
  `station` int(11) NOT NULL,
  `type` enum('new','move','purged','noppm','renamed') DEFAULT NULL,
  `details` text
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `positions_mgrs`
--

DROP TABLE IF EXISTS `positions_mgrs`;
CREATE TABLE IF NOT EXISTS `positions_mgrs` (
  `time` char(10) NOT NULL,
  `station` smallint(5) UNSIGNED NOT NULL,
  `ref` char(9) NOT NULL,
  `strength` smallint(5) UNSIGNED NOT NULL,
  `lowest` smallint(5) NOT NULL,
  `highest` smallint(5) NOT NULL,
  `count` int(10) UNSIGNED NOT NULL,
  PRIMARY KEY (`ref`,`station`,`time`),
  KEY `rt` (`ref`,`time`),
  KEY `sta` (`station`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 DELAY_KEY_WRITE=1
;

-- --------------------------------------------------------

--
-- Table structure for table `roughcoverage`
--

DROP TABLE IF EXISTS `roughcoverage`;
CREATE TABLE IF NOT EXISTS `roughcoverage` (
  `station` smallint(5) UNSIGNED NOT NULL,
  `ref` char(9) NOT NULL,
  `strength` smallint(5) UNSIGNED NOT NULL,
  `count` int(11) DEFAULT NULL,
  UNIQUE KEY `posmgrs_uniq` (`station`,`ref`),
  KEY `posmgrs_ref` (`ref`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `stationlocation`
--

DROP TABLE IF EXISTS `stationlocation`;
CREATE TABLE IF NOT EXISTS `stationlocation` (
  `time` char(10) DEFAULT NULL,
  `station` smallint(5) UNSIGNED DEFAULT NULL,
  `lt` decimal(7,4) DEFAULT NULL,
  `lg` decimal(7,4) DEFAULT NULL,
  `height` smallint(6) DEFAULT NULL,
  `country` char(50) DEFAULT 'Unknown',
  `version` char(16) DEFAULT NULL,
  UNIQUE KEY `s1` (`station`,`time`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `stations`
--

DROP TABLE IF EXISTS `stations`;
CREATE TABLE IF NOT EXISTS `stations` (
  `id` smallint(6) NOT NULL AUTO_INCREMENT,
  `station` char(11) DEFAULT NULL,
  `country` char(2) DEFAULT NULL COMMENT 'Not used',
  `active` char(1) DEFAULT 'Y' COMMENT 'Indication of active or not',
  `otime` datetime(6) DEFAULT '1970-01-01 00:00:00.000000' COMMENT 'Time of the last hearbeat',
  PRIMARY KEY (`id`),
  UNIQUE KEY `station` (`station`),
  KEY `sup` (`active`,`station`),
  KEY `Otime` (`otime`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `stats`
--

DROP TABLE IF EXISTS `stats`;
CREATE TABLE IF NOT EXISTS `stats` (
  `time` datetime NOT NULL,
  `station` smallint(5) UNSIGNED NOT NULL,
  `positions` int(10) UNSIGNED NOT NULL,
  `gliders` smallint(5) UNSIGNED NOT NULL,
  `crc` smallint(5) UNSIGNED NOT NULL,
  `ignoredpositions` smallint(5) UNSIGNED NOT NULL,
  `cpu` tinyint(3) UNSIGNED NOT NULL DEFAULT '0',
  `temp` tinyint(3) UNSIGNED DEFAULT '0',
  UNIQUE KEY `st` (`station`,`time`),
  KEY `sta` (`station`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `statssummary`
--

DROP TABLE IF EXISTS `statssummary`;
CREATE TABLE IF NOT EXISTS `statssummary` (
  `station` smallint(5) UNSIGNED NOT NULL,
  `time` datetime NOT NULL,
  `positions` int(10) UNSIGNED NOT NULL,
  `gliders` smallint(5) UNSIGNED NOT NULL,
  `crc` smallint(5) UNSIGNED NOT NULL,
  `ignoredpositions` smallint(5) UNSIGNED NOT NULL,
  `cpu` tinyint(3) UNSIGNED NOT NULL DEFAULT '0',
  `temp` tinyint(3) UNSIGNED DEFAULT '0',
  UNIQUE KEY `st` (`station`)
) ENGINE=MEMORY DEFAULT CHARSET=latin1;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

