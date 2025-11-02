# Usa una imagen base de PHP con Apache
FROM php:8.2-apache

# Copia todos los archivos del proyecto al contenedor
COPY . /var/www/html/

# Instala extensiones necesarias para MySQL
RUN docker-php-ext-install mysqli pdo pdo_mysql

# Expone el puerto 80
EXPOSE 80

# Inicia Apache
CMD ["apache2-foreground"]