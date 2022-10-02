#!/usr/bin/env bash
if [[ "$2" == "" ]]; then
    WORKDIR=$(mktemp -d)
else
    WORKDIR="$2"
    if [[ ! -d "$WORKDIR" ]]; then
	    mkdir -p "$WORKDIR"
    fi
fi
if [[ "$1" == "--build-iso" ]]; then
    cp chrooted-iso.sh chrooted.sh
    MKARCHISO_FLAGS="-v -w $WORKDIR -o . antergos"
    rm -fv *.iso
elif [[ "$1" == "--build-bootstrap" ]]; then
    cp chrooted-bootstrap.sh chrooted.sh
    MKARCHISO_FLAGS="-m bootstrap -v -w $WORKDIR -o . antergos"
    rm -fv *.tar.gz
else
   RESULTCODE=0
    if [[ "$1" == "" ]]; then
        echo "no option given, available options are:"
        RESULTCODE=1
    elif [[ "$1" != "--help" ]]; then
        echo "option '$1' not known, available options are:"
        RESULTCODE=1
    fi
    echo "--build-iso		builds a antergos linux iso"
    echo "--build-bootstrap	builds a antergos linux rootfs tarball"
    echo "--help			display this message"
    exit $RESULTCODE
fi
cp antergos/pacman.conf antergos/airootfs/etc/.

echo "Built on $(date +"%D @ %T EST")" > antergos/airootfs/etc/buildstamp

time sudo ./mkarchiso $MKARCHISO_FLAGS

sudo rm -rf $WORKDIR
if [[ "$1" == "--build-iso" ]]; then
    sudo chown $USER:$USER *.iso
else
    sudo chown $USER:$USER *.tar.gz
fi
