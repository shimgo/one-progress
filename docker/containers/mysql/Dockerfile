FROM mysql:5.7.13

COPY ./localdb-run.sh /
RUN chmod 755 /localdb-run.sh

ENTRYPOINT ["/localdb-run.sh"] 

