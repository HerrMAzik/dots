function kdbx --description "Backup keepassxc database"
    set -l user_agent "Mozilla/5.0 (X11; Linux x86_64; rv:75.0) Gecko/20100101 Firefox/75.0"
    
    set -l token (pass yandex/disk/token)
    if [ $status -ne 0 ] || [ -z $token ]
            echo "Token is mandatory"
            return -1
        end
    set -l header "Authorization: OAuth $token"

    xz -vvzkfc9eT0 $HOME/repo/man.kdbx | gpg --batch --output /tmp/kdbx --passphrase (pass kdb) --symmetric --yes --cipher-algo AES256
    
    set -l url "https://cloud-api.yandex.net/v1/disk/resources/upload?path=disk:/backup/kdbx&overwrite=true"
    set -l resp (curl -L -A "user_agent" --stderr /dev/null -H "$header" "$url")
    if [ $status -ne 0 ]
        echo "Uploading kdbx failed"
        return -1
    end
    set -l url (echo $resp | jq -r .href)
    set -l method (echo $resp | jq -r .method)
    if [ -z $url ] || [ -z $method ]
        echo "Unable to get uploading url for kdbx"
        return -1
    end
    echo "Uploading kdbx to yandex"
    curl -A "$user_agent" -X "$method" --compressed --compressed-ssh -H "$header" -T '/tmp/kdbx' "$url"
    echo "Uploading kdbx to yandex completed"

    set -l passphrase (pass keybase)
    set -l account (echo 'jA0ECQMCmrPAwkScX2/r0kABlVaTprzFpn9cIrn+oXM8GL8Mmd39FUTjOvGwat1uKOpGQT3b+ySRZdHUErZ0xohFv3SM8ULTSCWKAri2uRU6' | base64 --decode | gpg --batch --decrypt --quiet --passphrase $passphrase)
    systemctl --user start kbfs.service keybase.service
    expect -c "spawn keybase login;expect \"Please enter the Keybase password*\";send \"$passphrase\r\";expect eof;"
    echo 'Logged in'
    echo "Uploading kdbx to keybase"
    keybase fs rm /keybase/public/$account/kdbx
    keybase fs cp /tmp/kdbx /keybase/public/$account/kdbx
    keybase logout
    echo 'Uploading kdbx to keybase completed'
end
