FROM semaphoreui/semaphore:latest

USER root
RUN apk add --no-cache python3 py3-pip sudo cifs-utils && \
    mkdir -p /mnt/HomeLab && \
    echo "semaphore ALL=(ALL:ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/semaphore && \
    pip install pywinrm jmespath netaddr passlib requests pytz matrix_client pynetbox

USER semaphore
