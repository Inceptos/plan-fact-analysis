FROM postgres:latest

#ENV POSTGRES_USER=myuser
#ENV POSTGRES_PASSWORD=sohardpass
#ENV POSTGRES_DB=planfactDB

COPY init*.sql /docker-entrypoint-initdb.d/

EXPOSE 5432