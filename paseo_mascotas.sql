-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 10-10-2025 a las 22:47:49
-- Versión del servidor: 10.4.32-MariaDB
-- Versión de PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `paseo_mascotas`
--

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `administradores`
--

CREATE TABLE `administradores` (
  `id` int(11) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `contraseña` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `calificaciones`
--

CREATE TABLE `calificaciones` (
  `id` int(11) NOT NULL,
  `usuario_id` int(11) NOT NULL,
  `paseador_id` int(11) NOT NULL,
  `paseo_id` int(11) NOT NULL,
  `puntuacion` int(11) DEFAULT NULL CHECK (`puntuacion` between 1 and 5),
  `comentario` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `historialpaseos`
--

CREATE TABLE `historialpaseos` (
  `id` int(11) NOT NULL,
  `paseo_id` int(11) NOT NULL,
  `detalles` text DEFAULT NULL,
  `distancia` float DEFAULT NULL,
  `duracion` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `mascotas`
--

CREATE TABLE `mascotas` (
  `id` int(11) NOT NULL,
  `usuario_id` int(11) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `especie` varchar(50) NOT NULL,
  `raza` varchar(50) DEFAULT NULL,
  `edad` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `mascotas`
--

INSERT INTO `mascotas` (`id`, `usuario_id`, `nombre`, `especie`, `raza`, `edad`) VALUES
(1, 1, 'martina', 'perro', 'chiguagua', 6),
(2, 6, 'toby', 'perro', 'pitbull', 12);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `mensajes`
--

CREATE TABLE `mensajes` (
  `id` int(11) NOT NULL,
  `emisor_id` int(11) NOT NULL,
  `receptor_id` int(11) NOT NULL,
  `contenido` text NOT NULL,
  `enviado_en` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `notificaciones`
--

CREATE TABLE `notificaciones` (
  `id` int(11) NOT NULL,
  `usuario_id` int(11) NOT NULL,
  `mensaje` text NOT NULL,
  `leida` tinyint(1) DEFAULT 0,
  `enviada_en` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `pagos`
--

CREATE TABLE `pagos` (
  `id` int(11) NOT NULL,
  `usuario_id` int(11) NOT NULL,
  `paseador_id` int(11) NOT NULL,
  `paseo_id` int(11) NOT NULL,
  `monto` decimal(10,2) NOT NULL,
  `metodo` varchar(50) NOT NULL,
  `fecha` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `paseadores`
--

CREATE TABLE `paseadores` (
  `id` int(11) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `contraseña` varchar(100) NOT NULL,
  `telefono` varchar(20) DEFAULT NULL,
  `direccion` varchar(150) DEFAULT NULL,
  `experiencia` text DEFAULT NULL,
  `disponibilidad` text DEFAULT NULL,
  `calificacion_promedio` float DEFAULT 0,
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `paseadores`
--

INSERT INTO `paseadores` (`id`, `nombre`, `email`, `contraseña`, `telefono`, `direccion`, `experiencia`, `disponibilidad`, `calificacion_promedio`, `created_at`) VALUES
(1, 'sandro', 'mesa@gmail.com', '123456', '3118575066', 'calle693', '2', 'tarde', 0, '2025-09-05 15:43:25'),
(2, 'messi', 'messi@gmail.com', '$2y$10$q9zrcto8attFrgCIDSRJIO5EIwKgUeLz8.lw9cv1zXwqlu0Zd/yUm', '31139492765', 'calle87A', '1', 'completa', 0, '2025-09-05 15:44:20'),
(3, 'andres', 'andre@gmail.com', '$2y$10$4TwbwzhS/oviE3Tm.0Cm.ecr1w7o6Z65HsNlLl1tw4tWQt1up8G/e', '31183492734', 'calle55', '3', 'mañana', 0, '2025-10-02 23:08:21'),
(4, 'maikol', 'maikol@gmail.com', '$2y$10$DGX5OW1l0deI8YJAAdpJ6enN7Boo3yWKtG7DRWqtpIk.6Vqyoayg.', '34486547566', 'calle5555', '2', 'lunes a vierenes', 0, '2025-10-10 14:39:08');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `paseos`
--

CREATE TABLE `paseos` (
  `id` int(11) NOT NULL,
  `solicitud_id` int(11) NOT NULL,
  `inicio` datetime DEFAULT NULL,
  `fin` datetime DEFAULT NULL,
  `ruta` text DEFAULT NULL,
  `estado` varchar(20) DEFAULT 'pendiente'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `paseos`
--

INSERT INTO `paseos` (`id`, `solicitud_id`, `inicio`, `fin`, `ruta`, `estado`) VALUES
(1, 2, '2025-10-02 23:08:53', NULL, NULL, 'activo'),
(2, 50, '2025-10-10 15:44:13', NULL, NULL, 'activo');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `perfilesmascota`
--

CREATE TABLE `perfilesmascota` (
  `id` int(11) NOT NULL,
  `mascota_id` int(11) NOT NULL,
  `vacunas` text DEFAULT NULL,
  `condiciones` text DEFAULT NULL,
  `preferencias` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `solicitudespaseo`
--

CREATE TABLE `solicitudespaseo` (
  `id` int(11) NOT NULL,
  `usuario_id` int(11) NOT NULL,
  `paseador_id` int(11) NOT NULL,
  `mascota_id` int(11) NOT NULL,
  `fecha` datetime NOT NULL,
  `estado` varchar(20) DEFAULT 'pendiente'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `solicitudespaseo`
--

INSERT INTO `solicitudespaseo` (`id`, `usuario_id`, `paseador_id`, `mascota_id`, `fecha`, `estado`) VALUES
(1, 1, 1, 1, '2025-10-04 11:03:00', 'pendiente'),
(2, 3, 3, 1, '2025-10-04 11:08:00', 'aceptada'),
(50, 6, 4, 2, '2025-10-11 09:40:00', 'aceptada');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuarios`
--

CREATE TABLE `usuarios` (
  `id` int(11) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `contraseña` varchar(100) NOT NULL,
  `telefono` varchar(20) DEFAULT NULL,
  `direccion` varchar(150) DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `usuarios`
--

INSERT INTO `usuarios` (`id`, `nombre`, `email`, `contraseña`, `telefono`, `direccion`, `created_at`) VALUES
(1, 'jose luis valencia', 'joluvalencia1803@gmail.com', '$2y$10$U1K7GiYTz/y/617b91lS6eGCmp9rQDfGKNaiAQfX29O2ugoFvFv/2', '3117213811', 'calle45', '2025-08-28 22:10:29'),
(2, 'yeison', 'js@gmail.com', '$2y$10$h7Z5gmXlUS26Ov2xWQ6cx.5ZsX/Xea/wgiDdLdjtVpvMoMFE/ib06', '311235356345', 'calle44', '2025-09-05 15:29:56'),
(3, 'campo', 'campo12@gmail.com', '$2y$10$y7epHuY9N4V2/kvTGpIfn.zs30T82T8DszX1G3aKZKsVSBpy0/35W', '3118376493834', 'calle44', '2025-09-05 15:30:39'),
(5, 'pedro pascal', 'pascal@gmail.com', '$2y$10$eAmMkXSJr7q/rwwyuix.SeUXciEcV5jO3J.SI4tJ./yf4jxssc35G', '3118214355', 'calle45', '2025-10-10 14:35:06'),
(6, 'melisa', 'meli123@gmail.com', '$2y$10$BX7cmBP.D4cAKMzpVA3dIO3JQ4FlXtZiJWqFF0Knp9qQlSS9YHhSe', '3118554923', 'calle606', '2025-10-10 14:58:49');

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `administradores`
--
ALTER TABLE `administradores`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indices de la tabla `calificaciones`
--
ALTER TABLE `calificaciones`
  ADD PRIMARY KEY (`id`),
  ADD KEY `usuario_id` (`usuario_id`),
  ADD KEY `paseador_id` (`paseador_id`),
  ADD KEY `paseo_id` (`paseo_id`);

--
-- Indices de la tabla `historialpaseos`
--
ALTER TABLE `historialpaseos`
  ADD PRIMARY KEY (`id`),
  ADD KEY `paseo_id` (`paseo_id`);

--
-- Indices de la tabla `mascotas`
--
ALTER TABLE `mascotas`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_mascotas_usuario` (`usuario_id`);

--
-- Indices de la tabla `mensajes`
--
ALTER TABLE `mensajes`
  ADD PRIMARY KEY (`id`),
  ADD KEY `emisor_id` (`emisor_id`),
  ADD KEY `receptor_id` (`receptor_id`),
  ADD KEY `idx_mensajes_fecha` (`enviado_en`);

--
-- Indices de la tabla `notificaciones`
--
ALTER TABLE `notificaciones`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_notificaciones_usuario` (`usuario_id`,`leida`);

--
-- Indices de la tabla `pagos`
--
ALTER TABLE `pagos`
  ADD PRIMARY KEY (`id`),
  ADD KEY `usuario_id` (`usuario_id`),
  ADD KEY `paseador_id` (`paseador_id`),
  ADD KEY `paseo_id` (`paseo_id`);

--
-- Indices de la tabla `paseadores`
--
ALTER TABLE `paseadores`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indices de la tabla `paseos`
--
ALTER TABLE `paseos`
  ADD PRIMARY KEY (`id`),
  ADD KEY `solicitud_id` (`solicitud_id`),
  ADD KEY `idx_paseos_estado` (`estado`);

--
-- Indices de la tabla `perfilesmascota`
--
ALTER TABLE `perfilesmascota`
  ADD PRIMARY KEY (`id`),
  ADD KEY `mascota_id` (`mascota_id`);

--
-- Indices de la tabla `solicitudespaseo`
--
ALTER TABLE `solicitudespaseo`
  ADD PRIMARY KEY (`id`),
  ADD KEY `usuario_id` (`usuario_id`),
  ADD KEY `paseador_id` (`paseador_id`),
  ADD KEY `mascota_id` (`mascota_id`),
  ADD KEY `idx_solicitudes_fecha` (`fecha`),
  ADD KEY `idx_solicitudes_estado` (`estado`);

--
-- Indices de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `idx_usuarios_email` (`email`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `administradores`
--
ALTER TABLE `administradores`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `calificaciones`
--
ALTER TABLE `calificaciones`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `historialpaseos`
--
ALTER TABLE `historialpaseos`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `mascotas`
--
ALTER TABLE `mascotas`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `mensajes`
--
ALTER TABLE `mensajes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `notificaciones`
--
ALTER TABLE `notificaciones`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `pagos`
--
ALTER TABLE `pagos`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `paseadores`
--
ALTER TABLE `paseadores`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `paseos`
--
ALTER TABLE `paseos`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `perfilesmascota`
--
ALTER TABLE `perfilesmascota`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `solicitudespaseo`
--
ALTER TABLE `solicitudespaseo`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=51;

--
-- AUTO_INCREMENT de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `calificaciones`
--
ALTER TABLE `calificaciones`
  ADD CONSTRAINT `calificaciones_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`),
  ADD CONSTRAINT `calificaciones_ibfk_2` FOREIGN KEY (`paseador_id`) REFERENCES `paseadores` (`id`),
  ADD CONSTRAINT `calificaciones_ibfk_3` FOREIGN KEY (`paseo_id`) REFERENCES `paseos` (`id`);

--
-- Filtros para la tabla `historialpaseos`
--
ALTER TABLE `historialpaseos`
  ADD CONSTRAINT `historialpaseos_ibfk_1` FOREIGN KEY (`paseo_id`) REFERENCES `paseos` (`id`) ON DELETE CASCADE;

--
-- Filtros para la tabla `mascotas`
--
ALTER TABLE `mascotas`
  ADD CONSTRAINT `mascotas_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE;

--
-- Filtros para la tabla `mensajes`
--
ALTER TABLE `mensajes`
  ADD CONSTRAINT `mensajes_ibfk_1` FOREIGN KEY (`emisor_id`) REFERENCES `usuarios` (`id`),
  ADD CONSTRAINT `mensajes_ibfk_2` FOREIGN KEY (`receptor_id`) REFERENCES `usuarios` (`id`);

--
-- Filtros para la tabla `notificaciones`
--
ALTER TABLE `notificaciones`
  ADD CONSTRAINT `notificaciones_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE;

--
-- Filtros para la tabla `pagos`
--
ALTER TABLE `pagos`
  ADD CONSTRAINT `pagos_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`),
  ADD CONSTRAINT `pagos_ibfk_2` FOREIGN KEY (`paseador_id`) REFERENCES `paseadores` (`id`),
  ADD CONSTRAINT `pagos_ibfk_3` FOREIGN KEY (`paseo_id`) REFERENCES `paseos` (`id`);

--
-- Filtros para la tabla `paseos`
--
ALTER TABLE `paseos`
  ADD CONSTRAINT `paseos_ibfk_1` FOREIGN KEY (`solicitud_id`) REFERENCES `solicitudespaseo` (`id`) ON DELETE CASCADE;

--
-- Filtros para la tabla `perfilesmascota`
--
ALTER TABLE `perfilesmascota`
  ADD CONSTRAINT `perfilesmascota_ibfk_1` FOREIGN KEY (`mascota_id`) REFERENCES `mascotas` (`id`) ON DELETE CASCADE;

--
-- Filtros para la tabla `solicitudespaseo`
--
ALTER TABLE `solicitudespaseo`
  ADD CONSTRAINT `solicitudespaseo_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`),
  ADD CONSTRAINT `solicitudespaseo_ibfk_2` FOREIGN KEY (`paseador_id`) REFERENCES `paseadores` (`id`),
  ADD CONSTRAINT `solicitudespaseo_ibfk_3` FOREIGN KEY (`mascota_id`) REFERENCES `mascotas` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
