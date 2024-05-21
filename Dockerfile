# Base image: ubuntu:22.04
FROM ubuntu:22.04

# ARGs
# https://docs.docker.com/engine/reference/builder/#understand-how-arg-and-from-interact
ARG TARGETPLATFORM=linux/amd64,linux/arm64
ARG DEBIAN_FRONTEND=noninteractive

# neo4j 5.5.0 installation and some cleanup
RUN apt-get update && \
    apt-get install -y wget gnupg software-properties-common && \
    wget -O - https://debian.neo4j.com/neotechnology.gpg.key | apt-key add - && \
    echo 'deb https://debian.neo4j.com stable latest' > /etc/apt/sources.list.d/neo4j.list && \
    add-apt-repository universe && \
    apt-get update && \
    apt-get install -y nano unzip neo4j=1:5.5.0 python3-pip && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#create cse511 directory 

WORKDIR cse511

#Downloading the data
RUN wget -v -O /cse511/yellow_tripdata_2022-03.parquet https://d37ci6vzurychx.cloudfront.net/trip-data/yellow_tripdata_2022-03.parquet

#Downloading data_loader.py

RUN apt-get update && apt-get install -y git
RUN sh -c 'git clone https://maitry-trivedi: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@github.com/CSE511-SPRING-2023/mtrived4-project-2.git'
RUN mv mtrived4-project-2/data_loader.py /cse511

#Installing python libs
RUN pip install pandas && pip install pyarrow
RUN pip install --upgrade pip
RUN pip install neo4j
RUN neo4j-admin dbms set-initial-password project2phase1
RUN echo 'server.default_listen_address=0.0.0.0' >> /etc/neo4j/neo4j.conf
#RUN nano /etc/neo4j/neo4j.conf

RUN wget https://graphdatascience.ninja/neo4j-graph-data-science-2.3.1.zip
RUN apt-get update && apt-get install unzip
RUN unzip neo4j-graph-data-science-2.3.1.zip
RUN mv neo4j-graph-data-science-2.3.1.jar /var/lib/neo4j/plugins/
RUN echo 'dbms.security.procedures.unrestricted=gds.*' >> /etc/neo4j/neo4j.conf
RUN pip install requests
#RUN sh -c 'cd cse511/'
# Run the data loader script
RUN chmod +x /cse511/data_loader.py && \
    neo4j start && \
    python3 data_loader.py && \
    neo4j stop


	
# Expose neo4j ports
EXPOSE 7474 7687

# Start neo4j service and show the logs on container run
CMD ["/bin/bash", "-c", "neo4j start && tail -f /dev/null"]