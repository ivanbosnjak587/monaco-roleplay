-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Apr 07, 2024 at 02:55 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `monaco`
--

-- --------------------------------------------------------

--
-- Table structure for table `players`
--

CREATE TABLE `players` (
  `id` int(11) NOT NULL,
  `username` varchar(24) NOT NULL,
  `registered` int(11) NOT NULL DEFAULT 0,
  `password` char(64) NOT NULL,
  `email` varchar(50) DEFAULT NULL,
  `admin` int(11) NOT NULL DEFAULT 0,
  `skin` int(11) NOT NULL DEFAULT 0,
  `chargender` int(11) NOT NULL DEFAULT 0,
  `fightstyle` int(11) NOT NULL DEFAULT 4,
  `money` int(20) NOT NULL DEFAULT 0,
  `bankmoney` int(20) NOT NULL DEFAULT 0,
  `kills` mediumint(8) NOT NULL DEFAULT 0,
  `deaths` mediumint(8) NOT NULL DEFAULT 0,
  `x` float NOT NULL DEFAULT 0,
  `y` float NOT NULL DEFAULT 0,
  `z` float NOT NULL DEFAULT 0,
  `angle` float NOT NULL DEFAULT 0,
  `interior` tinyint(3) NOT NULL DEFAULT 0,
  `virtualworld` int(11) NOT NULL DEFAULT 0
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `players`
--

INSERT INTO `players` (`id`, `username`, `registered`, `password`, `email`, `admin`, `skin`, `chargender`, `fightstyle`, `money`, `bankmoney`, `kills`, `deaths`, `x`, `y`, `z`, `angle`, `interior`, `virtualworld`) VALUES
(5, 'Ivan_Destigo', 1, '$2y$12$EFFp60RWs6l/3MOKdimoxestl8FjSFlCTvHLrEdCrABYLDUHrrHM2', 'ivandestigo@gmail.com', 0, 20, 4, 4, 0, 0, 0, 0, 1545.76, -2310.59, 13.555, 356.715, 0, 0);

-- --------------------------------------------------------

--
-- Table structure for table `vehicles`
--

CREATE TABLE `vehicles` (
  `id` int(11) NOT NULL,
  `model` int(11) NOT NULL DEFAULT 0,
  `positionX` float NOT NULL DEFAULT 0,
  `positionY` float NOT NULL DEFAULT 0,
  `positionZ` float DEFAULT 0,
  `positionA` float NOT NULL DEFAULT 0,
  `color1` int(11) NOT NULL DEFAULT 0,
  `color2` int(11) NOT NULL DEFAULT 0,
  `veh_usage` int(11) NOT NULL DEFAULT 0,
  `veh_owner_id` int(11) NOT NULL DEFAULT 0,
  `veh_owner` varchar(30) NOT NULL DEFAULT '"Drzava"'
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `players`
--
ALTER TABLE `players`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`);

--
-- Indexes for table `vehicles`
--
ALTER TABLE `vehicles`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `players`
--
ALTER TABLE `players`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `vehicles`
--
ALTER TABLE `vehicles`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
