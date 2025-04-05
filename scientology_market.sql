-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Creato il: Feb 28, 2025 alle 22:04
-- Versione del server: 10.4.32-MariaDB
-- Versione PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `scientology_market`
--

-- --------------------------------------------------------

--
-- Struttura della tabella `persona`
--

CREATE TABLE `persona` (
  `id` int(11) NOT NULL,
  `nome` varchar(64) NOT NULL,
  `cognome` varchar(64) NOT NULL,
  `mail` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dump dei dati per la tabella `persona`
--

INSERT INTO `persona` (`id`, `nome`, `cognome`, `mail`) VALUES
(1, 'Mario', 'Rossi', 'mario.rossi@example.com'),
(2, 'Luigi', 'Verdi', 'luigi.verdi@example.com'),
(3, 'Giovanna', 'Bianchi', 'giovanna.bianchi@example.com'),
(4, 'Anna', 'Neri', 'anna.neri@example.com'),
(22, 'gino', 'pino', 'lallo@hma.c'),
(24, 'gigi', 'sos', 'ls@s.c');

-- --------------------------------------------------------

--
-- Struttura della tabella `sede`
--

CREATE TABLE `sede` (
  `id` int(11) NOT NULL,
  `nome` varchar(64) NOT NULL,
  `indirizzo` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dump dei dati per la tabella `sede`
--

INSERT INTO `sede` (`id`, `nome`, `indirizzo`) VALUES
(-1, 'sdcs', 'sdfvds'),
(1, 'Sede Centrale', 'Via Roma 123, Milano'),
(2, 'Sede Nord', 'Via Torino 45, Torino'),
(3, 'Sede Sud', 'Via Napoli 67, Napoli'),
(4, 'Sede Planck', 'via pani boh 32');

-- --------------------------------------------------------

--
-- Struttura della tabella `tessera`
--

CREATE TABLE `tessera` (
  `id` int(11) NOT NULL,
  `sede_creazione_id` int(11) NOT NULL,
  `punti` int(11) NOT NULL,
  `cliente_id` int(11) NOT NULL,
  `data_creazione` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dump dei dati per la tabella `tessera`
--

INSERT INTO `tessera` (`id`, `sede_creazione_id`, `punti`, `cliente_id`, `data_creazione`) VALUES
(1, 1, 100, 1, '2023-10-01 10:00:00'),
(2, 2, 50, 2, '2023-10-02 11:30:00'),
(3, 3, 200, 3, '2023-10-03 09:15:00'),
(4, 1, 75, 4, '2023-10-04 14:45:00'),
(5, 2, 120, 1, '2023-01-15 08:00:00'),
(6, 3, 80, 2, '2023-02-20 12:30:00'),
(7, 1, 150, 3, '2023-03-10 16:45:00'),
(8, 2, 90, 4, '2023-04-05 09:20:00'),
(9, 3, 200, 1, '2023-05-12 14:10:00'),
(10, 1, 60, 2, '2023-06-18 10:50:00'),
(11, 2, 110, 3, '2023-07-22 17:30:00'),
(12, 3, 70, 4, '2023-08-30 11:15:00'),
(13, 1, 180, 1, '2023-09-14 13:40:00'),
(14, 2, 95, 2, '2023-10-25 15:00:00'),
(15, 3, 130, 3, '2022-11-11 10:00:00'),
(16, 1, 85, 4, '2022-12-24 18:20:00'),
(17, 3, 0, 22, '2025-02-28 20:21:31'),
(19, 2, 0, 24, '2025-02-28 21:22:43'),
(20, 1, 0, 24, '2025-10-15 21:49:35');

--
-- Indici per le tabelle scaricate
--

--
-- Indici per le tabelle `persona`
--
ALTER TABLE `persona`
  ADD PRIMARY KEY (`id`);

--
-- Indici per le tabelle `sede`
--
ALTER TABLE `sede`
  ADD PRIMARY KEY (`id`);

--
-- Indici per le tabelle `tessera`
--
ALTER TABLE `tessera`
  ADD PRIMARY KEY (`id`),
  ADD KEY `sede_creazione` (`sede_creazione_id`),
  ADD KEY `cliente` (`cliente_id`);

--
-- AUTO_INCREMENT per le tabelle scaricate
--

--
-- AUTO_INCREMENT per la tabella `persona`
--
ALTER TABLE `persona`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=25;

--
-- AUTO_INCREMENT per la tabella `sede`
--
ALTER TABLE `sede`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT per la tabella `tessera`
--
ALTER TABLE `tessera`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- Limiti per le tabelle scaricate
--

--
-- Limiti per la tabella `tessera`
--
ALTER TABLE `tessera`
  ADD CONSTRAINT `tessera_ibfk_1` FOREIGN KEY (`sede_creazione_id`) REFERENCES `sede` (`id`),
  ADD CONSTRAINT `tessera_ibfk_2` FOREIGN KEY (`cliente_id`) REFERENCES `persona` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
