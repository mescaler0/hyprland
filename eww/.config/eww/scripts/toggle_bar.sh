#!/bin/bash

BAR_TYPE=$1

case $BAR_TYPE in
volume)
  # Se già aperto, chiudi
  if eww active-windows | grep -q "*volume_bar"; then
    eww close volume_bar
    # Kill timer precedente se esiste
    [ -f /tmp/eww-volume-timer.pid ] && kill $(cat /tmp/eww-volume-timer.pid) 2>/dev/null
    exit 0
  fi

  # Apri volume bar
  eww open volume_bar

  # Auto-close dopo 5 secondi in background
  (
    sleep 5
    eww close volume_bar 2>/dev/null
  ) &

  # Salva PID del timer
  echo $! >/tmp/eww-volume-timer.pid
  ;;

mic)
  # Se già aperto, chiudi
  if eww active-windows | grep -q "*mic_bar"; then
    eww close mic_bar
    # Kill timer precedente se esiste
    [ -f /tmp/eww-mic-timer.pid ] && kill $(cat /tmp/eww-mic-timer.pid) 2>/dev/null
    exit 0
  fi

  # Apri mic bar
  eww open mic_bar

  # Auto-close dopo 5 secondi in background
  (
    sleep 5
    eww close mic_bar 2>/dev/null
  ) &

  # Salva PID del timer
  echo $! >/tmp/eww-mic-timer.pid
  ;;

calendar)
  if eww active-windows | grep -q "*calendar_bar"; then
    eww close calendar_bar
    [ -f /tmp/eww-calendar-timer.pid ] && kill $(cat /tmp/eww-calendar-timer.pid) 2>/dev/null
    exit 0
  fi

  eww open calendar_bar

  (
    sleep 10 # Calendario resta aperto 10 secondi
    eww close calendar_bar 2>/dev/null
  ) &

  echo $! >/tmp/eww-calendar-timer.pid
  ;;
esac
