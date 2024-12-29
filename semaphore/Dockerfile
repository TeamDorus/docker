FROM semaphoreui/semaphore:latest

USER root
RUN apk add --no-cache python3 py3-pip sudo cifs-utils && \
    mkdir -p /mnt/HomeLab && \
    mkdir -p /tmp/semaphore/.ssh && chown semaphore:root /tmp/semaphore/.ssh && \
    mkdir -p /tmp/semaphore/.ansible && chown semaphore:root /tmp/semaphore/.ansible && \
    echo "semaphore ALL=(ALL:ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/semaphore && \
    pip install pywinrm jmespath netaddr passlib requests pytz matrix_client pynetbox

USER semaphore
