FROM ubuntu:14.04
MAINTAINER Andrea Grandi <a.grandi@gmail.com>
MAINTAINER Gonzalo Gasca Meza <gonzalo@parzee.com>

# Add the PostgreSQL PGP key to verify their Debian packages.
# It should be the same key as https://www.postgresql.org/media/keys/ACCC4CF8.asc
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8

# Add PostgreSQL's repository. It contains the most recent stable release
#     of PostgreSQL, ``9.3``.
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main" > /etc/apt/sources.list.d/pgdg.list

# Update the Ubuntu and PostgreSQL repository indexes and install ``python-software-properties``,
# ``software-properties-common`` and PostgreSQL 9.3
# There are some warnings (in red) that show up during the build. You can hide
# them by prefixing each apt-get statement with DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get -y -q install python-software-properties software-properties-common \
    && apt-get -y -q install postgresql-9.3 postgresql-client-9.3 postgresql-contrib-9.3

USER postgres

# Create imbuedb and user. Add options to add a database using UNICODE

RUN /etc/init.d/postgresql start \
	&& psql --command "UPDATE pg_database SET datistemplate = FALSE WHERE datname = 'template1';" \
	&& psql --command "DROP DATABASE template1;" \
	&& psql --command "CREATE DATABASE template1 WITH TEMPLATE = template0 ENCODING = 'UNICODE';" \
	&& psql --command "UPDATE pg_database SET datistemplate = TRUE WHERE datname = 'template1';" \
	&& psql --command "\c template1;" \
	&& psql --command "VACUUM FREEZE;" \	
    && psql --command "CREATE DATABASE imbuedb ENCODING 'UTF8';" \
    && psql --command "CREATE USER imbue WITH SUPERUSER PASSWORD 'imbue';ALTER ROLE imbue WITH LOGIN;ALTER DATABASE imbuedb OWNER TO imbue;" \
    && psql --command "CREATE USER pguser WITH SUPERUSER PASSWORD 'pguser';" \
    && createdb -O pguser pgdb 

USER root

# Adjust PostgreSQL configuration so that remote connections to the
# database are possible.
RUN echo "host all  all    0.0.0.0/0  md5" >> /etc/postgresql/9.3/main/pg_hba.conf

# And add ``listen_addresses`` to ``/etc/postgresql/9.3/main/postgresql.conf``
RUN echo "listen_addresses='*'" >> /etc/postgresql/9.3/main/postgresql.conf

# Expose the PostgreSQL port
EXPOSE 5432

RUN mkdir -p /var/run/postgresql && chown -R postgres /var/run/postgresql

# Add VOLUMEs to allow backup of config, logs and databases
VOLUME  ["/etc/postgresql", "/var/log/postgresql", "/var/lib/postgresql"]

USER postgres

# Set the default command to run when starting the container
CMD ["/usr/lib/postgresql/9.3/bin/postgres", "-D", "/var/lib/postgresql/9.3/main", "-c", "config_file=/etc/postgresql/9.3/main/postgresql.conf"]
