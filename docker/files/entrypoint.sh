#!/bin/bash -e

USER_ID=${LOCAL_USER_ID:-501}
GROUP_ID=${LOCAL_GROUP_ID:-501}
FULL_NAME=${FULL_NAME:-"Aptly Repo Signing"}
EMAIL_ADDRESS=${EMAIL_ADDRESS:-root@localhost}
GPG_KEY_LENGTH=${GPG_KEY_LENGTH:-4096}
GPG_BINARY=${GPG_BINARY:-gpg1}
export HOME=/var/lib/aptly

echo "Creating user aptly with UID $USER_ID"
getent group aptly >/dev/null || groupadd --system -g $GROUP_ID aptly
getent passwd aptly >/dev/null || useradd --system --shell /bin/bash -u $USER_ID -g aptly -d ${HOME} -m aptly

if [ $(stat -c '%u' ${HOME}) != $USER_ID ]; then
    echo "Fixing ${HOME} permissions.."
    chown -R aptly:aptly ${HOME}
fi

if [ ! -e ${HOME}/.gnupg ]; then
    echo "Generating new GPG keypair.."
    [ -e ${HOME}/gpg_batch ] || cat << EOF > ${HOME}/gpg_batch
%echo Generating a default key
Key-Type: RSA
Key-Length: ${GPG_KEY_LENGTH}
Subkey-Type: ELG-E
Subkey-Length: 1024
Name-Real: ${FULL_NAME}
Name-Comment: Aptly repository signing key
Name-Email: ${EMAIL_ADDRESS}
Expire-Date: 0
%no-protection
%commit
%echo done
EOF
    gosu aptly bash -c "$GPG_BINARY --batch --gen-key ${HOME}/gpg_batch"

    echo "Importing distribution keyring.."
    gosu aptly bash -c "for i in /usr/share/keyrings/*; do $GPG_BINARY --no-default-keyring --keyring \$i --export | $GPG_BINARY --import; done"

    echo "Storing public key in ${HOME}/public/public.gpg"
    [ -d ${HOME}/public ] || gosu aptly bash -c "mkdir ${HOME}/public"
    if [ $(stat -c '%u' ${HOME}/public) != $USER_ID ]; then
        echo "Fixing ${HOME}/public permissions.."
        chown -R aptly:aptly ${HOME}/public
    fi
    [ -e ${HOME}/public/public.gpg ] || gosu aptly bash -c "$GPG_BINARY --armor --export ${EMAIL_ADDRESS} > ${HOME}/public/public.gpg"
fi

exec gosu aptly "$@"
