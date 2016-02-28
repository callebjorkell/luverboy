-- MySQL dump 10.11
--
-- Host: localhost    Database: luvers
-- ------------------------------------------------------
-- Server version	5.0.45

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
-- Table structure for table `activematches`
--

DROP TABLE IF EXISTS `activematches`;
CREATE TABLE `activematches` (
  `server` varchar(50) NOT NULL,
  `opponent` varchar(20) default NULL,
  `ourscore` int(5) default '0',
  `oppscore` int(5) default '0',
  `map` varchar(50) NOT NULL default '',
  `lineup` text,
  PRIMARY KEY  (`server`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Table structure for table `badgames`
--

DROP TABLE IF EXISTS `badgames`;
CREATE TABLE `badgames` (
  `matchid` int(10) unsigned NOT NULL,
  `name` varchar(50) NOT NULL default '',
  `comment` text,
  `date` int(11) unsigned NOT NULL,
  PRIMARY KEY  (`matchid`,`name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Table structure for table `clans`
--

DROP TABLE IF EXISTS `clans`;
CREATE TABLE `clans` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `tag` text NOT NULL,
  `name` text NOT NULL,
  `url` text,
  `irc` text,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=467 DEFAULT CHARSET=utf8;

--
-- Table structure for table `countdowns`
--

DROP TABLE IF EXISTS `countdowns`;
CREATE TABLE `countdowns` (
  `owner` varchar(50) NOT NULL,
  `description` text,
  `date` int(11) NOT NULL,
  `addeddate` int(11) default NULL,
  PRIMARY KEY  (`owner`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Table structure for table `definitions`
--

DROP TABLE IF EXISTS `definitions`;
CREATE TABLE `definitions` (
  `keyphrase` varchar(100) NOT NULL,
  `definition` text NOT NULL,
  `date` int(11) NOT NULL,
  `author` text NOT NULL,
  PRIMARY KEY  (`keyphrase`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Table structure for table `goodgames`
--

DROP TABLE IF EXISTS `goodgames`;
CREATE TABLE `goodgames` (
  `matchid` int(10) unsigned NOT NULL,
  `name` varchar(50) NOT NULL default '',
  `comment` text,
  `date` int(11) unsigned NOT NULL,
  PRIMARY KEY  (`matchid`,`name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Table structure for table `irchosts`
--

DROP TABLE IF EXISTS `irchosts`;
CREATE TABLE `irchosts` (
  `memberid` int(10) unsigned NOT NULL,
  `host` varchar(100) NOT NULL,
  PRIMARY KEY  (`memberid`,`host`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Table structure for table `ircnicks`
--

DROP TABLE IF EXISTS `ircnicks`;
CREATE TABLE `ircnicks` (
  `memberid` int(10) unsigned NOT NULL default '0',
  `nick` varchar(50) NOT NULL,
  PRIMARY KEY  (`memberid`,`nick`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Table structure for table `maprating`
--

DROP TABLE IF EXISTS `maprating`;
CREATE TABLE `maprating` (
  `map` varchar(25) NOT NULL,
  `name` varchar(50) NOT NULL,
  `rating` int(2) NOT NULL default '0',
  PRIMARY KEY  (`map`,`name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Table structure for table `matchcomments`
--

DROP TABLE IF EXISTS `matchcomments`;
CREATE TABLE `matchcomments` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `matchid` int(10) unsigned NOT NULL default '0',
  `date` int(11) NOT NULL default '0',
  `name` text NOT NULL,
  `comment` text,
  `printed` int(1) NOT NULL default '1',
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=2013 DEFAULT CHARSET=utf8;

--
-- Table structure for table `matches`
--

DROP TABLE IF EXISTS `matches`;
CREATE TABLE `matches` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `opponent` varchar(15) NOT NULL default '',
  `date` int(11) NOT NULL default '0',
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=3114 DEFAULT CHARSET=utf8;

--
-- Table structure for table `matchfrags`
--

DROP TABLE IF EXISTS `matchfrags`;
CREATE TABLE `matchfrags` (
  `matchid` int(10) unsigned NOT NULL,
  `scoreid` int(10) NOT NULL default '-1',
  `name` varchar(40) NOT NULL,
  `frags` int(5) default NULL,
  PRIMARY KEY  (`matchid`,`scoreid`,`name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Table structure for table `matchopponents`
--

DROP TABLE IF EXISTS `matchopponents`;
CREATE TABLE `matchopponents` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `scoreid` int(10) unsigned NOT NULL,
  `frags` int(5) default NULL,
  `name` text,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=13057 DEFAULT CHARSET=utf8;

--
-- Table structure for table `memberalias`
--

DROP TABLE IF EXISTS `memberalias`;
CREATE TABLE `memberalias` (
  `memberid` int(10) unsigned NOT NULL,
  `name` varchar(50) NOT NULL,
  PRIMARY KEY  (`memberid`,`name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Table structure for table `memberquotes`
--

DROP TABLE IF EXISTS `memberquotes`;
CREATE TABLE `memberquotes` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `memberid` int(10) unsigned NOT NULL,
  `quote` text,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=200 DEFAULT CHARSET=utf8;

--
-- Table structure for table `members`
--

DROP TABLE IF EXISTS `members`;
CREATE TABLE `members` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `name` text NOT NULL,
  `place` text,
  `info` text,
  `favmap` text,
  `favweap` text,
  `favitem` text,
  `birthday` date NOT NULL default '0000-00-00',
  `password` text,
  `active` int(1) NOT NULL default '0',
  `status` int(1) NOT NULL default '0',
  `phone` text,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=63 DEFAULT CHARSET=utf8;

--
-- Table structure for table `news`
--

DROP TABLE IF EXISTS `news`;
CREATE TABLE `news` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `text` text,
  `date` int(11) NOT NULL default '0',
  `author` varchar(20) NOT NULL default '',
  `topic` text NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=86 DEFAULT CHARSET=utf8;

--
-- Table structure for table `scores`
--

DROP TABLE IF EXISTS `scores`;
CREATE TABLE `scores` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `matchid` int(10) unsigned NOT NULL default '0',
  `map` text,
  `ourscore` int(3) NOT NULL default '0',
  `oppscore` int(3) NOT NULL default '0',
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=6061 DEFAULT CHARSET=utf8;

--
-- Table structure for table `servers`
--

DROP TABLE IF EXISTS `servers`;
CREATE TABLE `servers` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `address` text NOT NULL,
  `type` int(1) default NULL,
  `available` int(1) default NULL,
  `downdate` int(11) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=117 DEFAULT CHARSET=utf8;

--
-- Table structure for table `tells`
--

DROP TABLE IF EXISTS `tells`;
CREATE TABLE `tells` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `tonick` text NOT NULL,
  `message` text NOT NULL,
  `fromnick` text NOT NULL,
  `delivered` int(1) default '0',
  `date` int(11) NOT NULL default '0',
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=167 DEFAULT CHARSET=utf8;

--
-- Table structure for table `votees`
--

DROP TABLE IF EXISTS `votees`;
CREATE TABLE `votees` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `memberid` int(10) unsigned NOT NULL,
  `voteid` int(10) unsigned NOT NULL,
  `denied` int(1) NOT NULL default '0',
  `comment` text NOT NULL,
  `vote` enum('Yes','No','Dunno') NOT NULL default 'Dunno',
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=996 DEFAULT CHARSET=utf8;

--
-- Table structure for table `votes`
--

DROP TABLE IF EXISTS `votes`;
CREATE TABLE `votes` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `date` int(11) NOT NULL default '0',
  `subject` text,
  `printed` int(1) NOT NULL default '0',
  `owner` text,
  `signup` int(1) NOT NULL default '0',
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=140 DEFAULT CHARSET=utf8;

/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2009-05-26 10:38:43
