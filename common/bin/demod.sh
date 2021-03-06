#!/bin/sh

# Paths
DEVICE_ID_DB="%PREFIX%/share/outernet/sdrids.txt"
STARSDR_PATH="%PREFIX%/sdr.d"

fail() {
  msg="$*"
  echo "ERROR: demod: $msg"
  exit 1
}

radio_devices() {
  lsusb | cut -d " " -f 6 | tr A-F a-f | while read -r dev_id; do
    grep "$dev_id" "$DEVICE_ID_DB" | cut -d ";" -f 2
  done
}

get_radio() {
  radios="$(radio_devices)"
  nradios=$(echo "$RADIOS" | wc -c)
  [ "$nradios" = 1 ] && echo "$radios"
}

rtlsdr_demod() {
  rtl_biast -b 1
  sdr100 -o /tmp/ondd.data "$@"
}

mirics_demod() {
  sdr100 -o /tmp/ondd.data "$@"
}

radio="$(get_radio)"

# Sanity checks
[ -d "$STARSDR_PATH" ] || fail "StarSDR is not installed"
[ -z "$radio" ] && fail "No usable radio detected"

export LD_LIBRARY_PATH="$STARSDR_PATH/starsdr-$radio"

"${radio}_demod" "$@"
