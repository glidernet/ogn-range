--
-- Table structure for table `gliders`
--

DROP TABLE IF EXISTS `gliders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gliders` (
  `glider_id` int(11) NOT NULL AUTO_INCREMENT,
  `callsign` char(32) NOT NULL,
  PRIMARY KEY (`glider_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

