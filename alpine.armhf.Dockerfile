# Pull image to build java file with maven
#FROM balenalib/raspberry-pi-alpine-openjdk:8-jdk-latest AS java-builder
FROM openjdk:8-jdk-alpine AS java-builder

ENV LANG C.UTF-8

# Repository settings
ENV REPOSITORY https://github.com/Tob1as/TelefonWahnsinn.git

# build
RUN git clone ${REPOSITORY} /telefonwahnsinn/
#COPY .  /telefonwahnsinn
RUN cd /telefonwahnsinn \
	&& chmod +x mvnw \
	&& ./mvnw clean package

# Pull image to run the application
#FROM balenalib/raspberry-pi-openjdk:8-jre-latest
#FROM balenalib/raspberry-pi-alpine-openjdk:8-jre-latest
FROM arm32v7/openjdk:8-jre-alpine

LABEL maintainer="Tobias Hargesheimer <docker@ison.ws>"
LABEL description="TelefonWahnsinn (PhoneMadness): \
A Application written in JAVA monitors various sensors (Telephone -Innovaphone-, Fritz!Box, doorsensor) and \
switched accordingly the music (player: MPD, XBMC or VLC) to stop/pause or play."

ENV LANG C.UTF-8

# Copy application from build image
COPY --from=java-builder /telefonwahnsinn/target/TelefonWahnsinn-jar-with-dependencies.jar /TelefonWahnsinn.jar
COPY --from=java-builder /telefonwahnsinn/config/config.xml.example /config/config.xml

# Define Volumes
VOLUME ["/config","/sys/class/gpio"]

# Define default command
CMD ["java","-jar","/TelefonWahnsinn.jar"]
