-- phpMyAdmin SQL Dump
-- version 4.8.4
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Mar 21, 2019 at 09:48 AM
-- Server version: 5.7.25-0ubuntu0.18.04.2
-- PHP Version: 7.2.15-0ubuntu0.18.04.1

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
CREATE TABLE `availability` (
  `station_id` smallint(5) UNSIGNED NOT NULL,
  `time` int(10) UNSIGNED DEFAULT NULL,
  `status` char(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `availability_log`
--

DROP TABLE IF EXISTS `availability_log`;
CREATE TABLE `availability_log` (
  `station_id` smallint(5) UNSIGNED DEFAULT NULL,
  `time` int(10) UNSIGNED DEFAULT NULL,
  `status` char(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `estimatedcoverage`
--

DROP TABLE IF EXISTS `estimatedcoverage`;
CREATE TABLE `estimatedcoverage` (
  `station` smallint(5) UNSIGNED NOT NULL,
  `ref` char(9) NOT NULL,
  `strength` smallint(5) UNSIGNED NOT NULL,
  `count` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `gliders`
--

DROP TABLE IF EXISTS `gliders`;
CREATE TABLE `gliders` (
  `glider_id` int(11) NOT NULL,
  `callsign` char(32) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `history`
--

DROP TABLE IF EXISTS `history`;
CREATE TABLE `history` (
  `time` datetime NOT NULL,
  `station` int(11) NOT NULL,
  `type` enum('new','move','purged','noppm') DEFAULT NULL,
  `details` text
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `positions_mgrs`
--

DROP TABLE IF EXISTS `positions_mgrs`;
CREATE TABLE `positions_mgrs` (
  `time` char(10) NOT NULL,
  `station` smallint(5) UNSIGNED NOT NULL,
  `ref` char(9) NOT NULL,
  `strength` smallint(5) UNSIGNED NOT NULL,
  `lowest` smallint(5) NOT NULL,
  `highest` smallint(5) NOT NULL,
  `count` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 DELAY_KEY_WRITE=1
PARTITION BY RANGE COLUMNS(`time`)
(
PARTITION p1 VALUES LESS THAN ('2017-01-01') ENGINE=InnoDB,
PARTITION p2 VALUES LESS THAN ('2017-06-01') ENGINE=InnoDB,
PARTITION p3 VALUES LESS THAN ('2018-01-01') ENGINE=InnoDB,
PARTITION p18a VALUES LESS THAN ('2018-06-01') ENGINE=InnoDB,
PARTITION p18b VALUES LESS THAN ('2019-01-01') ENGINE=InnoDB,
PARTITION p19a VALUES LESS THAN ('2019-06-01') ENGINE=InnoDB
);

-- --------------------------------------------------------

--
-- Table structure for table `roughcoverage`
--

DROP TABLE IF EXISTS `roughcoverage`;
CREATE TABLE `roughcoverage` (
  `station` smallint(5) UNSIGNED NOT NULL,
  `ref` char(9) NOT NULL,
  `strength` smallint(5) UNSIGNED NOT NULL,
  `count` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `stationlocation`
--

DROP TABLE IF EXISTS `stationlocation`;
CREATE TABLE `stationlocation` (
  `time` char(10) DEFAULT NULL,
  `station` smallint(5) UNSIGNED DEFAULT NULL,
  `lt` decimal(7,4) DEFAULT NULL,
  `lg` decimal(7,4) DEFAULT NULL,
  `height` smallint(6) DEFAULT NULL,
  `country` char(50) DEFAULT 'Unknown',
  `version` char(16) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `stations`
--

DROP TABLE IF EXISTS `stations`;
CREATE TABLE `stations` (
  `id` smallint(6) NOT NULL,
  `station` char(11) DEFAULT NULL,
  `country` char(2) DEFAULT NULL,
  `active` char(1) DEFAULT 'Y'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `stats`
--

DROP TABLE IF EXISTS `stats`;
CREATE TABLE `stats` (
  `time` datetime NOT NULL,
  `station` smallint(5) UNSIGNED NOT NULL,
  `positions` int(10) UNSIGNED NOT NULL,
  `gliders` smallint(5) UNSIGNED NOT NULL,
  `crc` smallint(5) UNSIGNED NOT NULL,
  `ignoredpositions` smallint(5) UNSIGNED NOT NULL,
  `cpu` tinyint(3) UNSIGNED NOT NULL DEFAULT '0',
  `temp` tinyint(3) UNSIGNED DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `statssummary`
--

DROP TABLE IF EXISTS `statssummary`;
CREATE TABLE `statssummary` (
  `station` smallint(5) UNSIGNED NOT NULL,
  `time` datetime NOT NULL,
  `positions` int(10) UNSIGNED NOT NULL,
  `gliders` smallint(5) UNSIGNED NOT NULL,
  `crc` smallint(5) UNSIGNED NOT NULL,
  `ignoredpositions` smallint(5) UNSIGNED NOT NULL,
  `cpu` tinyint(3) UNSIGNED NOT NULL DEFAULT '0',
  `temp` tinyint(3) UNSIGNED DEFAULT '0'
) ENGINE=MEMORY DEFAULT CHARSET=latin1;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `availability`
--
ALTER TABLE `availability`
  ADD PRIMARY KEY (`station_id`);

--
-- Indexes for table `availability_log`
--
ALTER TABLE `availability_log`
  ADD KEY `a_s` (`station_id`,`time`);

--
-- Indexes for table `estimatedcoverage`
--
ALTER TABLE `estimatedcoverage`
  ADD UNIQUE KEY `posmgrs_uniq` (`station`,`ref`),
  ADD KEY `posmgrs_ref` (`ref`);

--
-- Indexes for table `gliders`
--
ALTER TABLE `gliders`
  ADD PRIMARY KEY (`glider_id`);

--
-- Indexes for table `positions_mgrs`
--
ALTER TABLE `positions_mgrs`
  ADD PRIMARY KEY (`ref`,`station`,`time`),
  ADD KEY `rt` (`ref`,`time`);

--
-- Indexes for table `roughcoverage`
--
ALTER TABLE `roughcoverage`
  ADD UNIQUE KEY `posmgrs_uniq` (`station`,`ref`),
  ADD KEY `posmgrs_ref` (`ref`);

--
-- Indexes for table `stationlocation`
--
ALTER TABLE `stationlocation`
  ADD UNIQUE KEY `s1` (`station`,`time`);

--
-- Indexes for table `stations`
--
ALTER TABLE `stations`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `station` (`station`),
  ADD KEY `sup` (`active`,`station`);

--
-- Indexes for table `stats`
--
ALTER TABLE `stats`
  ADD UNIQUE KEY `st` (`station`,`time`);

--
-- Indexes for table `statssummary`
--
ALTER TABLE `statssummary`
  ADD UNIQUE KEY `st` (`station`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `gliders`
--
ALTER TABLE `gliders`
  MODIFY `glider_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `stations`
--
ALTER TABLE `stations`
  MODIFY `id` smallint(6) NOT NULL AUTO_INCREMENT;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
