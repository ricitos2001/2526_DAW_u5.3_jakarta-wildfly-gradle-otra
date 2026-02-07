###############################################################################
# ETAPA 1: BUILD DEL WAR CON GRADLE
###############################################################################
FROM gradle:8.6-jdk17 AS builder

# Directorio de trabajo dentro del contenedor
WORKDIR /app

# Copiamos el proyecto completo
COPY . .

# Generamos el WAR usando el wrapper si existe
RUN gradle clean build

###############################################################################
# ETAPA 2: WILDFLY + DESPLIEGUE
###############################################################################
FROM quay.io/wildfly/wildfly:latest

# Variables de entorno para el usuario de administración
ENV WILDFLY_USER=wildfly
ENV WILDFLY_PASSWORD=wildfly

# Añadimos usuario de gestión (Management User)
RUN /opt/jboss/wildfly/bin/add-user.sh \
    -u ${WILDFLY_USER} \
    -p ${WILDFLY_PASSWORD} \
    -g '' \
    -s

# Copiamos el WAR generado a deployments
COPY --from=builder \
    /app/build/libs/app.war \
    /opt/jboss/wildfly/standalone/deployments/app.war

# Exponemos puertos
EXPOSE 8080 9990

# Arranque de WildFly con interfaces abiertas
CMD ["/opt/jboss/wildfly/bin/standalone.sh", \
     "-b", "0.0.0.0", \
     "-bmanagement", "0.0.0.0"]
