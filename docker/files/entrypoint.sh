#!/bin/bash -e

USER_ID=${LOCAL_USER_ID:-501}
FULL_NAME=${FULL_NAME:-"Aptly Repo Signing"}
EMAIL_ADDRESS=${EMAIL_ADDRESS:-root@localhost}
export HOME=/var/lib/aptly

echo "Creating user aptly with UID $USER_ID"
useradd --shell /bin/bash -u $USER_ID -d ${HOME} -m aptly

if [ $(stat -c '%u' ${HOME}) != $USER_ID ]; then
    echo "Fixing ${HOME} permissions.."
    chown -R aptly:aptly ${HOME}
fi

if [ ! -e ${HOME}/.gnupg/secret.gpg ]; then
    echo "Generating new GPG keypair.."
    [ -e ${HOME}/gpg_batch ] || cat << EOF > ${HOME}/gpg_batch
%echo Generating a GPG key, might take a while
Key-Type: RSA
Key-Length: 4096
Subkey-Type: ELG-E
Subkey-Length: 1024
Name-Real: ${FULL_NAME}
Name-Comment: Aptly Repo Signing
Name-Email: ${EMAIL_ADDRESS}
Expire-Date: 0
%no-protection
%pubring ${HOME}/.gnupg/pubring.gpg
%secring ${HOME}/.gnupg/secring.gpg
%commit
%echo done
EOF
    gosu aptly bash -c "gpg --batch --gen-key ${HOME}/gpg_batch"

    echo "Importing distribution keyring.."
    gosu aptly bash -c 'for i in /usr/share/keyrings/*; do gpg --no-default-keyring --keyring $i --export | gpg --import; done'
fi

exec gosu aptly "$@"
