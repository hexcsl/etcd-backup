#!/bin/sh

#
# Defaults setup
#
S3CMD=/usr/bin/s3cmd
S3FCG=/opt/.s3cfg
DATE=`/bin/date '+%Y-%m-%d'`
DATE_FULL=`/bin/date '+%Y-%m-%d_%H-%M-%S_%s'`

if [ -z "${BUCKET}" ]; then
    BUCKET=etcd-backup/ocp
    echo "Set bucket to default value: $BUCKET"
fi

if [ -z "${ETCD_BACKUP_MASTER_PATH}" ]; then
    ETCD_BACKUP_MASTER_PATH=/home/core/assets/backup
    echo "Set backup destination to default value: $ETCD_BACKUP_MASTER_PATH"
fi

if [ -z "${ETCD_BACKUP_MASTER_PATH_S3}" ]; then
    ETCD_BACKUP_MASTER_PATH_S3=/home/core/assets/s3
    echo "Set backup destination for S3 to default value: $ETCD_BACKUP_MASTER_PATH_S3"
fi


if [ -z "${SYNC_COMMAND}" ]; then
    SYNC_COMMAND="${S3CMD} --config=${S3FCG} sync ${HOST_PATH}/${ETCD_BACKUP_MASTER_PATH_S3}/* s3://${BUCKET}/${DATE}/"
    echo "Set sync command to default value: $SYNC_COMMAND"
fi

# Prune backup files
rm -f ${HOST_PATH}/${ETCD_BACKUP_MASTER_PATH}/*.db ${HOST_PATH}/${ETCD_BACKUP_MASTER_PATH}/*.tar.gz ${HOST_PATH}/${ETCD_BACKUP_MASTER_PATH_S3}/*.tar.gz

# Make etcd backup
chroot ${HOST_PATH} ${ETCD_BACKUP_SCRIPT} ${ETCD_BACKUP_MASTER_PATH} 

# Arhive backup
TAR_COMMAND="chroot ${HOST_PATH} tar -zcvf ${ETCD_BACKUP_MASTER_PATH_S3}/${DATE_FULL}.tar.gz ${ETCD_BACKUP_MASTER_PATH}"
chroot ${HOST_PATH} mkdir -p ${ETCD_BACKUP_MASTER_PATH_S3}
echo "Create archive for S3 with command: ${TAR_COMMAND}"
${TAR_COMMAND}

# Copy backup files (etcd and static pods) to S3 storage and prune backup files
echo "Syncing backup files with command: ${SYNC_COMMAND}"
${SYNC_COMMAND}
