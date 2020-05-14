function w10 --description "Backup w10"
    set -l arg "$argv[1]"
    if ! test -e $arg
        echo "Wrong file arg"
        return -1
    end
    if test -d $arg
        echo "Only file is acceptable"
        return -1
    end
    set -l filepath (readlink -f $arg)
    set -l directory (dirname $filepath)
    set -l user_agent "Mozilla/5.0 (X11; Linux x86_64; rv:75.0) Gecko/20100101 Firefox/75.0"

    set -l tempdir "$directory/temp"
    if ! test -d $tempdir
        echo "Creating $tempdir"
        mkdir $tempdir

        # ln -s $filepath $tempdir/w10
        # xz -vvzkf9eT0 $tempdir/w10
        # rm $tempdir/w10

        set -l filename (basename $filepath)
        echo "Splitting $filename"
        split $filepath $tempdir/w10_ --verbose -d -b 512MB

        set -l w10pass (pass w10 2>/dev/null)
        if [ $status -ne 0 ] || [ -z $w10pass ]
            echo "Password is mandatory"
            return -1
        end
        for part in $tempdir/*
            set -l partname (basename $part)
            echo "Encrypting $partname"
            gpg --passphrase $w10pass --batch --output $part.enc --symmetric --cipher-algo AES256 $part
            echo "Removing $partname"
            rm $part
        end
    end

    set -l token (pass yandex/disk/token)
    if [ $status -ne 0 ] || [ -z $token ]
            echo "Token is mandatory"
            return -1
        end
    set -l header "Authorization: OAuth $token"
    for filepath in $tempdir/*.enc
        set -l filename (basename $filepath)
        set -l url "https://cloud-api.yandex.net/v1/disk/resources?path=disk:/backup/images/w10/$filename"
        set -l resp (curl -L -A "user_agent" --stderr /dev/null -H "$header" "$url")
        if [ $status -ne 0 ]
            echo "Uploading $filename failed"
            continue
        end
        set -l local_hash (sha256sum $filepath | awk '{ print $1 }')
        set -l remote_hash (echo $resp | jq -r .sha256)
        if [ "$local_hash" = "$remote_hash" ]
            echo "Skip $filename"
            continue
        end

        set -l url "https://cloud-api.yandex.net/v1/disk/resources/upload?path=disk:/backup/images/w10/$filename&overwrite=true"
        set -l resp (curl -L -A "user_agent" --stderr /dev/null -H "$header" "$url")
        if [ $status -ne 0 ]
            echo "Uploading $filename failed"
            continue
        end
        set -l url (echo $resp | jq -r .href)
        set -l method (echo $resp | jq -r .method)
        if [ -z $url ] || [ -z $method ]
            echo "Unable to get uploading url for $filename"
            continue
        end
        echo "Need to upload $filename"
        # echo "Uploading $filename"
        # curl --verbose --trace-time -A "$user_agent" -X "$method" --compressed --compressed-ssh -H "$header" -T "$filepath" "$url"
    end
end
