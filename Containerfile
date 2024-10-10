FROM registry.access.redhat.com/ubi8/ubi:latest
RUN dnf install nmap -y
CMD ["/usr/bin/sleep", "30"]
